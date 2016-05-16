//
// ASJPushNotificationManager.m
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

#import "ASJPushNotificationDelegateHandler.h"
#import "ASJPushNotificationManager+Utils.h"
#import <objc/runtime.h>

NSString *const kDeviceTokenDefaultsKey = @"asj_device_token";
NSString *const ASJUserNotificationSettingsNotification = @"asj_user_notification_settings_notification";
NSString *const ASJTokenErrorNotification = @"asj_token_error_notification";
NSString *const ASJTokenReceivedNotification = @"asj_token_received_notification";
NSString *const ASJPushReceivedNotification = @"asj_push_received_notification";

@interface ASJPushNotificationManager ()

@property (copy, nonatomic) NSString *deviceToken;
@property (copy, nonatomic) NSString *deviceTokenPrivate;
@property (copy) CompletionBlock callback;

- (void)startListeningForAppDelegateNotifications;
- (void)registerForAlliOSDevices;
- (void)handleRegisteredSettings:(NSNotification *)note;
- (void)handleDeviceTokenError:(NSNotification *)note;
- (void)handleDeviceTokenReceived:(NSNotification *)note;
- (void)handlePushReceived:(NSNotification *)note;
- (void)stopListeningForAppDelegateNotifications;

@end

@implementation ASJPushNotificationManager

#pragma mark - Swizzling

+ (void)load
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^ {
    
    Class class = [ASJPushNotificationDelegateHandler class];
    Class appDelegateClass = [self appDelegateClass];
    
    for (NSString *selectorString in [self selectorsToSwizzle])
    {
      SEL selector = NSSelectorFromString(selectorString);
      
      Method originalMethod = class_getInstanceMethod(appDelegateClass, selector);
      Method swizzledMethod = class_getInstanceMethod(class, selector);
      
      // adding delegate method that's implemented here below to app delegate
      BOOL didAddMethod = class_addMethod(appDelegateClass, selector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
      
      // NO comes if delegate is implemented in AppDelegate
      if (!didAddMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
      }
      else {
        class_replaceMethod(class, selector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
      }
    }
  });
}

+ (Class)appDelegateClass
{
  unsigned int numberOfClasses = 0;
  Class *classes = objc_copyClassList(&numberOfClasses);
  
  for (unsigned int i=0; i<numberOfClasses; ++i)
  {
    Class class = classes[i];
    
    // does class adopt "UIApplicationDelegate" protocol?
    if (!class_conformsToProtocol(class, @protocol(UIApplicationDelegate))) {
      continue;
    }
    
    // ignore delegate handler class for adopting "UIApplicationDelegate" protocol
    if ([NSStringFromClass(class) isEqualToString:NSStringFromClass([ASJPushNotificationDelegateHandler class])]) {
      continue;
    }
    
    // all that's left
    return classes[i];
  }
  
  return nil;
}

+ (NSArray<NSString *> *)selectorsToSwizzle
{
  NSMutableArray *selectors = [[NSMutableArray alloc] init];
  [selectors addObject:@"application:didRegisterUserNotificationSettings:"];
  [selectors addObject:@"application:didFailToRegisterForRemoteNotificationsWithError:"];
  [selectors addObject:@"application:didRegisterForRemoteNotificationsWithDeviceToken:"];
  [selectors addObject:@"application:didReceiveRemoteNotification:"];
  [selectors addObject:@"application:handleActionWithIdentifier:forRemoteNotification:completionHandler:"];
  [selectors addObject:@"application:handleActionWithIdentifier:forRemoteNotification:withResponseInfo:completionHandler:"];
  
  // this one requires remote notification capability in info.plist
  NSArray *backgroundModes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIBackgroundModes"];
  if ([backgroundModes containsObject:@"remote-notification"])
  {
    [selectors addObject:@"application:didReceiveRemoteNotification:fetchCompletionHandler:"];
  }
  
  return [NSArray arrayWithArray:selectors];
}

#pragma mark - Singleton

