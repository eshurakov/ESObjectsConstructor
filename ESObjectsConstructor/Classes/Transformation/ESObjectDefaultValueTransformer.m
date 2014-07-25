//
//  ESObjectDefaultValueTransformer.m
//
//  Created by Evgeny Shurakov on 17.04.14.
//  Copyright (c) 2014 Evgeny Shurakov. All rights reserved.
//

#import "ESObjectDefaultValueTransformer.h"

@implementation ESObjectDefaultValueTransformer
{
    NSNumberFormatter *_numberFormatter;
}

- (id)trasformValue:(id)value toClass:(Class)class error:(NSError *__autoreleasing *)error {
    if ([value isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    if ([value isKindOfClass:class]) {
        return value;
    }
    
    id result = nil;
    
    if (!class) {
        result = value;
    }
    
    if ([class isEqual:[NSString class]]) {
        if ([value respondsToSelector:@selector(stringValue)]) {
            result = [value stringValue];
        }
    } else if ([class isEqual:[NSNumber class]] && [value isKindOfClass:[NSString class]]) {
        if (_numberFormatter == nil) {
            _numberFormatter = [[NSNumberFormatter alloc] init];
            [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [_numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        }
        
        result = [_numberFormatter numberFromString:value];
        
    } else if ([class isEqual:[NSDecimalNumber class]] && [value isKindOfClass:[NSString class]]) {
        result = [NSDecimalNumber decimalNumberWithString:value];
        if ([result isEqual:[NSDecimalNumber notANumber]]) {
            result = nil;
        }
        
    } else if ([class isEqual:[NSDate class]] && [value isKindOfClass:[NSNumber class]]) {
        result = [NSDate dateWithTimeIntervalSince1970:([value longLongValue] / 1000.0)];
    }
    
    if (!result && error) {
        *error = [NSError errorWithDomain:@""
                                     code:0
                                 userInfo:@{NSLocalizedDescriptionKey : @"can't convert value"}];
    }
    
    return result;
}

@end
