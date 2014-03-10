//
//  ESObjectProperty.h
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ESObjectPropertyType) {
    ESObjectPropertyTypeUnknown = 0,
    ESObjectPropertyTypeID,
    ESObjectPropertyTypeChar,
    ESObjectPropertyTypeInt,
    ESObjectPropertyTypeShort,
    ESObjectPropertyTypeLong,
    ESObjectPropertyTypeLongLong,
    ESObjectPropertyTypeUnsignedChar,
    ESObjectPropertyTypeUnsignedInt,
    ESObjectPropertyTypeUnsignedShort,
    ESObjectPropertyTypeUnsignedLong,
    ESObjectPropertyTypeUnsignedLongLong,
    ESObjectPropertyTypeFloat,
    ESObjectPropertyTypeDouble
};

@interface ESObjectProperty : NSObject

- (instancetype)initWithName:(NSString *)name;

@property(nonatomic, copy, readonly) NSString *name;
@property(nonatomic, assign) ESObjectPropertyType type;
@property(nonatomic, assign) Class propertyClass;
@property(nonatomic, assign, getter = isDynamic) BOOL dynamic;
@property(nonatomic, assign, getter = isReadonly) BOOL readonly;
@property(nonatomic, assign, readonly, getter = isPrimitive) BOOL primitive;

@property(nonatomic, assign) SEL getter;
@property(nonatomic, assign) SEL setter;

@end
