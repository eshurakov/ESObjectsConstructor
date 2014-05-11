//
//  ESObjectMapping.h
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESObjectMappingProtocol.h"

@class ESObjectsConstructorConfig;
@class ESObjectPropertyMapping;
@class ESObjectProperty;

@protocol ESObjectValueTransformerProtocol;

@interface ESObjectMapping : NSObject <ESObjectMappingProtocol>

@property(nonatomic, strong, readonly) Class modelClass;

- (instancetype)initWithModelClass:(Class)modelClass;

- (void)mapProperties:(NSArray *)properties;

- (ESObjectPropertyMapping *)mapKeyPath:(NSString *)sourceKeyPath;
- (ESObjectPropertyMapping *)mapKeyPath:(NSString *)sourceKeyPath withConfig:(ESObjectsConstructorConfig *)config;
- (ESObjectPropertyMapping *)mapKeyPath:(NSString *)sourceKeyPath withValueTransformer:(id <ESObjectValueTransformerProtocol>)valueTransformer;

- (ESObjectProperty *)propertyForMapping:(ESObjectPropertyMapping *)mapping;
- (ESObjectPropertyMapping *)propertyMappingForKeyPath:(NSString *)keyPath;

@end
