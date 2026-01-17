import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';

class Translations {
  static Map<String, dynamic> _localizedValues = {};

  static Future<void> load(Locale locale) async {
    final String jsonString = await rootBundle.loadString(
      'assets/translations/${locale.languageCode}.json',
    );
    _localizedValues = json.decode(jsonString) as Map<String, dynamic>;
  }

  static String translate(String key) {
    return _localizedValues[key] ?? key;
  }

  static String get appName => translate('app_name');
  static String get home => translate('home');
  static String get profile => translate('profile');
  static String get settings => translate('settings');
  static String get postPromoCode => translate('post_promo_code');
  static String get promoCodeDetails => translate('promo_code_details');
  static String get noPromoCodes => translate('no_promo_codes');
  static String get errorLoading => translate('error_loading');
  static String get retry => translate('retry');
  static String get pleaseSignIn => translate('please_sign_in');
  static String get serviceName => translate('service_name');
  static String get promoCode => translate('promo_code');
  static String get comment => translate('comment');
  static String get expirationDate => translate('expiration_date');
  static String get selectExpirationDate => translate('select_expiration_date');
  static String get clearExpirationDate => translate('clear_expiration_date');
  static String get post => translate('post');
  static String get published => translate('published');
  static String get expires => translate('expires');
  static String get expired => translate('expired');
  static String get active => translate('active');
  static String get status => translate('status');
  static String get karma => translate('karma');
  static String get language => translate('language');
  static String get theme => translate('theme');
  static String get systemDefault => translate('system_default');
  static String get light => translate('light');
  static String get dark => translate('dark');
  static String get notifications => translate('notifications');
  static String get enableNotifications => translate('enable_notifications');
  static String get feedback => translate('feedback');
  static String get rateApp => translate('rate_app');
  static String get leaveReview => translate('leave_review');
  static String get about => translate('about');
  static String get version => translate('version');
  static String get appIcon => translate('app_icon');
  static String get account => translate('account');
  static String get deleteAccount => translate('delete_account');
  static String get deleteAccountMessage => translate('delete_account_message');
  static String get cancel => translate('cancel');
  static String get delete => translate('delete');
  static String get noExpiration => translate('no_expiration');
  static String get promoCodes => translate('promo_codes');
  static String get noPromoCodesYet => translate('no_promo_codes_yet');
  static String get pleaseSignInToVote => translate('please_sign_in_to_vote');
  static String get pleaseSignInToPost => translate('please_sign_in_to_post');
  static String get pleaseSelectService => translate('please_select_service');
  static String get promoCodePostedSuccess => translate('promo_code_posted_success');
  static String get failedToVote => translate('failed_to_vote');
  static String copied(String code) => '${translate("copied")}: $code';
  static String get selected => translate('selected');
}

final translationsProvider = FutureProvider<void>((ref) async {
  final locale = ref.watch(localeProvider);
  await Translations.load(locale);
  return;
});
