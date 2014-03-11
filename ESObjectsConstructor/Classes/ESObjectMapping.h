//
//  ESObjectMapping.h
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESObjectsConstructorConfig;

@interface ESObjectMapping : NSObject

@property(nonatomic, strong, readonly) Class modelClass;
@property(nonatomic, copy, readonly) NSArray *mappings;

- (instancetype)initWithModelClass:(Class)modelClass;

- (void)mapKeyPath:(NSString *)sourceKeyPath
		toProperty:(NSString *)destinationProperty;

- (void)mapKeyPath:(NSString *)sourceKeyPath
		toProperty:(NSString *)destinationProperty
			config:(ESObjectsConstructorConfig *)config;

- (void)mapProperties:(NSArray *)properties;

@end
