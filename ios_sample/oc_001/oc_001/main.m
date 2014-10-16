//
//  main.m
//  oc_001
//
//  Created by Ming Wang on 9/20/14.
//  Copyright (c) 2014 wangming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

int main(int argc, const char * argv[]) {
    
    Person *newPerson = [[Person alloc] init];
    newPerson.firstName = @"mmm";
    NSString *firstName = newPerson.firstName;
    NSLog(@"newPerson's firstName = %@", firstName);
    return 0;
}
