import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Platform-aware icon set for the app.
///
/// iOS gets the Cupertino glyphs (what users expect from system apps),
/// Android keeps the Material ones. Call sites stay one-liners:
///
/// ```dart
/// Icon(AppIcons.clock(isIOS: Platform.isIOS))
/// ```
class AppIcons {
  const AppIcons._();

  static IconData clock({required bool isIOS}) =>
      isIOS ? CupertinoIcons.clock : Icons.access_time_rounded;

  static IconData sync({required bool isIOS}) =>
      isIOS ? CupertinoIcons.arrow_2_circlepath : Icons.sync_rounded;

  static IconData gauge({required bool isIOS}) =>
      isIOS ? CupertinoIcons.gauge : Icons.speed_rounded;

  static IconData swap({required bool isIOS}) =>
      isIOS ? CupertinoIcons.arrow_left_right : Icons.swap_horiz_rounded;

  static IconData trendUp({required bool isIOS}) =>
      isIOS ? CupertinoIcons.graph_square : Icons.trending_up_rounded;

  static IconData wallet({required bool isIOS}) =>
      isIOS ? CupertinoIcons.creditcard : Icons.account_balance_wallet_rounded;

  static IconData cart({required bool isIOS}) =>
      isIOS ? CupertinoIcons.cart : Icons.shopping_cart_rounded;

  static IconData add({required bool isIOS}) =>
      isIOS ? CupertinoIcons.add : Icons.add_rounded;

  static IconData scan({required bool isIOS}) =>
      isIOS ? CupertinoIcons.doc_text_viewfinder : Icons.document_scanner_rounded;

  static IconData more({required bool isIOS}) =>
      isIOS ? CupertinoIcons.ellipsis : Icons.more_horiz_rounded;

  static IconData mic({required bool isIOS}) =>
      isIOS ? CupertinoIcons.mic_fill : Icons.mic_rounded;

  static IconData stop({required bool isIOS}) =>
      isIOS ? CupertinoIcons.stop_fill : Icons.stop_rounded;

  // ---- Settings rows ----

  static IconData appearance({required bool isDark, required bool isIOS}) =>
      isIOS
          ? (isDark ? CupertinoIcons.moon : CupertinoIcons.sun_max)
          : (isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined);

  static IconData currency({required bool isIOS}) =>
      isIOS ? CupertinoIcons.money_dollar_circle : Icons.payments_outlined;

  static IconData categories({required bool isIOS}) =>
      isIOS ? CupertinoIcons.square_grid_2x2 : Icons.category_outlined;

  static IconData profile({required bool isIOS}) =>
      isIOS ? CupertinoIcons.person : Icons.person_outline_rounded;

  static IconData language({required bool isIOS}) =>
      isIOS ? CupertinoIcons.globe : Icons.language_rounded;

  static IconData hideBalance({required bool isIOS}) =>
      isIOS ? CupertinoIcons.eye_slash : Icons.visibility_off_outlined;

  static IconData security({required bool isIOS}) =>
      isIOS ? CupertinoIcons.lock : Icons.lock_outline_rounded;

  static IconData rate({required bool isIOS}) =>
      isIOS ? CupertinoIcons.star : Icons.star_rounded;

  static IconData feedback({required bool isIOS}) =>
      isIOS ? CupertinoIcons.hand_thumbsup : Icons.thumb_up_alt_rounded;

  static IconData website({required bool isIOS}) =>
      isIOS ? CupertinoIcons.compass : Icons.public_rounded;

  static IconData camera({required bool isIOS}) =>
      isIOS ? CupertinoIcons.camera : Icons.camera_alt_rounded;

  static IconData privacy({required bool isIOS}) =>
      isIOS ? CupertinoIcons.hand_raised : Icons.privacy_tip_outlined;

  static IconData terms({required bool isIOS}) =>
      isIOS ? CupertinoIcons.doc_text : Icons.description_outlined;

  static IconData delete({required bool isIOS}) =>
      isIOS ? CupertinoIcons.trash : Icons.delete_outline_rounded;

  static IconData logout({required bool isIOS}) =>
      isIOS ? CupertinoIcons.arrow_right_square : Icons.logout_rounded;

  static IconData edit({required bool isIOS}) =>
      isIOS ? CupertinoIcons.pencil : Icons.edit_outlined;

  // ---- Assistant ----

  static IconData sparkles({required bool isIOS}) =>
      isIOS ? CupertinoIcons.sparkles : Icons.auto_awesome_rounded;

  static IconData sendUp({required bool isIOS}) =>
      isIOS ? CupertinoIcons.arrow_up : Icons.arrow_upward_rounded;

  static IconData arrowUpRight({required bool isIOS}) => isIOS
      ? CupertinoIcons.arrow_up_right
      : Icons.north_east_rounded;

  static IconData copy({required bool isIOS}) =>
      isIOS ? CupertinoIcons.doc_on_doc : Icons.copy_rounded;

  static IconData thumbUp({required bool isIOS}) =>
      isIOS ? CupertinoIcons.hand_thumbsup : Icons.thumb_up_alt_rounded;

  static IconData thumbDown({required bool isIOS}) =>
      isIOS ? CupertinoIcons.hand_thumbsdown : Icons.thumb_down_alt_rounded;

  static IconData check({required bool isIOS}) =>
      isIOS ? CupertinoIcons.checkmark : Icons.check_rounded;
}
