import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Phosphor Regular renders optically smaller than Font Awesome Solid at the
/// same logical size. [opticalScale] preserves visual parity after migration.
class AppIcon extends StatelessWidget {
  static const double opticalScale = 1.12;

  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final TextDirection? textDirection;

  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.textDirection,
  });

  static double renderSize(double designSize) => designSize * opticalScale;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final baseSize = size ?? theme.size ?? 24.0;

    return Icon(
      icon,
      size: renderSize(baseSize),
      color: color ?? theme.color,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
    );
  }
}

/// Phosphor Icons (Regular) used across the app.
abstract final class AppIcons {
  static const arrowLeft = PhosphorIconsRegular.arrowLeft;
  static const arrowRightFromBracket = PhosphorIconsRegular.signOut;
  static const arrowTrendDown = PhosphorIconsRegular.trendDown;
  static const arrowTrendUp = PhosphorIconsRegular.trendUp;
  static const bicycle = PhosphorIconsRegular.bicycle;
  static const book = PhosphorIconsRegular.book;
  static const bookOpen = PhosphorIconsRegular.bookOpen;
  static const boxesStacked = PhosphorIconsRegular.package;
  static const box = PhosphorIconsRegular.package;
  static const bullhorn = PhosphorIconsRegular.megaphone;
  static const bus = PhosphorIconsRegular.bus;
  static const calendar = PhosphorIconsRegular.calendar;
  static const calendarBlank = PhosphorIconsRegular.calendarBlank;
  static const calendarDots = PhosphorIconsRegular.calendarDots;
  static const car = PhosphorIconsRegular.car;
  static const cartShopping = PhosphorIconsRegular.shoppingCart;
  static const chartLine = PhosphorIconsRegular.chartLineUp;
  static const chartDonut = PhosphorIconsRegular.chartDonut;
  static const chartDonutFilled = PhosphorIconsFill.chartDonut;
  static const chartPie = PhosphorIconsRegular.chartPie;
  static const chartSimple = PhosphorIconsRegular.chartBar;
  static const check = PhosphorIconsRegular.check;
  static const chevronDown = PhosphorIconsRegular.caretDown;
  static const chevronRight = PhosphorIconsRegular.caretRight;
  static const chevronUp = PhosphorIconsRegular.caretUp;
  static const circleInfo = PhosphorIconsRegular.info;
  static const circleQuestion = PhosphorIconsRegular.question;
  static const cloud = PhosphorIconsRegular.cloud;
  static const coins = PhosphorIconsRegular.coins;
  static const creditCard = PhosphorIconsRegular.creditCard;
  static const crown = PhosphorIconsRegular.crown;
  static const desktop = PhosphorIconsRegular.desktop;
  static const dollarSign = PhosphorIconsRegular.currencyDollar;
  static const dumbbell = PhosphorIconsRegular.barbell;
  static const ellipsisVertical = PhosphorIconsRegular.dotsThreeVertical;
  static const envelope = PhosphorIconsRegular.envelope;
  static const fileInvoiceDollar = PhosphorIconsRegular.receipt;
  static const fileLines = PhosphorIconsRegular.fileText;
  static const gamepad = PhosphorIconsRegular.gameController;
  static const gift = PhosphorIconsRegular.gift;
  static const graduationCap = PhosphorIconsRegular.graduationCap;
  static const handshake = PhosphorIconsRegular.handshake;
  static const headset = PhosphorIconsRegular.headset;
  static const heartPulse = PhosphorIconsRegular.heartbeat;
  static const house = PhosphorIconsRegular.house;
  static const houseFilled = PhosphorIconsFill.house;
  static const inbox = PhosphorIconsRegular.tray;
  static const mobileScreen = PhosphorIconsRegular.deviceMobile;
  static const moneyBill = PhosphorIconsRegular.money;
  static const moneyBillWave = PhosphorIconsRegular.money;
  static const moon = PhosphorIconsRegular.moon;
  static const motorcycle = PhosphorIconsRegular.motorcycle;
  static const palette = PhosphorIconsRegular.palette;
  static const paw = PhosphorIconsRegular.pawPrint;
  static const pen = PhosphorIconsRegular.pencilSimple;
  static const planeDeparture = PhosphorIconsRegular.airplaneTakeoff;
  static const plus = PhosphorIconsRegular.plus;
  static const scaleBalanced = PhosphorIconsRegular.scales;
  static const scissors = PhosphorIconsRegular.scissors;
  static const screwdriverWrench = PhosphorIconsRegular.wrench;
  static const shapes = PhosphorIconsRegular.shapes;
  static const shield = PhosphorIconsRegular.shield;
  static const shoppingBag = PhosphorIconsRegular.shoppingBag;
  static const solidCircleUser = PhosphorIconsRegular.userCircle;
  static const solidUser = PhosphorIconsRegular.user;
  static const arrowsUpDown = PhosphorIconsRegular.arrowsDownUp;
  static const sortDown = PhosphorIconsRegular.sortDescending;
  static const star = PhosphorIconsRegular.star;
  static const sun = PhosphorIconsRegular.sun;
  static const taxi = PhosphorIconsRegular.taxi;
  static const train = PhosphorIconsRegular.train;
  static const trash = PhosphorIconsRegular.trash;
  static const triangleExclamation = PhosphorIconsRegular.warning;
  static const truck = PhosphorIconsRegular.truck;
  static const tv = PhosphorIconsRegular.television;
  static const userGear = PhosphorIconsRegular.userGear;
  static const utensils = PhosphorIconsRegular.forkKnife;
  static const wallet = PhosphorIconsRegular.wallet;
  static const wifi = PhosphorIconsRegular.wifiHigh;
  static const xmark = PhosphorIconsRegular.x;
}
