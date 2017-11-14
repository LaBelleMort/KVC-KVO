//
//  PQCAccount.h
//  KVC&KVO
//
//  Created by 满脸胡茬的怪蜀黍 on 2017/11/6.
//  Copyright © 2017年 满脸胡茬的怪蜀黍. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PQCAccount : NSObject

@property(nonatomic, assign) float balance;
@property(nonatomic, strong) NSMutableArray *array;

- (void)addItem;

- (void)addItemObserver ;

- (void)removeItemObserver;

@end
