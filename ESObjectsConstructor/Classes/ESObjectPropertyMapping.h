//
//  ESObjectPropertyMapping.h
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESObjectsConstructorConfig;
@protocol ESObjectValueTransformerProtocol;

@interface ESObjectPropertyMapping : NSObject

@property(nonatomic, strong, readonly) NSString *sourceKeyPath;

@property(nonatomic, copy) NSString *destinationKey;
@property(nonatomic, strong) ESObjectsConstructorConfig *destinationConfig;

@property(nonatomic, strong) id <ESObjectValueTransformerProtocol> valueTransformer;

@property(nonatomic, assign, getter = isOptional) BOOL optional;

- (instancetype)initWithKeyPath:(NSString *)keyPath;

@end
