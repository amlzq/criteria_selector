import 'package:flutter/material.dart';

/// Native design dimensions of the simulated phone (before any [FittedBox]
/// scaling). The inner [MediaQuery] in the playground uses [kPhoneContentSize]
/// so overlay / dialog / bottom-sheet sizing matches the actual screen area.
const double kPhoneWidth = 390;
const double kPhoneHeight = 844;
const double kPhonePadding = 12;
const double kStatusBarHeight = 44;
const double kHomeIndicatorHeight = 28;

/// Actual inner screen area of the phone, i.e. the [ClipRRect] content box after
/// the [kPhonePadding] is removed from all sides, minus the status bar and home
/// indicator. This must match the [MediaQuery] size the playground injects for
/// the scoped [Navigator], otherwise dropdown overlays clamp against a screen
/// rect that is wider/taller than the real phone and overflow on the right /
/// bottom (getting clipped by the phone shell).
const double kPhoneContentWidth = kPhoneWidth - 2 * kPhonePadding;
const double kPhoneContentHeight =
    kPhoneHeight - 2 * kPhonePadding - kStatusBarHeight - kHomeIndicatorHeight;
const Size kPhoneContentSize = Size(kPhoneContentWidth, kPhoneContentHeight);

/// A purely decorative phone shell that hosts the demo screen. The dropdown
/// overlays / dialogs / bottom sheets are routed into a scoped [Navigator]
/// inside [screen], so they render within the phone rather than on the app's
/// root overlay.
class PhoneFrame extends StatelessWidget {
  final Widget screen;

  const PhoneFrame({required this.screen, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kPhoneWidth,
      height: kPhoneHeight,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(46),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: ColoredBox(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              const _StatusBar(),
              Expanded(child: screen),
              const _HomeIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '9:41',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: <Widget>[
              Icon(Icons.signal_cellular_alt, color: Colors.black, size: 16),
              SizedBox(width: 6),
              Icon(Icons.wifi, color: Colors.black, size: 16),
              SizedBox(width: 6),
              Icon(Icons.battery_full, color: Colors.black, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      color: Colors.white,
      child: Center(
        child: Container(
          width: 120,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
