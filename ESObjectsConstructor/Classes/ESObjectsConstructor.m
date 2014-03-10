//
//  ESObjectsConstructor.m
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import "ESObjectsConstructor.h"

#import "ESObjectMapping.h"
#import "ESObjectPropertyMapping.h"
#import "ESObjectsConstructorConfig.h"

#import "ESPropertyInspector.h"
#import "ESObjectProperty.h"

NSString * const ESObjectsConstructorErrorDomain = @"ESObjectsConstructorErrorDomain";

@implementation ESObjectsConstructor

- (id)constructFromData:(id)data withConfig:(ESObjectsConstructorConfig *)config error:(NSError **)error {
    NSParameterAssert(config);
    NSError *localError = nil;
    id result = nil;
    switch (config.type) {
        case ESObjectsConstructorConfigObject:
            result = [self constructObjectFromDictionary:data
                                              withConfig:config.objectMapping
                                                   error:&localError];
            break;
            
        case ESObjectsConstructorConfigCollection:
            result = [self constructObjectsFromArray:data
                                          withConfig:config.objectMapping
                                               error:&localError];
            break;
            
        default:
            localError = [NSError errorWithDomain:ESObjectsConstructorErrorDomain
                                             code:ESObjectsConstructorInvalidData
                                         userInfo:nil];
            break;
    }

    if (error) {
        *error = localError;
    }
    
    return result;
}

#pragma mark -

- (NSArray *)constructObjectsFromArray:(NSArray *)objects
                            withConfig:(ESObjectMapping *)config
                                 error:(NSError **)error {
	NSParameterAssert(config);
    if (![objects isKindOfClass:[NSArray class]]) {
        *error = [NSError errorWithDomain:ESObjectsConstructorErrorDomain
                                     code:ESObjectsConstructorInvalidData
                                 userInfo:nil];
        return nil;
    }
    
	NSMutableArray *results = [[NSMutableArray alloc] init];
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
	for (NSDictionary *objectData in objects) {
        NSError *objectError = nil;
        
		id object = [self constructObjectFromDictionary:objectData
                                             withConfig:config
                                                  error:&objectError];

        if (objectError) {
            [errors addObject:objectError];
        }
        
        if (object) {
            [results addObject:object];
        }
	}
	
    if ([errors count] > 0) {
        *error = [NSError errorWithDomain:ESObjectsConstructorErrorDomain
                                     code:ESObjectsConstructorCorruptedObjects
                                 userInfo:nil];
    }
    
	return results;
}

- (id)constructObjectFromDictionary:(NSDictionary *)objectDict
                         withConfig:(ESObjectMapping *)config
                              error:(NSError **)error {
    NSParameterAssert(config);
    if (![objectDict isKindOfClass:[NSDictionary class]]) {
        *error = [NSError errorWithDomain:ESObjectsConstructorErrorDomain
                                     code:ESObjectsConstructorInvalidData
                                 userInfo:nil];
        return nil;
    }
    
    id object = [[config.modelClass alloc] init];
    if (!object) {
        *error = [NSError errorWithDomain:ESObjectsConstructorErrorDomain
                                     code:ESObjectsConstructorNilModel
                                 userInfo:nil];
        return nil;
    }
    
	for (ESObjectPropertyMapping *mapping in config.mappings) {
        ESObjectProperty *property = [ESPropertyInspector propertyWithName:mapping.destinationKeyPath inClass:config.modelClass];
        
        if (!property || property.type == ESObjectPropertyTypeUnknown) {
            *error = [NSError errorWithDomain:ESObjectsConstructorErrorDomain
                                         code:ESObjectsConstructorUnknownProperty
                                     userInfo:nil];
            return nil;
        }
		      
		id value = [objectDict valueForKeyPath:mapping.sourceKeyPath];
        if (!value) {
            *error = [NSError errorWithDomain:ESObjectsConstructorErrorDomain
                                         code:ESObjectsConstructorMissingValue
                                     userInfo:nil];
            return nil;
        }
        
        NSError *relationshipError = nil;
		if (mapping.destinationConfig) {
            value = [self constructFromData:value withConfig:mapping.destinationConfig error:&relationshipError];
		}
        
		value = [self convertValue:value forProperty:property error:error];
        if (*error) {
            return nil;
        }
        
        *error = relationshipError;
        
		[object setValue:value forKey:mapping.destinationKeyPath];
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
    
	if ([class isSubclassOfClass:[NSString class]]) {
		if ([value respondsToSelector:@selector(stringValue)]) {
			return [value stringValue];
		}
	} else if ([class isSubclassOfClass:[NSNumber class]]) {
        if ([value respondsToSelector:@selector(doubleValue)]) {
            return @([value doubleValue]);
        }
    }
	
    *error = [NSError errorWithDomain:ESObjectsConstructorErrorDomain
                                 code:ESObjectsConstructorMissingValue
                             userInfo:nil];
    
	return nil;
}

@end
