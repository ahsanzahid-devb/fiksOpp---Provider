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
  String get confirm => 'Bekreft';

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

  String get description => 'Beskrivelse';

  String get address => 'Adresse';

  String get contactUs => 'Kontakt oss';

  String get aboutUs => 'Om oss';

  String get help => 'Hjelp';

  String get faq => 'Ofte stilte spørsmål';

  @override
  String get noDataFound => 'Ingen data funnet';

  String get somethingWentWrong => 'Noe gikk galt';

  String get internetNotAvailable => 'Internett er ikke tilgjengelig';

  String get requiredField => 'Dette feltet er obligatorisk';

  String get invalidEmail => 'Ugyldig e-postadresse';

  String get retry => 'Prøv igjen';

  String get refresh => 'Oppdater';

  String get welcome => 'Velkommen';

  @override
  String get viewAll => 'Se alle';

  String get seeMore => 'Se mer';

  String get seeLess => 'Se mindre';

  @override
  String get today => 'I dag';

  @override
  String get tomorrow => 'I morgen';

  // ----- Profile / Settings -----
  @override
  String get setting => 'INNSTILLINGER';
  @override
  String get general => 'GENERELT';
  @override
  String get other => 'ANNET';
  @override
  String get pushNotification => 'Push-varsler';
  @override
  String get lblOptionalUpdateNotify => 'Varsling om oppdateringer';
  @override
  String get lblDangerZone => 'Faresone';
  @override
  String get lblDeleteAccount => 'Slett konto';
  @override
  String get lblDeleteAccountConformation =>
      'Kontoen din vil bli slettet permanent. Data kan ikke gjenopprettes.';
  @override
  String get lblCancel => 'Avbryt';
  @override
  String get lblDelete => 'Slett';
  @override
  String get saveChanges => 'Lagre endringer';
  @override
  String get lblEdit => 'Rediger';
  @override
  String get lblProfile => 'Profil';
  @override
  String get lblAccount => 'Konto';
  @override
  String get afterLogoutTxt =>
      'Vil du logge ut? Du kan alltid logge inn igjen.';
  @override
  String get chooseTheme => 'Velg app-tema';
  @override
  String get darkMode => 'Mørk modus';
  @override
  String get lightMode => 'Lys modus';
  @override
  String get systemDefault => 'Systemmodus';
  @override
  String get notification => 'Varsler';
  @override
  String get accept => 'Godta';
  @override
  String get decline => 'Avvis';
  @override
  String get lblOk => 'OK';
  @override
  String get hintRequired => 'Dette feltet er obligatorisk';
  @override
  String get hintOldPasswordTxt => 'Nåværende passord';
  @override
  String get hintReenterPasswordTxt => 'Skriv inn passord på nytt';
  @override
  String get changePasswordTitle =>
      'Det nye passordet må være forskjellig fra tidligere passord';
  @override
  String get passwordNotMatch => 'Passordene stemmer ikke overens';
  @override
  String get passwordLengthShouldBe => 'Passordet må være 8–12 tegn.';
  @override
  String get youMustProvideValidCurrentPassword =>
      'Du må oppgi et gyldig nåværende passord';
  @override
  String get doNotHaveAccount => 'Har du ikke konto?';
  @override
  String get alreadyHaveAccountTxt => 'Har du allerede konto?';
  @override
  String get rememberMe => 'Husk meg';
  @override
  String get forgotPasswordTitleTxt => 'Skriv inn e-postadressen din';
  @override
  String get hintFirstNameTxt => 'Fornavn';
  @override
  String get hintLastNameTxt => 'Etternavn';
  @override
  String get hintContactNumberTxt => 'Telefonnummer';
  @override
  String get hintUserNameTxt => 'Brukernavn';
  @override
  String get camera => 'Kamera';
  @override
  String get btnSave => 'Lagre';
  @override
  String get lblUpdate => 'Oppdater';
  @override
  String get notAvailable => 'Ikke tilgjengelig';
  @override
  String get confirmationRequestTxt =>
      'Er du sikker på at du vil utføre denne handlingen?';
  @override
  String get lblYes => 'Ja';
  @override
  String get lblNo => 'Nei';
  @override
  String get lblGallery => 'Galleri';
  @override
  String get cantLogin => 'Kan ikke logge inn';
  @override
  String get pleaseContactAdmin => 'Vennligst kontakt administrator';
  @override
  String get cannotChatWithYourself => 'Du kan ikke chatte med deg selv';
  @override
  String get selectCountry => 'Velg land';
  @override
  String get selectState => 'Velg region';
  @override
  String get selectCity => 'Velg by';
  @override
  String get review => 'Anmeldelser';
  @override
  String get paymentStatus => 'Betalingsstatus';
  @override
  String get paymentMethod => 'Betalingsmetode';
  @override
  String get hintAddress => 'Skriv inn adresse';
  @override
  String get quantity => 'Antall';
  @override
  String get lblReason => 'Årsak';
  @override
  String get lblAssign => 'Tildel';
  @override
  String get lblCall => 'Ring';
  @override
  String get lblAssignHandyman => 'Tildel håndverker';

  @override
  String get lblAssignBooking => 'Tildel booking';

  @override
  String get lblNoTeamMembersForAssign =>
      'Ingen teammedlemmer ennå. Du kan fortsatt tildele bookingen til deg selv nedenfor.';

  @override
  String get lblAssigned => 'Tildelt';
  @override
  String get lblSelectHandyman => 'Velg håndverker';
  @override
  String get lblMonthlyRevenue => 'Månedlig inntekt';
  @override
  String get lblRevenue => 'Inntekt';
  @override
  String get lblAddHandyman => 'Legg til håndverker';
  @override
  String get lblBooking => 'Bestillinger';
  @override
  String get lblTotalBooking => 'Totalt antall bestillinger';
  @override
  String get lblTotalService => 'Totalt antall tjenester';
  @override
  String get lblTotalHandyman => 'Totalt antall håndverkere';
  @override
  String get monthlyEarnings => 'Månedlig inntekt';
  @override
  String get lblPayment => 'Betalinger';
  @override
  String get lblBookingID => 'Bestillings-ID';
  @override
  String get lblPaymentID => 'Betalings-ID';
  @override
  String get lblAmount => 'Beløp';
  @override
  String get hintAddService => 'Legg til tjeneste';
  @override
  String get hintServiceName => 'Tjenestenavn';
  @override
  String get hintSelectCategory => 'Velg kategori';
  @override
  String get hintSelectType => 'Velg type';
  @override
  String get hintSelectStatus => 'Velg status';
  @override
  String get hintPrice => 'Pris';
  @override
  String get hintDiscount => 'Rabatt';
  @override
  String get hintDuration => 'Varighet';
  @override
  String get hintSetAsFeature => 'Sett som utvalgt';
  @override
  String get hintAdd => 'Legg til';
  @override
  String get hintChooseImage => 'Velg bilde';
  @override
  String get customer => 'Kunde';
  @override
  String get lblAllHandyman => 'Håndverkerliste';
  @override
  String get lblTime => 'Tid';
  @override
  String get lblMyService => 'Mine tjenester';
  @override
  String get lblAllService => 'Alle tjenester';
  @override
  String get lblChat => 'Samtale';
  @override
  String get selectAddress => 'Velg tjenesteadresser';
  @override
  String get editAddress => 'Rediger tjenesteadresse';
  @override
  String get lblServiceAddress => 'Tjenesteadresser';
  @override
  String get lblServices => 'Tjenester';
  @override
  String get lblEditService => 'Rediger tjeneste';
  @override
  String get lblDurationHr => 'Varighet: timer';
  @override
  String get lblDurationMin => 'Varighet: minutter';
  @override
  String get hintPassword => 'Passord';
  @override
  String get lblUnAuthorized => 'Demobruker kan ikke utføre denne handlingen';
  @override
  String get lblDate => 'Dato';
  @override
  String get lblEstimatedTime => 'Estimert tid';
  @override
  String get lblNotProvided => 'Ikke oppgitt';
  @override
  String get lblStatus => 'Status';
  @override
  String get lblAddress => 'Adresse';
  @override
  String get lblType => 'Type';
  @override
  String get lblWallet => 'Lommebok';
  @override
  String get lblWalletHistory => 'Lommebokhistorikk';
  @override
  String get lblSubmit => 'Send inn';
  @override
  String get lblTaxes => 'Avgifter';
  @override
  String get lblPrivacyPolicy => 'Personvernregler';
  @override
  String get lblTermsAndConditions => 'Vilkår og betingelser';
  @override
  String get lblHelpAndSupport => 'Hjelp og støtte';
  @override
  String get lblAbout => 'Om';
  @override
  String get lblRateUs => 'Vurder oss';
  @override
  String get pleaseTryAgain => 'Vennligst prøv igjen';
  @override
  String get lblSearchHere => 'Søk her...';
  @override
  String get handymanEarningList => 'Håndverkerinntekter';
  @override
  String get handymanCommission => 'Håndverkerprovisjon';
  @override
  String get packages => 'Pakker';
  @override
  String get addonServices => 'Tilleggstjenester';
  @override
  String get timeSlots => 'Tidsluker';
  @override
  String get bidList => 'Tilbudsliste';
  @override
  String get lblBankDetails => 'Bankopplysninger';
  @override
  String get promotionalBanners => 'Kampanjer';
  @override
  String get helpDesk => 'Kundeservice';
  @override
  String get walletBalance => 'Lommeboksaldo';

  // ----- Full Norwegian overrides (match language_en) -----
  @override
  String planAboutToExpire(int days) => 'Planen din utløper om $days dager';
  @override
  String get lblShowingOnly4Handyman => 'Viser kun 4 håndverkere';
  @override
  String get lblRecentlyOnlineHandyman => 'Nylig påloggede håndverkere';
  @override
  String get lblStartDrive => 'Start kjøring';

  @override
  String get selectImgNote =>
      'Merk: Du kan laste opp bilder med \'jpg\', \'png\', \'jpeg\' og velge flere bilder';

  @override
  String get lblWaitForAcceptReq =>
      'Vennligst vent på at admin godkjenner forespørselen din';
  @override
  String get lblAddServiceAddress => 'Legg til tjenesteadresse';
  @override
  String get errorPasswordLength => 'Passordlengden må være mer enn';

  @override
  String get btnVerifyId => 'Bekreft ID';
  @override
  String get confirmationUpload =>
      'Er du sikker på at du vil laste opp dette dokumentet?';
  @override
  String get toastSuccess => 'Leverandørdokument er lagret';
  @override
  String get lblSelectDoc => 'Velg dokument';
  @override
  String get lblAddDoc => 'Legg til dokumenter';

  @override
  String get lblProviderType => 'Leverandørtype';
  @override
  String get lblMyCommission => 'Min provisjon';
  @override
  String get lblTaxName => 'Avgiftsnavn';
  @override
  String get lblMyTax => 'Min avgift';
  @override
  String get lblLoginTitle => 'Hei igjen!';
  @override
  String get lblLoginSubtitle => 'Velkommen tilbake!';
  @override
  String get lblBySigningInYouAgree => 'Ved innlogging godtar du våre ';
  @override
  String get lblSignupTitle => 'Hei!';
  @override
  String get lblSignupSubtitle => 'Opprett konto for bedre opplevelse';
  @override
  String get lblSignup => 'Registrer deg';
  @override
  String get lblUserType => 'Brukertype';
  @override
  String get lblPurchaseCode => 'Kjøp full kildekode';
  @override
  String get lblRating => 'Vurdering';
  @override
  String get lblOff => 'Av';
  @override
  String get lblHr => 't';
  @override
  String get lblAboutHandyman => 'Om håndverker';
  @override
  String get lblAboutCustomer => 'Om kunde';
  @override
  String get lblPaymentDetail => 'Betalingsdetaljer';
  @override
  String get lblId => 'ID';
  @override
  String get lblMethod => 'Metode';
  @override
  String get lblPriceDetail => 'Prisdetaljer';
  @override
  String get lblSubTotal => 'Delsum';
  @override
  String get lblTax => 'Avgift';
  @override
  String get lblCoupon => 'Kupong';
  @override
  String get lblTotalAmount => 'Totalbeløp';
  @override
  String get lblOnBasisOf => 'Basert på';
  @override
  String get lblCheckStatus => 'Sjekk status';
  @override
  String get lblUnreadNotification => 'Uleste varsler';
  @override
  String get lblMarkAllAsRead => 'Merk alle som lest';
  @override
  String get lblCloseAppMsg => 'Trykk tilbake igjen for å avslutte';
  @override
  String get lblHandymanType => 'Håndverkertype';
  @override
  String get lblFixed => 'Fast';
  @override
  String get lblHello => 'Hei';
  @override
  String get lblWelcomeBack => 'Velkommen tilbake!';
  @override
  String get lblNoReviewYet => 'Ingen anmeldelser ennå';
  @override
  String get lblWaitingForResponse => 'Venter på svar';
  @override
  String get lblConfirmPayment => 'Bekreft betaling';
  @override
  String get lblDelivered => 'Levert';
  @override
  String get lblDay => 'Dag';
  @override
  String get lblYear => 'År';
  @override
  String get lblExperience => 'Erfaring';
  @override
  String get lblOf => '(er) av';
  @override
  String get lblSelectAddress => 'Velg adresse';
  @override
  String get lblOppS => 'Oops';
  @override
  String get lblNoInternet =>
      'Noe er galt med tilkoblingen. Vennligst prøv igjen.';
  @override
  String get lblRetry => 'PRØV IGJEN';
  @override
  String get lblServiceStatus => 'Tjenestestatus';
  @override
  String get lblMemberSince => 'Medlem siden';
  @override
  String get lblDeleteAddress => 'Slett adresse';
  @override
  String get lblDeleteAddressMsg => 'Vil du slette denne adressen?';
  @override
  String get lblChoosePaymentMethod => 'Velg betalingsmetode';
  @override
  String get lblNoPayments => 'Ingen betalinger';
  @override
  String lblPayWith(String title) => 'Vil du betale med $title?';
  @override
  String get lblProceed => 'Fortsett';
  @override
  String get lblPricingPlan => 'Prisplan';
  @override
  String get lblSelectPlan => 'Klar til å komme i gang?';
  @override
  String get lblMakePayment => 'Betal';
  @override
  String get lblRestore => 'Gjenopprett';
  @override
  String get lblForceDelete => 'Slett permanent';
  @override
  String get lblActivated => 'Aktivert';
  @override
  String get lblDeactivated => 'Deaktivert';
  @override
  String get lblNoDescriptionAvailable => 'Ingen beskrivelse tilgjengelig';
  @override
  String get lblFAQs => 'FAQ';
  @override
  String get lblGetDirection => 'Få rute';
  @override
  String get lblDeleteTitle => 'Vil du logge ut?';
  @override
  String get lblDeleteSubTitle => 'Vil du logge ut?';
  @override
  String get lblUpcomingServices => 'Kommende tjenester';
  @override
  String get lblTodayServices => 'Dagens bestillinger';
  @override
  String get lblPlanExpired => 'Planen er utløpt';
  @override
  String get lblPlanSubTitle => 'Din forrige plan er utløpt';
  @override
  String get btnTxtBuyNow => 'Kjøp nå';
  @override
  String get lblChooseYourPlan => 'Velg din plan';
  @override
  String get lblRenewSubTitle => 'Kjøp ny plan for å få nye bestillinger';
  @override
  String get lblReminder => 'Påminnelse';
  @override
  String get lblRenew => 'Forny';
  @override
  String get lblCurrentPlan => 'Gjeldende plan';
  @override
  String get lblValidTill => 'Gyldig til';

  @override
  String get lblEarningList => 'Inntektsliste';
  @override
  String get lblSubscriptionTitle => 'Vil du avbryte gjeldende plan?';
  @override
  String get lblPlan => 'Plan';
  @override
  String get lblCancelPlan => 'Avbryt plan';
  @override
  String get lblSubscriptionHistory => 'Abonnementshistorikk';
  @override
  String get lblTrashHandyman => 'Håndverker er slettet';
  @override
  String get lblPlsSelectAddress => 'Vennligst velg adresse';
  @override
  String get lblPlsSelectCategory => 'Vennligst velg kategori';
  @override
  String get lblEnterHours => 'Skriv inn timer (opptil 24)';
  @override
  String get lblEnterMinute => 'Skriv inn minutter (opptil 60)';
  @override
  String get lblSelectSubCategory => 'Velg underkategori';
  @override
  String get lblCategory => 'Kategori';
  @override
  String get lblServiceProof => 'Tjenestebevis';
  @override
  String get lblTitle => 'Tittel';
  @override
  String get lblAddImage => 'Legg til bilde';
  @override
  String get lblServiceRatings => 'Tjenestevurderinger';
  @override
  String get lblSelectCommission => 'Velg provisjon';
  @override
  String get lblIAgree => 'Jeg godtar';
  @override
  String get lblTermsOfService => 'Tjenestevilkår';
  @override
  String get lblLoginAgain => 'Vennligst logg inn igjen';
  @override
  String get lblTermCondition => 'Vennligst godta vilkår og betingelser';
  @override
  String get lblServiceTotalTime => 'Total tjenestetid';
  @override
  String get lblHelpLineNum => 'Hjelpelinje';

  @override
  String get lblAboutEmail => 'E-post';
  @override
  String get lblReasonCancelling => 'Årsak til avbestilling';
  @override
  String get lblReasonRejecting => 'Årsak til avvisning';
  @override
  String get lblFailed => 'Årsak til at bestillingen mislyktes';
  @override
  String get lblDesignation => 'Betegnelse';
  @override
  String get lblHandymanIsOffline => 'Håndverker er frakoblet';
  @override
  String get lblDoYouWantToRestore => 'Vil du gjenopprette?';
  @override
  String get lblDoYouWantToDeleteForcefully => 'Vil du slette permanent?';
  @override
  String get lblDoYouWantToDelete => 'Vil du slette?';
  @override
  String get lblPleaseEnterMobileNumber => 'Vennligst skriv inn mobilnummer';
  @override
  String get lblUnderMaintenance => 'Under vedlikehold...';
  @override
  String get lblCatchUpAfterAWhile => 'Sjekk igjen om en stund';
  @override
  String get lblRecheck => 'Sjekk igjen';
  @override
  String get lblTrialFor => 'Prøveperiode';
  @override
  String get lblDays => 'Dag(er)';
  @override
  String get lblFreeTrial => 'Gratis prøveperiode';
  @override
  String get lblAtLeastOneImage => 'Velg minst ett bilde';
  @override
  String get lblService => 'Tjeneste';
  @override
  String get lblNewUpdate => 'Ny oppdatering';
  @override
  String get lblAnUpdateTo => 'En oppdatering til ';
  @override
  String get lblIsAvailableWouldYouLike => 'er tilgjengelig. Vil du oppdatere?';
  @override
  String lblAreYouSureYouWantToAssignThisServiceTo(String name) =>
      'Vil du tildele denne tjenesten til $name?';
  @override
  String get lblAreYouSureYouWantToAssignToYourself =>
      'Vil du tildele til deg selv?';
  @override
  String get lblAssignToMyself => 'Tildel til meg';
  @override
  String get lblFree => 'Gratis';
  @override
  String get lblMyProvider => 'Min leverandør';
  @override
  String get lblAvailableStatus => 'Tilgjengelighetsstatus';
  @override
  String get lblYouAre => 'Du er';
  @override
  String get lblEmailIsVerified => 'E-post er bekreftet';
  @override
  String get lblHelp => 'Hjelp';
  @override
  String get lblAddYourCountryCode => 'Legg til landskode';
  @override
  String get lblRegistered => 'registrert';
  @override
  String get lblRequiredAfterCountryCode => 'påkrevd etter landskode';
  @override
  String get lblExtraCharges => 'Tilleggsgebyr';
  @override
  String get lblAddExtraCharges => 'Legg til tilleggsgebyr';
  @override
  String get lblCompleted => 'Fullført';
  @override
  String get lblAddExtraChargesDetail => 'Legg til gebyrdetaljer';
  @override
  String get lblEnterExtraChargesDetail => 'Skriv inn gebyrdetaljer';
  @override
  String get lblTotalCharges => 'Totale tilleggsgebyr';
  @override
  String get lblSuccessFullyAddExtraCharges => 'Tilleggsgebyr lagt til';
  @override
  String get lblChargeName => 'Gebyrdetaljer';
  @override
  String get lblPrice => 'Pris';
  @override
  String get lblEnterAmount => 'Skriv inn beløp';
  @override
  String get lblHourly => 'Per time';

  @override
  String get bidSavedSuccessfully => 'Tilbudet er lagret.';

  // ----- Missing Norwegian overrides (from missing_no_report) -----
  @override
  String get aboutYou => 'Om deg';
  @override
  String get accepted => 'Akseptert';
  @override
  String get accountNumber => 'Kontonummer';
  @override
  String get active => 'Aktiv';
  @override
  String get addAddonService => 'Legg til tilleggstjeneste';
  @override
  String get addBank => 'Legg til bank';
  @override
  String get addBlog => 'Legg til blogg';
  @override
  String get addEssentialSkill => 'Legg til ferdighet';
  @override
  String get addHandymanCommission => 'Legg til håndverkerprovisjon';
  @override
  String get addHandymanPayout => 'Legg til håndverkerutbetaling';
  @override
  String get addKnownLanguage => 'Legg til kjent språk';
  @override
  String get addNew => 'Legg til ny';
  @override
  String get addOns => 'Tillegg';
  @override
  String get addPackage => 'Legg til pakke';
  @override
  String get addPromotionalBanner => 'Legg til kampanjelogo';
  @override
  String get addReason => 'Legg til årsak';
  @override
  String get addReasons => 'Legg til årsaker';
  @override
  String get addonServiceName => 'Navn på tilleggstjeneste';
  @override
  String get admin => 'Administrator';
  @override
  String get adminApprovedTheRequest => 'Admin godkjente forespørselen';
  @override
  String get adminEarning => 'Admininntekt';
  @override
  String get advancePaid => 'Forhåndsbetalt';
  @override
  String get advancePayAmountPer => 'Forhåndsbetaling (%)';
  @override
  String get advancePayment => 'Forhåndsbetaling';
  @override
  String get advancedRefund => 'Avansert refusjon';
  @override
  String get advertiseYourServicesEffectively =>
      'Reklamer for tjenestene dine og få mer engasjement.';
  @override
  String get airtelMoney => 'Airtel Money';
  @override
  String get airtelMoneyPayment => 'Airtel Money-betaling';
  @override
  String get all => 'Alle';
  @override
  String get ambiguous => 'Uklar';
  @override
  String get amountToBeReceived => 'Beløp som mottas';
  @override
  String get appliedTaxes => 'Betalte avgifter';
  @override
  String get apply => 'Bruk';
  @override
  String get approved => 'Godkjent';
  @override
  String get approvedByAdmin => 'Godkjent av admin';
  @override
  String get approvedByHandyman => 'Godkjent av håndverker';
  @override
  String get approvedByProvider => 'Godkjent av leverandør';
  @override
  String get apr => 'apr';
  @override
  String get areYouSureWantToDeleteThe => 'Er du sikker på at du vil slette';
  @override
  String get areYouSureWantToRemoveThisFile =>
      'Er du sikker på at du vil fjerne denne filen?';
  @override
  String get assigned => 'Tildelt';
  @override
  String get assignedProvider => 'Tildelt leverandør';
  @override
  String get at => 'kl.';
  @override
  String get aug => 'aug';
  @override
  String get authorBy => 'Av';
  @override
  String get availableAt => 'Tilgjengelig sted';
  @override
  String get availableBalance => 'Tilgjengelig saldo';
  @override
  String get badGateway => '502: Feil gateway';
  @override
  String get badRequest => '400: Feil forespørsel';
  @override
  String get bank => 'Bank';
  @override
  String get bankAddress => 'Bankadresse';
  @override
  String get bankList => 'Bankliste';
  @override
  String get bankName => 'Banknavn';
  @override
  String get bid => 'Tilbud';
  @override
  String get blogs => 'Blogger';
  @override
  String get booking => 'Bestilling';
  @override
  String get bookingStatus => 'Bestillingsstatus';
  @override
  String get branchName => 'Avdeling';
  @override
  String get browse => 'Bla';
  @override
  String get by => 'av';
  @override
  String get canTFindRevenuecatProduct => 'Finner ikke revenueCat-produkt';
  @override
  String get cancelled => 'Kansellert';
  @override
  String get cash => 'Kontant';
  @override
  String get cashBalance => 'Kontantsaldo';
  @override
  String get cashList => 'Kontantliste';
  @override
  String get cashManagement => 'Kontanthåndtering';
  @override
  String get cashPaymentApproval => 'Godkjenning av kontantbetaling';
  @override
  String get cashPaymentConfirmation => 'Bekreftelse av kontantbetaling';
  @override
  String get cashStatus => 'Kontantstatus';
  @override
  String get categoryBasedPackage => 'Kategoripakke';
  @override
  String get chatCleared => 'Chat tømt';
  @override
  String get chooseAction => 'Velg handling';
  @override
  String get chooseAnyOnePayment => 'Velg minst én betalingsmetode';
  @override
  String get chooseBank => 'Velg bank';
  @override
  String get chooseCashOrContactAdminForBankInformation =>
      'Velg kontant eller kontakt admin for bankopplysninger';
  @override
  String get chooseImage => 'Velg bilde';
  @override
  String get choosePaymentMethod => 'Velg betalingsmetode';
  @override
  String get chooseService => 'Velg tjeneste';
  @override
  String get chooseTime => 'Velg tid';
  @override
  String get chooseWithdrawalMethod => 'Velg uttaksmetode';
  @override
  String get chooseYourDateRange => 'Velg datoperiode';
  @override
  String get cinet => 'Cinet';
  @override
  String get cinetpayIsnTSupportedByCurrencies =>
      'CinetPay støttes ikke av valutaen din';
  @override
  String get clearChat => 'Tøm chat';
  @override
  String get clearChatMessage => 'Vil du tømme denne chaten?';
  @override
  String get clearFilter => 'Nullstill filter';
  @override
  String get close => 'Lukk';
  @override
  String get closeApp => 'Lukk app';
  @override
  String get closed => 'LUKKET';
  @override
  String get closedBy => 'Lukket av';
  @override
  String get closedOn => 'Lukket:';
  @override
  String get commission => 'Provisjon';
  @override
  String get completed => 'Fullført';
  @override
  String get completedBookings => 'Fullførte bestillinger';
  @override
  String get confirmationRemovePackage =>
      'Vil du fjerne denne tjenesten fra pakken?';
  @override
  String get connect => 'Koble til';
  @override
  String get connectWithFirebaseForChat => 'Koble til Firebase for chat';
  @override
  String get copied => 'Kopiert';
  @override
  String get copyMessage => 'Kopier melding';
  @override
  String get copyTo => 'Kopier til';
  @override
  String get couldNotFetchEncryption => 'Kunne ikke hente krypteringsnøkkel';
  @override
  String get createBy => 'Opprettet av';
  @override
  String get credit => 'Kreditt';
  @override
  String get customDate => 'Egendefinert dato';
  @override
  String get customerNotFound => 'Kunde ikke funnet';
  @override
  String get dateRange => 'Datoperiode';
  @override
  String get day => 'Dag';
  @override
  String daysSelected(String totalDaysCount) => '$totalDaysCount dager valgt';
  @override
  String get debit => 'Debet';
  @override
  String get dec => 'des';
  @override
  String get deleteBankTitle =>
      'Er du sikker på at du vil slette denne banken?';
  @override
  String get deleteBlogTitle => 'Vil du slette denne bloggen?';
  @override
  String get deleteMessage => 'Slett melding';
  @override
  String get detailsOfTheBank => 'Bankdetaljer';
  @override
  String get digitalService => 'Digital tjeneste';
  @override
  String get digitalServiceSwitchSubText =>
      'Digital bestilling med oppdatert status.';
  @override
  String get disable => 'deaktiver';
  @override
  String get disabled => 'Deaktivert';
  @override
  String get doNotHonor => 'Avvist';
  @override
  String get doWantToDelete => 'Vil du slette denne tjenesten?';
  @override
  String get doYouWantClosedThisQuery => 'Vil du lukke denne henvendelsen?';
  @override
  String get doYouWantTo => 'Vil du';
  @override
  String get doYouWantToDeleteBanner => 'Vil du slette dette kampanjelogoen?';
  @override
  String get doesThisServicesContainsTimeslot =>
      'Har denne tjenesten tidsluker?';
  @override
  String get done => 'Ferdig';
  @override
  String get dropYourFilesHereOr => 'Slipp filer her eller';
  @override
  String get eGDamagedFurniture => 'f.eks. Skadet møbel';
  @override
  String get eGDuringTheService => 'f.eks. Under tjenesten ble møbelet skadet.';
  @override
  String get eGHandymanTrustedService => 'f.eks. Pålitelig håndverkertjeneste';
  @override
  String get eGHttpsWwwYourlinkCom => 'f.eks. https://www.dinlenke.no';
  @override
  String get earningDetails => 'Inntektsdetaljer';
  @override
  String get editAddonService => 'Rediger tilleggstjeneste';
  @override
  String get editHandymanCommission => 'Rediger håndverkerprovisjon';
  @override
  String get editPackage => 'Rediger pakke';
  @override
  String get editProfile => 'Rediger profil';
  @override
  String get eg3000 => 'f.eks. 3000';
  @override
  String get egCentralNationalBank => 'f.eks. Sentralbank';
  @override
  String get email => 'E-post:';
  @override
  String get enable => 'aktiver';
  @override
  String get enablePrePayment => 'Aktiver forhåndsbetaling';
  @override
  String get enablePrePaymentMessage =>
      'Tillat at tjenesten betales på forhånd.';
  @override
  String get enabled => 'Aktivert';
  @override
  String get encryptionKeyHasBeen => 'Krypteringsnøkkel er hentet.';
  @override
  String get endDate => 'Sluttdato';
  @override
  String get enterBidPrice => 'Skriv inn tilbudspris';
  @override
  String get enterBlogTitle => 'Skriv inn bloggtittel';
  @override
  String get enterLink => 'Skriv inn lenke';
  @override
  String get enterValidCommissionValue => 'Skriv inn gyldig provisjonsverdi';
  @override
  String get enterYourMsisdnHere => 'Skriv inn mobilnummer her';
  @override
  String get errorWhileFetchingEncryption =>
      'Feil ved henting av krypteringsnøkkel';
  @override
  String get essentialSkills => 'Ferdigheter';
  @override
  String get estimatedPrice => 'Estimatpris';
  @override
  String get exceedsWithdrawalAmountLimitS =>
      'Over uttaksgrense / Uttaksbeløp overstiger tillatt grense';
  @override
  String get externalWallet => 'Ekstern lommebok';
  @override
  String get failed => 'Mislyktes';
  @override
  String get feb => 'feb';
  @override
  String get filter => 'Filtrer';
  @override
  String get filterAtLeastOneBookingStatusToast =>
      'Velg minst én bestillingsstatus.';
  @override
  String get filterBy => 'Filtrer på';
  @override
  String get flutterWave => 'FlutterWave';
  @override
  String get forBidden => 'Forbudt';
  @override
  String get forbidden => '403: Forbudt';
  @override
  String get forgotPasswordSubtitle =>
      'En lenke for å tilbakestille passord sendes til e-posten.';
  @override
  String get fri => 'fre';
  @override
  String get from => 'Fra';
  @override
  String get fullNameOnBankAccount => 'Avdelingsnavn';
  @override
  String get gatewayTimeout => '504: Tidsavbrudd';
  @override
  String get getYourFirstReview => 'Få din første anmeldelse';
  @override
  String get giveYourEstimatePriceHere => 'Oppgi estimatpris her';
  @override
  String get handymanApprovedTheRequest => 'Håndverker godkjente forespørselen';
  @override
  String get handymanEarning => 'Håndverkerinntekt';
  @override
  String get handymanEarnings => 'Håndverkerinntekter';
  @override
  String get handymanHome => 'Håndverkerforside';
  @override
  String get handymanLocation => 'Håndverkerposisjon';
  @override
  String get handymanName => 'Håndverkernavn';
  @override
  String get handymanNotFound => 'Håndverker ikke funnet';
  @override
  String get handymanPaidAmount => 'Utbetalt til håndverker';
  @override
  String get handymanPayDue => 'Håndverker gjeld';
  @override
  String get handymanPayoutList => 'Utbetalinger til håndverkere';
  @override
  String get hintDescription => 'Beskrivelse';
  @override
  String get hold => 'Pause';
  @override
  String get home => 'Hjem';
  @override
  String get lblJobs => 'Jobber';
  @override
  String get hour => 'time';
  @override
  String get iFSCCode => 'IFSC-kode';
  @override
  String get inAppPurchase => 'Innkjøp i app';
  @override
  String get inProcess => 'Pågår';
  @override
  String get inProgress => 'Pågår';
  @override
  String get inactive => 'Inaktiv';
  @override
  String get includedInThisPackage => 'Inkludert i denne pakken';
  @override
  String get incorrectPin => 'Feil PIN';
  @override
  String get incorrectPinHasBeen => 'Feil PIN er oppgitt';
  @override
  String get inputMustBeNumberOrDigit => 'Må være tall';
  @override
  String get internalServerError => '500: Intern serverfeil';
  @override
  String get invalidAmount => 'Ugyldig beløp';
  @override
  String get invalidInput => 'Ugyldig inndata';
  @override
  String get isAcceptedAsOn => 'er godkjent den';
  @override
  String get isAvailableGoTo =>
      'er tilgjengelig. Gå til Play Store og last ned.';
  @override
  String get isNotAvailableForChat => 'er ikke tilgjengelig for chat';
  @override
  String get isNotValid => 'er ugyldig';
  @override
  String get jan => 'jan';
  @override
  String get jobPrice => 'Jobbpris';
  @override
  String get jobRequestList => 'Jobbforespørsler';
  @override
  String get july => 'juli';
  @override
  String get jun => 'jun';
  @override
  String get knownLanguages => 'Kjente språk';
  @override
  String get lastUpdatedAt => 'Sist oppdatert:';
  @override
  String get later => 'Senere';
  @override
  String get lbHours => 'Timer';
  @override
  String get lbMinutes => 'Minutter';
  @override
  String get lblAcceptBooking => 'Godta bestilling';

  @override
  String get lblBookingAcceptedSuccessfully =>
      'Bestillingen er godtatt og ligger nå i planen din.';

  @override
  String get lblAccountNumberMustBetween11And16Digits =>
      'Kontonummer må være 11–16 siffer';
  @override
  String get lblAccountNumberMustContainOnlyDigits =>
      'Kontonummer må kun inneholde tall';
  @override
  String get lblAfterJobDescription => 'Beskrivelse etter jobb';
  @override
  String get lblAfterJobImage => 'Bilde etter jobb';
  @override
  String get lblApproveBooking => 'Godkjenn bestilling';
  @override
  String get lblAudio => 'Lyd';
  @override
  String get lblBeforeJobImage => 'Bilde før jobb';
  @override
  String get lblChangeCountry => 'Bytt land';
  @override
  String get lblCheckOutWithCinetPay => 'Betal med CinetPay';
  @override
  String get lblChooseOneImage => 'Velg minst ett bilde';
  @override
  String get lblConFirmResumeService =>
      'Er du sikker på at du vil gjenoppta tjenesten?';
  @override
  String get lblConfirmService => 'Bekreft tjeneste';
  @override
  String get lblConfirmationForDeleteMsg => 'Vil du slette meldingen?';
  @override
  String get lblEndServicesMsg =>
      'Er du sikker på at du vil avslutte tjenesten?';
  @override
  String get lblExample => 'Eksempel';
  @override
  String get lblFailedToLoadPredictions => 'Kunne ikke laste forslag';
  @override
  String get lblFeatureBlog => 'Dette er en utvalgt blogg';
  @override
  String get lblHold => 'Pause';
  @override
  String get lblStartJob => 'Start jobb';
  @override
  String get lblImage => 'Bilde';
  @override
  String get lblInvalidTransaction => 'Ugyldig transaksjon';
  @override
  String get lblMessage => 'Melding';
  @override
  String get lblNext => 'Neste';
  @override
  String get lblNoEarningFound => 'Ingen inntekt funnet';
  @override
  String get lblNoTaxesFound => 'Ingen avgifter funnet';
  @override
  String get lblNoTransactionFound => 'Ingen transaksjon funnet';
  @override
  String get lblNoUserFound => 'Ingen bruker funnet';
  @override
  String get lblPleaseEnterAccountNumber => 'Vennligst skriv inn kontonummer';
  @override
  String get lblPleaseSelectCity => 'Vennligst velg by';
  @override
  String get lblReassign => 'Tildel på nytt';
  @override
  String get lblRejectReason => 'Årsak til avvisning';
  @override
  String get lblResume => 'Gjenoppta';
  @override
  String get lblSearchFullAddress => 'Søk full adresse';
  @override
  String get lblStart => 'Kom i gang';
  @override
  String get lblStripeTestCredential =>
      'Testopplysninger kan ikke betale mer enn 500';
  @override
  String get lblSubTitleNoTransaction =>
      'Ingen transaksjoner ennå. Fullfør tjenester for å se historikk.';
  @override
  String get lblSuccessFullyActivated => 'er aktivert';
  @override
  String get lblTokenExpired => 'Sesjon utløpt';
  @override
  String get lblTransactionCancelled => 'Transaksjon kansellert';
  @override
  String get lblTransactionFailed => 'Transaksjon mislyktes';
  @override
  String get lblVideo => 'Videoklipp';
  @override
  String get lbldefault => 'Standard';
  @override
  String get link => 'Lenke';
  @override
  String get loadingChats => 'Laster chatter...';
  @override
  String get mar => 'mar';
  @override
  String get markAsClosed => 'Merk som lukket';
  @override
  String get may => 'mai';
  @override
  String get midtrans => 'Midtrans';
  @override
  String get min => 'min.';
  @override
  String get minRead => 'min lesning';
  @override
  String get mon => 'man';
  @override
  String get monthly => 'Månedlig';
  @override
  String get myBid => 'Mitt tilbud';
  @override
  String get myEarning => 'Min inntekt';
  @override
  String get myTimeSlots => 'Mine tidsluker';
  @override
  String get noActivityYet => 'Ingen aktivitet ennå';
  @override
  String get noBankDataSubTitle => 'Du har ikke lagt til bank ennå';
  @override
  String get noBankDataTitle => 'Ingen bankopplysninger';
  @override
  String get noBanksAvailable => 'Ingen banker tilgjengelig';
  @override
  String get noBlogsFound => 'Ingen blogger funnet';
  @override
  String get noBookingSubTitle =>
      'Det ser ikke ut til at kunder har bestilt ennå.';
  @override
  String get noBookingTitle => 'Ingen bestillinger';
  @override
  String get noCommissionTypeListFound => 'Ingen provisjonstyper funnet';
  @override
  String get noConversation => 'Ingen samtale';
  @override
  String get noConversationSubTitle => 'Du har ikke hatt noen samtaler ennå';
  @override
  String get noDocumentFound => 'Ingen dokumenter funnet';
  @override
  String get noDocumentSubTitle => 'Ingen dokumenter for verifisering';
  @override
  String get noExtraChargesHere => 'Ingen tilleggsgebyr her';
  @override
  String get noHandymanAvailable => 'Ingen håndverker tilgjengelig';
  @override
  String get noHandymanSubTitle => 'Sjekk at håndverker er aktiv';
  @override
  String get noHandymanYet => 'Ingen håndverkere ennå';
  @override
  String get noNotificationSubTitle => 'Vi varsler når vi har noe til deg';
  @override
  String get noNotificationTitle => 'Det ser litt tomt ut her';
  @override
  String get noPaymentMethodsFound => 'Ingen betalingsmetoder funnet';
  @override
  String get noPaymentsFounds => 'Ingen betalinger funnet';
  @override
  String get noPayoutFound => 'Ingen utbetaling funnet';
  @override
  String get noPromotionalBannerYet => 'Ingen kampanjelogo ennå';
  @override
  String get noRecordsFound => 'Ingen poster funnet';
  @override
  String get noRecordsFoundFor => 'Ingen poster funnet for';
  @override
  String noRecordsFoundForBanner(String status) =>
      'Ingen poster funnet for $status kampanjelogoer';
  @override
  String get noServiceAccordingToCoordinates =>
      'Fant ingen resultater for adressen eller koordinatene';
  @override
  String get noServiceAddressSubTitle => 'Legg til tjenesteadresse først';
  @override
  String get noServiceAddressTitle => 'Ingen tjenesteadresse';
  @override
  String get noServiceFound => 'Ingen tjeneste funnet';
  @override
  String get serviceDetailNotAvailableTxt =>
      'Denne tjenestedetaljen er ikke tilgjengelig. Tjenesten kan ha blitt fjernet, eller du har kanskje ikke tilgang til å se den.';
  @override
  String get postJobDataNotFound => 'Innleggsdata for jobben ble ikke funnet.';
  @override
  String get noServiceSubTitle =>
      'Legg til tjenester for å få flere bestillinger.';
  @override
  String get noSlotsAvailable => 'Ingen tidsluker tilgjengelig';
  @override
  String get noSubscriptionFound => 'Ingen abonnement funnet';
  @override
  String get noSubscriptionPlan => 'Ingen abonnementsplan';
  @override
  String get noSubscriptionSubTitle => 'Du har ikke abonnert ennå';
  @override
  String get noTexesFound => 'Ingen avgifter funnet';
  @override
  String get noWalletHistorySubTitle =>
      'Du har ikke fylt på lommeboken. Fyll på for å se historikk.';
  @override
  String get noWalletHistoryTitle => 'Ingen lommebokhistorikk';
  @override
  String get notEnoughBalance => 'Ikke nok saldo';
  @override
  String get note => 'Merk:';
  @override
  String get noteYouCanUpload =>
      'Merk: Du kan laste opp bilde med jpg, png, jpeg.';
  @override
  String get notes => 'Notater:';
  @override
  String get nov => 'nov';
  @override
  String get oct => 'okt';
  @override
  String get ofTransfer => 'av overføring';
  @override
  String get on => 'den';
  @override
  String get onGoing => 'Pågår';
  @override
  String get onSiteVisit => 'Besøk på stedet';
  @override
  String get onlineRemoteService => 'Nett/ekstern tjeneste';
  @override
  String get open => 'ÅPEN';
  @override
  String get oppsLooksLikeYou =>
      'Du har ikke lagt til noen tilleggstjenester ennå.';
  @override
  String get package => 'Pakke';
  @override
  String get packageDescription => 'Pakkebeskrivelse';
  @override
  String get packageName => 'Pakkenavn';
  @override
  String get packageNotAvailable => 'Pakke ikke tilgjengelig';
  @override
  String get packagePrice => 'Pakkepris';
  @override
  String get packageService => 'Pakketjeneste';
  @override
  String get packageServicesWillAppearHere => 'Pakketjenester vises her';
  @override
  String get pageNotFound => '404: Side ikke funnet';
  @override
  String get paid => 'Betalt';
  @override
  String get pay => 'Betal';
  @override
  String get payPal => 'PayPal';
  @override
  String get payStack => 'PayStack';
  @override
  String get payeeIsAlreadyInitiated =>
      'Mottaker er allerede initiert eller sperret.';
  @override
  String get paymentBreakdown => 'Betalingsdetaljer';
  @override
  String get paymentHistory => 'Betalingshistorikk';
  @override
  String get paymentSuccess => 'Betaling fullført';
  @override
  String get paymentType => 'Betalingstype';
  @override
  String get payout => 'Utbetaling';
  @override
  String get paytm => 'Paytm';
  @override
  String get pending => 'Venter';
  @override
  String get pendingApproval => 'Venter på godkjenning';
  @override
  String get pendingByAdmin => 'Venter på admin';
  @override
  String get pendingByProvider => 'Venter på leverandør';
  @override
  String get percentage => 'Prosent';
  @override
  String get permissionDeniedUnableTo =>
      'Ingen tilgang. Kan ikke redigere håndverker.';
  @override
  String get personalInfo => 'Personopplysninger';
  @override
  String get phonePe => 'PhonePe';
  @override
  String get pickAProviderYou => 'Velg leverandør du vil samarbeide med';
  @override
  String get pix => 'Pix';
  @override
  String get pleaseAddEssentialSkill => 'Vennligst legg til ferdighet';
  @override
  String get pleaseAddKnownLanguage => 'Vennligst legg til kjent språk';
  @override
  String get pleaseAddLessThanOrEqualTo =>
      'Vennligst legg til mindre enn eller lik';
  @override
  String get pleaseAddReason => 'Vennligst legg til årsak';
  @override
  String get pleaseCheckThePayment =>
      'Sjekk at betalingsforespørselen er sendt til din e-post.';
  @override
  String get pleaseContactYourAdmin =>
      'Kontoen din er inaktiv. Vennligst kontakt administrator.';
  @override
  String get pleaseEnterTheDefaultTimeslotsFirst =>
      'Vennligst fyll inn standard tidsluker først';
  @override
  String get pleaseEnterTheEndDate => 'Vennligst velg sluttdato';
  @override
  String get pleaseEnterValidBidPrice =>
      'Vennligst skriv inn gyldig tilbudspris';
  @override
  String get pleaseNoteThatAllServiceMarkedCompleted =>
      'Merk at alle tilleggstjenester markert som fullført.';
  @override
  String get pleaseSelectAService => 'Vennligst velg en tjeneste';
  @override
  String get pleaseSelectCommission => 'Vennligst velg provisjon';
  @override
  String get pleaseSelectImages => 'Vennligst velg bilder';
  @override
  String get pleaseSelectService => 'Vennligst velg tjeneste';
  @override
  String get pleaseSelectServiceAddresses => 'Vennligst velg tjenesteadresser';
  @override
  String get pleaseSelectTheCategory => 'Vennligst velg kategori';
  @override
  String get pleaseUploadAllRequired =>
      'Vennligst last opp alle nødvendige dokumenter';
  @override
  String get pleaseUploadTheFollowing =>
      'Last opp følgende dokumenter for verifisering.';
  @override
  String get pleaseWaitWhileWeChangeTheStatus =>
      'Vennligst vent mens status oppdateres';
  @override
  String get pleaseWaitWhileWeLoadBankDetails =>
      'Vennligst vent mens bankopplysninger lastes...';
  @override
  String get pleaseWaitWhileWeLoadChatDetails =>
      'Vennligst vent mens chat lastes...';
  @override
  String get plzSelectOneZone => 'Vennligst velg tjenestesone';
  @override
  String get postJob => 'Legg ut jobb';
  @override
  String get postJobDescription => 'Beskrivelse av jobb';
  @override
  String get postJobTitle => 'Tittel på jobb';
  @override
  String get priceAmountValidationMessage => 'Pris må være større enn 0';
  @override
  String promoteYourBusinessBanners(String perDayAmount) =>
      'Reklamer for bedriften i $perDayAmount/dag.';
  @override
  String get promotionalBanner => 'Kampanjelogo';
  @override
  String get promotionalBannerDetail => 'Kampanjedetaljer';
  @override
  String promotionalBannerYet(String name) => 'Ingen $name kampanjelogo ennå';
  @override
  String get providerApprovedTheRequest => 'Leverandør godkjente forespørselen';
  @override
  String get providerHome => 'Leverandørforside';
  @override
  String get providerList => 'Leverandørliste';
  @override
  String get providerNotFound => 'Leverandør ikke funnet';
  @override
  String get published => 'Publisert';
  @override
  String get queries => 'henvendelser.';
  @override
  String get queryYet => 'Ingen henvendelser ennå';
  @override
  String get ratingViewAllSubtitle =>
      'Få gode produktanmeldelser for tjenestene dine.';
  @override
  String get razorPay => 'RazorPay';
  @override
  String get reason => 'Årsak:';
  @override
  String get reasonsToChooseYour => 'Grunner til å velge din tjeneste';
  @override
  String get redirectingToBookings => 'Videresender til bestillinger...';
  @override
  String get refNumber => 'Ref.nr.';
  @override
  String get refused => 'Avvist';
  @override
  String get rejected => 'Avvist';
  @override
  String get reload => 'Last inn på nytt';
  @override
  String get remainingAmount => 'Gjenstående beløp';
  @override
  String get remainingPayout => 'Gjenstående utbetaling';
  @override
  String get remark => 'Merknad';
  @override
  String get removeImage => 'Fjern bilde';
  @override
  String get removeThisFile => 'Fjern denne filen';
  @override
  String get repliedBy => 'Svart av';
  @override
  String get reply => 'Svar';
  @override
  String get requestList => 'Forespørsler';
  @override
  String get requestPendingWithTheAdmin => 'Forespørsel venter på admin';
  @override
  String get requestPendingWithTheProvider =>
      'Forespørsel venter på leverandør';
  @override
  String get requestSentToTheAdmin => 'Forespørsel sendt til admin';
  @override
  String get requestSentToTheProvider => 'Forespørsel sendt til leverandør';
  @override
  String get requested => 'Forespurt';
  @override
  String get requiredAfterCountryCode => 'påkrevd etter landskode';
  @override
  String get requiredDocumentsMustBe => 'Nødvendige dokumenter må lastes opp.';
  @override
  String get reset => 'Nullstill';
  @override
  String get retryPaymentDetails => 'Prøv betaling på nytt';
  @override
  String get role => 'ROLLE';
  @override
  String get sadadPayment => 'Sadad';
  @override
  String get sat => 'lør';
  @override
  String get search => 'Søk';
  @override
  String
      get selectABankTransferMoneyAndEnterTheReferenceIDInTheTextFieldBelow =>
          'Velg bank, overfør beløp og skriv inn referansenummer nedenfor.';
  @override
  String get selectDuration => 'Velg varighet';
  @override
  String get selectMethod => 'Velg metode';
  @override
  String get selectPlanSubTitle => 'Velg en plan som passer deg';
  @override
  String get selectService => 'Velg tjeneste';
  @override
  String get selectServiceZone => 'Velg tjenestesone';
  @override
  String get selectServiceZones => 'Velg tjenestesoner';
  @override
  String get selectStartDateEndDate => 'Velg start- og sluttdato';
  @override
  String get selectStatus => 'Velg status';
  @override
  String get selectUserType => 'Velg brukertype';
  @override
  String get selectYourDay => 'Velg dag';
  @override
  String get selectZones => 'Velg soner';
  @override
  String get selecteDateNote =>
      'Dette kampanjelogoen vises fra {startDate} til {endDate}.';
  @override
  String get selectedProvider => 'Valgt leverandør';
  @override
  String get sendCashToAdmin => 'Send kontant til admin';
  @override
  String get sendCashToProvider => 'Send kontant til leverandør';
  @override
  String get sendMessage => 'Send melding';
  @override
  String get sendToAdmin => 'Send til admin';
  @override
  String get sendToProvider => 'Send til leverandør';
  @override
  String get sentToAdmin => 'Sendt til admin';
  @override
  String get sentToProvider => 'Sendt til leverandør';
  @override
  String get sentYouAMessage => 'sendte deg en melding';
  @override
  String get sept => 'sep';
  @override
  String get service => 'TJENESTE';
  @override
  String get serviceAddOns => 'Tilleggstjenester';
  @override
  String get serviceInProgress => 'Tjenesten pågår';
  @override
  String get serviceOnHold => 'Tjenesten er satt på pause';
  @override
  String get serviceProofMediaUploadNote =>
      'Merk: Du kan laste opp bilde (JPG, PNG osv.).';
  @override
  String get serviceUnavailable => '503: Tjenesten utilgjengelig';
  @override
  String get serviceVisitType => 'Type tjenestebesøk';
  @override
  String get servicesDelivered => 'Leverte tjenester';
  @override
  String get setAsDefault => 'Sett som standard';
  @override
  String get shortDescription => 'Kort beskrivelse';
  @override
  String get showMessage => 'Vis melding';
  @override
  String get showingFixPriceServices => 'Faste priser (timepriser ekskludert)';
  @override
  String get sortBy => 'Sorter etter';
  @override
  String get start => 'Sett i gang';
  @override
  String get startDate => 'Startdato';
  @override
  String get stripe => 'Stripe';
  @override
  String get subTitleOfSelectService =>
      'Du kan velge én eller flere tjenester.';
  @override
  String get subject => 'Emne';
  @override
  String get success => 'Vellykket';
  @override
  String get successful => 'Vellykket';
  @override
  String get successfullyActivated => 'er aktivert';
  @override
  String get successfullyFetchedEncryptionKey => 'Krypteringsnøkkel hentet';
  @override
  String get sun => 'søn';
  @override
  String get tapBelowButtonToConnectWithOurChatServer =>
      'Du er ikke koblet til chat. Trykk på knappen nedenfor.';
  @override
  String get taxAmount => 'Avgiftsbeløp';
  @override
  String get theAmountUserIs =>
      'Beløpet brukeren prøver å overføre er lavere enn tillatt.';
  @override
  String get theService => 'tjenesten';
  @override
  String get theTransactionIsStill => 'Transaksjonen behandles fortsatt.';
  @override
  String get theTransactionWasNot => 'Transaksjonen ble ikke funnet.';
  @override
  String get theTransactionWasRefused => 'Transaksjonen ble avvist';
  @override
  String get theTransactionWasTimed => 'Transaksjonen tidsavbrutt.';
  @override
  String get theUserHasExceeded =>
      'Brukeren har overskredet tillatt lommebokgrense.';
  @override
  String get thisBannerIsCurrently => 'Dette kampanjelogoen vurderes av admin.';
  @override
  String get thisCommissionHasBeen =>
      'Denne provisjonen er opprettet av admin.';
  @override
  String get thisIsAGeneric => 'Generisk avvisning med flere mulige årsaker.';
  @override
  String get thisMonth => 'Denne måneden';
  @override
  String get thisOrderWillBe =>
      'Denne bestillingen markeres som fullført. Er du sikker?';
  @override
  String get thisServiceIsCurrently => 'Denne tjenesten vurderes av admin.';
  @override
  String get thisServiceIsOnlineRemote =>
      'Denne tjenesten fullføres på nett/fjernstyrt.';
  @override
  String get thisServiceMayTake => 'Denne tjenesten kan ta';
  @override
  String get thisSlotIsNotAvailable => 'Denne tidsluken er ikke tilgjengelig';
  @override
  String get thisWeek => 'Denne uken';
  @override
  String get thisYear => 'Dette året';
  @override
  String get thu => 'tor';
  @override
  String get timeSlotAvailable => 'Tidsluke tilgjengelig';
  @override
  String get timeSlotsNotes1 => 'Tidsluker gjelder kun for leverandører.';
  @override
  String get timeSlotsNotes2 => 'Du kan sette tidsluker per tjeneste.';
  @override
  String get timeSlotsNotes3 =>
      'Kunden ser tidslukene når tjenesten er tilgjengelig.';
  @override
  String get to => 'til';
  @override
  String get toSubmitYourBanner =>
      'Trykk på legg til og last opp kampanjelogo.';
  @override
  String get toSubmitYourProblems => 'Trykk på legg til og beskriv problemet.';
  @override
  String get todaySEarning => 'Dagens inntekt';
  @override
  String get tooManyRequests => '429: For mange forespørsler';
  @override
  String get totalActiveCount => 'Totalt antall aktive:';
  @override
  String get totalAmount => 'Totalbeløp:';
  @override
  String get totalAmountShouldBeLessThan => 'Totalbeløp må være mindre enn';
  @override
  String get totalAmountShouldBeMoreThan => 'Totalbeløp må være større enn';
  @override
  String get totalAmountToPay => 'Totalbeløp å betale';
  @override
  String get totalCash => 'Total kontant';
  @override
  String get totalEarning => 'Total inntekt';
  @override
  String get totalRevenue => 'Total inntekt';
  @override
  String get track => 'Spor';
  @override
  String get trackHandymanLocation => 'Spor håndverkerposisjon';
  @override
  String get transactionExpired => 'Transaksjon utløpt';
  @override
  String get transactionHasBeenExpired => 'Transaksjonen er utløpt';
  @override
  String get transactionId => 'Transaksjons-ID';
  @override
  String get transactionIdIsInvalid => 'Transaksjons-ID er ugyldig';
  @override
  String get transactionInPendingState =>
      'Transaksjon venter. Sjekk igjen senere.';
  @override
  String get transactionIsInProcess => 'Transaksjon behandles...';
  @override
  String get transactionIsSuccessful => 'Transaksjon fullført';
  @override
  String get transactionNotFound => 'Transaksjon ikke funnet';
  @override
  String get transactionNotPermittedTo =>
      'Transaksjon ikke tillatt for mottaker';
  @override
  String get transactionTimedOut => 'Transaksjon tidsavbrutt';
  @override
  String get transactions => 'Transaksjoner';
  @override
  String get tue => 'tir';
  @override
  String get type => 'Typen:';
  @override
  String get typeName => 'Typenavn';
  @override
  String get unlimited => 'Ubegrenset';
  @override
  String get upTo => 'opptil';
  @override
  String get upcomingBookings => 'Kommende bestillinger';
  @override
  String get updateBlog => 'Oppdater blogg';
  @override
  String get updateYourLocation => 'Oppdater posisjon';
  @override
  String get uploadDocuments => 'Last opp dokumenter';
  @override
  String get uploadMedia => 'Last opp media';
  @override
  String get uploadRequiredDocuments => 'Last opp nødvendige dokumenter';
  @override
  String get use24HourFormat => 'Bruk 24-timers format?';
  @override
  String get userDidnTEnterThePin => 'Brukeren oppga ikke PIN';
  @override
  String get userRole => 'Brukerrolle';
  @override
  String get userWalletDoesNot => 'Brukerens lommebok har ikke nok saldo.';
  @override
  String get valueConditionMessage => 'Verdi må være mellom 0 og 99';
  @override
  String get verified => 'Bekreftet';
  @override
  String get verifyEmail => 'Bekreft e-post';
  @override
  String get viewBooking => 'Se bestilling';
  @override
  String get viewBreakdown => 'Se detaljer';
  @override
  String get viewDetail => 'Se detaljer';
  @override
  String get viewPDF => 'Se PDF';
  @override
  String get viewStatus => 'Se status';
  @override
  String get views => 'Visninger';
  @override
  String get visitOption => 'Besøksalternativ';
  @override
  String get waitForAWhile => 'Vent mens abonnementet lagres.';
  @override
  String get waiting => 'Venter';
  @override
  String get waitingForProviderToStart =>
      'Venter på at leverandør starter tjenesten';
  @override
  String get wallet => 'Lommebok';
  @override
  String get wed => 'ons';
  @override
  String get withExtraAndAdvanceCharge =>
      'Med tilleggsgebyr og forhåndsbetaling';
  @override
  String get withExtraCharge => 'Med tilleggsgebyr';
  @override
  String get withdraw => 'Ta ut';
  @override
  String get withdrawRequest => 'Uttaksforespørsel';
  @override
  String get wouldYouLikeToAssignThisBooking =>
      'Vil du tildele denne bestillingen?';
  @override
  String get writeHere => 'Skriv her';
  @override
  String get writeReason => 'skriv årsak';
  @override
  String get writeShortLineAbout =>
      'Kort tekst om hvorfor kunden bør velge deg';
  @override
  String get xSignatureAndPayloadDid => 'x-signatur og payload stemte ikke.';
  @override
  String get yesterday => 'I går';
  @override
  String get youAreNotConnectedWithChatServer => 'Koble til chattserver';
  @override
  String get youCanMarkThis => 'Du kan lukke denne når du er fornøyd.';
  @override
  String get youCanTUpdateDeleted => 'Du kan ikke oppdatere slettede elementer';
  @override
  String get youHaveAnInsufficient =>
      'Du har ikke nok saldo. Velg annen betalingsmetode.';
  @override
  String get youHavePermanentlyDenied =>
      'Du har nektet posisjonstilgang permanent.';
  @override
  String get lblLocationNeededForBidTitle => 'Posisjonstilgang';

  @override
  String get lblLocationNeededForBidMessage =>
      'For å legge inn et bud trenger appen tilgang til enheten din. Trykk Tillat for å fortsette med systemmeldingen.';

  @override
  String get lblJobMissingServiceLocation =>
      'Forespørselen mangler tjenestested fra kunden. Be kunden legge til adresse. Dette er ikke det samme som posisjonstilgang på telefonen.';

  @override
  String get lblJobNoSavedLocationRepost =>
      'Denne jobben har ingen lagret lokasjon. Kunden må legge inn på nytt fra kundeappen etter backend-oppdateringen.';

  @override
  String get lblJobServiceLocationOnFile => 'Tjenestested registrert';

  @override
  String get lblJobLocationCityAreaFallback =>
      'Tjenesteområde (by)';

  @override
  String get lblAllowLocation => 'Tillat';

  @override
  String get lblPostNewJobRequest => 'Legg ut ny jobbforespørsel';

  @override
  String get lblJobRequestLocation => 'Jobblokasjon';

  @override
  String get hintJobRequestAddress =>
      'Hvor skal jobben utføres? Skriv gate, område eller stedsnavn.';

  @override
  String get lblUseMyLocation => 'Bruk min nåværende posisjon';

  @override
  String get lblPostJobSave => 'Publiser jobbforespørsel';

  @override
  String get lblPostJobLocationRequired =>
      'Legg til sted: skriv adresse og/eller bruk nåværende posisjon.';

  @override
  String get lblSelectServiceForJob => 'Relatert tjeneste';

  @override
  String get lblPostJobSaved => 'Jobbforespørsel er publisert';

  @override
  String get lblLocationUpdated => 'Posisjon oppdatert';

  @override
  String get lblLocationServicesDisabled =>
      'Slå på posisjonstjenester i enhetsinnstillingene.';

  @override
  String get lblLatitude => 'Breddegrad';

  @override
  String get lblLongitude => 'Lengdegrad';

  @override
  String get lblLocationPermissionDeniedShort =>
      'Posisjonstillatelse kreves for denne handlingen.';

  @override
  String get youWillGetTheseServicesWithThisPackage =>
      'Disse tjenestene er inkludert i pakken';
  @override
  String get yourCashPaymentForBookingId => 'Din kontantbetaling for';
  @override
  String get yourPaymentFailedPleaseTryAgain =>
      'Betalingen mislyktes. Prøv igjen.';
  @override
  String get yourPaymentHasBeenMadeSuccessfully => 'Betalingen er fullført.';
  @override
  String get yourPriceShouldNotBeLessThan => 'Prisen bør ikke være lavere enn';
  @override
  String get yourWithdrawalRequestHasBeenSuccessfullySubmitted =>
      'Uttaksforespørselen er sendt.';
}
