//
//  ASJPushNotificationDelegateHandler.m
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
#import <UIKit/UIApplication.h>

NSString *const ASJUserNotificationSettingsNotificationPrivate = @"asj_user_notification_settings_notification_private";
NSString *const ASJTokenErrorNotificationPrivate = @"asj_token_error_notification_private";
NSString *const ASJTokenReceivedNotificationPrivate = @"asj_token_received_notification_private";
NSString *const ASJPushReceivedNotificationPrivate = @"asj_push_received_notification_private";

@interface ASJPushNotificationDelegateHandler () <UIApplicationDelegate>

@end

@implementation ASJPushNotificationDelegateHandler

#pragma mark - UIApplicationDelegate

// registered user notification settings
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
  [[NSNotificationCenter defaultCenter] postNotificationName:ASJUserNotificationSettingsNotificationPrivate object:notificationSettings];
}

// failed
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
  [[NSNotificationCenter defaultCenter] postNotificationName:ASJTokenErrorNotificationPrivate object:error];
}

// rec'd device token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
  [[NSNotificationCenter defaultCenter] postNotificationName:ASJTokenReceivedNotificationPrivate object:deviceToken];
}

// rec'd push
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
  [[NSNotificationCenter defaultCenter] postNotificationName:ASJPushReceivedNotificationPrivate object:userInfo];
}

// rec'd push (block)
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
  completionHandler(UIBackgroundFetchResultNewData);
  
  [[NSNotificationCenter defaultCenter] postNotificationName:ASJPushReceivedNotificationPrivate object:userInfo];
}

/*
 
 - (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler NS_AVAILABLE_IOS(8_0);
 
 - (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler NS_AVAILABLE_IOS(9_0);
 */

@end
