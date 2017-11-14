
     
    
##  KVC／KVO

### 概念
- KVC ： 即 Key-Value-Coding，用于键值编码。作为 cocoa 的一个标准化组成部分，它是基于 NSKeyValueCoding 非正式协议的机制。简单来说，就是直接通过 key  值对对象的属性进行存取操作，而不需要调用明确的存取方法（set 和 get 方法 ）。基本上所有的 OC 对象都支持 KVC。

- KVO ： 即 Key-Value-Observing ，键值观察。回调机制，当指定的对象属性（内存地址/常量改变）被修改后，对象就会受到通知。使用 KVO 机制的前提：必须能支持 KVC 机制；另外，在 MVC 设计架构中， KVO 适合 在 Model 和 Controller 之间通讯。

### KVC /  KVO 的使用
其实，我们经常会用到 KVC 和 KVO 机制来解决实际开发中的好多问题，尤其是 KVC，因为这种基于运行时的编程方式大大地提高了灵活性，简化代码；比如，我们经常会用如下代码来修改 textField 的 placeHolder 的字体和颜色等属性。
```
   [self setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
   [self setValue:[UIFont boldSystemFontOfSize:20] forKeyPath:@"_placeholderLabel.font"];
```
下面，来为大家列举一下 KVC / KVO 的使用场景

#### KVC的使用

KVC 的常用的方法：

```
- (nullable id)valueForKey:(NSString *)key;                          //直接通过Key来取值
- (void)setValue:(nullable id)value forKey:(NSString *)key;          //通过Key来设值
- (nullable id)valueForKeyPath:(NSString *)keyPath;                  //通过KeyPath来取值
- (void)setValue:(nullable id)value forKeyPath:(NSString *)keyPath;  //通过KeyPath来设值
```
NSKeyValueCoding 类别中的一些其他方法：
```
+ (BOOL)accessInstanceVariablesDirectly;
//默认返回YES，表示如果没有找到Set<Key>方法的话，会按照_key，_iskey，key，iskey的顺序搜索成员，设置成NO就不这样搜索

- (BOOL)validateValue:(inout id __nullable * __nonnull)ioValue forKey:(NSString *)inKey error:(out NSError **)outError;
//KVC提供属性值正确性验证的API，它可以用来检查set的值是否正确、为不正确的值做一个替换值或者拒绝设置新值并返回错误原因。

- (NSMutableArray *)mutableArrayValueForKey:(NSString *)key;
//这是集合操作的API，里面还有一系列这样的API，如果属性是一个NSMutableArray，那么可以用这个方法来返回。

- (nullable id)valueForUndefinedKey:(NSString *)key;
//如果Key不存在，且没有KVC无法搜索到任何和Key有关的字段或者属性，则会调用这个方法，默认是抛出异常。

- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key;
//和上一个方法一样，但这个方法是设值。

- (void)setNilValueForKey:(NSString *)key;
//如果你在SetValue方法时面给Value传nil，则会调用这个方法

- (NSDictionary<NSString *, id> *)dictionaryWithValuesForKeys:(NSArray<NSString *> *)keys;
//输入一组key,返回该组key对应的Value，再转成字典返回，用于将Model转到字典。
```

 - 动态地取值和设值
 
 - 用 KVC 来访问和修改私有变量
  对于类里的私有属性，Objective-C是无法直接访问的，但是KVC是可以的
  
 - Model 和 字典转换
 其实，常见的第三方 模型解析库就是利用 KVC 和 Objective-C 的 动态性 Runtime 实现的。
 
 - 修改一些控件的内部属性
 利用 KVC 来修改我们无法访问和修改控件的样式，但是 Apple 并没有为我们提供访问这些控件的 API，因此我们不好获取这些属性名。所以，我们又要使用 Runtime 这个东西了。比如，我们可以使用以下代码来获取 UITableView 的属性列表。
```
    unsigned int count = 0;
    objc_property_t *propertyList = class_copyPropertyList([UITableView class], &count);
    NSMutableArray * mutableList_property = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int  i = 0; i < count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        [mutableList_property addObject:[NSString stringWithUTF8String:propertyName]];
    }
    free(propertyList);
    NSArray * propertylist = [NSArray arrayWithArray:mutableList_property];
    NSLog(@"\n获取UITableView的属性列表:%@",propertylist);
    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
```
- 操作集合
苹果 对于 KVC 的 valueForKey: 方法做了特殊的实现。常见的容器类就实现了这些方法。
- 实现高阶消息传递
当对容器使用 KVC 时， valueForKey 会直接呗传递给 容器中的每一个对象，而不只是对容器本身进行操作。结果会被添加进返回的容器。

