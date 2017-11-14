//
//  PQCPeople.h
//  KVC&KVO
//
//  Created by 满脸胡茬的怪蜀黍 on 2017/11/6.
//  Copyright © 2017年 满脸胡茬的怪蜀黍. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PQCAccount.h"

@interface PQCPeople : NSObject {
    @private
    int age;
}

@property(nonatomic, copy) NSString *namestr;
@property(nonatomic,retain) PQCAccount *account;

- (void)showMessage;
- (void)showMess;
- (void)printUserInfo;
- (void)setNamestr:(NSString *)namestr;

@end

@interface TwoTimesArray : NSObject
-(void)incrementCount;
-(NSUInteger)countOfNumbers;
-(id)objectInNumbersAtIndex:(NSUInteger)index;
@end

