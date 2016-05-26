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
#import <UIKit/UIUserNotificationSettings.h>

typedef NS_ENUM(NSUInteger, ASJPushNotificationType) {
  ASJPushNotificationTypeNone = 0,
  ASJPushNotificationTypeBadge = 1 << 0,
  ASJPushNotificationTypeSound = 1 << 1,
  ASJPushNotificationTypeAlert
};

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
- (void)registerWithTypes:(ASJPushNotificationType)types categories:(nullable NSSet<UIUserNotificationCategory *> *)categories completion:(nullable CompletionBlock)completion;

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