```
NSArray* arrStr = @[@"english",@"franch",@"chinese"];
NSArray* arrCapStr = [arrStr valueForKey:@"capitalizedString"];
for (NSString* str  in arrCapStr) {
    NSLog(@"%@",str);
}
NSArray* arrCapStrLength = [arrStr valueForKeyPath:@"capitalizedString.length"];
for (NSNumber* length  in arrCapStrLength) {
    NSLog(@"%ld",(long)length.integerValue);
}
打印结果
2016-04-20 16:29:14.239 KVCDemo[1356:118667] English
2016-04-20 16:29:14.240 KVCDemo[1356:118667] Franch
2016-04-20 16:29:14.240 KVCDemo[1356:118667] Chinese
2016-04-20 16:29:14.240 KVCDemo[1356:118667] 7
2016-04-20 16:29:14.241 KVCDemo[1356:118667] 6
2016-04-20 16:29:14.241 KVCDemo[1356:118667] 7
```
- 用 KVC  中的函数操作集合
KVC 提供了很复杂的函数：
1. 简单集合运算符： @avg @count @max @min @sum （不支持自定义）
2. 对象运算级： @distinctUnionOfObjects @unionOfObjects （比集合运算符稍微复杂，能以数组的方式返回指定的内容）
3.  Array 和 Set 操作符： @distinctUnionOfArrays @unionOfArrays @distinctUnionOfSets

#### KVO 的使用
对于，KVO 的使用，就是观察键值。在 MVC 设计架构中， KVO 适合 在 Model 和 Controller 之间通讯。
使用步骤：
1. 注册观察者，实施监听

```
//第一个参数observer：观察者 （这里观察self.myKVO对象的属性变化）

//第二个参数keyPath： 被观察的属性名称(这里观察self.myKVO中num属性值的改变)

//第三个参数options： 观察属性的新值、旧值等的一些配置（枚举值，可以根据需要设置，例如这里可以使用两项）

//第四个参数context： 上下文，可以为kvo的回调方法传值（例如设定为一个放置数据的字典）

//注册观察者

[self.myKVO addObserver:self forKeyPath:@"num" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil]; 
```

2. 在回调方法中处理属性发生的变化

```
/keyPath:属性名称

//object:被观察的对象

//change:变化前后的值都存储在change字典中

//context:注册观察者时，context传过来的值

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
}
```
3. 移除观察者

**注意：**
观察者观察的是属性，只有遵循 KVO 变更属性值的方式才会执行KVO的回调方法，例如是否执行了setter方法、或者是否使用了KVC赋值。如果赋值没有通过setter方法或者KVC，而是直接修改属性对应的成员变量，例如：仅调用_name = @"newName"，这时是不会触发kvo机制，更加不会调用回调方法的。

### 实现原理

 KVO 是 基于 KVC 实现的。首先了解 KVC 的机制，才能更好的理解 KVO。

#### KVC 是如何寻找 Key 值的

- 当调用 `setValue: forKey:` 时
 1. 优先调用 `set <Key>:属性值` 方法 ，代码实现 setter 方法
 2. 如果无 set 方法， KVC 会检查  `+ (BOOL)accessInstanceVariablesDirectly` 有没有返回 YES（默认为 YES，如果重写使其返回 NO 的话，就会执行 `setValue：forUndefinedKey：`）。KVC 机制会按照`_key，_iskey，key，iskey`的顺序搜索成员，对其赋值。
 3. 如果都不存在，系统会执行该对象的 `setValue：forUndefinedKey：`方法，默认抛出异常。



- 当调用 `valueForKey:` 时：
  KVC对key的搜索方式不同于setValue：属性值 forKey：@”name“，其搜索方式如下：
 1. 首先按 `get<Key>,<key>,is<Key>` 的顺序方法查找 getter 方法，找到的话会直接调用。如果是BOOL或者Int等值类型， 会将其包装成一个NSNumber对象。
 2. 如果上面的 getter 方法未找到，KVC则会查找 `countOf<Key> , objectIn<Key>AtIndex` 或` <Key>AtIndexes` 格式的方法。如果 countOf<Key> 方法和另外两个方法中的一个被找到，那么就会返回一个可以响应 NSArray 所有方法的代理集合(它是 NSKeyValueArray ，是NSArray的子类)，调用这个代理集合的方法，或者说给这个代理集合发送属于NSArray的方法，就会以countOf<Key> ,objectIn<Key>AtIndex或<Key>AtIndexes这几个方法组合的形式调用。还有一个可选的`get<Key>: range:` 方法。所以你想重新定义 KVC 的一些功能，你可以添加这些方法，需要注意的是你的方法名要符合KVC的标准命名方法，包括方法签名。
 3. 如果上面的方法没有找到，那么会同时查找`countOf<Key>，enumeratorOf<Key>,memberOf<Key>`格式的方法。如果这三个方法都找到，那么就返回一个可以响应NSSet所的方法的代理集合，和上面一样，给这个代理集合发NSSet的消息，就会以countOf<Key>，enumeratorOf<Key>,memberOf<Key>组合的形式调用。
 4. 如果还未找到，则和先前的设值一样，会按`_<key>,_is<Key>,<key>,is<Key>`的顺序搜索成员变量名，这里不推荐这么做，因为这样直接访问实例变量破坏了封装性，使代码更脆弱。如果重写了类方法 `+ (BOOL)accessInstanceVariablesDirectly`返回NO的话，那么会直接调用`valueForUndefinedKey:`
 5.  还没有找到的话，调用`valueForUndefinedKey:`

