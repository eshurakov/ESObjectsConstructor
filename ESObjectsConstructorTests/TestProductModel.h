//
//  TestProductModel.h
//
//  Created by Evgeny Shurakov on 2014/04/27.
//  Copyright (c) 2014 Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestProductModel : NSObject

@property(nonatomic, strong) NSString *stringField;
@property(nonatomic, strong) NSNumber *numberField;
@property(nonatomic, strong) NSDecimalNumber *decimalField;
@property(nonatomic, assign) double doubleField;
@property(nonatomic, strong) TestProductModel *testModel;
@property(nonatomic, strong) NSDate *dateField;
@property(nonatomic, assign) BOOL boolField;

@end
