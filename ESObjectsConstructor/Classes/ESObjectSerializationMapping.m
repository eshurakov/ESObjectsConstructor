//
//  ESObjectSerializationMapping.m
//
//  Created by Evgeny Shurakov on 2014/04/27.
//  Copyright (c) 2014 Evgeny Shurakov. All rights reserved.
//

#import "ESObjectSerializationMapping.h"
#import "ESObjectProperty.h"
#import "ESObjectPropertyMapping.h"

#import "ESObjectValueTransformerProtocol.h"
#import "ESObjectDefaultValueSerializer.h"

@implementation ESObjectSerializationMapping
{
    ESObjectDefaultValueSerializer *_valueSerializer;
}

- (ESObjectProperty *)propertyForMapping:(ESObjectPropertyMapping *)mapping {
    NSParameterAssert(mapping);
    ESObjectProperty *property = [[ESObjectProperty alloc] initWithName:mapping.destinationKey];
    property.type = ESObjectPropertyTypeID;
    return property;
}

#pragma mark - ESObjectMappingProtocol

- (id)newResultObject {
    return [[NSMutableDictionary alloc] init];
}

- (BOOL)canMapObjectOfClass:(Class)objectClass {
    return (self.modelClass && [objectClass isSubclassOfClass:self.modelClass]);
}

- (id <ESObjectValueTransformerProtocol>)valueTransformer {
    if (_valueSerializer == nil) {
        _valueSerializer = [[ESObjectDefaultValueSerializer alloc] init];
    }
    
    return _valueSerializer;
}

@end
