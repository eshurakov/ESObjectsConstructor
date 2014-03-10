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
    ESObjectsConstructorCorruptedObjects,
    ESObjectsConstructorNilModel,
    ESObjectsConstructorUnknownProperty,
    ESObjectsConstructorMissingValue
};

@class ESObjectsConstructorConfig;

@interface ESObjectsConstructor : NSObject

- (id)constructFromData:(id)data withConfig:(ESObjectsConstructorConfig *)config error:(NSError **)error;

@end