- 在 KVC 中 使用 keyPath
用小数点分割 key,，然后再像普通key一样按照先前介绍的顺序搜索下去。如果属性不存在，同样会调用 `valueForUndefinedKey:`

- KVC处理异常
重写抛出异常的那两个方法，通常情况下，KVC不允许你要在调用setValue：属性值 forKey：@”name“(或者keyPath)时对非对象传递一个nil的值。

- KVC 处理非对象和自定义对象
`valueForKey：`总是返回一个id对象，如果原本的变量类型是值类型或者结构体，返回值会封装成NSNumber或者NSValue对象，但是 `setValue：forKey：`却不行。你必须手动将值类型转换成NSNumber或者NSValue类型，才能传递过去。

- KVC与容器类
不可变的有序容器属性（NSArray）和无序容器属性（NSSet）一般可以使用 `valueForKey：`来获取。如有一个叫 items 的 NSArray 的属性，你可以使用 `valuleaForKey:@"items"` 来获取这个属性。
当对象的属性是可变的容器时，对于有序容器，可以使用如下方法：
`- (NSMutableArray *)mutableArrayValueForKey:(NSString *)key;`
该方法的返回值是一个可变的有序数组，如果调用该方法，KVC 的搜索顺序如下：
	1. 搜索 `insertObject: in<Key>AtIndex:` , `removeObjectFrom<Key>AtIndex:` 或者 `insert<Key>AtIndexes`，`remove<Key>AtIndexes` 格式的方法。如果至少找到一个 insert 方法和一个 remove 方法，那么同样返回一个可以响应 NSMutableArray 所有方法代理集合(类名是 NSKeyValueFastMutableArray2 )，那么给这个代理集合发送NSMutableArray 的方法，就会以 `insertObject:in<Key>AtIndex:` , `removeObjectFrom<Key>AtIndex:` 或者 `insert<Key>AdIndexes` , `remove<Key>AtIndexes`组合的形式调用。还有两个可选实现的接口：`replaceOnjectAtIndex:withObject:`,`replace<Key>AtIndexes:with<Key>:`。
	2. 如果上步的方法没有找到，则搜索`set<Key>:` 格式的方法，如果找到，那么发送给代理集合的 NSMutableArray 最终都会调用`set<Key>:`方法。 也就是说，`mutableArrayValueForKey:`取出的代理集合修改后，用`set<Key>:` 重新赋值回去去。这样做效率会低很多。所以推荐实现上面的方法。
	3. 如果上一步的方法还还没有找到，再检查类方法`+ (BOOL)accessInstanceVariablesDirectly`,如果返回 YES (默认行为)，会按 `_<key>,<key>`,的顺序搜索成员变量名，如果找到，那么发送的 NSMutableArray 消息方法直接交给这个成员变量处理。
	4. 如果还未找到，则调用 `valueForUndefinedKey:`，默认抛出异常 。
	
 除了用于有序的可变容器外，`mutableArrayValueForKey:`一般还用于对 NSMutableArray 添加 Observer 上。如果对象属性是个 可变容器类型时，你给他添加 KVO时，你会发现当你添加或移除元素时并不会接受到变化。因为 KVO 的本质是系统监测到某个属性的内存地址或者常量改变时，会添加上`- (void)willChangeValueForKey:(NSString *)key`和`- (void)didChangeValueForKey:(NSString *)key`方法来发送通知，所以一种方法是手动调用这两个方法，一种是使用上述的  `mutableArrayValueForKey:` 方法。
对于无序容器时，可以使用下面的方法：
`- (NSMutableSet *)mutableSetValueForKey:(NSString *)key;`
该方法返回一个可变的无序数组，如果调用该方法，KVC 的搜索顺序除了检查 receiver 是 ManagedObject 以外，其搜索顺序和 `mutableArrayValueForKey` 基本一致。


- KVC与字典
当对NSDictionary对象使用KVC时，valueForKey:的表现行为和objectForKey:一样。所以使用valueForKeyPath:用来访问多层嵌套的字典是比较方便的。

#### KVO 的原理
我们之前就说了 KVO 的实现依靠的是 Objective-C 强大的 Runtime。那么具体的，我们是如何实现这一机制的呢？下面让我们共同来探讨一下。

**基本原理：**
当观察对象 A 时， KVO 机制动态的创建了一个对象 A 当前的子类，并为这个新的子类重写了被观察属性 keyPath 的 setter 方法。在 setter 方法中，我们通知观察对象属性的改变状态。

