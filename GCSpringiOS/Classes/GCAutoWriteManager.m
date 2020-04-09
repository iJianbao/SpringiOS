//
//  GCAutoWriteManager.m
//  GCSpringiOS
//
//  Created by apple on 2020/4/9.
//

#import "GCAutoWriteManager.h"
#import "Objc/runtime.h"
#import "GCSpringAutoWriteProtocol.h"
#import "GCSpringBeanProtocol.h"
#import "GCBuildProxyProtocol.h"

#import "GCBuildProxy.h"
#import "NSObject+GCBuild.h"

@implementation GCAutoWriteModel

- (void)dealloc {
    NSLog(@"%@ --- %s", self, __FUNCTION__);
}

@end

@interface GCAutoWriteManager ()

// 以当前对象的归属对象为key，保存当前对象的信息
@property (nonatomic, strong) NSMapTable<id, NSArray<GCAutoWriteModel *> *> *autoWriteMap;
// 被读取的对象
@property (nonatomic, weak) id readedTagert;
// 被读取的对象的属性量
@property (nonatomic, assign) unsigned int readedCount;
@end

@implementation GCAutoWriteManager

// 获取属性
- (void)readProperty:(id)tagert {
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(object_getClass(tagert), &propertyCount);
    // 记录初始值
    if (!self.readedTagert) {
        self.readedTagert = tagert;
        self.readedCount = propertyCount;
        NSLog(@"总共属性量 = %d", propertyCount);
    }
    if (properties) {
        for (unsigned int i = 0; i < propertyCount; i++) {
            objc_property_t property = properties[i];
            [self readPropertyDetail:tagert withProperty:property];
        }
        if (self.readedTagert == tagert) {
            [self startInit:tagert];
        }
        free(properties);
    }
}

// 获取属性详情
- (void)readPropertyDetail:(id)tagert withProperty:(objc_property_t)property {
    NSString *properyName = [NSString stringWithUTF8String:property_getName(property)];
    NSLog(@"读取到的属性名称：%@", properyName);
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
    for (unsigned int i = 0; i < attrCount; i++) {
        NSLog(@"----%s", attrs[i].name);
        if (attrs[i].name[0] != 'T') {
            continue;
        }
        if (attrs[i].value) {
            NSString *typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
            NSScanner *scanner = [NSScanner scannerWithString:typeEncoding];
            if (![scanner scanString:@"@\"" intoString:NULL]) continue;
            
            NSString *claName;
            if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&claName]) {
                NSLog(@"扫描到的类名 %@", claName);
            }
            while ([scanner scanString:@"<" intoString:NULL]) {
                NSString* protocolName = nil;
                if ([scanner scanUpToString:@">" intoString:&protocolName]) {
                    NSString *autoWriteProtocolName= [NSString stringWithUTF8String:protocol_getName(@protocol(GCAutoWriteProtocol))];
                    if ([protocolName containsString:autoWriteProtocolName]) {
                        id objc = [self autoWrite:tagert properyClass:NSClassFromString(claName) properyName:properyName];
                        [self readProperty:objc];
                    }
                }
                [scanner scanString:@">" intoString:NULL];
            }
        }
    }
    free(attrs);
}

/// 根据遵守的协议，判断bean的类型
/// @param tagert 被创建实列的所属对象
/// @param class 被创建实列的类
/// @param name 被创建实列的名称
- (id)autoWrite:(id)tagert properyClass:(Class)class properyName:(NSString *)name {
    if ([class conformsToProtocol:@protocol(GCSpringPrototypeProtocol)]) {
        return [self prototype:tagert properyClass:class properyName:name];
    }else if ([class conformsToProtocol:@protocol(GCSpringCopyProtocol)]) {
        return [self copy:tagert properyClass:class properyName:name];
    }else if ([class conformsToProtocol:@protocol(GCSpringSingletonProtocol)]) {
        return [self singleton:tagert properyClass:class properyName:name];
    }else {
        // 其他类型实现了 GCAutoWriteProtocol 协议，默认采用 GCSpringPrototypeProtocol 的方式去注入
    }
    return nil;
}

/// 总是创建一个新的实列
/// @param tagert 被创建实列的所属对象
/// @param class 被创建实列的类
/// @param name 被创建实列的名称
- (id)prototype:(id)tagert properyClass:(Class)class properyName:(NSString *)name {
    // 只创建，不调用初始化方法
    id inst = [class alloc];
    // 判断是否需要被代理
    [self gc_write:tagert properyValue:inst properyClass:class properyName:name];
    // 创建关联对象
    GCAutoWriteModel *model = [[GCAutoWriteModel alloc] init];
    model.ascriptionObjc = tagert;
    model.protocol = @protocol(GCSpringPrototypeProtocol);
    model.currentObjc = inst;
    
    NSArray *array = [self.autoWriteMap objectForKey:tagert];
    NSMutableArray *mutArray = array ? array.mutableCopy : @[].mutableCopy;
    [mutArray addObject:model];
    
    [self.autoWriteMap setObject:mutArray forKey:tagert];
    self.gcCreatePrototypeBlock(model);
    return inst;
}

