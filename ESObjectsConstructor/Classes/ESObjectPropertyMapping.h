//
//  ESObjectPropertyMapping.h
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESObjectsConstructorConfig;

@interface ESObjectPropertyMapping : NSObject

@property(nonatomic, strong) NSString *sourceKeyPath;

@property(nonatomic, strong) NSString *destinationKeyPath;
@property(nonatomic, strong) ESObjectsConstructorConfig *destinationConfig;

@property(nonatomic, assign, getter = isOptional) BOOL optional;

@end
