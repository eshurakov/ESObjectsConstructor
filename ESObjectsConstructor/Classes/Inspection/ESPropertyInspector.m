//
//  ESPropertyInspector.m
//
//  Created by Evgeny Shurakov
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//
//  Some code for this class is taken from RestKit
//  https://github.com/RestKit/RestKit

#import "ESPropertyInspector.h"
#import "ESObjectProperty.h"

#import <objc/message.h>

static NSMutableDictionary *propertyInspectorSingleClassCache = nil;
static NSMutableDictionary *propertyInspectorChainCache = nil;

@implementation ESPropertyInspector

+ (void)initialize {
    propertyInspectorSingleClassCache = [[NSMutableDictionary alloc] init];
    propertyInspectorChainCache = [[NSMutableDictionary alloc] init];
}

+ (ESObjectProperty *)propertyWithName:(NSString *)properyName fromClass:(Class)class {
    NSArray *properties = [self propertiesForClass:class];
    for (ESObjectProperty *property in properties) {
        if ([property.name isEqualToString:properyName]) {
            return property;
        }
    }
    return nil;
}

+ (NSArray *)propertiesForClass:(Class)class {
    return [self propertiesForClass:class includeSuperclasses:YES];
}

+ (NSArray *)propertiesForClass:(Class)class includeSuperclasses:(BOOL)includeSuperclasses {
    static dispatch_queue_t privateQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        privateQueue = dispatch_queue_create("ESPropertyInspector", DISPATCH_QUEUE_SERIAL);
    });
    
    if (!class) {
        return nil;
    }
    
    __block NSArray *properties = nil;
    
    dispatch_sync(privateQueue, ^{
        if (includeSuperclasses) {
            properties = propertyInspectorChainCache[(id)class];
        } else {
            properties = propertyInspectorSingleClassCache[(id)class];
        }
        
        if (!properties) {
            properties = [self _propertiesForClass:class includeSuperclasses:includeSuperclasses];
            if (properties) {
                if (includeSuperclasses) {
                    propertyInspectorChainCache[(id)class] = properties;
                } else {
                    propertyInspectorSingleClassCache[(id)class] = properties;
                }
            }
        }
    });
    
    return properties;
}

+ (NSMutableArray *)_propertiesForClass:(Class)class includeSuperclasses:(BOOL)includeSuperclasses {
    static NSMutableSet *breakClasses = nil;
    if (!breakClasses) {
        breakClasses = [NSMutableSet setWithCapacity:2];
        [breakClasses addObject:[NSObject class]];
        Class managedObjectClass = NSClassFromString(@"NSManagedObject");
        if (managedObjectClass) {
            [breakClasses addObject:managedObjectClass];
        }
    }
    
    NSMutableArray *properties = [[NSMutableArray alloc] init];
    
    Class currentClass = class;
    while (currentClass != nil) {
        if ([breakClasses containsObject:currentClass]) {
            break;
        }
        
        // Get the raw list of properties
        unsigned int outCount = 0;
        objc_property_t *propList = class_copyPropertyList(currentClass, &outCount);
        
        // Collect the property names
        for (typeof(outCount) i = 0; i < outCount; i++) {
            objc_property_t *prop = propList + i;
            const char *propName = property_getName(*prop);
            
            if (strcmp(propName, "_mapkit_hasPanoramaID") == 0) {
                continue;
            }
            
            const char *attr = property_getAttributes(*prop);
            if (!attr) {
                continue;
            }
            
            NSString *propNameObj = [[NSString alloc] initWithCString:propName
                                                             encoding:NSUTF8StringEncoding];
            NSString *attrObj = [[NSString alloc] initWithCString:attr
                                                         encoding:NSUTF8StringEncoding];
            
            ESObjectProperty *property = [[self class] propertyWithName:propNameObj
                                                             attributes:attrObj];
            
            if (property) {
                [properties addObject:property];
            }
        }
        
        free(propList);
        
        if (!includeSuperclasses) {
            break;
        }
        
        currentClass = [currentClass superclass];
    }
    
    return properties;
}

