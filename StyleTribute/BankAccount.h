//
//  BankAccount.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 29/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseModel.h"

@interface BankAccount : BaseModel

@property NSString* accountNumber;
@property NSString* beneficiary;
@property NSString* branchCode;
@property NSString* bankCode;
@property NSString* bankName;

+(instancetype)parseFromJson:(NSDictionary*)dict;

@end
