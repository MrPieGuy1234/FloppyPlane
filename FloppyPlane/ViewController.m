/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <KoboldKit.h>
#import <GameKit/GameKit.h>
#import "ViewController.h"
#import "GameScene.h"
#import "GCHelper.h"
#import "GADBannerView.h"
#import "GADInterstitial.h"
#import "RemoveAdsIAPHelper.h"

@implementation ViewController

-(void) presentFirstScene
{
	NSLog(@"%@", koboldKitCommunityVersion());
	NSLog(@"%@", koboldKitProVersion());

	// create and present first scene
	GameScene* scene = [[GameScene alloc] initWithSize:self.view.bounds.size andView:self];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [[GCHelper sharedInstance] authenticateLocalUser:self];
	[self.kkView presentScene:scene];
    
    [[RemoveAdsIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            self.products = products;
            NSLog(@"%li", (unsigned long)products.count);
        }
    }];
    
    self.request = [GADRequest request];
    // self.request.testDevices = @[@"b41e97b13f0801f8bcc3ede1edb7437f", @"00a197fca7eb71468a015ff07eb9101b"];
    [self.banner loadRequest:self.request];
}
- (BOOL)shouldAutorotate {
    return NO;
}
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)createBannerBottomAd {
    self.iadBanner = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    [self.iadBanner setDelegate:self];
    [self.kkView addSubview:self.iadBanner];
}
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [self.iadBanner performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    self.banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    self.banner.adUnitID = @"ca-app-pub-4565571048501936/9340871203";
    self.banner.rootViewController = self;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.banner.adSize = kGADAdSizeLeaderboard;
    }
    [self.kkView addSubview:self.banner];
}
- (void)createInterstitialAd {
    self.interstitial = [[GADInterstitial alloc] init];
    self.interstitial.adUnitID = @"ca-app-pub-4565571048501936/1817604404";
    [self reloadInterstitial];
}
- (void)reloadInterstitial {
    [self.interstitial loadRequest:self.request];
}
- (void)presentInterstitial {
    [self.interstitial presentFromRootViewController:self];
}
@end
