//
//  TestUserModel.h
//
//  Created by Evgeny Shurakov on 2014/04/27.
//  Copyright (c) 2014 Evgeny Shurakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestUserModel : NSObject

@property(nonatomic, copy) NSString *email;
@property(nonatomic, strong) NSNumber *age;
@property(nonatomic, strong) NSDecimalNumber *balance;
@property(nonatomic, assign) double score;
@property(nonatomic, assign) BOOL verified;

@end
