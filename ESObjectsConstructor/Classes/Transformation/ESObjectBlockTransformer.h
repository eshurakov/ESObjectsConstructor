//
//  ESObjectBlockTransformer.h
//
//  Created by Evgeny Shurakov on 2014/04/29.
//  Copyright (c) 2014 Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESObjectValueTransformerProtocol.h"

typedef id (^ESObjectBlockTransformerBlock)(id value, Class destinationClass, NSError **error);

@interface ESObjectBlockTransformer : NSObject <ESObjectValueTransformerProtocol>

- (instancetype)initWithBlock:(ESObjectBlockTransformerBlock)block;

@end
