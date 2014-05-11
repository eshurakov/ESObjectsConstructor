//
//  ESObjectPropertyMapping.m
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import "ESObjectPropertyMapping.h"

@implementation ESObjectPropertyMapping

- (instancetype)init {
    return [self initWithKeyPath:nil];
}

- (instancetype)initWithKeyPath:(NSString *)keyPath {
    NSParameterAssert(keyPath);
    self = [super init];
    if (self) {
        [self parseSourceKeyPath:keyPath];
        _destinationKey = _sourceKeyPath;
    }
    return self;
}

- (void)parseSourceKeyPath:(NSString *)sourceKeyPath {
    if ([sourceKeyPath hasSuffix:@"?"]) {
        _optional = YES;
        sourceKeyPath = [sourceKeyPath substringToIndex:[sourceKeyPath length] - 1];
    }
    _sourceKeyPath = sourceKeyPath;
}

@end