**进一步剖析：**
其实 Apple 使用了 isa 混写，即 isa-swizzling 来实现 KVO。
> Automatic key-value observing is implemented using a technique called isa-swizzling.
> The isa pointer, as the name suggests, points to the object’s class which maintains a dispatch table. This dispatch table essentially contains pointers to the methods the class implements, among other data.

> When an observer is registered for an attribute of an object the isa pointer of the observed object is modified, pointing to an intermediate class rather than at the true class. As a result the value of the isa pointer does not necessarily reflect the actual class of the instance.

> You should never rely on the isa pointer to determine class membership. Instead, you should use the class method to determine the class of an object instance.

那么，我们通过下面的代码来看看，isa-swizzling 的真面目到底是什么？

```
// 在 PQCPeople.m 中,我们模拟 KVO 的过程，打印 isa 指针指向的类，以及 setter 方法的的函数指针
- (void)printUserInfo {
    NSLog(@"isa:%@,supperclass:%@",NSStringFromClass(object_getClass(self)),
          class_getSuperclass(object_getClass(self)));
    NSLog(@"self:%@, [self superclass]:%@", self, [self superclass]);
    NSLog(@"name setter function pointer:%p", class_getMethodImplementation(object_getClass(self), @selector(setNamestr:)));
    NSLog(@"printInfo function pointer:%p", class_getMethodImplementation(object_getClass(self), @selector(printUserInfo)));
}
```
在运行过程中，在添加Observer前，添加Observer以及删除Observer后分别打印出该类的信息。

```
    PQCPeople *person = [[PQCPeople alloc]init];
    NSLog(@"Before add observer————————————————————————–");
    [person printUserInfo];
    [person addObserver:self forKeyPath:@"namestr" options:NSKeyValueObservingOptionNew context:nil];
    NSLog(@"After add observer————————————————————————–");
    [person printUserInfo];
    [person removeObserver:self forKeyPath:@"namestr"];
    NSLog(@"After remove observer————————————————————————–");
    [person printUserInfo];
```
以下是打印的信息：

```
2017-11-14 13:06:51.927605+0800 KVC&KVO[851:92433] Before add observer————————————————————————–
2017-11-14 13:06:51.927701+0800 KVC&KVO[851:92433] isa:PQCPeople,supperclass:NSObject
2017-11-14 13:06:51.927814+0800 KVC&KVO[851:92433] self:<PQCPeople: 0x604000059c50>, [self superclass]:NSObject
2017-11-14 13:06:51.927904+0800 KVC&KVO[851:92433] name setter function pointer:0x10c2429d0
2017-11-14 13:06:51.927987+0800 KVC&KVO[851:92433] printInfo function pointer:0x10c242ba0
2017-11-14 13:06:51.928224+0800 KVC&KVO[851:92433] After add observer————————————————————————–
2017-11-14 13:06:51.928316+0800 KVC&KVO[851:92433] isa:NSKVONotifying_PQCPeople,supperclass:PQCPeople
2017-11-14 13:06:51.928489+0800 KVC&KVO[851:92433] self:<PQCPeople: 0x604000059c50>, [self superclass]:NSObject
2017-11-14 13:06:51.928628+0800 KVC&KVO[851:92433] name setter function pointer:0x10c58f666
2017-11-14 13:06:51.928798+0800 KVC&KVO[851:92433] printInfo function pointer:0x10c242ba0
2017-11-14 13:06:51.928954+0800 KVC&KVO[851:92433] After remove observer————————————————————————–
2017-11-14 13:06:51.929077+0800 KVC&KVO[851:92433] isa:PQCPeople,supperclass:NSObject
2017-11-14 13:06:51.929268+0800 KVC&KVO[851:92433] self:<PQCPeople: 0x604000059c50>, [self superclass]:NSObject
2017-11-14 13:06:51.929431+0800 KVC&KVO[851:92433] name setter function pointer:0x10c2429d0
2017-11-14 13:06:51.929586+0800 KVC&KVO[851:92433] printInfo function pointer:0x10c242ba0
```

通过分析，我们会发现在添加KVO之后，isa 已经替换成了`NSKVONotifying_PQCPeople`,而根据 `class_getSuperclass`得到的结果竟然是 PQCPerson, 然后 namestr 是我们KVO需要观察的属性，它的 `setter`函数指针也变了。
我们上面也说道， OC 的消息机制是通过 isa 去查找实现的，那么我们可以根据以上的分析，可以大致得出，KVO的实现应该是：
- 添加 Observe
通过 runtime 偷偷实现了一个子类，并且以 NSKVONotifying_+类名 来命名；
将之前那个对象的isa指针指向了这个子类；
重写了观察的对象setter方法，并且在重写的中添加了`willChangeValueForKey:`以及`didChangeValueForKey:`

- 移除 Observe
将 isa 的指向指回原来的类对象中。

