//
//  ESObjectsConstructorTests.m
//
//  Created by Evgeny Shurakov.
//  Copyright (c) Evgeny Shurakov. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ESObjectsConstructor.h"
#import "ESObjectsConstructorConfig.h"
#import "ESObjectMapping.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

@interface TestProductModel : NSObject
@property(nonatomic, strong) NSString *stringField;
@property(nonatomic, strong) NSNumber *numberField;
@property(nonatomic, strong) NSDecimalNumber *decimalField;
@property(nonatomic, assign) double doubleField;
@property(nonatomic, strong) TestProductModel *testModel;
@end

@implementation TestProductModel

@end


@interface ESObjectsConstructorTests : XCTestCase
{
    ESObjectsConstructor *_objectsConstructor;
}

@end

@implementation ESObjectsConstructorTests

- (void)setUp {
    [super setUp];
    
    _objectsConstructor = [[ESObjectsConstructor alloc] init];
}

- (void)testFailIfObjectDoesntHaveRequiredProperty {
    NSDictionary *json = @{@"unknownField": @"test"};
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:[json allKeys]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[[ESObjectsConstructorConfig alloc] initWithType:ESObjectsConstructorConfigObject objectMapping:config] error:&error];
    assertThat(model, nilValue());
    assertThat(error.domain, equalTo(ESObjectsConstructorErrorDomain));
    assertThatInteger(error.code, equalToInteger(ESObjectsConstructorUnknownProperty));
}

- (void)testFailMissingFieldInJSON {
    NSDictionary *json = @{@"stringField": @"test"};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:@[@"stringField", @"numberField", @"doubleField"]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[[ESObjectsConstructorConfig alloc] initWithType:ESObjectsConstructorConfigObject objectMapping:config] error:&error];
    assertThat(model, nilValue());
    assertThat(error.domain, equalTo(ESObjectsConstructorErrorDomain));
    assertThatInteger(error.code, equalToInteger(ESObjectsConstructorMissingValue));
}

- (void)testFailInvalidData {
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:[NSSet set] withConfig:[[ESObjectsConstructorConfig alloc] initWithType:ESObjectsConstructorConfigObject objectMapping:config] error:&error];
    assertThat(model, nilValue());
    assertThat(error.domain, equalTo(ESObjectsConstructorErrorDomain));
    assertThatInteger(error.code, equalToInteger(ESObjectsConstructorInvalidData));
}

- (void)testFailNilData {
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:nil withConfig:[[ESObjectsConstructorConfig alloc] initWithType:ESObjectsConstructorConfigObject objectMapping:config] error:&error];
    assertThat(model, nilValue());
    assertThat(error.domain, equalTo(ESObjectsConstructorErrorDomain));
    assertThatInteger(error.code, equalToInteger(ESObjectsConstructorInvalidData));
}

- (void)testFailOneOfObjectsOfArray {
    NSArray *json = @[
                      @{@"stringField" : @"test1"},
                      @{},
                      @{@"stringField" : @"test3"},
                      ];
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:@[@"stringField"]];
    
    NSError *error = nil;
    NSArray *results = [_objectsConstructor mapData:json withConfig:[[ESObjectsConstructorConfig alloc] initWithType:ESObjectsConstructorConfigCollection objectMapping:config] error:&error];
    assertThat(error.domain, equalTo(ESObjectsConstructorErrorDomain));
    assertThatInteger(error.code, equalToInteger(ESObjectsConstructorMissingValue));
    
    assertThatUnsignedInteger([results count], equalToUnsignedInteger(2));
    
    [self testFields:@{@"stringField" : @"test1"} inModel:results[0]];
    [self testFields:@{@"stringField" : @"test3"} inModel:results[1]];
}

- (void)testDirectMapping {
    NSDictionary *json = @{@"stringField": @"test",
                           @"numberField" : @2.4535,
                           @"doubleField" : @3.145142342};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:[json allKeys]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[[ESObjectsConstructorConfig alloc] initWithType:ESObjectsConstructorConfigObject objectMapping:config] error:&error];
    assertThat(error, nilValue());
    [self testFields:json inModel:model];
}

