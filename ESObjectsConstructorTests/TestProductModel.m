//
//  TestProductModel.m
//
//  Created by Evgeny Shurakov on 2014/04/27.
//  Copyright (c) 2014 Evgeny Shurakov. All rights reserved.
//

#import "TestProductModel.h"

@implementation TestProductModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _invocations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    [_invocations addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    [super setValue:value forKey:key];
}

@end
