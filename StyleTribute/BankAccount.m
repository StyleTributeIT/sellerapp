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
    NSLog(@"%@",dict);
    
    BankAccount* account = [BankAccount new];
    
    account.accountNumber = [[self class] parseString:@"bank_account" fromDict:dict];
    account.beneficiary = [[self class] parseString:@"bank_beneficiary" fromDict:dict];
    account.branchCode = [[self class] parseString:@"bank_branch_code" fromDict:dict];
    account.bankCode = [[self class] parseString:@"bank_code" fromDict:dict];
    account.bankName = [[self class] parseString:@"bank_name" fromDict:dict];
    
    return account;
}

@end
