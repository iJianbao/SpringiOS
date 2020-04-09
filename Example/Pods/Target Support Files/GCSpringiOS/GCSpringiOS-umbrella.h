#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "GCApplicationContext.h"
#import "GCAutoWriteManager.h"
#import "GCBuildProxy.h"
#import "GCBuildProxyProtocol.h"
#import "GCSpringAutoWriteProtocol.h"
#import "GCSpringBeanProtocol.h"
#import "GCSpringiOS.h"
#import "NSObject+GCBuild.h"

FOUNDATION_EXPORT double GCSpringiOSVersionNumber;
FOUNDATION_EXPORT const unsigned char GCSpringiOSVersionString[];

