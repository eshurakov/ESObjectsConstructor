//
//  ESObjectsConstructionOperation.h
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESObjectsConstructorConfig;

@interface ESObjectsConstructionOperation : NSObject

@property(nonatomic, strong) NSArray *errors;
@property(nonatomic, strong, readonly) id resultData;

- (instancetype)initWithData:(id)data config:(ESObjectsConstructorConfig *)config;

- (void)execute;

@end
