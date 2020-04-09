# GCSpringiOS

# 实现对参数的自动注入，以及快速实现面向切面功能


[![CI Status](https://img.shields.io/travis/506227061@qq.com/GCSpringiOS.svg?style=flat)](https://travis-ci.org/506227061@qq.com/GCSpringiOS)
[![Version](https://img.shields.io/cocoapods/v/GCSpringiOS.svg?style=flat)](https://cocoapods.org/pods/GCSpringiOS)
[![License](https://img.shields.io/cocoapods/l/GCSpringiOS.svg?style=flat)](https://cocoapods.org/pods/GCSpringiOS)
[![Platform](https://img.shields.io/cocoapods/p/GCSpringiOS.svg?style=flat)](https://cocoapods.org/pods/GCSpringiOS)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### EXample1：实现自动注入参数
1.1 定义一个ViewModel类，遵守 GCSpringPrototypeProtocol 协议
@interface TestViewModel : NSObject<GCSpringPrototypeProtocol>

- (void)testRun;
- (void)testRun2:(id)obj;
- (void)testRun2:(id)obj withObj2:(id)obj2;
@end

@implementation TestViewModel
- (void)testRun {
    NSLog(@"%s - %@", __func__, self);
}

- (void)testRun2:(id)obj {
    NSLog(@"%s - %@ - %@", __func__, self, obj);
}

- (void)testRun2:(id)obj withObj2:(id)obj2 {
    NSLog(@"%s - %@ - %@ - %@", __func__, self, obj, obj2);
}
@end
1.2 在 AViewController 中增加属性 TestViewModel 
@interface AViewController : UIViewController

@property (nonatomic, strong) TestViewModel<GCAutoWriteProtocol> *testViewModel;

@end

@implementation AViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:UIColor.greenColor];
    NSLog(@"viewDidLoad");
    [_testViewModel testRun];
    [_testViewModel testRun2:@"11111"];
    [_testViewModel testRun2:@"22222" withObj2:@"33333"];
}
@end
1.3 执行打印
GCSpringiOS_Example[42707:3359415] -[TestViewModel testRun] - <TestViewModel: 0x600002303c40>
GCSpringiOS_Example[42707:3359415] -[TestViewModel testRun2:] - <TestViewModel: 0x600002303c40> - 11111
GCSpringiOS_Example[42707:3359415] -[TestViewModel testRun2:withObj2:] - <TestViewModel: 0x600002303c40> - 22222 - 33333

### EXample2：实现面向切面
2.1 定义一个ViewModel类，遵守 GCSpringPrototypeProtocol 和 GCBuildProxyProtocol 协议
@interface TestViewModel : NSObject<GCSpringPrototypeProtocol, GCBuildProxyProtocol>

- (void)testRun;
- (void)testRun2:(id)obj;
- (void)testRun2:(id)obj withObj2:(id)obj2;
@end

2.2 添加适应的对象和方法，以及被适应的方法
@implementation TestViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addAdapte:[[TestAdapte alloc] init] selName:@"testRun" adapterSelName:@"printTime"];
        [self addAdapte:[[TestAdapte alloc] init] selName:@"testRun2:" adapterSelName:@"printTime2:"];
        [self addAdapte:[[TestAdapte alloc] init] selName:@"testRun2:withObj2:" adapterSelName:@"printTime2:withObjc2:"];
    }
    return self;
}
@end

2.2 定义 TestAdapte 类，将printTime方法，插入到testRun方法之前或者之后

@implementation TestAdapte

- (void)printTime {
    NSLog(@"时间 = %f", [[NSDate date] timeIntervalSince1970]);
}

- (void)printTime2:(id)obj {
    NSLog(@"时间 = %f, %@", [[NSDate date] timeIntervalSince1970], obj);
}

- (void)printTime2:(id)obj1 withObjc2:(id)obj2 {
    NSLog(@"时间 = %f, %@, %@", [[NSDate date] timeIntervalSince1970], obj1, obj2);
}

2.3 执行打印
viewDidLoad
GCSpringiOS_Example[42819:3363254] 时间 = 1586414746.308509
GCSpringiOS_Example[42819:3363254] -[TestViewModel testRun] - <TestViewModel: 0x600000f4d8a0>
GCSpringiOS_Example[42819:3363254] 时间 = 1586414746.308986
GCSpringiOS_Example[42819:3363254] 时间 = 1586414746.309266, 11111
GCSpringiOS_Example[42819:3363254] -[TestViewModel testRun2:] - <TestViewModel: 0x600000f4d8a0> - 11111
GCSpringiOS_Example[42819:3363254] 时间 = 1586414746.309760, 11111
GCSpringiOS_Example[42819:3363254] 时间 = 1586414746.310046, 22222, 33333
GCSpringiOS_Example[42819:3363254] -[TestViewModel testRun2:withObj2:] - <TestViewModel: 0x600000f4d8a0> - 22222 - 33333
GCSpringiOS_Example[42819:3363254] 时间 = 1586414746.310619, 22222, 33333

## Requirements

## Installation

GCSpringiOS is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'GCSpringiOS'
```

## Author

506227061@qq.com, jianbao_hundun@163.com

## License

GCSpringiOS is available under the MIT license. See the LICENSE file for more info.

