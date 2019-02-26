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
    NSDictionary *dicttemp = [dict valueForKey:@"data"];
  //  NSLog(@"%@",dicttemp);
    BankAccount* account = [BankAccount new];
    
    account.accountNumber = [[self class] parseString:@"bank_account" fromDict:dicttemp];
    account.beneficiary = [[self class] parseString:@"beneficiary_name" fromDict:dicttemp];
    account.branchCode = [[self class] parseString:@"branch_code" fromDict:dicttemp];
    account.bankCode = [[self class] parseString:@"bank_code" fromDict:dicttemp];
    account.bankName = [[self class] parseString:@"bank_name" fromDict:dicttemp];
    
    return account;
}

@end
