import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdArea extends StatefulWidget {
  const BannerAdArea({super.key});

  @override
  State<BannerAdArea> createState() => _BannerAdAreaState();
}

class _BannerAdAreaState extends State<BannerAdArea> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // This is the OFFICIAL Google Test ID for Android Banners.
  // ALWAYS use this for testing. Do not use your real ID yet.
  final String _adUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          print('Banner Ad failed to load: $err');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    // Return empty box if ad isn't loaded yet
    return const SizedBox.shrink();
  }
}