因此，我们的 KVO 就是通过上述分析的这种机制，进行键值观察。
![isa_swizzling.jpg](http://upload-images.jianshu.io/upload_images/2726320-fa39c5bab1cdf221.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 文末
通过上面的分析，我们也大概了解了 KVC 以及 KVO 的实现过程以及实现原理，对这个感兴趣的同学，我们可以试着去自己实现一下 KVC 以及 KVO。
KVC／KVO

概念

KVC ： 即 Key-Value-Coding，用于键值编码。作为 cocoa 的一个标准化组成部分，它是基于 NSKeyValueCoding 非正式协议的机制。简单来说，就是直接通过 key 值对对象的属性进行存取操作，而不需要调用明确的存取方法（set 和 get 方法 ）。基本上所有的 OC 对象都支持 KVC。
KVO ： 即 Key-Value-Observing ，键值观察。回调机制，当指定的对象属性（内存地址/常量改变）被修改后，对象就会受到通知。使用 KVO 机制的前提：必须能支持 KVC 机制；另外，在 MVC 设计架构中， KVO 适合 在 Model 和 Controller 之间通讯。
KVC / KVO 的使用

其实，我们经常会用到 KVC 和 KVO 机制来解决实际开发中的好多问题，尤其是 KVC，因为这种基于运行时的编程方式大大地提高了灵活性，简化代码；比如，我们经常会用如下代码来修改 textField 的 placeHolder 的字体和颜色等属性。

   [self setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
   [self setValue:[UIFont boldSystemFontOfSize:20] forKeyPath:@"_placeholderLabel.font"];
下面，来为大家列举一下 KVC / KVO 的使用场景

KVC的使用

KVC 的常用的方法：

- (nullable id)valueForKey:(NSString *)key;                          //直接通过Key来取值
- (void)setValue:(nullable id)value forKey:(NSString *)key;          //通过Key来设值
- (nullable id)valueForKeyPath:(NSString *)keyPath;                  //通过KeyPath来取值
- (void)setValue:(nullable id)value forKeyPath:(NSString *)keyPath;  //通过KeyPath来设值
NSKeyValueCoding 类别中的一些其他方法：

+ (BOOL)accessInstanceVariablesDirectly;
//默认返回YES，表示如果没有找到Set<Key>方法的话，会按照_key，_iskey，key，iskey的顺序搜索成员，设置成NO就不这样搜索

- (BOOL)validateValue:(inout id __nullable * __nonnull)ioValue forKey:(NSString *)inKey error:(out NSError **)outError;
//KVC提供属性值正确性验证的API，它可以用来检查set的值是否正确、为不正确的值做一个替换值或者拒绝设置新值并返回错误原因。

- (NSMutableArray *)mutableArrayValueForKey:(NSString *)key;
//这是集合操作的API，里面还有一系列这样的API，如果属性是一个NSMutableArray，那么可以用这个方法来返回。

- (nullable id)valueForUndefinedKey:(NSString *)key;
//如果Key不存在，且没有KVC无法搜索到任何和Key有关的字段或者属性，则会调用这个方法，默认是抛出异常。

- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key;
//和上一个方法一样，但这个方法是设值。

- (void)setNilValueForKey:(NSString *)key;
//如果你在SetValue方法时面给Value传nil，则会调用这个方法

- (NSDictionary<NSString *, id> *)dictionaryWithValuesForKeys:(NSArray<NSString *> *)keys;
//输入一组key,返回该组key对应的Value，再转成字典返回，用于将Model转到字典。
动态地取值和设值
用 KVC 来访问和修改私有变量 
对于类里的私有属性，Objective-C是无法直接访问的，但是KVC是可以的
Model 和 字典转换 
其实，常见的第三方 模型解析库就是利用 KVC 和 Objective-C 的 动态性 Runtime 实现的。
修改一些控件的内部属性 
利用 KVC 来修改我们无法访问和修改控件的样式，但是 Apple 并没有为我们提供访问这些控件的 API，因此我们不好获取这些属性名。所以，我们又要使用 Runtime 这个东西了。比如，我们可以使用以下代码来获取 UITableView 的属性列表。
    unsigned int count = 0;
    objc_property_t *propertyList = class_copyPropertyList([UITableView class], &count);
    NSMutableArray * mutableList_property = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int  i = 0; i < count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        [mutableList_property addObject:[NSString stringWithUTF8String:propertyName]];
    }
    free(propertyList);
    NSArray * propertylist = [NSArray arrayWithArray:mutableList_property];
    NSLog(@"\n获取UITableView的属性列表:%@",propertylist);
    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
操作集合 
苹果 对于 KVC 的 valueForKey: 方法做了特殊的实现。常见的容器类就实现了这些方法。
实现高阶消息传递 
当对容器使用 KVC 时， valueForKey 会直接呗传递给 容器中的每一个对象，而不只是对容器本身进行操作。结果会被添加进返回的容器。
NSArray* arrStr = @[@"english",@"franch",@"chinese"];
NSArray* arrCapStr = [arrStr valueForKey:@"capitalizedString"];
for (NSString* str  in arrCapStr) {
    NSLog(@"%@",str);
}
NSArray* arrCapStrLength = [arrStr valueForKeyPath:@"capitalizedString.length"];
for (NSNumber* length  in arrCapStrLength) {
    NSLog(@"%ld",(long)length.integerValue);
}
打印结果
2016-04-20 16:29:14.239 KVCDemo[1356:118667] English
2016-04-20 16:29:14.240 KVCDemo[1356:118667] Franch
2016-04-20 16:29:14.240 KVCDemo[1356:118667] Chinese
2016-04-20 16:29:14.240 KVCDemo[1356:118667] 7
2016-04-20 16:29:14.241 KVCDemo[1356:118667] 6
2016-04-20 16:29:14.241 KVCDemo[1356:118667] 7
用 KVC 中的函数操作集合 
KVC 提供了很复杂的函数： 
简单集合运算符： @avg @count @max @min @sum （不支持自定义）
对象运算级： @distinctUnionOfObjects @unionOfObjects （比集合运算符稍微复杂，能以数组的方式返回指定的内容）
Array 和 Set 操作符： @distinctUnionOfArrays @unionOfArrays @distinctUnionOfSets
KVO 的使用

对于，KVO 的使用，就是观察键值。在 MVC 设计架构中， KVO 适合 在 Model 和 Controller 之间通讯。 
使用步骤：

注册观察者，实施监听
//第一个参数observer：观察者 （这里观察self.myKVO对象的属性变化）

//第二个参数keyPath： 被观察的属性名称(这里观察self.myKVO中num属性值的改变)

//第三个参数options： 观察属性的新值、旧值等的一些配置（枚举值，可以根据需要设置，例如这里可以使用两项）

//第四个参数context： 上下文，可以为kvo的回调方法传值（例如设定为一个放置数据的字典）

//注册观察者

[self.myKVO addObserver:self forKeyPath:@"num" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil]; 
在回调方法中处理属性发生的变化
/keyPath:属性名称

//object:被观察的对象

//change:变化前后的值都存储在change字典中

//context:注册观察者时，context传过来的值

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
}
移除观察者
注意： 
观察者观察的是属性，只有遵循 KVO 变更属性值的方式才会执行KVO的回调方法，例如是否执行了setter方法、或者是否使用了KVC赋值。如果赋值没有通过setter方法或者KVC，而是直接修改属性对应的成员变量，例如：仅调用_name = @”newName”，这时是不会触发kvo机制，更加不会调用回调方法的。

