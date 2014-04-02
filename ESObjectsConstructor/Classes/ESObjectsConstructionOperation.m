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

#import "ESPropertyInspector.h"
#import "ESObjectProperty.h"

@implementation ESObjectsConstructionOperation
{
    id _data;
    ESObjectsConstructorConfig *_config;
    
    NSMutableArray *_errors;
    NSMutableArray *_breadcrumbs;
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
            result = [self constructObjectFromDictionary:data
                                             withMapping:config.objectMapping];
            break;
            
        case ESObjectsConstructorConfigCollection:
            result = [self constructObjectsFromArray:data
                                         withMapping:config.objectMapping];
            break;
            
        default:
            [self addErrorWithCode:ESObjectsConstructorInvalidData
                       description:[NSString stringWithFormat:@"invalid config type: %lu", config.type]];
            break;
    }
    
    return result;
}

- (NSArray *)constructObjectsFromArray:(NSArray *)objects
                           withMapping:(ESObjectMapping *)objectMapping {
    NSParameterAssert(objectMapping);
    
    if (![objects isKindOfClass:[NSArray class]]) {
        [self addErrorWithCode:ESObjectsConstructorInvalidData
                   description:[NSString stringWithFormat:@"expected array, but got %@", [objects class]]];
        return nil;
    }
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    [objects enumerateObjectsUsingBlock:^(NSDictionary *objectData, NSUInteger idx, BOOL *stop) {
        [_breadcrumbs addObject:[NSString stringWithFormat:@"%lu", (unsigned long)idx]];
        id object = [self constructObjectFromDictionary:objectData
                                            withMapping:objectMapping];
        if (object) {
            [results addObject:object];
        }
        [_breadcrumbs removeLastObject];
    }];
    
    return results;
}

- (id)constructObjectFromDictionary:(NSDictionary *)objectDict
                        withMapping:(ESObjectMapping *)objectMapping {
    NSParameterAssert(objectMapping);
    if (![objectDict isKindOfClass:[NSDictionary class]]) {
        [self addErrorWithCode:ESObjectsConstructorInvalidData
                   description:[NSString stringWithFormat:@"expected dict, but got %@", [objectDict class]]];
        return nil;
    }
    
    id object = [[objectMapping.modelClass alloc] init];
    if (!object) {
        [self addErrorWithCode:ESObjectsConstructorNilModel
                   description:[NSString stringWithFormat:@"couldn't create object with class: %@", objectMapping.modelClass]];
        return nil;
    }
    
    for (ESObjectPropertyMapping *propertyMapping in objectMapping.mappings) {
        [_breadcrumbs addObject:propertyMapping.sourceKeyPath];
        
        ESObjectProperty *property = [ESPropertyInspector propertyWithName:propertyMapping.destinationKeyPath
                                                                 fromClass:objectMapping.modelClass];
        
        if (!property || property.type == ESObjectPropertyTypeUnknown) {
            [self addErrorWithCode:ESObjectsConstructorUnknownProperty
                       description:[NSString stringWithFormat:@"unknown property: %@", propertyMapping.destinationKeyPath]];
            [_breadcrumbs removeLastObject];
            return nil;
        }
        
        id value = [objectDict valueForKeyPath:propertyMapping.sourceKeyPath];
        if (!value) {
            if (propertyMapping.optional) {
                continue;
            }
           
            [self addErrorWithCode:ESObjectsConstructorMissingValue
                       description:@"missing value"];
            [_breadcrumbs removeLastObject];
            return nil;
        }
        
        if (propertyMapping.destinationConfig) {
            value = [self mapData:value
                       withConfig:propertyMapping.destinationConfig];
        }
        
        NSError *error = nil;
        value = [self convertValue:value forProperty:property error:&error];
        if (error) {
            [self addErrorWithCode:ESObjectsConstructorInvalidData
                       description:error.localizedDescription];
            [_breadcrumbs removeLastObject];
            return nil;
        }
        
        [object setValue:value forKey:propertyMapping.destinationKeyPath];
        [_breadcrumbs removeLastObject];
    }
    
    return object;
}

- (id)convertValue:(id)value forProperty:(ESObjectProperty *)property error:(NSError **)error {
    if (property.type == ESObjectPropertyTypeID) {
        if (!value || [value isKindOfClass:[NSNull class]]) {
            return nil;
        }
    }
    
    Class class = property.propertyClass;
    if (!class && [property isPrimitive]) {
        class = [NSNumber class];
    }
    
    if (!class || [value isKindOfClass:class]) {
        return value;
    }
    
    if ([class isEqual:[NSString class]]) {
        if ([value respondsToSelector:@selector(stringValue)]) {
            return [value stringValue];
        }
    } else if ([class isEqual:[NSNumber class]] && [value isKindOfClass:[NSString class]]) {
        static NSNumberFormatter *numberFormatter = nil;
        if (numberFormatter == nil) {
            numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        }
        
        NSNumber *result = [numberFormatter numberFromString:value];
        if (result) {
            return result;
        }
    } else if ([class isEqual:[NSDecimalNumber class]] && [value isKindOfClass:[NSString class]]) {
        NSDecimalNumber *result = [NSDecimalNumber decimalNumberWithString:value];
        if (result && ![result isEqual:[NSDecimalNumber notANumber]]) {
            return result;
        }
    } else if ([class isEqual:[NSDate class]] && [value isKindOfClass:[NSNumber class]]) {
        NSDate *result = [NSDate dateWithTimeIntervalSince1970:([value longLongValue] / 1000.0)];
        if (result) {
            return result;
        }
    }
    
    if (error) {
        *error = [NSError errorWithDomain:ESObjectsConstructorErrorDomain
                                     code:ESObjectsConstructorMissingValue
                                 userInfo:@{NSLocalizedDescriptionKey: @"can't convert value"}];
    }
    
    return nil;
}

- (void)addErrorWithCode:(NSInteger)code description:(NSString *)description {
    description = [NSString stringWithFormat:@"%@: %@", [_breadcrumbs componentsJoinedByString:@"."], description];
    NSError *error = [NSError errorWithDomain:ESObjectsConstructorErrorDomain
                                         code:code
                                     userInfo:@{NSLocalizedDescriptionKey : description}];
    [_errors addObject:error];
}

@end
