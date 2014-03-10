//
//  ESObjectProperty.m
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import "ESObjectProperty.h"

@implementation ESObjectProperty

- (instancetype)init {
    return [self initWithName:nil];
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        if (!name) {
            return nil;
        }
        _name = name;
    }
    return self;
}

- (BOOL)isPrimitive {
    return self.type > ESObjectPropertyTypeID;
}

- (NSString *)description {
    NSString *result = [NSString stringWithFormat:@"%@", _name];
    if (self.dynamic) {
        result = [result stringByAppendingString:@", dynamic"];
    }
    if (self.readonly) {
        result = [result stringByAppendingString:@", readonly"];
    }
    return result;
}

@end