实现原理

KVO 是 基于 KVC 实现的。首先了解 KVC 的机制，才能更好的理解 KVO。

KVC 是如何寻找 Key 值的

当调用 setValue: forKey: 时

优先调用 set <Key>:属性值 方法 ，代码实现 setter 方法
如果无 set 方法， KVC 会检查 + (BOOL)accessInstanceVariablesDirectly 有没有返回 YES（默认为 YES，如果重写使其返回 NO 的话，就会执行 setValue：forUndefinedKey：）。KVC 机制会按照_key，_iskey，key，iskey的顺序搜索成员，对其赋值。
如果都不存在，系统会执行该对象的 setValue：forUndefinedKey：方法，默认抛出异常。
当调用 valueForKey: 时： 
KVC对key的搜索方式不同于setValue：属性值 forKey：@”name“，其搜索方式如下：

首先按 get<Key>,<key>,is<Key> 的顺序方法查找 getter 方法，找到的话会直接调用。如果是BOOL或者Int等值类型， 会将其包装成一个NSNumber对象。
如果上面的 getter 方法未找到，KVC则会查找 countOf<Key> , objectIn<Key>AtIndex 或<Key>AtIndexes 格式的方法。如果 countOf 方法和另外两个方法中的一个被找到，那么就会返回一个可以响应 NSArray 所有方法的代理集合(它是 NSKeyValueArray ，是NSArray的子类)，调用这个代理集合的方法，或者说给这个代理集合发送属于NSArray的方法，就会以countOf ,objectInAtIndex或AtIndexes这几个方法组合的形式调用。还有一个可选的get<Key>: range: 方法。所以你想重新定义 KVC 的一些功能，你可以添加这些方法，需要注意的是你的方法名要符合KVC的标准命名方法，包括方法签名。
如果上面的方法没有找到，那么会同时查找countOf<Key>，enumeratorOf<Key>,memberOf<Key>格式的方法。如果这三个方法都找到，那么就返回一个可以响应NSSet所的方法的代理集合，和上面一样，给这个代理集合发NSSet的消息，就会以countOf，enumeratorOf,memberOf组合的形式调用。
如果还未找到，则和先前的设值一样，会按_<key>,_is<Key>,<key>,is<Key>的顺序搜索成员变量名，这里不推荐这么做，因为这样直接访问实例变量破坏了封装性，使代码更脆弱。如果重写了类方法 + (BOOL)accessInstanceVariablesDirectly返回NO的话，那么会直接调用valueForUndefinedKey:
还没有找到的话，调用valueForUndefinedKey:
在 KVC 中 使用 keyPath 
用小数点分割 key,，然后再像普通key一样按照先前介绍的顺序搜索下去。如果属性不存在，同样会调用 valueForUndefinedKey:
KVC处理异常 
重写抛出异常的那两个方法，通常情况下，KVC不允许你要在调用setValue：属性值 forKey：@”name“(或者keyPath)时对非对象传递一个nil的值。
KVC 处理非对象和自定义对象 
valueForKey：总是返回一个id对象，如果原本的变量类型是值类型或者结构体，返回值会封装成NSNumber或者NSValue对象，但是 setValue：forKey：却不行。你必须手动将值类型转换成NSNumber或者NSValue类型，才能传递过去。
KVC与容器类 
不可变的有序容器属性（NSArray）和无序容器属性（NSSet）一般可以使用 valueForKey：来获取。如有一个叫 items 的 NSArray 的属性，你可以使用 valuleaForKey:@"items" 来获取这个属性。 
当对象的属性是可变的容器时，对于有序容器，可以使用如下方法： 
- (NSMutableArray *)mutableArrayValueForKey:(NSString *)key; 
该方法的返回值是一个可变的有序数组，如果调用该方法，KVC 的搜索顺序如下：

