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
        _callbackQueue = dispatch_get_main_queue();
        _workQueue = dispatch_queue_create("ESObjectsConstructor", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (id)mapData:(id)data withConfig:(ESObjectsConstructorConfig *)config error:(NSError **)error {
    __block NSError *tmpError = nil;
    __block id result = nil;
    
    dispatch_sync(_workQueue, ^{
        ESObjectsConstructionOperation *operation = [[ESObjectsConstructionOperation alloc] initWithData:data config:config];
        result = [operation execute:&tmpError];
    });
    
    if (error) {
        *error = tmpError;
    }
    
    return result;
}

- (id)serializeObject:(id)object withConfig:(ESObjectsConstructorConfig *)config error:(NSError **)error {
    return [self mapData:object withConfig:config error:error];
}

- (void)mapData:(id)data
     withConfig:(ESObjectsConstructorConfig *)config
     completion:(void (^)(id mappedObject, NSError *error))completion {
    __weak ESObjectsConstructor *weakSelf = self;
    dispatch_async(_workQueue, ^{
        ESObjectsConstructor *strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSError *error = nil;
        ESObjectsConstructionOperation *operation = [[ESObjectsConstructionOperation alloc] initWithData:data config:config];
        id mappedObject = [operation execute:&error];
        
        dispatch_async(strongSelf->_callbackQueue, ^{
            completion(mappedObject, error);
        });
    });
}

- (void)serializeObject:(id)object
             withConfig:(ESObjectsConstructorConfig *)config
             completion:(void (^)(id serializedObject, NSError *error))completion {
    [self mapData:object withConfig:config completion:completion];
}

@end
