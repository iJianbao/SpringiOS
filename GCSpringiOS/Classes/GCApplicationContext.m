//
//  GCApplicationContext.m
//  GCSpringiOS_Example
//
//  Created by apple on 2020/3/5.
//  Copyright © 2020 506227061@qq.com. All rights reserved.
//

#import "GCApplicationContext.h"
#import "Objc/runtime.h"
#import "GCSpringBeanProtocol.h"
#import "GCSpringAutoWriteProtocol.h"
#import "GCBuildProxyProtocol.h"
#import "GCBuildProxy.h"
#import "GCAutoWriteManager.h"

@interface GCApplicationContext()
// 锁
@property (nonatomic, strong) NSLock *gcLock;
// 保存弱引用：key：实列，value：属性实列
@property (nonatomic, strong) NSMapTable *prototypeWeakMap;
// 保存强引用：key：属性类型名称，value：属性实列
@property (nonatomic, strong) NSMapTable *singletonStrongMap;
// 自动注入管理
@property (nonatomic, strong) GCAutoWriteManager *autoWriteManager;
@end

@implementation GCApplicationContext

static inline void gc_swizzleSelector(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

static inline BOOL gc_addMethod(Class theClass, SEL selector, Method method) {
    return class_addMethod(theClass, selector,  method_getImplementation(method),  method_getTypeEncoding(method));
}

+ (void)load {
    SEL originalSEL = @selector(viewDidLoad);
    SEL swizzledSEL = @selector(gc_viewDidLoad);
    Method swizzledMethod = class_getInstanceMethod([self class], swizzledSEL);
    if (gc_addMethod(UIViewController.class, swizzledSEL, swizzledMethod)) {
        gc_swizzleSelector(UIViewController.class, originalSEL, swizzledSEL);
    }
}

// 单例
+ (instancetype)sharedGCApplicationContext {
    static GCApplicationContext *sharedGCApplicationContext;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGCApplicationContext = [[self alloc] init];
        sharedGCApplicationContext.autoWriteManager = [[GCAutoWriteManager alloc] init];
    });
    return sharedGCApplicationContext;
}

- (void)gc_viewDidLoad {
    __weak typeof(self) weakSelf = self;
    GCAutoWriteManager *manager = [[GCAutoWriteManager alloc] init];
    manager.gcCreatePrototypeBlock = ^(GCAutoWriteModel * _Nonnull model) {
        [[GCApplicationContext sharedGCApplicationContext].gcLock lock];
        // 保留弱引用，根据类名去保存
        [[GCApplicationContext sharedGCApplicationContext].prototypeWeakMap setObject:model.currentObjc forKey:model.ascriptionObjc];
        [[GCApplicationContext sharedGCApplicationContext].gcLock unlock];
        [GCApplicationContext printInfo];
    };
    manager.gcCreateCopyBlock = ^NSMapTable * _Nonnull{
        return [GCApplicationContext sharedGCApplicationContext].prototypeWeakMap;
    };
    manager.gcCreateSingletonBlock = ^NSMapTable * _Nonnull(GCAutoWriteModel * _Nullable model) {
        if (model) {
            [[GCApplicationContext sharedGCApplicationContext].gcLock lock];
            // 保留强引用，根据类名去保存
            NSString *className = NSStringFromClass( object_getClass(model.currentObjc));
            [[GCApplicationContext sharedGCApplicationContext].singletonStrongMap setObject:model.currentObjc forKey:className];
            [[GCApplicationContext sharedGCApplicationContext].gcLock unlock];
            [GCApplicationContext printInfo];
        }
        return [GCApplicationContext sharedGCApplicationContext].singletonStrongMap;
    };
    [manager readProperty:weakSelf];
    [self gc_viewDidLoad];
}


- (NSLock *)gcLock {
    if (_gcLock == nil) {
        _gcLock = [[NSLock alloc] init];
    }
    return _gcLock;
}

- (NSMapTable *)prototypeWeakMap {
    if (_prototypeWeakMap == nil) {
        _prototypeWeakMap = [NSMapTable weakToWeakObjectsMapTable];
    }
    return _prototypeWeakMap;
}

- (NSMapTable *)singletonStrongMap {
    if (_singletonStrongMap == nil) {
        _singletonStrongMap = [NSMapTable strongToStrongObjectsMapTable];
    }
    return _singletonStrongMap;
}
/*
+ (void)gc_methodList:(Class)class {
    unsigned int count;
    Method *methods = class_copyMethodList(class, &count);
    for (int i = 0; i < count; i++) {
        SEL sel = method_getName(methods[i]);
        NSLog(@"读到方法 %s", sel_getName(sel));
        [self gc_invocationInstance:class methodName:sel];
    }
    free(methods);
}

+ (void)gc_invocationInstance:(Class)class methodName:(SEL)sel {
    NSMethodSignature *sig = [class instanceMethodSignatureForSelector:sel];
    // 1: 判断 构造方法
    if (![[NSString stringWithUTF8String:sel_getName(sel)] hasPrefix:@"init"]) {
        return;
    }
    const char *sigretun = sig.methodReturnType;  // 方法签名的返回值
    NSUInteger 6 = sig.methodReturnLength; // 方法签名返回值长度； 如果是字符串返回8，数字返回4，没有返回值返回0；
    // 2: 返回类型判断
    if (siglength == 0) {
        NSLog(@"没有返回值");
        return;
    }
    if (strcmp(sigretun, "@") != 0) {
        NSLog(@"返回值类型不是 id");
        return;
    }
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    
}
*/

+ (void)printInfo {
    NSLog(@"prototypeWeakMap：%@", [GCApplicationContext sharedGCApplicationContext].prototypeWeakMap);
    NSLog(@"singletonStrongMap：%@", [GCApplicationContext sharedGCApplicationContext].singletonStrongMap);
}

@end
