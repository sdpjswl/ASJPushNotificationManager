# ASJPushNotificationManager

There is a lot of setup required to enable push/remote notifications in your app. You have to create certificates on the Apple developer portal and register for them in your project. I personally find that clutters up my `AppDelegate`.

The procedure to setup push notifications changed from iOS 8.0, and if your app still supports versions below, it means more code. This library abstracts away the code for registering device for push notifications and handles the delegate methods for you as well.

# Installation

CocoaPods is the recommended way to install this library. Just add the following command in your `Podfile` and run `pod install`:

```
pod 'ASJPushNotificationManager'
```

# Usage

You need to import `ASJPushNotificationManager.h` in the class where you need to ask the user permission to send them pushes. This class is a singleton and you are required to use its shared instance to access the defined properties and methods:

```objc
+ (instancetype)sharedInstance;
```

To register the device to receive push notifications, call:

```objc
- (void)registerWithCompletion:(NSString * _Nullable deviceToken, NSError * _Nullable error)completion;
```

When executed for the first time, it will prompt the user that the app would like to send push notifications. Depending on whether use allows or doesn't, the completion block will fire and you will receive the device token or error object.

The default delegate method `application:didRegisterForRemoteNotificationsWithDeviceToken:` returns the device token as `NSData`. It is converted into a usable `NSString` before you receive it in the block. You can pass this string on to your server like always.

The generated device token is always available for use as an exposed property:

```objc
@property (nullable, readonly, copy, nonatomic) NSString *deviceToken;
```

Note that it can be `nil`, in case user did not allow receiving push notifications.

If you want to stop receiving pushes in app, you can unregister:

```objc
- (void)unregister;
```

### Handling push events

All the usual delegate methods are abstracted away and **will not** be called even if you write them in `AppDelegate`. You will need to observe `NSNotification`s for the different events you are interested in. Just be sure to remove your observers in `dealloc`:

```objc
extern NSString *const ASJUserNotificationSettingsNotification;
```

Posted when `application:didRegisterUserNotificationSettings:` is called.

```objc
extern NSString *const ASJTokenErrorNotification;
```

Notification posted when `application:didFailToRegisterForRemoteNotificationsWithError:` is called.

```objc
extern NSString *const ASJTokenReceivedNotification;
```

Notification posted when `application:didRegisterForRemoteNotificationsWithDeviceToken:` is called.

```objc
extern NSString *const ASJPushReceivedNotification;
```

Notification posted when `application:didReceiveRemoteNotification:` or `application:didReceiveRemoteNotification:fetchCompletionHandler:` is called.

# Credits

- [NSHipster - Method Swizzling](http://nshipster.com/method-swizzling)
- [UIApplication Class Reference](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplication_Class/index.html#//apple_ref/occ/instm/UIApplication/unregisterForRemoteNotifications)
- [iOS: Access app-info.plist variables in code](http://stackoverflow.com/questions/9530075/ios-access-app-info-plist-variables-in-code)
- [didReceiveRemoteNotification: fetchCompletionHandler: open from icon vs push notification](http://stackoverflow.com/questions/22085234/didreceiveremotenotification-fetchcompletionhandler-open-from-icon-vs-push-not)
- [Can you swizzle application:didReceiveRemoteNotification:](http://stackoverflow.com/questions/20483159/can-you-swizzle-applicationdidreceiveremotenotification/33493541#33493541)
- [M2DPushNotificationManager](https://github.com/0x0c/M2DPushNotificationManager) let me know how to check status of push registeration on iOS 7

# License

`ASJPushNotificationManager` is available under the MIT license. See the LICENSE file for more info.
