//
//  ESObjectDefaultValueSerializer.m
//
//  Created by Evgeny Shurakov on 2014/04/27.
//  Copyright (c) 2014 Evgeny Shurakov. All rights reserved.
//

#import "ESObjectDefaultValueSerializer.h"

@implementation ESObjectDefaultValueSerializer

- (BOOL)acceptNilValue {
    return YES;
}

- (id)trasformValue:(id)value toClass:(Class)class error:(NSError *__autoreleasing *)error {
    static NSArray *baseClasses = nil;
    if (!baseClasses) {
        baseClasses = @[[NSString class], [NSNumber class], [NSDictionary class], [NSArray class]];
    }
    
    if (!value) {
        return [NSNull null];
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
    
    if (error) {
        *error = [NSError errorWithDomain:@""
                                     code:0
                                 userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"'%@' is not one of the classes supported for serialization", [value class]]}];
    }
    
    return nil;
}

@end
