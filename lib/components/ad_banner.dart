import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:budget_tracker/providers/ads_provider.dart';

class AdBanner extends ConsumerStatefulWidget {
  const AdBanner({super.key});

  @override
  AdBannerState createState() => AdBannerState();
}

class AdBannerState extends ConsumerState<AdBanner> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() {}),
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(adFreeProvider)) return const SizedBox();
    
    return _bannerAd != null
        ? Container(
            height: _bannerAd!.size.height.toDouble(),
            width: double.infinity,
            alignment: Alignment.center,
            child: AdWidget(ad: _bannerAd!),
          )
        : const SizedBox();
  }
}