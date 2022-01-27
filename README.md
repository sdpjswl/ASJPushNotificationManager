# ASJPushNotificationManager

There is a lot of setup required to enable push/remote notifications in your app. You have to create certificates on the Apple developer portal and register for them in your project. I personally find that clutters up my `AppDelegate`.

The procedure to setup push notifications changed from iOS 8.0, and if your app still supports versions below, it means more code. This library abstracts away the code for registering device for push notifications and handles the delegate methods for you as well.

# Installation

CocoaPods is the recommended way to install this library. Just add the following command in your `Podfile` and run `pod install`:

```ruby
pod 'ASJPushNotificationManager'
```

# Usage

You need to import `ASJPushNotificationManager.h` in the class where you need to ask the user permission to send them pushes. 

```objc
+ (instancetype)sharedInstance;
```

This class is a singleton and you are required to use its shared instance to access the defined properties and methods.

```objc
- (void)registerWithTypes:(ASJPushNotificationType)types categories:(nullable NSSet<UNNotificationCategory *> *)categories completion:(nullable CompletionBlock)completion;
```

Call this method to invoke the registration flow. When called for the first time, it will prompt the user that the app would like to send push notifications. The completion block will fire after the user makes a choice, and you will receive the device token or error object.

The default delegate method `application:didRegisterForRemoteNotificationsWithDeviceToken:` returns the device token as `NSData`. It is converted into a usable `NSString` before you receive it in the block. You can pass this string on to your server like always. **Note** that you will **not** get a token on simulator.

```objc
@property (nullable, readonly, copy, nonatomic) NSString *deviceToken;
```

The generated device token is always available for use as an exposed property. Note that it can be `nil`, in case user did not allow receiving push notifications.

```objc
- (void)unregister;
```

To stop receiving pushes in app, you can unregister.

### Handling push events

Most of the delegate methods are abstracted away and **will not** be called even if you write them in `AppDelegate` (See below). You will need to observe `NSNotification`s for the different events you are interested in. Just be sure to remove your observers in `dealloc`:

```objc
extern NSString *const ASJAuthorizationSuccessfulNotification;
```

Posted when permissions are granted.

```objc
extern NSString *const ASJAuthorizationFailedNotification;
```

Posted when permissions are not granted.

```objc
extern NSString *const ASJTokenErrorNotification;
```

Notification posted when `application:didFailToRegisterForRemoteNotificationsWithError:` is called.

```objc
extern NSString *const ASJTokenReceivedNotification;
```

Notification posted when `application:didRegisterForRemoteNotificationsWithDeviceToken:` is called.

```objc
extern NSString *const ASJSilentPushReceivedNotification;
```

Notification posted when `application:didReceiveRemoteNotification:fetchCompletionHandler:` is called.

```objc
extern NSString *const ASJVisiblePushReceivedNotification;
```

Notification posted when `userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:` is called.

### Note

For methods that have `completionHandler`, you **must** call the block in these methods for them to work. The block will be received as part of the `NSNotification`'s `object`.

# Credits

- [NSHipster - Method Swizzling](http://nshipster.com/method-swizzling)
- [UIApplication Class Reference](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplication_Class/index.html#//apple_ref/occ/instm/UIApplication/unregisterForRemoteNotifications)
- [iOS: Access app-info.plist variables in code](http://stackoverflow.com/questions/9530075/ios-access-app-info-plist-variables-in-code)
- [didReceiveRemoteNotification: fetchCompletionHandler: open from icon vs push notification](http://stackoverflow.com/questions/22085234/didreceiveremotenotification-fetchcompletionhandler-open-from-icon-vs-push-not)
- [Can you swizzle application:didReceiveRemoteNotification:](http://stackoverflow.com/questions/20483159/can-you-swizzle-applicationdidreceiveremotenotification/33493541#33493541)
- [Best way to serialize an NSData into a hexadeximal string](http://stackoverflow.com/questions/1305225/best-way-to-serialize-an-nsdata-into-a-hexadeximal-string)
- [M2DPushNotificationManager](https://github.com/0x0c/M2DPushNotificationManager) - Check status of push registration below iOS 8
- [Nick Lockwood's](https://github.com/nicklockwood) ['Deprecated' gist](https://gist.github.com/nicklockwood/d63c69ba2f40a33d7aa4) to get rid of iOS 7 warnings
- [Upgradation to iOS 10 - UserNotifications framework](https://www.plotprojects.com/blog/migrating-from-uilocalnotification-ios-10-dev-guide/)

# To-do

- ~~Add checks for iOS 7 so that there are no warnings.~~

# License

`ASJPushNotificationManager` is available under the MIT license. See the LICENSE file for more info.
