//
//  ESPropertyInspector.h
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESObjectProperty;

@interface ESPropertyInspector : NSObject

+ (NSArray *)propertiesForClass:(Class)class;
+ (ESObjectProperty *)propertyWithName:(NSString *)properyName fromClass:(Class)class;

@end
