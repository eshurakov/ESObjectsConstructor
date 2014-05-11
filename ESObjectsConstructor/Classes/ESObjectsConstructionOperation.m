//
//  ESObjectsConstructionOperation.m
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import "ESObjectsConstructionOperation.h"
#import "ESObjectsConstructor.h"

#import "ESObjectMappingProtocol.h"
#import "ESObjectPropertyMapping.h"
#import "ESObjectsConstructorConfig.h"

#import "ESObjectProperty.h"

#import "ESObjectValueTransformerProtocol.h"

@implementation ESObjectsConstructionOperation
{
    id _data;
    ESObjectsConstructorConfig *_config;
    
    NSMutableArray *_breadcrumbs;
    NSError *_error;
}

- (instancetype)init {
    return [self initWithData:nil config:nil];
}

- (instancetype)initWithData:(id)data config:(ESObjectsConstructorConfig *)config {
    NSParameterAssert(config);
    
    self = [super init];
    if (self) {
        _data = data;
        _config = config;
        
        _breadcrumbs = [[NSMutableArray alloc] initWithObjects:@"", nil];
    }
    return self;
}

- (id)execute:(NSError *__autoreleasing *)error {
    NSError *localError = nil;
    id result = [self mapData:_data withConfig:_config error:&localError];
    
    if (error) {
        *error = localError;
    }
    return result;
}

- (id)mapData:(id)data withConfig:(ESObjectsConstructorConfig *)config error:(NSError *__autoreleasing *)error {
    NSParameterAssert(config);
    
    id result = nil;
    switch (config.type) {
        case ESObjectsConstructorConfigObject:
            result = [self constructObjectFromObject:data
                                         withMapping:config.objectMapping
                                               error:error];
            break;
            
        case ESObjectsConstructorConfigCollection:
            result = [self constructObjectsFromArray:data
                                          withConfig:config.config
                                               error:error];
            break;
            
        default:
            *error = [self errorWithCode:ESObjectsConstructorInvalidData description:[NSString stringWithFormat:@"invalid config type: %lu", config.type]];
            break;
    }
    
    if (*error) {
        return nil;
    }
    
    return result;
}

- (NSArray *)constructObjectsFromArray:(NSArray *)objects withConfig:(ESObjectsConstructorConfig *)config error:(NSError *__autoreleasing *)error {
    NSParameterAssert(config);
    
    if (![objects isKindOfClass:[NSArray class]]) {
        *error = [self errorWithCode:ESObjectsConstructorInvalidData
                         description:[NSString stringWithFormat:@"expected array, but got %@", [objects class]]];
        return nil;
    }
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    NSUInteger idx = 0;
    for (id objectData in objects) {
        [_breadcrumbs addObject:[NSString stringWithFormat:@"%lu", (unsigned long)idx]];
        id object = [self mapData:objectData withConfig:config error:error];
        [_breadcrumbs removeLastObject];
        
        if (*error) {
            return nil;
        }
        
        [results addObject:object];
        ++idx;
    }
        
    return results;
}

- (id)constructObjectFromObject:(NSDictionary *)sourceObject
                    withMapping:(id <ESObjectMappingProtocol>)objectMapping
                          error:(NSError *__autoreleasing *)error {
    NSParameterAssert(objectMapping);
    
    if (![objectMapping canMapObjectOfClass:[sourceObject class]]) {
        *error = [self errorWithCode:ESObjectsConstructorInvalidData
                         description:[NSString stringWithFormat:@"can't map source object with class %@", [sourceObject class]]];
        return nil;
    }
    
    __block id resultObject = [objectMapping newResultObject];
    if (!resultObject) {
        *error = [self errorWithCode:ESObjectsConstructorNilModel description:@"couldn't create result object"];
        return nil;
    }
    
    [objectMapping enumerateMappingsWithBlock:^(ESObjectPropertyMapping *propertyMapping, ESObjectProperty *property, BOOL *stop) {
        [_breadcrumbs addObject:propertyMapping.sourceKeyPath];
        
        if (!property || property.type == ESObjectPropertyTypeUnknown) {
            *error = [self errorWithCode:ESObjectsConstructorUnknownProperty
                             description:[NSString stringWithFormat:@"unknown property: %@", propertyMapping.destinationKey]];
            [_breadcrumbs removeLastObject];
            
            resultObject = nil;
            *stop = YES;
            return;
        }
        
        id value = [sourceObject valueForKeyPath:propertyMapping.sourceKeyPath];
        if (!value && propertyMapping.optional) {
            [_breadcrumbs removeLastObject];
            return;
        }

        if (value && ![value isKindOfClass:[NSNull class]] &&
            ![property isPrimitive] && propertyMapping.destinationConfig) {
            value = [self mapData:value
                       withConfig:propertyMapping.destinationConfig
                            error:error];
            
            if (*error) {
                [_breadcrumbs removeLastObject];
                
                resultObject = nil;
                *stop = YES;
                return;
            }
        }
        
        id <ESObjectValueTransformerProtocol> transformer = propertyMapping.valueTransformer ?: objectMapping.valueTransformer;
        
        Class class = property.propertyClass;
        if (!class && [property isPrimitive]) {
            class = [NSNumber class];
        }
        
        NSError *transformationError = nil;
        value = [transformer trasformValue:value toClass:class error:&transformationError];
        
        if (transformationError) {
            *error = [self errorWithCode:ESObjectsConstructorInvalidData
                             description:transformationError.localizedDescription];
            [_breadcrumbs removeLastObject];
            
            resultObject = nil;
            *stop = YES;
            return;
        }
        
        if (!value && [property isPrimitive]) {
            value = @(0);
        }
        
        [resultObject setValue:value forKey:propertyMapping.destinationKey];
        [_breadcrumbs removeLastObject];
    }];
        
    return resultObject;
}

- (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description {
    description = [NSString stringWithFormat:@"%@: %@", [_breadcrumbs componentsJoinedByString:@"."], description];
    return [NSError errorWithDomain:ESObjectsConstructorErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey : description}];
}

@end
