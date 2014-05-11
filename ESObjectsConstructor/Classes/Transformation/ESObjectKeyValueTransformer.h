//
//  ESObjectKeyValueTransformer.h
//
//  Created by Evgeny Shurakov on 17.04.14.
//  Copyright (c) 2014 Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESObjectValueTransformerProtocol.h"

@interface ESObjectKeyValueTransformer : NSObject <ESObjectValueTransformerProtocol>

- (void)setObject:(id)object forKey:(id<NSCopying>)key;

@end
