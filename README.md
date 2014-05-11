#### Strict framework for mapping between NSDictionary and strongly typed objects

Let's say we have User and Address models, represented by the following interfaces:

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
@interface Address
@property(nonatomic, copy) NSString *city;
@property(nonatomic, copy) NSString *street;
@property(nonatomic, assign) int houseNumber;
@end
```

We also have a dictionary, which was probably loaded from the web or disk:

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

Now, to transform the dictionary into strong-typed User model we need to create two mappings: for User model and for Address model.  
Mapping is a set of rules, describing which properties should be mapped and how to map a non-trivial one.

```objc
ESObjectMapping *userMapping = [[ESObjectMapping alloc] initWithModelClass:[User class]];

// only specifies properties are mapped
[userMapping mapProperties:@[@"name", @"age", @"cash", @"score"]];

// destination key can be different from the source one
[[userMapping mapKeyPath:@"id"] setDestinationKey:@"identifier"];

// transformer can be provide to create object from source data
[userMapping mapKeyPath:@"lastVisited" 
   withValueTransformer:(id <ESObjectValueTransformerProtocol>)dateTransformer];

[userMapping mapKeyPath:@"address" 
             withConfig:[ESObjectsConstructorConfig objectWithMapping:addressMapping]];
```

```objc
ESObjectMapping *addressMapping = [[ESObjectMapping alloc] initWithModelClass:[Address class]];

[addressMapping mapProperties:@[@"city", @"street", @"houseNumber"]];
```

```objc
ESObjectsConstructor *objectsConstructor = [[ESObjectsConstructor alloc] init];
NSError *error = nil;
User *user = [objectsConstructor mapData:arrayOrDictionary 
                              withConfig:[ESObjectsConstructorConfig objectWithMapping:userMapping] 
                                   error:&error];
```

The framework inspects the model and check types of the values from the source data.   
All properties specified in the mapping config must present in the source data.
