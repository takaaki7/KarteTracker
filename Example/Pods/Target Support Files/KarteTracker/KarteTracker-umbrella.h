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

#import "KarteTracker.h"
#import "KarteTrackerAppProfile.h"
#import "KarteTrackerConfig.h"
#import "KarteTrackerUserProfile.h"
#import "KarteTrackerUtil.h"

FOUNDATION_EXPORT double KarteTrackerVersionNumber;
FOUNDATION_EXPORT const unsigned char KarteTrackerVersionString[];

