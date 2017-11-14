//
//  PQCAccount.m
//  KVC&KVO
//
//  Created by 满脸胡茬的怪蜀黍 on 2017/11/6.
//  Copyright © 2017年 满脸胡茬的怪蜀黍. All rights reserved.
//

#import "PQCAccount.h"

@implementation PQCAccount

- (id)init {
    if (self == [super init]) {
        _array = [NSMutableArray array];
        [self addObserver:self forKeyPath:@"array" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)addItem {
    [_array addObject:@"1"];
}

- (void)addItemObserver {
    [[self mutableArrayValueForKey:@"array"]  addObject:@"1"];
}

- (void)removeItemObserver {
    [[self mutableArrayValueForKey:@"array"] removeObject:@"1"];
}
-  (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"change -- %@",change);
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"array"]; //一定要在dealloc里面移除观察
}


@end
