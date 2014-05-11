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

@protocol ESObjectMappingProtocol;

@interface ESObjectsConstructorConfig : NSObject

@property(nonatomic, assign, readonly) ESObjectsConstructorConfigType type;
@property(nonatomic, strong, readonly) id <ESObjectMappingProtocol> objectMapping;
@property(nonatomic, strong, readonly) ESObjectsConstructorConfig *config;

+ (instancetype)objectWithMapping:(id <ESObjectMappingProtocol>)objectMapping;
+ (instancetype)collectionWithObjectMapping:(id <ESObjectMappingProtocol>)objectMapping;
+ (instancetype)collectionOfCollectionsWithObjectMapping:(id <ESObjectMappingProtocol>)objectMapping;

@end
