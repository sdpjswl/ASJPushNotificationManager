//
// ASJPushNotificationManager+Utils.h
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

#import "ASJPushNotificationManager.h"
#import <UIKit/UIApplication.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASJPushNotificationManager (Utils)

/**
 *  Is app already registered for remote notifications.
 */
@property (readonly, nonatomic) BOOL isAlreadyRegistered;

/**
 *  Is device version equal to or higher than iOS 8.0.
 */
@property (readonly, nonatomic) BOOL isiOS8OrAbove;

/**
 *  Convenience accessor for shared application object.
 */
@property (readonly, weak, nonatomic) UIApplication *application;

/**
 *  Convenience accessor for default notification center object.
 */
@property (readonly, weak, nonatomic) NSNotificationCenter *notificationCenter;

/**
 *  Convenience accessor for standard user defaults object.
 */
@property (readonly, weak, nonatomic) NSUserDefaults *userDefaults;

/**
 *  Device token is received as binary "NSData". This is a helper method to convert it into a usable "NSString" so that it can be sent to server.
 *
 *  @param data The device token "NSData".
 *
 *  @return The converted "NSString".
 */
+ (NSString *)deviceTokenStringFromData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
