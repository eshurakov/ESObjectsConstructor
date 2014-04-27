//
//  ESObjectMapping.h
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESObjectsConstructorConfig;
@class ESObjectPropertyMapping;
@class ESObjectProperty;

@protocol ESObjectValueTransformerProtocol;

@interface ESObjectMapping : NSObject

@property(nonatomic, strong, readonly) Class modelClass;
@property(nonatomic, copy, readonly) NSArray *mappings;

- (instancetype)initWithModelClass:(Class)modelClass;

- (void)mapProperties:(NSArray *)properties;

- (ESObjectPropertyMapping *)mapKeyPath:(NSString *)sourceKeyPath;
- (ESObjectPropertyMapping *)mapKeyPath:(NSString *)sourceKeyPath withConfig:(ESObjectsConstructorConfig *)config;
- (ESObjectPropertyMapping *)mapKeyPath:(NSString *)sourceKeyPath withValueTransformer:(id <ESObjectValueTransformerProtocol>)valueTransformer;

#pragma mark -

- (id)newResultObject;
- (BOOL)canMapObjectOfClass:(Class)objectClass;

- (void)enumerateMappingsWithBlock:(void (^)(ESObjectPropertyMapping *mapping, ESObjectProperty *property, BOOL *stop))block;

@end
