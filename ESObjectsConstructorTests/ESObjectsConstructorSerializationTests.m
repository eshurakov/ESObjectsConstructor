//
//  ESObjectsConstructorSerializationTests.m
//
//  Created by Evgeny Shurakov on 2014/04/27.
//  Copyright (c) 2014 Evgeny Shurakov. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ESObjectsConstructor.h"
#import "ESObjectsConstructorConfig.h"

#import "ESObjectSerializationMapping.h"

#import "TestProductModel.h"
#import "TestUserModel.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

@interface ESObjectsConstructorSerializationTests : XCTestCase
{
    ESObjectsConstructor *_objectsConstructor;
}

@end

@implementation ESObjectsConstructorSerializationTests

- (void)setUp {
    [super setUp];
    
    _objectsConstructor = [[ESObjectsConstructor alloc] init];
}

- (void)testExample {
    TestUserModel *user = [[TestUserModel alloc] init];
    user.email = @"test1";
    user.age = @(2341.10);
    user.balance = [NSDecimalNumber decimalNumberWithString:@"95234.32345"];
    user.score = 5.4432;
    
    ESObjectSerializationMapping *mapping = [[ESObjectSerializationMapping alloc] initWithModelClass:[TestUserModel class]];
    [mapping mapProperties:@[@"email", @"age", @"balance", @"score"]];
    
    NSError *error = nil;
    NSDictionary *result = [_objectsConstructor serializeObject:user
                                                     withConfig:[ESObjectsConstructorConfig objectWithMapping:mapping]
                                                          error:&error];
    
    assertThat(error, nilValue());
    assertThat(result, equalTo(@{
                                 @"email": @"test1",
                                 @"age": @(2341.10),
                                 @"balance" : @"95234.32345",
                                 @"score" : @(5.4432)
                                 }));
}

@end
