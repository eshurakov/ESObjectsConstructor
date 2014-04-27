//
//  ESObjectsConstructor.h
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const ESObjectsConstructorErrorDomain;
typedef NS_ENUM(NSUInteger, ESObjectsConstructorErrorCode) {
    ESObjectsConstructorMultipleIssues = 1,
    ESObjectsConstructorInvalidData,
    ESObjectsConstructorNilModel,
    ESObjectsConstructorUnknownProperty,
    ESObjectsConstructorMissingValue
};

@class ESObjectsConstructorConfig;
@protocol ESObjectValueTransformerProtocol;

@interface ESObjectsConstructor : NSObject

@property(nonatomic, strong) id <ESObjectValueTransformerProtocol> valueTransformer;
@property(nonatomic, strong) id <ESObjectValueTransformerProtocol> valueSerializer;

- (id)mapData:(id)data withConfig:(ESObjectsConstructorConfig *)config error:(NSError **)error;
- (id)serializeObject:(id)object withConfig:(ESObjectsConstructorConfig *)config error:(NSError **)error;

@end
