import 'package:my_wordbook/data/ad_unit_id.dart';
import 'package:my_wordbook/providers/store_operations.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class AdService extends ChangeNotifier {
  //TAM SAYFA REKLAMLAR
  InterstitialAd? interstitialAd;
  int _clickCount = 0;
  bool _firstAdShown = false;
  void loadInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdUnitId.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  void showInterstitialAd() {
    if (!_firstAdShown) {
      if (interstitialAd != null) {
        interstitialAd!.show();
        _firstAdShown = true;
        _clickCount = 0;
      }
    } else {
      _clickCount++;
      if (_clickCount >= 3) {
        if (interstitialAd != null) {
          interstitialAd!.show();
          _clickCount = 0;
        }
      }
    }

    loadInterstitialAd();
  }

  void resetAdState() {
    _clickCount = 0;
    _firstAdShown = false;
    loadInterstitialAd();
  }

  //ÖDÜLLÜ REKLAMLAR
  RewardedAd? rewardedAd;
  bool isClicked = false;

  void loadRewardedAd() {
    RewardedAd.load(
        adUnitId: AdUnitId.rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            rewardedAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
          },
        ));
  }

  void showRewardedAd(BuildContext context, int money) {
    if (rewardedAd != null) {
      rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          Provider.of<StoreOperations>(context, listen: false)
              .calculateMoney(money);
          notifyListeners();
        },
      );

      // Reklam gösteriminden sonra temizleme
      rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint("RewardedAd dismissed.");
          ad.dispose();
          rewardedAd = null;
          isClicked = true;
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint("RewardedAd failed to show: $error");
          ad.dispose();
          rewardedAd = null;
        },
      );
    } else {
      debugPrint("RewardedAd is not ready yet.");
    }
  }

  //BANNER REKLAMLAR
  BannerAd? _bannerAd;

  BannerAd? get bannerAd => _bannerAd;

  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdUnitId.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.fluid,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner Ad Loaded');
          notifyListeners();
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Banner Ad Failed: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  void disposeAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }
}
