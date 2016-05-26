//
// ASJPushNotificationManager+Utils.m
//
// Copyright (c) 2016 Sudeep Jaiswal
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ASJPushNotificationManager+Utils.h"

@implementation ASJPushNotificationManager (Utils)

- (BOOL)isAlreadyRegistered
{
  BOOL canCheckForRegister = [self.application respondsToSelector:@selector(isRegisteredForRemoteNotifications)];
  
  if (canCheckForRegister) {
    return self.application.isRegisteredForRemoteNotifications;
  }
  
  return (self.application.enabledRemoteNotificationTypes != UIRemoteNotificationTypeNone);
}

- (BOOL)isiOS8OrAbove
{
  return [self.application respondsToSelector:@selector(registerUserNotificationSettings:)];
}

- (UIApplication *)application
{
  return [UIApplication sharedApplication];
}

- (NSNotificationCenter *)notificationCenter
{
  return [NSNotificationCenter defaultCenter];
}

- (NSUserDefaults *)userDefaults
{
  return [NSUserDefaults standardUserDefaults];
}

+ (NSString *)deviceTokenStringFromData:(NSData *)data
{
  const unsigned char *dataBuffer = (const unsigned char *)data.bytes;
  if (!dataBuffer) {
    return [[NSString alloc] init];
  }
  NSUInteger dataLength = data.length;
  NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
  for (int i=0; i<dataLength; ++i)
  {
    [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
  }
  return [NSString stringWithString:hexString];
}

@end
