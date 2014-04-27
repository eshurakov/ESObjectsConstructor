//
//  ESObjectDefaultValueSerializer.m
//
//  Created by Evgeny Shurakov on 2014/04/27.
//  Copyright (c) 2014 Evgeny Shurakov. All rights reserved.
//

#import "ESObjectDefaultValueSerializer.h"

@implementation ESObjectDefaultValueSerializer

- (id)trasformValue:(id)value toClass:(Class)class {
    static NSArray *baseClasses = nil;
    if (!baseClasses) {
        baseClasses = @[[NSString class], [NSNumber class], [NSDictionary class], [NSArray class]];
    }
    
    if (!value) {
        return nil;
    }
    
    if ([value isKindOfClass:[NSDecimalNumber class]]) {
        return [value descriptionWithLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    } else if ([value isKindOfClass:[NSDate class]]) {
        return @([value timeIntervalSince1970] * 1000);
    }
    
    for (Class baseClass in baseClasses) {
        if ([value isKindOfClass:baseClass]) {
            return value;
        }
    }
    
    return nil;
}

@end
