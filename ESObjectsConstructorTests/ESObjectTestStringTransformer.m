//
//  ESObjectTestStringTransformer.m
//
//  Created by Evgeny Shurakov on 17.04.14.
//  Copyright (c) 2014 Evgeny Shurakov. All rights reserved.
//

#import "ESObjectTestStringTransformer.h"

@implementation ESObjectTestStringTransformer

- (id)trasformValue:(id)value toClass:(Class)class error:(NSError *__autoreleasing *)error {
    if ([class isEqual:[NSString class]] && [value isKindOfClass:class]) {
        return [value stringByAppendingString:@"-test"];
    }
    
    if (error) {
        *error = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey : @"invalid data"}];
    }
    
    return nil;
}

@end