搜索 insertObject: in<Key>AtIndex: , removeObjectFrom<Key>AtIndex: 或者 insert<Key>AtIndexes，remove<Key>AtIndexes 格式的方法。如果至少找到一个 insert 方法和一个 remove 方法，那么同样返回一个可以响应 NSMutableArray 所有方法代理集合(类名是 NSKeyValueFastMutableArray2 )，那么给这个代理集合发送NSMutableArray 的方法，就会以 insertObject:in<Key>AtIndex: , removeObjectFrom<Key>AtIndex: 或者 insert<Key>AdIndexes , remove<Key>AtIndexes组合的形式调用。还有两个可选实现的接口：replaceOnjectAtIndex:withObject:,replace<Key>AtIndexes:with<Key>:。
如果上步的方法没有找到，则搜索set<Key>: 格式的方法，如果找到，那么发送给代理集合的 NSMutableArray 最终都会调用set<Key>:方法。 也就是说，mutableArrayValueForKey:取出的代理集合修改后，用set<Key>: 重新赋值回去去。这样做效率会低很多。所以推荐实现上面的方法。
如果上一步的方法还还没有找到，再检查类方法+ (BOOL)accessInstanceVariablesDirectly,如果返回 YES (默认行为)，会按 _<key>,<key>,的顺序搜索成员变量名，如果找到，那么发送的 NSMutableArray 消息方法直接交给这个成员变量处理。
如果还未找到，则调用 valueForUndefinedKey:，默认抛出异常 。
除了用于有序的可变容器外，mutableArrayValueForKey:一般还用于对 NSMutableArray 添加 Observer 上。如果对象属性是个 可变容器类型时，你给他添加 KVO时，你会发现当你添加或移除元素时并不会接受到变化。因为 KVO 的本质是系统监测到某个属性的内存地址或者常量改变时，会添加上- (void)willChangeValueForKey:(NSString *)key和- (void)didChangeValueForKey:(NSString *)key方法来发送通知，所以一种方法是手动调用这两个方法，一种是使用上述的 mutableArrayValueForKey: 方法。 
对于无序容器时，可以使用下面的方法： 
- (NSMutableSet *)mutableSetValueForKey:(NSString *)key; 
该方法返回一个可变的无序数组，如果调用该方法，KVC 的搜索顺序除了检查 receiver 是 ManagedObject 以外，其搜索顺序和 mutableArrayValueForKey 基本一致。
KVC与字典 
当对NSDictionary对象使用KVC时，valueForKey:的表现行为和objectForKey:一样。所以使用valueForKeyPath:用来访问多层嵌套的字典是比较方便的。
KVO 的原理

我们之前就说了 KVO 的实现依靠的是 Objective-C 强大的 Runtime。那么具体的，我们是如何实现这一机制的呢？下面让我们共同来探讨一下。

基本原理： 
当观察对象 A 时， KVO 机制动态的创建了一个对象 A 当前的子类，并为这个新的子类重写了被观察属性 keyPath 的 setter 方法。在 setter 方法中，我们通知观察对象属性的改变状态。

进一步剖析： 
其实 Apple 使用了 isa 混写，即 isa-swizzling 来实现 KVO。

