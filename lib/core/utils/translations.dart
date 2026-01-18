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
  static String get blockedUsers => translate('blocked_users');
  static String get noBlockedUsers => translate('no_blocked_users');
  static String get usersBlocked => translate('users_blocked');
  static String get failedToLoadBlockedUsers => translate('failed_to_load_blocked_users');
  static String get anonymous => translate('anonymous');
  static String get unblockUser => translate('unblock_user');
  static String get blockUser => translate('block_user');
  static String get blockUserMessage => translate('block_user_message');
  static String get block => translate('block');
  static String get unblock => translate('unblock');
  static String get unblockUserMessage => translate('unblock_user_message');
  static String get userBlockedSuccess => translate('user_blocked_success');
  static String get userUnblockedSuccess => translate('user_unblocked_success');
  static String get failedToBlockUser => translate('failed_to_block_user');
  static String get failedToUnblockUser => translate('failed_to_unblock_user');
  static String get signOut => translate('sign_out');
  static String get signOutMessage => translate('sign_out_message');
  static String get appearance => translate('appearance');
  static String get pushNotifications => translate('push_notifications');
  static String get receiveNotifications => translate('receive_notifications');
  static String get appNameLabel => translate('app_name_label');
  static String get loading => translate('loading');
  static String get english => translate('english');
  static String get russian => translate('russian');
  static String get deletePromoCode => translate('delete_promo_code');
  static String get deletePromoCodeMessage => translate('delete_promo_code_message');
  static String get promoCodeDeleted => translate('promo_code_deleted');
  static String get failedToDelete => translate('failed_to_delete');
  static String get error => translate('error');
  static String get refresh => translate('refresh');
  static String get userNotFound => translate('user_not_found');
  static String get credibility => translate('credibility');
  static String get by => translate('by');
  static String get searchService => translate('search_service');
  static String get enterPromoCode => translate('enter_promo_code');
  static String get pleaseEnterPromoCode => translate('please_enter_promo_code');
  static String get optional => translate('optional');
  static String get addComment => translate('add_comment');
  static String get failedToCreatePromoCode => translate('failed_to_create_promo_code');
}

final translationsProvider = FutureProvider<void>((ref) async {
  final locale = ref.watch(localeProvider);
  await Translations.load(locale);
  return;
});
