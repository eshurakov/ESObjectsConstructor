//
//  ESObjectsConstructorConfig.h
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ESObjectsConstructorConfigType) {
    ESObjectsConstructorConfigObject = 1,
    ESObjectsConstructorConfigCollection
};

@class ESObjectMapping;

@interface ESObjectsConstructorConfig : NSObject

@property(nonatomic, assign, readonly) ESObjectsConstructorConfigType type;
@property(nonatomic, strong, readonly) ESObjectMapping *objectMapping;
@property(nonatomic, strong, readonly) ESObjectsConstructorConfig *config;

+ (instancetype)objectWithMapping:(ESObjectMapping *)objectMapping;
+ (instancetype)collectionWithObjectMapping:(ESObjectMapping *)objectMapping;
+ (instancetype)collectionOfCollectionsWithObjectMapping:(ESObjectMapping *)objectMapping;

@end