- (void)testCustomMapping {
    NSDictionary *json = @{@"string_field": @"test",
                           @"number_field" : @2.4535,
                           @"double_field" : @3.145142342};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapKeyPath:@"string_field" toProperty:@"stringField"];
    [config mapKeyPath:@"number_field" toProperty:@"numberField"];
    [config mapKeyPath:@"double_field" toProperty:@"doubleField"];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[[ESObjectsConstructorConfig alloc] initWithType:ESObjectsConstructorConfigObject objectMapping:config] error:&error];
    assertThat(error, nilValue());
    [self testFields:@{@"stringField": @"test",
                       @"numberField" : @2.4535,
                       @"doubleField" : @3.145142342}
             inModel:model];
}

- (void)testStringToNumberConversion {
    NSDictionary *json = @{@"numberField" : @"2.4535",
                           @"doubleField" : @"3.145142342",
                           @"decimalField" : @"129.5746204"};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:[json allKeys]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[[ESObjectsConstructorConfig alloc] initWithType:ESObjectsConstructorConfigObject objectMapping:config] error:&error];
    assertThat(error, nilValue());
    
    NSDictionary *reference = @{@"numberField" : @2.4535,
                                @"doubleField" : @3.145142342,
                                @"decimalField": [NSDecimalNumber decimalNumberWithString:@"129.5746204"]};
    [self testFields:reference inModel:model];
}

- (void)testInvalidStringToNumberConversion {
    NSDictionary *json = @{@"numberField" : @"invalid number"};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:[json allKeys]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[[ESObjectsConstructorConfig alloc] initWithType:ESObjectsConstructorConfigObject objectMapping:config] error:&error];
    assertThat(model, nilValue());
    
    assertThat(error.domain, equalTo(ESObjectsConstructorErrorDomain));
    assertThatInteger(error.code, equalToInteger(ESObjectsConstructorInvalidData));
}

- (void)testInvalidStringToDoubleConversion {
    NSDictionary *json = @{@"doubleField" : @"invalid number"};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:[json allKeys]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[[ESObjectsConstructorConfig alloc] initWithType:ESObjectsConstructorConfigObject objectMapping:config] error:&error];
    assertThat(model, nilValue());
    
    assertThat(error.domain, equalTo(ESObjectsConstructorErrorDomain));
    assertThatInteger(error.code, equalToInteger(ESObjectsConstructorInvalidData));
}

- (void)testInvalidStringToDecimalConversion {
    NSDictionary *json = @{@"decimalField" : @"invalid number"};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:[json allKeys]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[[ESObjectsConstructorConfig alloc] initWithType:ESObjectsConstructorConfigObject objectMapping:config] error:&error];
    assertThat(model, nilValue());
    
    assertThat(error.domain, equalTo(ESObjectsConstructorErrorDomain));
    assertThatInteger(error.code, equalToInteger(ESObjectsConstructorInvalidData));
}

- (void)testForeignAttributes {
    NSDictionary *json = @{@"numberField" : @2.4535,
                           @"doubleField" : @3.145142342,
                           @"testModel" : @{@"stringField": @"hello"}
                           };
    ESObjectMapping *foreignConfig = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [foreignConfig mapProperties:@[@"stringField"]];
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:@[@"numberField", @"doubleField"]];
    [config mapKeyPath:@"testModel" toProperty:@"testModel" config:[[ESObjectsConstructorConfig alloc] initWithType:ESObjectsConstructorConfigObject objectMapping:foreignConfig]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[[ESObjectsConstructorConfig alloc] initWithType:ESObjectsConstructorConfigObject objectMapping:config] error:&error];
    assertThat(error, nilValue());
    
    NSDictionary *reference = @{@"numberField" : @2.4535,
                                @"doubleField" : @3.145142342};
    [self testFields:reference inModel:model];
    
    [self testFields:@{@"stringField": @"hello"} inModel:model.testModel];
}

- (void)testOptionalJSONFields {
    NSDictionary *json = @{@"stringField": @"test"};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:@[@"stringField", @"numberField?", @"doubleField?"]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[[ESObjectsConstructorConfig alloc] initWithType:ESObjectsConstructorConfigObject objectMapping:config] error:&error];
    
    assertThat(error, nilValue());
    [self testFields:@{@"stringField": @"test"} inModel:model];
}

#pragma mark -

- (void)testFields:(NSDictionary *)fields inModel:(TestProductModel *)model {
    assertThat([model class], equalTo([TestProductModel class]));
    
    [fields enumerateKeysAndObjectsUsingBlock:^(id key, id referenceValue, BOOL *stop) {
        id value = [model valueForKey:key];
        assertThat(value, equalTo(referenceValue));
    }];
}

@end
