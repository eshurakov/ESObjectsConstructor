//
//  ESObjectsConstructor.m
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import "ESObjectsConstructor.h"
#import "ESObjectsConstructionOperation.h"
#import "ESObjectDefaultValueTransformer.h"
#import "ESObjectDefaultValueSerializer.h"

NSString * const ESObjectsConstructorErrorDomain = @"ESObjectsConstructorErrorDomain";

@implementation ESObjectsConstructor

- (id)mapData:(id)data withConfig:(ESObjectsConstructorConfig *)config error:(NSError **)error {
    ESObjectsConstructionOperation *operation = [[ESObjectsConstructionOperation alloc] initWithData:data config:config];
    
    return [operation execute:error];
}

- (id)serializeObject:(id)object withConfig:(ESObjectsConstructorConfig *)config error:(NSError **)error {
    ESObjectsConstructionOperation *operation = [[ESObjectsConstructionOperation alloc] initWithData:object config:config];
    
    return [operation execute:error];
}

@end
