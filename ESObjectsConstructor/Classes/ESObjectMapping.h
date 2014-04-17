//
//  ESObjectMapping.h
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESObjectsConstructorConfig;
@class ESObjectPropertyMapping;

@protocol ESObjectValueTransformerProtocol;

@interface ESObjectMapping : NSObject

@property(nonatomic, strong, readonly) Class modelClass;
@property(nonatomic, copy, readonly) NSArray *mappings;

- (instancetype)initWithModelClass:(Class)modelClass;

- (void)mapKeyPath:(NSString *)sourceKeyPath
		toProperty:(NSString *)destinationProperty __attribute__((deprecated));

- (void)mapKeyPath:(NSString *)sourceKeyPath
		toProperty:(NSString *)destinationProperty
			config:(ESObjectsConstructorConfig *)config __attribute__((deprecated));

- (void)mapProperties:(NSArray *)properties;

- (ESObjectPropertyMapping *)mapKeyPath:(NSString *)sourceKeyPath;
- (ESObjectPropertyMapping *)mapKeyPath:(NSString *)sourceKeyPath withConfig:(ESObjectsConstructorConfig *)config;
- (ESObjectPropertyMapping *)mapKeyPath:(NSString *)sourceKeyPath withValueTransformer:(id <ESObjectValueTransformerProtocol>)valueTransformer;

@end
