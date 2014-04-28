### Dictionary <-> Strongly-Typed Objects

```objc
@interface Address
@property(nonatomic, copy) NSString *city;
@property(nonatomic, copy) NSString *street;
@property(nonatomic, assign) int houseNumber;
@end
```

```objc
@interface User
@property(nonatomic, copy) NSString *identifier;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, strong) NSNumber *age;
@property(nonatomic, strong) NSDecimalNumber *cash;
@property(nonatomic, assign) double score;
@property(nonatomic, strong) NSDate *lastVisited;
@property(nonatomic, strong) Address *address;
@end
```

```objc
@{
	@"id" : @"4",
	@"name" : @"John",
	@"age" : @(42),
	@"cash" : @"101.01",
	@"score" : @(95.12),
	@"lastVisited" : @(1398716134000),
	@"address" : @{
		@"city" : @"New York",
		@"street" : @"Fifth Avenue",
		@"houseNumber" : @(10)
	}
}
```

```objc
ESObjectMapping *addressMapping = [[ESObjectMapping alloc] initWithModelClass:[Address class]];
[addressMapping mapProperties:@[@"city", @"street", @"houseNumber"]];
```

```objc
ESObjectMapping *userMapping = [[ESObjectMapping alloc] initWithModelClass:[User class]];
[userMapping mapProperties:@[@"name", @"age", @"cash", @"score"]];

[[userMapping mapKeyPath:@"id"] setDestinationKeyPath:@"identifier"];

[userMapping mapKeyPath:@"lastVisited" 
   withValueTransformer:(id <ESObjectValueTransformerProtocol>)dateTransformer];
   
[userMapping mapKeyPath:@"address" 
             withConfig:[ESObjectsConstructorConfig objectWithMapping:addressMapping]];
```

```objc
ESObjectsConstructor *objectsConstructor = [[ESObjectsConstructor alloc] init];
NSError *error = nil;
User *user = [objectsConstructor mapData:arrayOrDictionary 
                              withConfig:[ESObjectsConstructorConfig objectWithMapping:userMapping] 
                                   error:&error];
```
