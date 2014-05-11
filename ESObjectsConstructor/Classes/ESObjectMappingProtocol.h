//
//  ESObjectMappingProtocol.h
//
//  Created by Evgeny Shurakov on 2014/05/01.
//  Copyright (c) 2014 Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESObjectPropertyMapping;
@class ESObjectProperty;

@protocol ESObjectValueTransformerProtocol;

@protocol ESObjectMappingProtocol <NSObject>
@required
- (id)newResultObject;
- (BOOL)canMapObjectOfClass:(Class)objectClass;

- (id <ESObjectValueTransformerProtocol>)valueTransformer;

- (void)enumerateMappingsWithBlock:(void (^)(ESObjectPropertyMapping *mapping, ESObjectProperty *property, BOOL *stop))block;
@end
