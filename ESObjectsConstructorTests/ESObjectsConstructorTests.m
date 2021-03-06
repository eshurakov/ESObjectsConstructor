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
#import "ESObjectPropertyMapping.h"

#import "ESObjectDefaultValueTransformer.h"
#import "ESObjectTestStringTransformer.h"

#import "TestProductModel.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>


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
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    
    assertThat(model, nilValue());
    
    assertThat(error.domain, equalTo(ESObjectsConstructorErrorDomain));
    assertThatInteger(error.code, equalToInteger(ESObjectsConstructorUnknownProperty));
}

- (void)testFailMissingFieldInJSON {
    NSDictionary *json = @{@"stringField": @"test"};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:@[@"stringField", @"numberField", @"doubleField"]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    
    assertThat(model, nilValue());
    
    assertThat(error.domain, equalTo(ESObjectsConstructorErrorDomain));
    assertThatInteger(error.code, equalToInteger(ESObjectsConstructorInvalidData));
}

- (void)testFailMissingGenericClassFieldInJSON {
    NSDictionary *json = @{};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:@[@"idField"]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    
    assertThat(model, nilValue());
    
    assertThat(error.domain, equalTo(ESObjectsConstructorErrorDomain));
    assertThatInteger(error.code, equalToInteger(ESObjectsConstructorInvalidData));
}

- (void)testFailInvalidData {
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:[NSSet set] withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    
    assertThat(model, nilValue());
    
    assertThat(error.domain, equalTo(ESObjectsConstructorErrorDomain));
    assertThatInteger(error.code, equalToInteger(ESObjectsConstructorInvalidData));
}

- (void)testFailNilData {
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:nil withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    
    assertThat(model, nilValue());
    
    assertThat(error.domain, equalTo(ESObjectsConstructorErrorDomain));
    assertThatInteger(error.code, equalToInteger(ESObjectsConstructorInvalidData));
}

- (void)testFailOneOfObjectsOfArray {
    NSArray *json = @[
                      @{@"stringField" : @"test1"},
                      @{},
                      ];
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:@[@"stringField"]];
    
    NSError *error = nil;
    NSArray *results = [_objectsConstructor mapData:json
                                         withConfig:[ESObjectsConstructorConfig collectionWithObjectMapping:config]
                                              error:&error];
    assertThat(error.domain, equalTo(ESObjectsConstructorErrorDomain));
    assertThatInteger(error.code, equalToInteger(ESObjectsConstructorInvalidData));
    
    assertThat(results, nilValue());
}

- (void)testDirectMapping {
    NSDictionary *json = @{@"stringField": @"test",
                           @"numberField" : @2.4535,
                           @"doubleField" : @3.145142342,
                           @"boolField" : @(YES)};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:[json allKeys]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    assertThat(error, nilValue());
    [self testFields:json inModel:model];
}

- (void)testNullMapping {
    NSDictionary *json = @{@"stringField": [NSNull null],
                           @"numberField" : [NSNull null],
                           @"doubleField" : [NSNull null],
                           @"boolField" : [NSNull null]};
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:[json allKeys]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    assertThat(error, nilValue());
    assertThat(model.stringField, nilValue());
    assertThat(model.numberField, nilValue());
    assertThatDouble(model.doubleField, equalToDouble(0.0));
    assertThatBool(model.boolField, equalToBool(NO));
}

- (void)testNullMappingForForeignAttributes {
    NSDictionary *json = @{@"numberField" : [NSNull null],
                           @"testModel" : [NSNull null]
                           };
    ESObjectMapping *foreignConfig = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [foreignConfig mapProperties:@[@"stringField"]];
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:@[@"numberField"]];
    [config mapKeyPath:@"testModel" withConfig:[ESObjectsConstructorConfig objectWithMapping:foreignConfig]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    assertThat(error, nilValue());
    assertThat(model, notNilValue());
    assertThat(model.numberField, nilValue());
    assertThat(model.testModel, nilValue());
    
    assertThat(model.invocations, containsInAnyOrder(@"numberField=(null)", @"testModel=(null)", nil));
}

- (void)testCustomMapping {
    NSDictionary *json = @{@"string_field": @"test",
                           @"number_field" : @2.4535,
                           @"double_field" : @3.145142342};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [[config mapKeyPath:@"string_field"] setDestinationKey:@"stringField"];
    [[config mapKeyPath:@"number_field"] setDestinationKey:@"numberField"];
    [[config mapKeyPath:@"double_field"] setDestinationKey:@"doubleField"];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
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
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
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
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    assertThat(model, nilValue());
    
    assertThat(error.domain, equalTo(ESObjectsConstructorErrorDomain));
    assertThatInteger(error.code, equalToInteger(ESObjectsConstructorInvalidData));
}

- (void)testInvalidStringToDoubleConversion {
    NSDictionary *json = @{@"doubleField" : @"invalid number"};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:[json allKeys]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    assertThat(model, nilValue());
    
    assertThat(error.domain, equalTo(ESObjectsConstructorErrorDomain));
    assertThatInteger(error.code, equalToInteger(ESObjectsConstructorInvalidData));
}