/// 引用之前保存的实列，不会重新创建一个
/// @param tagert 被创建实列的所属对象
/// @param class  被创建实列的类
/// @param name 被创建实列的名称
- (id)copy:(id)tagert properyClass:(Class)class properyName:(NSString *)name {
    id inst = nil;
    // 查找之前的实列，根据枚举器遍历值
    NSEnumerator *enumerator1 = [self.gcCreateCopyBlock() objectEnumerator];
    id obj;
    while (obj = [enumerator1 nextObject]) {
        if ([obj isKindOfClass:class]) {
            inst = obj;
        }
    }
    if (!inst) {
        NSLog(@"gc_copy：未找到之前存在的 %@ 引用", NSStringFromClass(class));
        assert(NO);
        return nil;
    }
    [self gc_write:tagert properyValue:inst properyClass:class properyName:name];
    return inst;
}

/// 单例模式
/// @param tagert 被创建实列的所属对象
/// @param class  被创建实列的类
/// @param name 被创建实列的名称
- (id)singleton:(id)tagert properyClass:(Class)class properyName:(NSString *)name {
    NSString *className = NSStringFromClass(class);
    // 查找之前的实列
    id inst = [self.gcCreateSingletonBlock(nil) objectForKey:className];
    if (inst == nil) {
        NSLog(@"gc_singleton：创建 %@ 的单例模式", className);
        // 只创建，不调用初始化方法
        inst = [class alloc];
        // 判断是否需要被代理
        [self gc_write:tagert properyValue:inst properyClass:class properyName:name];
        // 创建关联对象
        GCAutoWriteModel *model = [[GCAutoWriteModel alloc] init];
        model.ascriptionObjc = tagert;
        model.protocol = @protocol(GCSpringSingletonProtocol);
        model.currentObjc = inst;
        
        NSArray *array = [self.autoWriteMap objectForKey:tagert];
        NSMutableArray *mutArray = array ? array.mutableCopy : @[].mutableCopy;
        [mutArray addObject:model];
        
        [self.autoWriteMap setObject:mutArray forKey:tagert];
        self.gcCreateSingletonBlock(model);
    }
    return inst;
}

/// 自动注入方法
/// @param tagert 被注入的对象
/// @param value 注入对象
/// @param class 注入对象的类
/// @param name 注入对象的
- (void)gc_write:(id)tagert properyValue:(NSObject *)value properyClass:(Class)class properyName:(NSString *)name {
    // 是否实现切面代理协议
    if ([class conformsToProtocol:@protocol(GCBuildProxyProtocol)]) {
        id inst = [GCBuildProxy buildProxy:value];
        // 关联代理
        value.myBuildProxy = inst;
        // 使用 set 方法注入代理实列
        [tagert setValue:inst forKey:name];
    }else {
        // 使用 set 方法注入实例
        [tagert setValue:value forKey:name];
    }
}

/// 对tagert进行遍历执行初始化方法
/// @param tagert tagert
- (void)startInit:(id)tagert {
    NSArray<GCAutoWriteModel *> *array = [self.autoWriteMap objectForKey:tagert];
    for (GCAutoWriteModel *model in array) {
        [self executeInit:model];
    }
}

/// 递归执行初始化方法，从内到外进行执行
/// @param model 需要执行的对象所在的model
- (void)executeInit:(GCAutoWriteModel *)model {
    NSArray<GCAutoWriteModel *> *array = [self.autoWriteMap objectForKey:model.currentObjc];
    for (GCAutoWriteModel *model in array) {
        [self executeInit:model];
    }
    if (!model.isFinishInit) {
        NSLog(@"开始执行初始化方法 %@", model.currentObjc);
        id tagert = [((NSObject *)model.currentObjc) init];
        NSLog(@"结束执行初始化方法 %@", tagert);
        model.isFinishInit = YES;
    }
}

- (NSMapTable<id, NSArray<GCAutoWriteModel *> *> *)autoWriteMap {
    if (_autoWriteMap == nil) {
        _autoWriteMap = [NSMapTable weakToStrongObjectsMapTable];
    }
    return _autoWriteMap;
}

- (void)dealloc {
    NSLog(@"%@ --- %s", self, __FUNCTION__);
}

@end
