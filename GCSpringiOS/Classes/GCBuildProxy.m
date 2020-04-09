//
//  GCBuildProxy.m
//  GCSpringiOS
//
//  Created by apple on 2020/3/18.
//

#import "GCBuildProxy.h"
#import "Objc/runtime.h"

@interface GCAdapterModel: NSObject

@property (nonatomic, strong) id adapter;
@property (nonatomic, copy) NSString *adaptedName;
@property (nonatomic, copy) NSString *adapteName;
@property (nonatomic, assign) AdapteType adapteType;

@end

@implementation GCAdapterModel

- (void)dealloc {
    NSLog(@"%@ --- %s", self, __FUNCTION__);
}

@end

@interface GCBuildProxy ()

// 被代理的类原型对象，需要强引用
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) NSMapTable<NSString *, NSArray<GCAdapterModel *> *> *adapteInfoMap;
// 暂存需要被适应的信息
//@property (nonatomic, strong) NSMapTable<id, NSArray<GCAdapterModel *> *> *tempProxyInfoMap;
@end

@implementation GCBuildProxy

- (instancetype)init:(id)tagert {
    self.delegate = tagert;
    /*
    NSArray *list = [[GCBuildProxy sharedProxy].tempProxyInfoMap objectForKey:tagert];
    for (GCAdapterModel *model in list) {
        [GCBuildProxy addAdapte:self adaptedName:model.adaptedName adapter:model.adapter adapteName:model.adapteName type:model.adapteType];
    }
    [[GCBuildProxy sharedProxy].tempProxyInfoMap removeObjectForKey:tagert];
     */
    return self;
}

// 提供一个单例，用来暂存需要被适应的信息
+ (instancetype)sharedProxy {
    static GCBuildProxy *sharedGCBuildProxy;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGCBuildProxy = [GCBuildProxy alloc];
    });
    return sharedGCBuildProxy;
}

+ (instancetype)buildProxy:(id)delegate {
    return [[GCBuildProxy alloc] init:delegate];
}
/** 增加一个被适应的方法
 * @param adaptedName 需要被适应的方法名称
 * @param adapter 适应类，包含适应的方法
 * @param adapteName 适应的方法，此方法需要在 adapter 中实现
 */
+ (void)addAdapte:(id)tagert adaptedName:(NSString *)adaptedName adapter:(id)adapter adapteName:(NSString *)adapteName type:(AdapteType)type {
    GCAdapterModel *model = [[GCAdapterModel alloc] init];
    model.adapter = adapter;
    model.adaptedName = adaptedName;
    model.adapteName = adapteName;
    model.adapteType = type;
    
    GCBuildProxy *proxy = tagert;
    NSArray *list = [proxy.adapteInfoMap objectForKey:adaptedName];
    NSMutableArray *modelList;
    if (list) {
        modelList = list.mutableCopy;
    }else {
        modelList = @[].mutableCopy;
    }
    [modelList addObject:model];
    [proxy.adapteInfoMap setObject:modelList forKey:adaptedName];
    NSLog(@"被适应信息 实现");
    /*
    const char * c = object_getClassName(tagert);
    const char * b = class_getName([GCBuildProxy class]);
    if (c != b) {
        NSArray *list = [[GCBuildProxy sharedProxy].tempProxyInfoMap objectForKey:tagert];
        NSMutableArray *modelList;
        if (list) {
            modelList = list.mutableCopy;
        }else {
            modelList = @[].mutableCopy;
        }
        [modelList addObject:model];
        [[GCBuildProxy sharedProxy].tempProxyInfoMap setObject:modelList forKey:tagert];
        NSLog(@"被适应信息 暂存");
    }else {
        GCBuildProxy *proxy = tagert;
        NSArray *list = [proxy.adapteInfoMap objectForKey:adaptedName];
        NSMutableArray *modelList;
        if (list) {
            modelList = list.mutableCopy;
        }else {
            modelList = @[].mutableCopy;
        }
        [modelList addObject:model];
        [proxy.adapteInfoMap setObject:modelList forKey:adaptedName];
        NSLog(@"被适应信息 实现");
    }*/
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [_delegate methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL sel = invocation.selector;
    NSString *selName = NSStringFromSelector(sel);
    NSArray<GCAdapterModel *> *list = [self.adapteInfoMap objectForKey:selName];
    if (list.count == 0) {
        [invocation invokeWithTarget:self.delegate];
    }else {
        for (GCAdapterModel *model in list) {
            [self readyExecute:invocation adapterModel:model];
        }
    }
}

- (void)readyExecute:(NSInvocation *)invocation adapterModel:(GCAdapterModel *)model {
    NSMutableArray *argumentArray = @[].mutableCopy;
    NSString *selNameStr = NSStringFromSelector(invocation.selector);
    NSInteger count = [selNameStr componentsSeparatedByString:@":"].count - 1;
    for (int i = 0; i < count; i++) {
        id argument;
        [invocation getArgument:&argument atIndex:2 + i];
        [argumentArray addObject:argument];
    }
    switch (model.adapteType) {
        case before: {
            [self startExecute:argumentArray adapterModel:model];
            [invocation invokeWithTarget:self.delegate];
        }
            break;
        case after: {
            [invocation invokeWithTarget:self.delegate];
            [self startExecute:argumentArray adapterModel:model];
        }
        default: {
            [self startExecute:argumentArray adapterModel:model];
            [invocation invokeWithTarget:self.delegate];
            [self startExecute:argumentArray adapterModel:model];
        }
            break;
    }
}

- (void)startExecute:(NSArray *)argumentList adapterModel:(GCAdapterModel *)model {
    SEL adapteSel = NSSelectorFromString(model.adapteName);
    NSInteger count = [model.adapteName componentsSeparatedByString:@":"].count - 1;
    NSMethodSignature *sig = [[model.adapter class] instanceMethodSignatureForSelector:adapteSel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    invocation.target = model.adapter;
    invocation.selector = adapteSel;
    for (int i = 0; i < count; i++) {
        id argument = nil;
        if (i < argumentList.count) {
            argument = argumentList[i];
        }
        [invocation setArgument:&argument atIndex:i + 2];
    }
    [invocation invoke];
}

- (NSMapTable<NSString *,NSArray<GCAdapterModel *> *> *)adapteInfoMap {
    if (_adapteInfoMap == nil) {
        _adapteInfoMap = [NSMapTable strongToStrongObjectsMapTable];
    }
    return _adapteInfoMap;
}

//- (NSMapTable<id, NSArray<GCAdapterModel *> *> *)tempProxyInfoMap {
//    if (_tempProxyInfoMap == nil) {
//        _tempProxyInfoMap = [NSMapTable weakToStrongObjectsMapTable];
//    }
//    return _tempProxyInfoMap;
//}

- (void)dealloc {
    NSLog(@"%@ --- %s", self, __FUNCTION__);
}
@end
