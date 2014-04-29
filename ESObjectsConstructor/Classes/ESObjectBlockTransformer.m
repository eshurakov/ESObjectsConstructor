//
//  ESObjectBlockTransformer.m
//
//  Created by Evgeny Shurakov on 2014/04/29.
//  Copyright (c) 2014 Evgeny Shurakov. All rights reserved.
//

#import "ESObjectBlockTransformer.h"

@implementation ESObjectBlockTransformer
{
    ESObjectBlockTransformerBlock _block;
}

- (instancetype)init {
    return [self initWithBlock:nil];
}

- (instancetype)initWithBlock:(ESObjectBlockTransformerBlock)block {
    NSParameterAssert(block);
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (id)trasformValue:(id)value toClass:(Class)class {
    return _block(value, class);
}

@end
