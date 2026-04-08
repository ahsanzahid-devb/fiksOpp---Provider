import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

const APP_NAME = '';
const DEFAULT_LANGUAGE = 'en';

const primaryColor = Color(0xFF008080);

/// Live Url
const DOMAIN_URL = "https://fiksopp.inoor.buzz";

const BASE_URL = "$DOMAIN_URL/api/";

/// You can specify in Admin Panel, These will be used if you don't specify in Admin Panel
const IOS_LINK_FOR_PARTNER = "";
const TERMS_CONDITION_URL = 'https://fiksopp.com/brukeravtale-for-fiksopp/';
const PRIVACY_POLICY_URL =
    'https://fiksopp.com/personvernerklaering-for-fiksopp/';
const HELP_AND_SUPPORT_URL = '';
const REFUND_POLICY_URL = '';
const INQUIRY_SUPPORT_EMAIL = '';

/// You can add help line number here for contact. It's demo number
const HELP_LINE_NUMBER = '+15265897485';

//Airtel Money Payments
///It Supports ["UGX", "NGN", "TZS", "KES", "RWF", "ZMW", "CFA", "XOF", "XAF", "CDF", "USD", "XAF", "SCR", "MGA", "MWK"]
const AIRTEL_CURRENCY_CODE = "MWK";
const AIRTEL_COUNTRY_CODE = "MW";
const AIRTEL_TEST_BASE_URL = 'https://openapiuat.airtel.africa/'; //Test Url
const AIRTEL_LIVE_BASE_URL = 'https://openapi.airtel.africa/'; // Live Url

/// PAYSTACK PAYMENT DETAIL
const PAYSTACK_CURRENCY_CODE = 'NGN';

/// SADAD PAYMENT DETAIL
const SADAD_API_URL = 'https://api-s.sadad.qa';
const SADAD_PAY_URL = "https://d.sadad.qa";

/// RAZORPAY PAYMENT DETAIL
const RAZORPAY_CURRENCY_CODE = 'INR';

/// PAYPAL PAYMENT DETAIL
const PAYPAL_CURRENCY_CODE = 'USD';

/// STRIPE PAYMENT DETAIL
const STRIPE_MERCHANT_COUNTRY_CODE = 'IN';
const STRIPE_CURRENCY_CODE = 'INR';

Country defaultCountry() {
  return Country(
    phoneCode: '45',
    countryCode: 'DK',
    e164Sc: 91,
    geographic: true,
    level: 1,
    name: 'Denmark',
    example: '4523456789',
    displayName: 'Denmark (DK) [+45]',
    displayNameNoCountryCode: 'Denmark (DK)',
    e164Key: '45-DK-0',
    fullExampleWithPlusSign: '+454523456789',
  );
}

int _exampleDigitCount(Country c) =>
    c.example.replaceAll(RegExp(r'[^0-9]'), '').length;

Country resolveCountryForPhoneRules(Country country) {
  if (_exampleDigitCount(country) > 0) return country;

  if (country.countryCode.isNotEmpty) {
    final iso = CountryParser.tryParseCountryCode(
      country.countryCode.toUpperCase(),
    );
    if (iso != null && _exampleDigitCount(iso) > 0) return iso;
  }

  final pc = country.phoneCode.replaceAll(RegExp(r'[^0-9]'), '');
  if (pc.isNotEmpty) {
    final exact = CountryParser.tryParsePhoneCode(pc);
    if (exact != null && _exampleDigitCount(exact) > 0) return exact;
    for (var len = pc.length; len >= 1; len--) {
      final sub = pc.substring(0, len);
      final m = CountryParser.tryParsePhoneCode(sub);
      if (m != null && _exampleDigitCount(m) > 0) return m;
    }
    if (pc == '1') {
      final us = CountryParser.tryParseCountryCode('US');
      if (us != null && _exampleDigitCount(us) > 0) return us;
    }
  }

  return country;
}

int nationalPhoneMaxLength(Country country) {
  final c = resolveCountryForPhoneRules(country);
  final n = _exampleDigitCount(c);
  if (n == 0) return 12;
  if (c.phoneCode == '1') return n;
  return n + 1;
}

Country countryFromDialCodePrefix(String rawPrefix) {
  final digits = rawPrefix.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return defaultCountry();

  for (var len = digits.length; len >= 1; len--) {
    final sub = digits.substring(0, len);
    final match = CountryParser.tryParsePhoneCode(sub);
    if (match != null) return match;
  }

  if (digits.startsWith('1')) {
    return CountryParser.tryParseCountryCode('US') ?? defaultCountry();
  }

  return defaultCountry();
}

const chatFilesAllowedExtensions = [
  'jpg', 'jpeg', 'png', 'gif', 'webp', // Images
  'pdf', 'txt', // Documents
  'mkv', 'mp4', // Video
  'mp3', // Audio
];
const max_acceptable_file_size = 5; //Size in Mb
