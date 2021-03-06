//
//  ViewController.m
//  Example-objc
//
//  Created by Daniel Griesser on 03.03.20.
//  Copyright © 2020 Sentry. All rights reserved.
//

#import "ViewController.h"
@import Sentry;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [SentrySDK configureScope:^(SentryScope * _Nonnull scope) {
        [scope setEnvironment:@"debug"];
        [scope setTagValue:@"objc" forKey:@"langauge"];
        [scope setExtraValue:[NSString stringWithFormat:@"%@", self] forKey:@"currentViewController"];
    }];
}

- (IBAction)addBreadcrumb:(id)sender {
    SentryBreadcrumb *crumb = [[SentryBreadcrumb alloc] init];
    crumb.message = @"tapped addBreadcrumb";
    [SentrySDK addBreadcrumb:crumb];
}

- (IBAction)captureMessage:(id)sender {
    NSString *eventId = [SentrySDK captureMessage:@"Yeah captured a message"];
    // Returns eventId in case of successfull processed event
    // otherwise nil
    NSLog(@"%@", eventId);
}

- (IBAction)captureError:(id)sender {
    NSError *error = [[NSError alloc] initWithDomain:@"" code:0 userInfo:@{
        NSLocalizedDescriptionKey: @"Object does not exist"
    }];
    [SentrySDK captureError:error withScopeBlock:^(SentryScope * _Nonnull scope) {
        // Changes in here will only be captured for this event
        // The scope in this callback is a clone of the current scope
        // It contains all data but mutations only influence the event being sent
        [scope setTagValue:@"value" forKey:@"myTag"];
    }];
}

- (IBAction)captureException:(id)sender {
    NSException *exception = [[NSException alloc] initWithName:@"My Custom exeption" reason:@"User clicked the button" userInfo:nil];
    SentryScope *scope = [[SentryScope alloc] init];
    [scope setLevel:kSentryLevelFatal];
    // By explicity just passing the scope, only the data in this scope object will be added to the event
    // The global scope (calls to configureScope) will be ignored
    // Only do this if you know what you are doing, you loose a lot of useful info
    // If you just want to mutate what's in the scope use the callback, see: captureError
    [SentrySDK captureException:exception withScope:scope];
}

- (IBAction)crash:(id)sender {
    [SentrySDK crash];
}

@end
