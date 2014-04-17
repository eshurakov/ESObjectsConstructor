//
//  ESObjectsConstructorConfig.m
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import "ESObjectsConstructorConfig.h"
#import "ESObjectMapping.h"

@interface ESObjectsConstructorConfig ()
@property(nonatomic, assign, readwrite) ESObjectsConstructorConfigType type;
@property(nonatomic, strong, readwrite) ESObjectMapping *objectMapping;
@property(nonatomic, strong, readwrite) ESObjectsConstructorConfig *config;
@end

@implementation ESObjectsConstructorConfig

+ (instancetype)objectWithMapping:(ESObjectMapping *)objectMapping {
    NSParameterAssert(objectMapping);
    
    ESObjectsConstructorConfig *config = [[[self class] alloc] init];
    config.type = ESObjectsConstructorConfigObject;
    config.objectMapping = objectMapping;
    return config;
}

+ (instancetype)collectionWithObjectMapping:(ESObjectMapping *)objectMapping {
    NSParameterAssert(objectMapping);
    
    ESObjectsConstructorConfig *config = [[[self class] alloc] init];
    config.type = ESObjectsConstructorConfigCollection;
    config.config = [self objectWithMapping:objectMapping];
    return config;
}

+ (instancetype)collectionOfCollectionsWithObjectMapping:(ESObjectMapping *)objectMapping {
    NSParameterAssert(objectMapping);
    
    ESObjectsConstructorConfig *config = [[[self class] alloc] init];
    config.type = ESObjectsConstructorConfigCollection;
    config.config = [self collectionWithObjectMapping:objectMapping];
    return config;
}

@end
