//
//  PQCPeople.m
//  KVC&KVO
//
//  Created by 满脸胡茬的怪蜀黍 on 2017/11/6.
//  Copyright © 2017年 满脸胡茬的怪蜀黍. All rights reserved.
//

#import "PQCPeople.h"
#import <objc/runtime.h>

@implementation PQCPeople {
    NSString *toSetName;
    //NSString *_name;
//    NSString *name;
    NSString *isName;
//    NSString *_isName;
}

//+ (BOOL)accessInstanceVariablesDirectly {
//    return NO;
//}
- (void)setNamestr:(NSString *)namestr {
    
}

- (id)valueForUndefinedKey:(NSString *)key {
    NSLog(@"无该key--%@",key);
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"出现异常，无该 key--%@",key);
}

-(void)showMessage{
    
    NSLog(@"name=%@,age=%d",_namestr,age);
}

- (void)showMess {
    NSLog(@"isname-%@,toSetname-%@",isName,toSetName);
}

// 模拟 KVO 的过程，打印 isa 指针指向的类，以及setter方法的的函数指针
- (void)printUserInfo {
    NSLog(@"isa:%@,supperclass:%@",NSStringFromClass(object_getClass(self)),
          class_getSuperclass(object_getClass(self)));
    NSLog(@"self:%@, [self superclass]:%@", self, [self superclass]);
    NSLog(@"name setter function pointer:%p", class_getMethodImplementation(object_getClass(self), @selector(setNamestr:)));
    NSLog(@"printInfo function pointer:%p", class_getMethodImplementation(object_getClass(self), @selector(printUserInfo)));
}


@end

@interface TwoTimesArray()

@property (nonatomic,readwrite,assign) NSUInteger count;
@property (nonatomic,copy) NSString* arrName;

@end

@implementation TwoTimesArray

- (void)incrementCount {
    self.count ++;
}
- (NSUInteger)countOfNumbers {
    return self.count;
}
- (id)objectInNumbersAtIndex:(NSUInteger)index {     //当key使用numbers时，KVC会找到这两个方法。
    return @(index * 2);
}

- (NSInteger)getNum {                 //第一个,自己一个一个注释试
    return 10;
}
- (NSInteger)num {                       //第二个
    return 11;
}
- (NSInteger)isNum {                    //第三个
    return 12;
}
@end