//R
//The property is read-only (readonly).
//C
//The property is a copy of the value last assigned (copy).
//&
//The property is a reference to the value last assigned (retain).
//N
//The property is non-atomic (nonatomic).
//G<name>
//The property defines a custom getter selector name. The name follows the G (for example, GcustomGetter,).
//S<name>
//The property defines a custom setter selector name. The name follows the S (for example, ScustomSetter:,).
//D
//The property is dynamic (@dynamic).
//W
//The property is a weak reference (__weak).
//P
//The property is eligible for garbage collection.
//t<encoding>
//Specifies the type using old-style encoding.

+ (ESObjectProperty *)propertyWithName:(NSString *)name attributes:(NSString *)attributes {
    ESObjectProperty *property = [[ESObjectProperty alloc] initWithName:name];
    NSArray *attributesComponents = [attributes componentsSeparatedByString:@","];
    for (NSString *attributeComponent in attributesComponents) {
        if ([attributeComponent length] > 1) {
            if ([attributeComponent hasPrefix:@"T"]) {
                const char *type = [attributeComponent UTF8String];
                ++type;
                
                switch (type[0]) {
                    case '@': {
                        char *openingQuoteLoc = strchr(type, '"');
                        if (openingQuoteLoc) {
                            char *closingQuoteLoc = strchr(openingQuoteLoc+1, '"');
                            if (closingQuoteLoc) {
                                size_t classNameStrLen = closingQuoteLoc-openingQuoteLoc;
                                char className[classNameStrLen];
                                memcpy(className, openingQuoteLoc+1, classNameStrLen-1);
                                // Null-terminate the array to stringify
                                className[classNameStrLen-1] = '\0';
                                property.propertyClass = objc_getClass(className);
                            }
                        }
                        property.type = ESObjectPropertyTypeID;
                        break;
                    }

                    case 'c': // char
                        property.type = ESObjectPropertyTypeChar;
                        break;
                    case 'C': // unsigned char
                        property.type = ESObjectPropertyTypeUnsignedChar;
                        break;
                    case 's': // short
                        property.type = ESObjectPropertyTypeShort;
                        break;
                    case 'S': // unsigned short
                        property.type = ESObjectPropertyTypeUnsignedShort;
                        break;
                    case 'i': // int
                        property.type = ESObjectPropertyTypeInt;
                        break;
                    case 'I': // unsigned int
                        property.type = ESObjectPropertyTypeUnsignedInt;
                        break;
                    case 'l': // long
                        property.type = ESObjectPropertyTypeLong;
                        break;
                    case 'L': // unsigned long
                        property.type = ESObjectPropertyTypeUnsignedLong;
                        break;
                    case 'q': // long long
                        property.type = ESObjectPropertyTypeLongLong;
                        break;
                    case 'Q': // unsigned long long
                        property.type = ESObjectPropertyTypeUnsignedLongLong;
                        break;
                    case 'f': // float
                        property.type = ESObjectPropertyTypeFloat;
                        break;
                    case 'd': // double
                        property.type = ESObjectPropertyTypeDouble;
                        break;
                    case 'B': // bool
                        property.type = ESObjectPropertyTypeBool;
                        break;

                    case '{': // struct
                    case 'b': // bitfield
                    case '(': // union                        
                    case '[': // c array
                    case '^': // pointer
                    case 'v': // void
                    case '*': // char *
                    case '#': // Class
                    case ':': // selector
                    case '?': // unknown type (function pointer, etc)
                    default:
                        break;
                }
            } else if ([attributeComponent hasPrefix:@"G"]) {
                property.getter = NSSelectorFromString([attributeComponent substringFromIndex:1]);
            } else if ([attributeComponent hasPrefix:@"S"]) {
                property.setter = NSSelectorFromString([attributeComponent substringFromIndex:1]);
            }
        } else if ([attributeComponent isEqualToString:@"R"]) {
            property.readonly = YES;
        } else if ([attributeComponent isEqualToString:@"D"]) {
            property.dynamic = YES;
        }
    }
    
    if (!property.getter) {
        property.getter = NSSelectorFromString(property.name);
    }
    
    if (!property.setter && !property.readonly) {
        property.setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [[property.name substringToIndex:1] uppercaseString], [property.name substringFromIndex:1]]);
    }
    
    return property;
}

@end
