//
//  ESObjectEnumValueTransformer.m
//
//  Created by Evgeny Shurakov on 17.04.14.
//  Copyright (c) 2014 Evgeny Shurakov. All rights reserved.
//

#import "ESObjectEnumValueTransformer.h"

@implementation ESObjectEnumValueTransformer
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

- (void)mapString:(NSString *)string toValue:(NSNumber *)value {
    [_map setValue:value forKey:string];
}

- (id)trasformValue:(id)value toClass:(Class)class {
    if (![class isEqual:[NSNumber class]]) {
        return nil;
    }
    
    if (![value isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    return _map[value];
}

@end
