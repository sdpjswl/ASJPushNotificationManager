//
// ASJPushNotificationDelegate.m
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

#import "ASJPushNotificationDelegate.h"
#import <UIKit/UIApplication.h>

NSString *const ASJTokenErrorNotificationPrivate = @"asj_token_error_notification_private";
NSString *const ASJTokenReceivedNotificationPrivate = @"asj_token_received_notification_private";
NSString *const ASJPushReceivedNotificationPrivate = @"asj_push_received_notification_private";

@interface ASJPushNotificationDelegate () <UIApplicationDelegate>

@property (readonly, weak, nonatomic) NSNotificationCenter *notificationCenter;

@end

@implementation ASJPushNotificationDelegate

#pragma mark - UIApplicationDelegate

// failed
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [self.notificationCenter postNotificationName:ASJTokenErrorNotificationPrivate object:error];
}

// rec'd device token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self.notificationCenter postNotificationName:ASJTokenReceivedNotificationPrivate object:deviceToken];
}

// rec'd push
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self.notificationCenter postNotificationName:ASJPushReceivedNotificationPrivate object:userInfo];
}

#pragma mark - Property

- (NSNotificationCenter *)notificationCenter
{
    return [NSNotificationCenter defaultCenter];
}

@end