+ (instancetype)sharedInstance
{
  static ASJPushNotificationManager *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

#pragma mark - Register

- (void)registerWithCompletion:(CompletionBlock)completion
{
  _callback = completion;
  
  // check and send back device token if already registered
  if (self.isAlreadyRegistered)
  {
    if (completion) {
      completion(self.deviceToken, nil);
    }
    return;
  }
  
  // start observing custom notifications which will be posted from delegate methods
  // after swizzling, the delegate methods are part of the perveived "AppDelegate" class
  // and not the current class, so we need a way to pass data from there to here
  [self startListeningForAppDelegateNotifications];
  
  // different way to register in iOS 7, changed from iOS 8
  [self registerForAlliOSDevices];
}

- (void)startListeningForAppDelegateNotifications
{
  [self.notificationCenter addObserver:self selector:@selector(handleRegisteredSettings:) name:ASJUserNotificationSettingsNotificationPrivate object:nil];
  
  [self.notificationCenter addObserver:self selector:@selector(handleDeviceTokenError:) name:ASJTokenErrorNotificationPrivate object:nil];
  
  [self.notificationCenter addObserver:self selector:@selector(handleDeviceTokenReceived:) name:ASJTokenReceivedNotificationPrivate object:nil];
  
  [self.notificationCenter addObserver:self selector:@selector(handlePushReceived:) name:ASJPushReceivedNotificationPrivate object:nil];
}

- (void)registerForAlliOSDevices
{
  if (self.isiOS8OrAbove)
  {
    [self.application registerUserNotificationSettings:self.iOS8NotificationSettings];
  }
  else
  {
    [self.application registerForRemoteNotificationTypes:self.iOS7NotificationTypes];
  }
}

#pragma mark - Notifications handling

- (void)handleRegisteredSettings:(NSNotification *)note
{
  // register for push
  [self.application registerForRemoteNotifications];
  
  UIUserNotificationSettings *userSettings = (UIUserNotificationSettings *)note.object;
  [self.notificationCenter postNotificationName:ASJUserNotificationSettingsNotification object:userSettings];
}

- (void)handleDeviceTokenError:(NSNotification *)note
{
  NSError *error = (NSError *)note.object;
  [self.notificationCenter postNotificationName:ASJTokenErrorNotification object:error];
  
  // token and error are also sent via block
  if (_callback) {
    _callback(nil,error);
  }
}

- (void)handleDeviceTokenReceived:(NSNotification *)note
{
  // convert device token data to string
  NSData *data = (NSData *)note.object;
  self.deviceToken = [ASJPushNotificationManager deviceTokenStringFromData:data];
  
  // send out public notification
  [self.notificationCenter postNotificationName:ASJTokenReceivedNotification object:self.deviceToken];
  
  // token and error are also sent via block
  if (_callback) {
    _callback(self.deviceToken, nil);
  }
}

- (void)handlePushReceived:(NSNotification *)note
{
  // send out public notification
  NSDictionary *userInfo = (NSDictionary *)note.object;
  [self.notificationCenter postNotificationName:ASJPushReceivedNotification object:userInfo];
}

#pragma mark - Unregister

- (void)unregister
{
  SEL unregister = @selector(unregisterForRemoteNotifications);
  
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
  if (self.isAlreadyRegistered)
  {
    if (self.application.isRegisteredForRemoteNotifications) {
      [self.application performSelector:unregister withObject:nil];
    }
  }
  else {
    [self.application performSelector:unregister withObject:nil];
  }
#pragma clang diagnostic pop
  
  // remove registered observers
  [self stopListeningForAppDelegateNotifications];
}

- (void)stopListeningForAppDelegateNotifications
{
  [self.notificationCenter removeObserver:self name:ASJUserNotificationSettingsNotificationPrivate object:nil];
  
  [self.notificationCenter removeObserver:self name:ASJTokenErrorNotificationPrivate object:nil];
  
  [self.notificationCenter removeObserver:self name:ASJTokenReceivedNotificationPrivate object:nil];
  
  [self.notificationCenter removeObserver:self name:ASJPushReceivedNotificationPrivate object:nil];
}

#pragma mark - Property

- (void)setDeviceToken:(NSString *)deviceToken
{
  if (deviceToken.length) {
    _deviceTokenPrivate = deviceToken;
  }
  
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:deviceToken];
  [self.userDefaults setObject:data forKey:kDeviceTokenDefaultsKey];
  [self.userDefaults synchronize];
}

- (NSString *)deviceToken
{
  if (_deviceTokenPrivate) {
    return _deviceTokenPrivate;
  }
  
  NSData *data = [self.userDefaults objectForKey:kDeviceTokenDefaultsKey];
  _deviceTokenPrivate = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  return _deviceTokenPrivate;
}

@end
