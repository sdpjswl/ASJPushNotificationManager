//
// ASJPushNotificationManager.h
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

#import <Foundation/NSString.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CompletionBlock)(NSString * _Nullable deviceToken, NSError * _Nullable error);

@interface ASJPushNotificationManager : NSObject

/**
 *  The unique token for the iOS device. It will return 'nil' until you have registered without error.
 */
@property (nullable, readonly, copy, nonatomic) NSString *deviceToken;

/**
 *  The singleton object.
 *
 *  @return The instance of ASJPushNotificationManager.
 */
+ (instancetype)sharedInstance;

/**
 *  Register for notification settings and push notifications.
 *
 *  @param completion A block containing the device token and error. Both may be nil in different situations. You can access the device token at any time using the "deviceToken" property.
 */
- (void)registerWithCompletion:(nullable CompletionBlock)completion;

/**
 *  Unregister for remote notifications. You will stop seeing notifications in app after this. You can always re-register later.
 */
- (void)unregister;

@end

/**
 *  Notification posted when "application:didRegisterUserNotificationSettings:" is called.
 */
extern NSString *const ASJUserNotificationSettingsNotification;

/**
 *  Notification posted when "application:didFailToRegisterForRemoteNotificationsWithError:" is called.
 */
extern NSString *const ASJTokenErrorNotification;

/**
 *  Notification posted when "application:didRegisterForRemoteNotificationsWithDeviceToken:" is called.
 */
extern NSString *const ASJTokenReceivedNotification;

/**
 *  Notification posted when "application:didReceiveRemoteNotification:" or "application:didReceiveRemoteNotification:fetchCompletionHandler:" is called.
 */
extern NSString *const ASJPushReceivedNotification;

NS_ASSUME_NONNULL_END

// http://stackoverflow.com/questions/26258071/how-to-override-swizzle-a-method-of-a-private-class-in-runtime-objective-c

// http://stackoverflow.com/questions/22361427/how-to-swizzle-a-method-of-a-private-class

// https://www.google.co.in/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=swizzle%20method%20from%20one%20class%20to%20other

// http://stackoverflow.com/questions/20483159/can-you-swizzle-applicationdidreceiveremotenotification/33493541#33493541

// http://stackoverflow.com/questions/22085234/didreceiveremotenotification-fetchcompletionhandler-open-from-icon-vs-push-not

// http://stackoverflow.com/questions/29869352/ios-8-push-notification-action-buttons-code-in-handleactionwithidentifier-does

// http://stackoverflow.com/questions/9530075/ios-access-app-info-plist-variables-in-code

// https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplication_Class/index.html#//apple_ref/occ/instm/UIApplication/unregisterForRemoteNotifications


