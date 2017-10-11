//
//  KarteTrackerUtil.m
//  Pods
//

#import <Foundation/Foundation.h>
#import <sys/utsname.h>
#import "KarteTrackerUtil.h"

static BOOL _showLog = NO;

void KarteTrackerShowLog(BOOL showLog)
{
  _showLog = showLog;
}

void KarteTrackerLog(NSString *format, ...)
{
  if(!_showLog){
    return;
  }
  
  va_list arglist;
  va_start(arglist, format);
  
  NSLogv(format, arglist);
  
  va_end(arglist);
}

NSString * GetTrackerSerializeFilePath(NSString *filename)
{
  NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
  return [filePath stringByAppendingPathComponent:filename];
}

NSString * GetDeviceName()
{
  struct utsname info;
  uname(&info);
  
  return [NSString stringWithCString:info.machine encoding:NSUTF8StringEncoding];
}