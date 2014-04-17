//
//  ESObjectValueTransformerProtocol.h
//
//  Created by Evgeny Shurakov on 17.04.14.
//  Copyright (c) 2014 Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ESObjectValueTransformerProtocol <NSObject>
@required
- (id)trasformValue:(id)value toClass:(Class)class;
@end
