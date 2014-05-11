//
//  ESObjectEnumValueTransformer.m
//
//  Created by Evgeny Shurakov on 17.04.14.
//  Copyright (c) 2014 Evgeny Shurakov. All rights reserved.
//

#import "ESObjectKeyValueTransformer.h"

@implementation ESObjectKeyValueTransformer
{
    NSMutableDictionary *_map;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _map = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setObject:(id)object forKey:(id<NSCopying>)key {
    _map[key] = object;
}

- (id)trasformValue:(id)value toClass:(Class)class error:(NSError *__autoreleasing *)error {
    if ([value conformsToProtocol:@protocol(NSCopying)]) {
        value = _map[value];
        
        if (value && (!class || (class && [value isKindOfClass:class]))) {
            return value;
        }
    }
    
    if (error) {
        *error = [NSError errorWithDomain:@""
                                     code:0
                                 userInfo:@{NSLocalizedDescriptionKey : @"can't convert value"}];
    }
    
    return nil;
}

@end
