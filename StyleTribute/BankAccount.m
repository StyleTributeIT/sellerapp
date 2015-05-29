//
//  BankAccount.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 29/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BankAccount.h"

@implementation BankAccount

+(instancetype)parseFromJson:(NSDictionary*)dict {
    BankAccount* account = [BankAccount new];
    
    account.accountNumber = [[self class] parseString:@"bankaccountnumber" fromDict:dict];
    account.beneficiary = [[self class] parseString:@"bankbeneficiary" fromDict:dict];
    account.branchCode = [[self class] parseString:@"bankbranchcode" fromDict:dict];
    account.bankCode = [[self class] parseString:@"bankcode" fromDict:dict];
    account.bankName = [[self class] parseString:@"bankname" fromDict:dict];
    
    return account;
}

@end
