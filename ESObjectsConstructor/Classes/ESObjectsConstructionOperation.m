//
//  ESObjectsConstructionOperation.m
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import "ESObjectsConstructionOperation.h"
#import "ESObjectsConstructor.h"

#import "ESObjectMapping.h"
#import "ESObjectPropertyMapping.h"
#import "ESObjectsConstructorConfig.h"

#import "ESObjectProperty.h"

#import "ESObjectValueTransformerProtocol.h"

@implementation ESObjectsConstructionOperation
{
    id _data;
    ESObjectsConstructorConfig *_config;
    
    id<ESObjectValueTransformerProtocol> _defaultValueTransformer;
    
    NSMutableArray *_errors;
    NSMutableArray *_breadcrumbs;
}

- (instancetype)init {
    return [self initWithData:nil config:nil defaultValueTransformer:nil];
}

- (instancetype)initWithData:(id)data config:(ESObjectsConstructorConfig *)config defaultValueTransformer:(id<ESObjectValueTransformerProtocol>)defaultValueTransformer {
    NSParameterAssert(config);
    NSParameterAssert(defaultValueTransformer);
    
    self = [super init];
    if (self) {
        _data = data;
        _config = config;
        _defaultValueTransformer = defaultValueTransformer;
        _breadcrumbs = [[NSMutableArray alloc] initWithObjects:@"", nil];
        _errors = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)execute {
    _resultData = [self mapData:_data withConfig:_config];
}

- (id)mapData:(id)data withConfig:(ESObjectsConstructorConfig *)config {
    NSParameterAssert(config);
    
    id result = nil;
    switch (config.type) {
        case ESObjectsConstructorConfigObject:
            result = [self constructObjectFromObject:data
                                         withMapping:config.objectMapping];
            break;
            
        case ESObjectsConstructorConfigCollection:
            result = [self constructObjectsFromArray:data
                                          withConfig:config.config];
            break;
            
        default:
            [self addErrorWithCode:ESObjectsConstructorInvalidData
                       description:[NSString stringWithFormat:@"invalid config type: %lu", config.type]];
            break;
    }
    
    return result;
}

- (NSArray *)constructObjectsFromArray:(NSArray *)objects withConfig:(ESObjectsConstructorConfig *)config {
    NSParameterAssert(config);
    
    if (![objects isKindOfClass:[NSArray class]]) {
        [self addErrorWithCode:ESObjectsConstructorInvalidData
                   description:[NSString stringWithFormat:@"expected array, but got %@", [objects class]]];
        return nil;
    }
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    [objects enumerateObjectsUsingBlock:^(id objectData, NSUInteger idx, BOOL *stop) {
        [_breadcrumbs addObject:[NSString stringWithFormat:@"%lu", (unsigned long)idx]];
        id object = [self mapData:objectData withConfig:config];
        
        if (object) {
            [results addObject:object];
        }
        [_breadcrumbs removeLastObject];
    }];
    
    return results;
}

- (id)constructObjectFromObject:(NSDictionary *)sourceObject
                    withMapping:(ESObjectMapping *)objectMapping {
    NSParameterAssert(objectMapping);
    
    if (![objectMapping canMapObjectOfClass:[sourceObject class]]) {
        [self addErrorWithCode:ESObjectsConstructorInvalidData
                   description:[NSString stringWithFormat:@"can't map source object with class %@", [sourceObject class]]];
        return nil;
    }
    
    __block id resultObject = [objectMapping newResultObject];
    if (!resultObject) {
        [self addErrorWithCode:ESObjectsConstructorNilModel
                   description:@"couldn't create result object"];
        return nil;
    }
    
    [objectMapping enumerateMappingsWithBlock:^(ESObjectPropertyMapping *propertyMapping, ESObjectProperty *property, BOOL *stop) {
        [_breadcrumbs addObject:propertyMapping.sourceKeyPath];
        
        if (!property || property.type == ESObjectPropertyTypeUnknown) {
            [self addErrorWithCode:ESObjectsConstructorUnknownProperty
                       description:[NSString stringWithFormat:@"unknown property: %@", propertyMapping.destinationKeyPath]];
            [_breadcrumbs removeLastObject];
            
            resultObject = nil;
            *stop = YES;
            return;
        }
        
        id value = [sourceObject valueForKeyPath:propertyMapping.sourceKeyPath];
        if (!value) {
            if (propertyMapping.optional) {
                return;
            }
            
            [self addErrorWithCode:ESObjectsConstructorMissingValue
                       description:@"missing value"];
            [_breadcrumbs removeLastObject];
            
            resultObject = nil;
            *stop = YES;
            return;
        }
        
        if (propertyMapping.destinationConfig) {
            value = [self mapData:value
                       withConfig:propertyMapping.destinationConfig];
        }
        
        NSError *error = nil;
        value = [self transformedValue:value forProperty:property withMapping:propertyMapping error:&error];
        if (error) {
            [self addErrorWithCode:ESObjectsConstructorInvalidData
                       description:error.localizedDescription];
            [_breadcrumbs removeLastObject];
            
            resultObject = nil;
            *stop = YES;
            return;
        }
        
        [resultObject setValue:value forKey:propertyMapping.destinationKeyPath];
        [_breadcrumbs removeLastObject];
    }];
        
    return resultObject;
}

- (id)transformedValue:(id)value forProperty:(ESObjectProperty *)property withMapping:(ESObjectPropertyMapping *)mapping error:(NSError **)error {    
    Class class = property.propertyClass;
    if (!class && [property isPrimitive]) {
        class = [NSNumber class];
    }
    
    id result = nil;
    
    if (mapping.valueTransformer) {
        result = [mapping.valueTransformer trasformValue:value toClass:class];
    } else {
        result = [_defaultValueTransformer trasformValue:value toClass:class];
    }
    
    if (!result && error) {
        *error = [NSError errorWithDomain:ESObjectsConstructorErrorDomain
                                     code:ESObjectsConstructorMissingValue
                                 userInfo:@{NSLocalizedDescriptionKey: @"can't convert value"}];
    }
    
    return result;
}

- (void)addErrorWithCode:(NSInteger)code description:(NSString *)description {
    description = [NSString stringWithFormat:@"%@: %@", [_breadcrumbs componentsJoinedByString:@"."], description];
    NSError *error = [NSError errorWithDomain:ESObjectsConstructorErrorDomain
                                         code:code
                                     userInfo:@{NSLocalizedDescriptionKey : description}];
    [_errors addObject:error];
}

@end
