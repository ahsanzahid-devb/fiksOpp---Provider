import 'package:handyman_provider_flutter/locale/language_en.dart';

/// Norwegian translations.
///
/// This class extends [LanguageEn] so any string you don't override here
/// will automatically fall back to English. You can gradually add more
/// overrides as you translate.
class LanguageNo extends LanguageEn {
  @override
  String get appName => 'Bestillingssystem';

  @override
  String get signIn => 'Logg inn';

  @override
  String get signUp => 'Registrer deg';

  @override
  String get logout => 'Logg ut';

  @override
  String get hintEmailAddressTxt => 'E-post';

  @override
  String get hintNewPasswordTxt => 'Passord';

  @override
  String get confirm => 'Bekreft passord';

  @override
  String get forgotPassword => 'Glemt passord';

  @override
  String get resetPassword => 'Tilbakestill passord';

  @override
  String get changePassword => 'Endre passord';

  @override
  String get language => 'Språk';

  @override
  String get appTheme => 'Tema';

  @override
  String get bookingHistory => 'Bestillingshistorikk';

  @override
  String get provider => 'Leverandør';

  @override
  String get handyman => 'Tjeneste';

  @override
  String get description => 'Beskrivelse';

  @override
  String get address => 'Adresse';

  @override
  String get contactUs => 'Kontakt oss';

  @override
  String get aboutUs => 'Om oss';

  @override
  String get help => 'Hjelp';

  @override
  String get faq => 'Ofte stilte spørsmål';

  @override
  String get noDataFound => 'Ingen data funnet';

  @override
  String get somethingWentWrong => 'Noe gikk galt';

  @override
  String get internetNotAvailable => 'Internett er ikke tilgjengelig';

  @override
  String get requiredField => 'Dette feltet er obligatorisk';

  @override
  String get invalidEmail => 'Ugyldig e-postadresse';

  @override
  String get retry => 'Prøv igjen';

  @override
  String get refresh => 'Oppdater';

  @override
  String get welcome => 'Velkommen';

  @override
  String get viewAll => 'Se alle';

  @override
  String get seeMore => 'Se mer';

  @override
  String get seeLess => 'Se mindre';

  @override
  String get today => 'I dag';

  @override
  String get tomorrow => 'I morgen';
}
