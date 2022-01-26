//
//  ViewController.m
//  ASJPushNotificationManagerExample
//
//  Created by sudeep on 14/05/16.
//  Copyright © 2016 sudeep. All rights reserved.
//

#import "ViewController.h"
#import "ASJPushNotificationManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *deviceTokenLabel;
@property (readonly, weak, nonatomic) NSNotificationCenter *notificationCenter;
@property (readonly, weak, nonatomic) ASJPushNotificationManager *pushNotificationManager;

- (void)setup;
- (void)didReceivePushNotification:(NSNotification *)note;
- (IBAction)registerForPushNotifcations:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.notificationCenter removeObserver:self];
}

#pragma mark - Setup

- (void)setup
{
    [self.notificationCenter addObserver:self selector:@selector(didReceivePushNotification:) name:ASJPushReceivedNotification object:nil];
}

- (void)didReceivePushNotification:(NSNotification *)note
{
    NSString *description = [note.object description];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Push received" message:description preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (NSNotificationCenter *)notificationCenter
{
    return [NSNotificationCenter defaultCenter];
}

#pragma mark - IBAction

- (IBAction)registerForPushNotifcations:(id)sender
{
    ASJPushNotificationType types = ASJPushNotificationTypeAlert | ASJPushNotificationTypeBadge | ASJPushNotificationTypeSound;
    
    [self.pushNotificationManager registerWithTypes:types categories:nil completion:^(NSString * _Nullable deviceToken, NSError * _Nullable error)
     {
        NSString *text = nil;
        if (deviceToken.length) {
            text = [NSString stringWithFormat:@"Device token: %@", deviceToken];
        }
        else {
            text = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self->_deviceTokenLabel.text = text;
        }];
    }];
}

- (ASJPushNotificationManager *)pushNotificationManager
{
    return [ASJPushNotificationManager sharedInstance];
}

@end
