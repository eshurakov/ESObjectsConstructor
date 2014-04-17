//
//  ESObjectMapping.m
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import "ESObjectMapping.h"
#import "ESObjectPropertyMapping.h"

@implementation ESObjectMapping {
    NSMutableArray *_mappings;
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

- (void)mapKeyPath:(NSString *)sourceKeyPath toProperty:(NSString *)destinationProperty {
    ESObjectPropertyMapping *mapping = [self mapKeyPath:sourceKeyPath];
    mapping.destinationKeyPath = destinationProperty;
}

- (void)mapKeyPath:(NSString *)sourceKeyPath toProperty:(NSString *)destinationProperty config:(ESObjectsConstructorConfig *)config {
    ESObjectPropertyMapping *mapping = [self mapKeyPath:sourceKeyPath];
    mapping.destinationKeyPath = destinationProperty;
    mapping.destinationConfig = config;
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

@end
