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
    [self mapKeyPath:sourceKeyPath toProperty:destinationProperty config:nil];
}

- (void)mapKeyPath:(NSString *)sourceKeyPath toProperty:(NSString *)destinationProperty config:(ESObjectsConstructorConfig *)config {
    NSParameterAssert(sourceKeyPath);
    
    ESObjectPropertyMapping *mapping = [[ESObjectPropertyMapping alloc] initWithSourceKeyPath:sourceKeyPath
                                                                           destinationKeyPath:destinationProperty];
    mapping.destinationConfig = config;
    
    [_mappings addObject:mapping];
}

- (void)mapProperties:(NSArray *)properties {
    for (NSString *keyPath in properties) {
        [self mapKeyPath:keyPath toProperty:nil];
    }
}

@end
