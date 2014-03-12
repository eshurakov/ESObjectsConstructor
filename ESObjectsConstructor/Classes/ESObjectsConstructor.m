//
//  ESObjectsConstructor.m
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import "ESObjectsConstructor.h"
#import "ESObjectsConstructionOperation.h"

NSString * const ESObjectsConstructorErrorDomain = @"ESObjectsConstructorErrorDomain";

@implementation ESObjectsConstructor

- (id)mapData:(id)data withConfig:(ESObjectsConstructorConfig *)config error:(NSError **)error {
    ESObjectsConstructionOperation *operation = [[ESObjectsConstructionOperation alloc] initWithData:data config:config];
    [operation execute];
    
    if (error) {
        if (operation.errors.count == 1) {
            *error = [operation.errors lastObject];
        } else if (operation.errors.count > 1) {
            *error = [NSError errorWithDomain:ESObjectsConstructorErrorDomain
                                         code:ESObjectsConstructorMultipleIssues
                                     userInfo:@{@"errors" : operation.errors}];
        }
    }
   
    return operation.resultData;
}

@end