- (void)testInvalidStringToDecimalConversion {
    NSDictionary *json = @{@"decimalField" : @"invalid number"};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:[json allKeys]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    assertThat(model, nilValue());
    
    assertThat(error.domain, equalTo(ESObjectsConstructorErrorDomain));
    assertThatInteger(error.code, equalToInteger(ESObjectsConstructorInvalidData));
}

- (void)testMillisecondsToDateConversion {
    NSDate *date = [NSDate date];
    long long milliseconds = [date timeIntervalSince1970] * 1000;
    date = [NSDate dateWithTimeIntervalSince1970:milliseconds / 1000.0];
    
    NSDictionary *json = @{@"dateField" : @(milliseconds)};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:[json allKeys]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    assertThat(error, nilValue());
    
    NSDictionary *reference = @{@"dateField" : date};
    [self testFields:reference inModel:model];
}

- (void)testIdField {
    NSDictionary *json = @{@"idField" : @"2.4535"};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:[json allKeys]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    assertThat(error, nilValue());
    assertThat(model.idField, equalTo(@"2.4535"));
}

- (void)testIdFieldAndNullValue {
    NSDictionary *json = @{@"idField" : [NSNull null]};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:[json allKeys]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    assertThat(error, nilValue());
    assertThat(model.invocations, containsInAnyOrder(@"idField=(null)", nil));
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
    [config mapKeyPath:@"testModel" withConfig:[ESObjectsConstructorConfig objectWithMapping:foreignConfig]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    assertThat(error, nilValue());
    
    NSDictionary *reference = @{@"numberField" : @2.4535,
                                @"doubleField" : @3.145142342};
    [self testFields:reference inModel:model];
    
    [self testFields:@{@"stringField": @"hello"} inModel:model.testModel];
}

- (void)testForeignAttributesError {
    NSDictionary *json = @{@"stringField" : @"hello",
                           @"testModel" : @{@"stringFiel": @"world"}
                           };
    ESObjectMapping *foreignConfig = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [foreignConfig mapProperties:@[@"stringField"]];
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:@[@"stringField"]];
    [config mapKeyPath:@"testModel" withConfig:[ESObjectsConstructorConfig objectWithMapping:foreignConfig]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    assertThat(error, notNilValue());
    assertThat(model, nilValue());
}

- (void)testOptionalJSONFields {
    NSDictionary *json = @{@"stringField": @"test", @"dateField" : [NSNull null]};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:@[@"stringField", @"numberField?", @"doubleField?", @"dateField?"]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    
    assertThat(error, nilValue());
    [self testFields:@{@"stringField": @"test"} inModel:model];
    
    assertThat(model.dateField, nilValue());
    assertThat(model.invocations, containsInAnyOrder(@"stringField=test", @"dateField=(null)", nil));
}

- (void)testOptionalJSONFieldWithInvalidValue {
    NSDictionary *json = @{@"doubleField": @"test"};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:@[@"doubleField?"]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    
    assertThat(model, nilValue());
    assertThat(error, notNilValue());
}

- (void)testNestedConfigs {
    NSArray *json = @[
                      @[@{@"stringField" : @"test1"}, @{@"stringField" : @"test3"}],
                      @[],
                      @[@{@"stringField" : @"test2"}],
                      ];
    ESObjectMapping *mapping = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [mapping mapProperties:@[@"stringField"]];
    
    ESObjectsConstructorConfig *config = [ESObjectsConstructorConfig collectionOfCollectionsWithObjectMapping:mapping];
    
    NSError *error = nil;
    NSArray *results = [_objectsConstructor mapData:json withConfig:config error:&error];
    
    assertThat(error, nilValue());
    assertThatUnsignedInteger([results count], equalToUnsignedInteger(3));
    assertThatUnsignedInteger([results[0] count], equalToUnsignedInteger(2));
    assertThatUnsignedInteger([results[1] count], equalToUnsignedInteger(0));
    assertThatUnsignedInteger([results[2] count], equalToUnsignedInteger(1));
    
    [self testFields:@{@"stringField" : @"test1"} inModel:results[0][0]];
    [self testFields:@{@"stringField" : @"test3"} inModel:results[0][1]];
    [self testFields:@{@"stringField" : @"test2"} inModel:results[2][0]];
}

- (void)testValueTransformer {
    NSDictionary *json = @{@"stringField": @"test",
                           @"numberField" : @2.4535,
                           @"doubleField" : @3.145142342};
    
    ESObjectMapping *config = [[ESObjectMapping alloc] initWithModelClass:[TestProductModel class]];
    [config mapProperties:@[@"numberField", @"doubleField"]];
    [config mapKeyPath:@"stringField" withValueTransformer:[[ESObjectTestStringTransformer alloc] init]];
    
    NSError *error = nil;
    TestProductModel *model = [_objectsConstructor mapData:json withConfig:[ESObjectsConstructorConfig objectWithMapping:config] error:&error];
    assertThat(error, nilValue());
    assertThat(model.invocations, containsInAnyOrder(@"stringField=test-test", @"numberField=2.4535", @"doubleField=3.145142342", nil));
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
