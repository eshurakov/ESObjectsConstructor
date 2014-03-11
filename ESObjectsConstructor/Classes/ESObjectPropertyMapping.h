//
//  ESObjectPropertyMapping.h
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESObjectsConstructorConfig;

@interface ESObjectPropertyMapping : NSObject

@property(nonatomic, strong, readonly) NSString *sourceKeyPath;

@property(nonatomic, strong, readonly) NSString *destinationKeyPath;
@property(nonatomic, strong) ESObjectsConstructorConfig *destinationConfig;

@property(nonatomic, assign, readonly, getter = isOptional) BOOL optional;

- (instancetype)initWithKeyPath:(NSString *)keyPath;
- (instancetype)initWithSourceKeyPath:(NSString *)sourceKeyPath destinationKeyPath:(NSString *)destinationKeyPath;

@end
