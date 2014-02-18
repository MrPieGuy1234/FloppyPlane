//
//  RemoveAdsIAPHelper.m
//  FloppyPlane
//
//  Created by Donny on 2/17/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "RemoveAdsIAPHelper.h"

@implementation RemoveAdsIAPHelper

+ (RemoveAdsIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static RemoveAdsIAPHelper *sharedInstance;
    dispatch_once(&once, ^{
        NSSet *productIdentifiers = [NSSet setWithObjects:@"removeAds", nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
