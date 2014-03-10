//
//  ESObjectsConstructorConfig.m
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import "ESObjectsConstructorConfig.h"
#import "ESObjectMapping.h"

@implementation ESObjectsConstructorConfig

- (instancetype)init {
    return [self initWithType:0 objectMapping:nil];
}

- (instancetype)initWithType:(ESObjectsConstructorConfigType)type objectMapping:(ESObjectMapping *)objectMapping {
    NSParameterAssert(objectMapping);
    self = [super init];
    if (self) {
        _type = type;
        _objectMapping = objectMapping;
    }
    return self;
}

@end