Automatic key-value observing is implemented using a technique called isa-swizzling. 
The isa pointer, as the name suggests, points to the object’s class which maintains a dispatch table. This dispatch table essentially contains pointers to the methods the class implements, among other data.

When an observer is registered for an attribute of an object the isa pointer of the observed object is modified, pointing to an intermediate class rather than at the true class. As a result the value of the isa pointer does not necessarily reflect the actual class of the instance.

You should never rely on the isa pointer to determine class membership. Instead, you should use the class method to determine the class of an object instance.
那么，我们通过下面的代码来看看，isa-swizzling 的真面目到底是什么？

// 在 PQCPeople.m 中,我们模拟 KVO 的过程，打印 isa 指针指向的类，以及 setter 方法的的函数指针
- (void)printUserInfo {
    NSLog(@"isa:%@,supperclass:%@",NSStringFromClass(object_getClass(self)),
          class_getSuperclass(object_getClass(self)));
    NSLog(@"self:%@, [self superclass]:%@", self, [self superclass]);
    NSLog(@"name setter function pointer:%p", class_getMethodImplementation(object_getClass(self), @selector(setNamestr:)));
    NSLog(@"printInfo function pointer:%p", class_getMethodImplementation(object_getClass(self), @selector(printUserInfo)));
}
在运行过程中，在添加Observer前，添加Observer以及删除Observer后分别打印出该类的信息。

    PQCPeople *person = [[PQCPeople alloc]init];
    NSLog(@"Before add observer————————————————————————–");
    [person printUserInfo];
    [person addObserver:self forKeyPath:@"namestr" options:NSKeyValueObservingOptionNew context:nil];
    NSLog(@"After add observer————————————————————————–");
    [person printUserInfo];
    [person removeObserver:self forKeyPath:@"namestr"];
    NSLog(@"After remove observer————————————————————————–");
    [person printUserInfo];
以下是打印的信息：

2017-11-14 13:06:51.927605+0800 KVC&KVO[851:92433] Before add observer————————————————————————–
2017-11-14 13:06:51.927701+0800 KVC&KVO[851:92433] isa:PQCPeople,supperclass:NSObject
2017-11-14 13:06:51.927814+0800 KVC&KVO[851:92433] self:<PQCPeople: 0x604000059c50>, [self superclass]:NSObject
2017-11-14 13:06:51.927904+0800 KVC&KVO[851:92433] name setter function pointer:0x10c2429d0
2017-11-14 13:06:51.927987+0800 KVC&KVO[851:92433] printInfo function pointer:0x10c242ba0
2017-11-14 13:06:51.928224+0800 KVC&KVO[851:92433] After add observer————————————————————————–
2017-11-14 13:06:51.928316+0800 KVC&KVO[851:92433] isa:NSKVONotifying_PQCPeople,supperclass:PQCPeople
2017-11-14 13:06:51.928489+0800 KVC&KVO[851:92433] self:<PQCPeople: 0x604000059c50>, [self superclass]:NSObject
2017-11-14 13:06:51.928628+0800 KVC&KVO[851:92433] name setter function pointer:0x10c58f666
2017-11-14 13:06:51.928798+0800 KVC&KVO[851:92433] printInfo function pointer:0x10c242ba0
2017-11-14 13:06:51.928954+0800 KVC&KVO[851:92433] After remove observer————————————————————————–
2017-11-14 13:06:51.929077+0800 KVC&KVO[851:92433] isa:PQCPeople,supperclass:NSObject
2017-11-14 13:06:51.929268+0800 KVC&KVO[851:92433] self:<PQCPeople: 0x604000059c50>, [self superclass]:NSObject
2017-11-14 13:06:51.929431+0800 KVC&KVO[851:92433] name setter function pointer:0x10c2429d0
2017-11-14 13:06:51.929586+0800 KVC&KVO[851:92433] printInfo function pointer:0x10c242ba0
通过分析，我们会发现在添加KVO之后，isa 已经替换成了NSKVONotifying_PQCPeople,而根据 class_getSuperclass得到的结果竟然是 PQCPerson, 然后 namestr 是我们KVO需要观察的属性，它的 setter函数指针也变了。 
我们上面也说道， OC 的消息机制是通过 isa 去查找实现的，那么我们可以根据以上的分析，可以大致得出，KVO的实现应该是：

添加 Observe 
通过 runtime 偷偷实现了一个子类，并且以 NSKVONotifying_+类名 来命名； 
将之前那个对象的isa指针指向了这个子类； 
重写了观察的对象setter方法，并且在重写的中添加了willChangeValueForKey:以及didChangeValueForKey:
移除 Observe 
将 isa 的指向指回原来的类对象中。
因此，我们的 KVO 就是通过上述分析的这种机制，进行键值观察。

isa_swizzling.jpg

文末

通过上面的分析，我们也大概了解了 KVC 以及 KVO 的实现过程以及实现原理，对这个感兴趣的同学，我们可以试着去自己实现一下 KVC 以及 KVO。

