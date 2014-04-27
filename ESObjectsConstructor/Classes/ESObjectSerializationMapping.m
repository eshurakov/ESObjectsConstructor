//
//  ESObjectSerializationMapping.m
//
//  Created by Evgeny Shurakov on 2014/04/27.
//  Copyright (c) 2014 Evgeny Shurakov. All rights reserved.
//

#import "ESObjectSerializationMapping.h"
#import "ESObjectProperty.h"
#import "ESObjectPropertyMapping.h"

@implementation ESObjectSerializationMapping

- (id)newResultObject {
    return [[NSMutableDictionary alloc] init];
}

- (BOOL)canMapObjectOfClass:(Class)objectClass {
    return (self.modelClass && [objectClass isSubclassOfClass:self.modelClass]);
}

- (void)enumerateMappingsWithBlock:(void (^)(ESObjectPropertyMapping *mapping, ESObjectProperty *property, BOOL *stop))block {
    NSParameterAssert(block);
    
    BOOL stop = NO;
    for (ESObjectPropertyMapping *mapping in self.mappings) {
        ESObjectProperty *property = [[ESObjectProperty alloc] initWithName:mapping.destinationKeyPath];
        property.type = ESObjectPropertyTypeID;
        
        block(mapping, property, &stop);
        if (stop) {
            return;
        }
    }
}

@end
