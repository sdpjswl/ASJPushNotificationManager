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

#import "ASJPushNotificationUtils.h"
#import "ASJPushNotificationDelegate.h"
#import <objc/runtime.h>

NSString *const kDeviceTokenDefaultsKey = @"asj_device_token";
NSString *const ASJAuthorizationSuccessfulNotification = @"asj_authorization_successful_notification";
NSString *const ASJAuthorizationFailedNotification = @"asj_authorization_failed_notification";
NSString *const ASJTokenErrorNotification = @"asj_token_error_notification";
NSString *const ASJTokenReceivedNotification = @"asj_token_received_notification";
NSString *const ASJPushReceivedNotification = @"asj_push_received_notification";

@interface ASJPushNotificationManager () <UNUserNotificationCenterDelegate>

@property (copy, nonatomic) NSString *deviceToken;
@property (copy, nonatomic) NSString *deviceTokenPrivate;
@property (copy) CompletionBlock callback;

- (void)startListeningForAppDelegateNotifications;
- (void)handleDeviceTokenError:(NSNotification *)note;
- (void)handleDeviceTokenReceived:(NSNotification *)note;
- (void)handlePushReceived:(NSNotification *)note;
- (void)stopListeningForAppDelegateNotifications;

@end

@implementation ASJPushNotificationManager

#pragma mark - Swizzling

/**
 *  Normally, the delegates related to push notifications come in 'AppDelegate'. I want to implement them elsewhere so that my 'AppDelegate' is not cluttered. The way to do this is swizzling.
 *  I am checking whether those delegate methods are implemented in 'AppDelegate'. If they are, I am exchanging their implementation with my own. If they aren't, I am adding my method+implementation in there. The best part of this is that control will come in those methods and it will be assumed that it's the 'AppDelegate' class.
 */
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        
        Class class = [ASJPushNotificationDelegate class];
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

/**
 *  It may happen that the 'AppDelegate' clsss in a project is not exactly called that. It may be have a prefix, or could be something entirely different. I am inferring what the 'AppDelegate' is by checking which classes adopt the 'UIApplicationDelegate' protocol. There will usually be only one such class. In my case, I am also adopting it in my custom delegate class, so I am ignoring it in my check.
 *
 *  @return The 'AppDelegate''s 'Class'
 */
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
        if ([NSStringFromClass(class) isEqualToString:NSStringFromClass([ASJPushNotificationDelegate class])]) {
            continue;
        }
        
        // all that's left
        return classes[i];
    }
    
    return nil;
}

/**
 *  These are the delegate methods that are being swizzled. The three with 'completionHandler:' are not present here.
 *
 *  @return An array of selector strings.
 */
+ (NSArray<NSString *> *)selectorsToSwizzle
{
    NSMutableArray *selectors = [[NSMutableArray alloc] init];
    [selectors addObject:@"application:didRegisterUserNotificationSettings:"];
    [selectors addObject:@"application:didFailToRegisterForRemoteNotificationsWithError:"];
    [selectors addObject:@"application:didRegisterForRemoteNotificationsWithDeviceToken:"];
    [selectors addObject:@"application:didReceiveRemoteNotification:"];
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

- (void)registerWithTypes:(ASJPushNotificationType)types categories:(nullable NSSet<UNNotificationCategory *> *)categories completion:(nullable CompletionBlock)completion
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
    
    // start observing custom notifications which will be posted from delegate methods. after swizzling, the delegate methods are part of the perceived 'AppDelegate' class and not the current class, so we need a way to pass data from there to here
    [self startListeningForAppDelegateNotifications];
    
    UNAuthorizationOptions options = (UNAuthorizationOptions)types;
    [self.userNotificationCenter requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error)
     {
        if (granted == NO)
        {
            // send out public notification
            [self.notificationCenter postNotificationName:ASJAuthorizationFailedNotification object:nil];
            return;
        }
        
        // register for push
        [self.application registerForRemoteNotifications];
        
        // send out public notification
        [self.notificationCenter postNotificationName:ASJAuthorizationSuccessfulNotification object:nil];
    }];
}

/**
 *  Private notifications are sent out by the custom delegate class. I am catching them and sending out public notifications.
 */
- (void)startListeningForAppDelegateNotifications
{
    [self.notificationCenter addObserver:self selector:@selector(handleDeviceTokenError:) name:ASJTokenErrorNotificationPrivate object:nil];
    
    [self.notificationCenter addObserver:self selector:@selector(handleDeviceTokenReceived:) name:ASJTokenReceivedNotificationPrivate object:nil];
    
    [self.notificationCenter addObserver:self selector:@selector(handlePushReceived:) name:ASJPushReceivedNotificationPrivate object:nil];
}

#pragma mark - Notifications handling

- (void)handleDeviceTokenError:(NSNotification *)note
{
    // send out public notification
    NSError *error = (NSError *)note.object;
    [self.notificationCenter postNotificationName:ASJTokenErrorNotification object:error];
    
    // token and error are also sent via block
    if (_callback) {
        _callback(nil, error);
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
    // check covers iOS 7 and 8+. same way for both
    if (self.isAlreadyRegistered) {
        [self.application unregisterForRemoteNotifications];
    }
    
    // remove registered observers
    [self stopListeningForAppDelegateNotifications];
}

- (void)stopListeningForAppDelegateNotifications
{
    [self.notificationCenter removeObserver:self name:ASJTokenErrorNotificationPrivate object:nil];
    
    [self.notificationCenter removeObserver:self name:ASJTokenReceivedNotificationPrivate object:nil];
    
    [self.notificationCenter removeObserver:self name:ASJPushReceivedNotificationPrivate object:nil];
}

#pragma mark - Device token

/**
 *  The device token is being archived into 'NSData' and saved in user defaults.
 */
- (void)setDeviceToken:(NSString *)deviceToken
{
    if (deviceToken.length == 0) {
        return;
    }
    
    NSData *data = nil;
    
    if (@available(iOS 11.0, *))
    {
        NSError *error = nil;
        data = [NSKeyedArchiver archivedDataWithRootObject:deviceToken requiringSecureCoding:YES error:&error];
        NSAssert((error == nil), @"Error archiving device token.");
    }
    else {
        data = [NSKeyedArchiver archivedDataWithRootObject:deviceToken];
    }
    
    [self.userDefaults setObject:data forKey:kDeviceTokenDefaultsKey];
    [self.userDefaults synchronize];
    
    _deviceTokenPrivate = deviceToken;
}

/**
 *  The device token is being retreived from  user defaults and unarchived back into 'NSString'.
 */
- (NSString *)deviceToken
{
    if (_deviceTokenPrivate) {
        return _deviceTokenPrivate;
    }
    
    NSData *data = [self.userDefaults objectForKey:kDeviceTokenDefaultsKey];
    NSString *token = nil;
    
    if (@available(iOS 11.0, *))
    {
        NSError *error = nil;
        token = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSString class] fromData:data error:&error];
        NSAssert((error == nil), @"Error unarchiving device token.");
    }
    else {
        token = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    _deviceTokenPrivate = token;
    return _deviceTokenPrivate;
}

@end
