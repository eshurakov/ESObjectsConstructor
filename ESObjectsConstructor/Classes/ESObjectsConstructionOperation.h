//
//  ESObjectsConstructionOperation.h
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESObjectsConstructorConfig;

@interface ESObjectsConstructionOperation : NSObject

- (instancetype)initWithData:(id)data config:(ESObjectsConstructorConfig *)config;

- (id)execute:(NSError **)error;

@end
