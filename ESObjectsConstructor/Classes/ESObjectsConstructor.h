//
//  ESObjectsConstructor.h
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const ESObjectsConstructorErrorDomain;
typedef NS_ENUM(NSUInteger, ESObjectsConstructorErrorCode) {
    ESObjectsConstructorInvalidData = 1,
    ESObjectsConstructorNilModel,
    ESObjectsConstructorUnknownProperty
};

@class ESObjectsConstructorConfig;

@interface ESObjectsConstructor : NSObject

@property(nonatomic, strong) dispatch_queue_t workQueue;
@property(nonatomic, strong) dispatch_queue_t callbackQueue;

- (id)mapData:(id)data withConfig:(ESObjectsConstructorConfig *)config error:(NSError **)error;
- (id)serializeObject:(id)object withConfig:(ESObjectsConstructorConfig *)config error:(NSError **)error;

- (void)mapData:(id)data
     withConfig:(ESObjectsConstructorConfig *)config
     completion:(void (^)(id mappedObject, NSError *error))completion;

- (void)serializeObject:(id)object
             withConfig:(ESObjectsConstructorConfig *)config
             completion:(void (^)(id serializedObject, NSError *error))completion;

@end
