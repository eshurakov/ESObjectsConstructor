//
//  ESObjectMapping.m
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import "ESObjectMapping.h"
#import "ESObjectPropertyMapping.h"

#import "ESPropertyInspector.h"

#import "ESObjectValueTransformerProtocol.h"
#import "ESObjectDefaultValueTransformer.h"

@implementation ESObjectMapping {
    NSMutableArray *_mappings;
    ESObjectDefaultValueTransformer *_valueTransformer;
}

- (instancetype)init {
    return [self initWithModelClass:nil];
}

- (instancetype)initWithModelClass:(Class)modelClass {
    NSParameterAssert(modelClass);
    self = [super init];
    if (self) {
        _mappings = [[NSMutableArray alloc] init];
        _modelClass = modelClass;
    }
    return self;
}

- (void)mapProperties:(NSArray *)properties {
    for (NSString *keyPath in properties) {
        [self mapKeyPath:keyPath];
    }
}

- (ESObjectPropertyMapping *)mapKeyPath:(NSString *)sourceKeyPath {
    NSParameterAssert(sourceKeyPath);
    ESObjectPropertyMapping *mapping = [[ESObjectPropertyMapping alloc] initWithKeyPath:sourceKeyPath];
    [_mappings addObject:mapping];
    return mapping;
}

- (ESObjectPropertyMapping *)mapKeyPath:(NSString *)sourceKeyPath withConfig:(ESObjectsConstructorConfig *)config {
    ESObjectPropertyMapping *mapping = [self mapKeyPath:sourceKeyPath];
    mapping.destinationConfig = config;
    return mapping;
}

- (ESObjectPropertyMapping *)mapKeyPath:(NSString *)sourceKeyPath withValueTransformer:(id <ESObjectValueTransformerProtocol>)valueTransformer {
    ESObjectPropertyMapping *mapping = [self mapKeyPath:sourceKeyPath];
    mapping.valueTransformer = valueTransformer;
    return mapping;
}

- (ESObjectProperty *)propertyForMapping:(ESObjectPropertyMapping *)mapping {
    NSParameterAssert(mapping);
    return [ESPropertyInspector propertyWithName:mapping.destinationKey
                                       fromClass:_modelClass];
}

- (ESObjectPropertyMapping *)propertyMappingForKeyPath:(NSString *)keyPath {
    if (!keyPath) {
        return nil;
    }
    
    for (ESObjectPropertyMapping *mapping in _mappings) {
        if ([mapping.sourceKeyPath isEqualToString:keyPath]) {
            return mapping;
        }
    }
    
    return nil;
}

#pragma mark - ESObjectMappingProtocol

- (id)newResultObject {
    return [[_modelClass alloc] init];
}

- (BOOL)canMapObjectOfClass:(Class)objectClass {
    return [objectClass isSubclassOfClass:[NSDictionary class]];
}

- (id <ESObjectValueTransformerProtocol>)valueTransformer {
    if (_valueTransformer == nil) {
        _valueTransformer = [[ESObjectDefaultValueTransformer alloc] init];
    }
    
    return _valueTransformer;
}

- (void)enumerateMappingsWithBlock:(void (^)(ESObjectPropertyMapping *mapping, ESObjectProperty *property, BOOL *stop))block {
    NSParameterAssert(block);
    
    BOOL stop = NO;
    for (ESObjectPropertyMapping *mapping in _mappings) {
        ESObjectProperty *property = [self propertyForMapping:mapping];
        block(mapping, property, &stop);
        if (stop) {
            return;
        }
    }
}

@end
