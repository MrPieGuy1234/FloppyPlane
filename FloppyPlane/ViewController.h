/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <GameKit/GameKit.h>
#import "GADBannerView.h"
#import "GADInterstitial.h"

@interface ViewController : KKViewController <GKGameCenterControllerDelegate>

- (void)createBannerBottomAd;
- (void)createInterstitialAd;
- (void)presentInterstitial;
- (void)reloadInterstitial;


@property (nonatomic, strong) GADBannerView *banner;
@property (nonatomic, strong) GADInterstitial *interstitial;
@property (nonatomic) GADRequest *request;
@property (nonatomic, strong) NSArray *products;
@end
