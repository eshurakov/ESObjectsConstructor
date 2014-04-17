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

- (id)trasformValue:(id)value toClass:(Class)class {
    if (!class || [value isKindOfClass:class]) {
        return value;
    }
    
    if ([class isEqual:[NSString class]]) {
        if ([value respondsToSelector:@selector(stringValue)]) {
            return [value stringValue];
        }
    } else if ([class isEqual:[NSNumber class]] && [value isKindOfClass:[NSString class]]) {
        if (_numberFormatter == nil) {
            _numberFormatter = [[NSNumberFormatter alloc] init];
            [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [_numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        }
        
        return [_numberFormatter numberFromString:value];
        
    } else if ([class isEqual:[NSDecimalNumber class]] && [value isKindOfClass:[NSString class]]) {
        NSDecimalNumber *result = [NSDecimalNumber decimalNumberWithString:value];
        if ([result isEqual:[NSDecimalNumber notANumber]]) {
            result = nil;
        }
        return result;
        
    } else if ([class isEqual:[NSDate class]] && [value isKindOfClass:[NSNumber class]]) {
        return [NSDate dateWithTimeIntervalSince1970:([value longLongValue] / 1000.0)];
    }
    
    return nil;
}

@end
