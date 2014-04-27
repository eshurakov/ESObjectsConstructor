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

- (instancetype)init {
    self = [super init];
    if (self) {
        _valueTransformer = [[ESObjectDefaultValueTransformer alloc] init];
        _valueSerializer = [[ESObjectDefaultValueSerializer alloc] init];
    }
    return self;
}

- (id)mapData:(id)data withConfig:(ESObjectsConstructorConfig *)config error:(NSError **)error {
    ESObjectsConstructionOperation *operation = [[ESObjectsConstructionOperation alloc] initWithData:data config:config defaultValueTransformer:_valueTransformer];
    [operation execute];
    
    if (error) {
        *error = [self errorFromOperation:operation];
    }
   
    return operation.resultData;
}

- (id)serializeObject:(id)object withConfig:(ESObjectsConstructorConfig *)config error:(NSError **)error {
    ESObjectsConstructionOperation *operation = [[ESObjectsConstructionOperation alloc] initWithData:object config:config defaultValueTransformer:_valueSerializer];
    [operation execute];
    
    if (error) {
        *error = [self errorFromOperation:operation];
    }
    
    return operation.resultData;
}

- (NSError *)errorFromOperation:(ESObjectsConstructionOperation *)operation {
    if (operation.errors.count == 1) {
        return [operation.errors lastObject];
    } else if (operation.errors.count > 1) {
        return [NSError errorWithDomain:ESObjectsConstructorErrorDomain
                                   code:ESObjectsConstructorMultipleIssues
                               userInfo:@{@"errors" : operation.errors}];
    }
    
    return nil;
}

@end
