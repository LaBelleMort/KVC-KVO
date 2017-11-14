//
//  ViewController.m
//  KVC&KVO
//
//  Created by 满脸胡茬的怪蜀黍 on 2017/11/6.
//  Copyright © 2017年 满脸胡茬的怪蜀黍. All rights reserved.
//

#import "ViewController.h"
#import "PQCPeople.h"
#import "PQCAccount.h"

@interface ViewController ()

@property(nonatomic, strong) NSMutableArray *array;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PQCPeople *person1=[[PQCPeople alloc]init];
    [person1 setValue:@"Kenshin" forKey:@"namestr"];
    [person1 setValue:@28 forKey:@"_age"];//注意即使一个私有变量仍然可以访问
    
    [person1 showMessage];
    //结果：name=Kenshin,age=28
    NSLog(@"person1's name is :%@,age is :%@",person1.namestr,[person1 valueForKey:@"_age"]);
    //结果：person1's name is :Kenshin,age is :28/Users/chen/Desktop/c++
    
    
    
    PQCAccount *account1=[[PQCAccount alloc]init];
    person1.account = account1;//注意这一步一定要先给account属性赋值，否则下面按路径赋值无法成功，因为account为nil，当然这一步骤也可以写成:[person1 setValue:account1 forKeyPath:@"account"];
    
    [person1 setValue:@100000000.0 forKeyPath:@"account.balance"];
//    [person1 setValue:@10000 forKey:@"balance"];
    NSLog(@"person1's balance is :%.2f",[[person1 valueForKeyPath:@"account.balance"] floatValue]);
    //结果：person1's balance is :100000000.00
    
    [person1 setValue:@"123" forKey:@"name"];
//    [person1 setValue:@"123" forKey:@"isname"];
//    [person1 setValue:@"123" forKey:@"name"];
    [person1 showMess];
    
    
    // 当调用 valueForKey: 时，首先会按照 get<Key>、<key>、<isKey> 的顺序查找 getter 方法
    TwoTimesArray* arr = [TwoTimesArray new];
    // 当我们的 key 是 num ,它会按照 getNum num isNum 的顺序查找这些方法
    NSNumber* num =   [arr valueForKey:@"num"];
    NSLog(@"%@",num);
    // 如果未查找到 getter 方法，就会查找 是否有 countOf<Key> objectIn<Key>AtIndex 或 <Key>AtIndexes 格式的方法，如果
    // 存在其中一个，那么就会返回一个 NSKeyValueArray（可以响应 NSArray 的所有方法的代理）。然后就可以给这个 NSKeyValueArray 发送属于 NSArray 的方法
    id ar = [arr valueForKey:@"numbers"];
    NSLog(@"%@",NSStringFromClass([ar class]));
    NSLog(@"0:%@     1:%@     2:%@     3:%@",ar[0],ar[1],ar[2],ar[3]);
    [arr incrementCount];                                                                            //count加1
    NSLog(@"%lu",(unsigned long)[ar count]);                                                         //打印出1
    [arr incrementCount];                                                                            //count再加1
    NSLog(@"%lu",(unsigned long)[ar count]);                                                         //打印出2
    
    // 如果上述方法还是未找到，会查找 countOf<Key>，enumeratorOf<Key>,memberOf<Key> 格式的方法，如果这三个方法都找到，就会返回一个可以响应 NSSet 所有方法的代理集合。和上述一样，可以给该返回的代理集合 发送 NSSet 相关的方法。
    // 如果，上述步骤还不满足,则和先前的设值一样，会按`_<key>,_is<Key>,<key>,is<Key>`的顺序搜索成员变量名，这里不推荐这么做，因为这样直接访问实例变量破坏了封装性，使代码更脆弱
    
    
// KVO 的使用
    [arr setValue:@"newName" forKey:@"arrName"];
    NSString* name = [arr valueForKey:@"arrName"];
    NSLog(@"%@",name);
    PQCAccount *account = [PQCAccount new];
    [account addItem];
    [account addItemObserver];
    [account removeItemObserver];
    
//  在添加Observer前，添加Observer以及删除Observer后分别打印出该类的信息
    PQCPeople *person = [[PQCPeople alloc]init];
    NSLog(@"Before add observer————————————————————————–");
    [person printUserInfo];
    [person addObserver:self forKeyPath:@"namestr" options:NSKeyValueObservingOptionNew context:nil];
    NSLog(@"After add observer————————————————————————–");
    [person printUserInfo];
    [person removeObserver:self forKeyPath:@"namestr"];
    NSLog(@"After remove observer————————————————————————–");
    [person printUserInfo];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
