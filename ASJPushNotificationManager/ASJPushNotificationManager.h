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
#import <UserNotifications/UNNotificationCategory.h>

typedef NS_ENUM(NSUInteger, ASJPushNotificationType)
{
    ASJPushNotificationTypeNone                             = 0,
    ASJPushNotificationTypeBadge                            = 1 << 0,
    ASJPushNotificationTypeSound                            = 1 << 1,
    ASJPushNotificationTypeAlert                            = 1 << 2,
    ASJAuthorizationOptionCarPlay                           = 1 << 3,
    ASJPushNotificationTypeCriticalAlert                    = 1 << 4,
    ASJPushNotificationTypeProvidesAppNotificationSettings  = 1 << 5,
    ASJPushNotificationTypeProvisional                      = 1 << 6,
    ASJPushNotificationTypeAnnouncement                     = 1 << 7,
    ASJPushNotificationTypeTimeSensitive                    = 1 << 8
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
 *  @return The instance of 'ASJPushNotificationManager'.
 */
+ (instancetype)sharedInstance;

/**
 *  Register for notification settings and push notifications.
 *
 *  @param types      You can specify the types of push notifications you'd like to receive. Check out 'ASJPushNotificationType' above. You can use bitmask to choose multiple types, like; ASJPushNotificationTypeNone | ASJPushNotificationTypeBadge, and so on.
 *  @param categories This needs to be an 'NSSet' of 'UIUserNotificationCategory's. This shows action buttons in the received push. It's optional and can be 'nil'.
 *  @param completion A block containing the device token and error. Both may be nil in different situations. You can access the device token at any time using the 'deviceToken' property.
 */
- (void)registerWithTypes:(ASJPushNotificationType)types categories:(nullable NSSet<UNNotificationCategory *> *)categories completion:(nullable CompletionBlock)completion;

/**
 *  Unregister for remote notifications. You will stop seeing notifications in app after this. You can always re-register later.
 */
- (void)unregister;

@end

/**
 *  Notification posted when permissions are granted.
 */
extern NSString *const ASJAuthorizationSuccessfulNotification;

/**
 *  Notification posted when permissions are not granted.
 */
extern NSString *const ASJAuthorizationFailedNotification;

/**
 *  Notification posted when 'application:didFailToRegisterForRemoteNotificationsWithError:' is called.
 */
extern NSString *const ASJTokenErrorNotification;

/**
 *  Notification posted when 'application:didRegisterForRemoteNotificationsWithDeviceToken:' is called.
 */
extern NSString *const ASJTokenReceivedNotification;

/**
 *  Notification posted when 'application:didReceiveRemoteNotification:fetchCompletionHandler:' is called.
 */
extern NSString *const ASJSilentPushReceivedNotification;

/**
 *  Notification posted when 'userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:' is called.
 */
extern NSString *const ASJVisiblePushReceivedNotification;

NS_ASSUME_NONNULL_END
