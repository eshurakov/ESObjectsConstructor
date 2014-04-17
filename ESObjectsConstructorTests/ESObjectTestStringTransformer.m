//
//  ESObjectTestStringTransformer.m
//
//  Created by Evgeny Shurakov on 17.04.14.
//  Copyright (c) 2014 Evgeny Shurakov. All rights reserved.
//

#import "ESObjectTestStringTransformer.h"

@implementation ESObjectTestStringTransformer

- (id)trasformValue:(id)value toClass:(Class)class {
    if (![class isEqual:[NSString class]]) {
        return nil;
    }
    
    if (![value isKindOfClass:class]) {
        return nil;
    }
    
    return [value stringByAppendingString:@"-test"];
}

@end
