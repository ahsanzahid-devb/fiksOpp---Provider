import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/utils/reverse_geocode_address.dart';
import 'package:geolocator/geolocator.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/models/service_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/lat_lng_valid.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/base_scaffold_widget.dart';
import '../../utils/constant.dart';

class AddPostJobScreen extends StatefulWidget {
  @override
  State<AddPostJobScreen> createState() => _AddPostJobScreenState();
}

class _AddPostJobScreenState extends State<AddPostJobScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final titleCont = TextEditingController();
  final descCont = TextEditingController();
  final priceCont = TextEditingController();
  final addressCont = TextEditingController();

  final titleFocus = FocusNode();
  final descFocus = FocusNode();
  final priceFocus = FocusNode();
  final addressFocus = FocusNode();

  ServiceData? selectedService;
  List<ServiceData> services = [];

  String? latitudeStr;
  String? longitudeStr;

  bool loadingServices = true;
  bool saving = false;
  bool fetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => loadingServices = true);
    try {
      final pid = appStore.providerId.validate();
      if (pid <= 0) {
        setState(() {
          services = [];
          loadingServices = false;
        });
        return;
      }
      final ServiceResponse res = await getServiceList(1, pid.toInt());
      services = res.data.validate();
    } catch (e) {
      log(e.toString());
      services = [];
    }
    setState(() => loadingServices = false);
  }

  bool get _hasUsableLocation {
    final addr = addressCont.text.trim();
    if (addr.isNotEmpty) return true;
    return isUsableLatLngStrings(latitudeStr, longitudeStr);
  }

  Future<void> _useCurrentLocation() async {
    setState(() => fetchingLocation = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        toast(languages.lblLocationServicesDisabled);
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        toast(languages.lblLocationPermissionDeniedShort);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      latitudeStr = pos.latitude.toString();
      longitudeStr = pos.longitude.toString();

      if (addressCont.text.trim().isEmpty) {
        try {
          final line = await reverseGeocodeLatLng(
            pos.latitude,
            pos.longitude,
          );
          if (line != null) addressCont.text = line;
        } catch (_) {}
      }
      setState(() {});
      toast(languages.lblLocationUpdated);
    } catch (e) {
      toast(e.toString());
    } finally {
      if (mounted) setState(() => fetchingLocation = false);
    }
  }

  Future<void> _submit() async {
    if (!_hasUsableLocation) {
      toast(languages.lblPostJobLocationRequired);
      return;
    }
    if (selectedService?.id == null) {
      toast(languages.lblSelectServiceForJob);
      return;
    }
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();
    hideKeyboard(context);

    setState(() => saving = true);
    try {
      final req = <String, dynamic>{
        SavePostJob.title: titleCont.text.trim(),
        SavePostJob.description: descCont.text.trim(),
        SavePostJob.price: priceCont.text.trim(),
        SavePostJob.serviceId: selectedService!.id,
        SavePostJob.address: addressCont.text.trim(),
      };
      if (isUsableLatLngStrings(latitudeStr, longitudeStr)) {
        req[SavePostJob.latitude] = latitudeStr!.trim();
        req[SavePostJob.longitude] = longitudeStr!.trim();
      }
      final res = await savePostJob(req);
      toast(res.message.validate().isNotEmpty
          ? res.message!
          : languages.lblPostJobSaved);
      LiveStream().emit(LIVESTREAM_UPDATE_BOOKINGS, 0);
      finish(context, true);
    } catch (e) {
      toast(e.toString());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    titleCont.dispose();
    descCont.dispose();
    priceCont.dispose();
    addressCont.dispose();
    titleFocus.dispose();
    descFocus.dispose();
    priceFocus.dispose();
    addressFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: languages.lblPostNewJobRequest,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(languages.lblJobRequestLocation,
                      style: boldTextStyle(size: 14)),
                  8.height,
                  AppTextField(
                    textFieldType: TextFieldType.MULTILINE,
                    controller: addressCont,
                    focus: addressFocus,
                    minLines: 2,
                    maxLines: 4,
                    isValidationRequired: false,
                    decoration: inputDecoration(
                      context,
                      hint: languages.hintJobRequestAddress,
                      fillColor: context.scaffoldBackgroundColor,
                    ),
                  ),
                  8.height,
                  AppButton(
                    text: languages.lblUseMyLocation,
                    color: context.primaryColor.withValues(alpha: 0.15),
                    textStyle: boldTextStyle(color: context.primaryColor),
                    width: context.width(),
                    onTap: () {
                      if (!fetchingLocation) _useCurrentLocation();
                    },
                  ),
                  if (isUsableLatLngStrings(latitudeStr, longitudeStr)) ...[
                    8.height,
                    Text(
                      '${languages.lblLatitude}: ${latitudeStr!.trim()}  ${languages.lblLongitude}: ${longitudeStr!.trim()}',
                      style: secondaryTextStyle(size: 12),
                    ),
                  ],
                  24.height,
                  Text(languages.postJobTitle, style: boldTextStyle(size: 14)),
                  8.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: titleCont,
                    focus: titleFocus,
                    nextFocus: descFocus,
                    isValidationRequired: true,
                    errorThisFieldRequired: languages.hintRequired,
                    decoration: inputDecoration(
                      context,
                      hint: languages.postJobTitle,
                      fillColor: context.scaffoldBackgroundColor,
                    ),
                  ),
                  16.height,
                  Text(languages.postJobDescription,
                      style: boldTextStyle(size: 14)),
                  8.height,
                  AppTextField(
                    textFieldType: TextFieldType.MULTILINE,
                    controller: descCont,
                    focus: descFocus,
                    nextFocus: priceFocus,
                    minLines: 3,
                    maxLines: 8,
                    isValidationRequired: true,
                    errorThisFieldRequired: languages.hintRequired,
                    decoration: inputDecoration(
                      context,
                      hint: languages.postJobDescription,
                      fillColor: context.scaffoldBackgroundColor,
                    ),
                  ),
                  16.height,
                  Text(languages.lblEstimatedTime,
                      style: boldTextStyle(size: 14)),
                  8.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: priceCont,
                    focus: priceFocus,
                    nextFocus: addressFocus,
                    isValidationRequired: true,
                    errorThisFieldRequired: languages.hintRequired,
                    decoration: inputDecoration(
                      context,
                      hint: languages.lblEstimatedTime,
                      fillColor: context.scaffoldBackgroundColor,
                    ),
                  ),
                  16.height,
                  Text(languages.lblSelectServiceForJob,
                      style: boldTextStyle(size: 14)),
                  8.height,
                  if (loadingServices)
                    LoaderWidget()
                  else if (services.isEmpty)
                    Text(languages.noServiceFound, style: secondaryTextStyle())
                  else
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: context.scaffoldBackgroundColor,
                        borderRadius: radius(),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ServiceData>(
                          isExpanded: true,
                          hint: Text(languages.lblSelectServiceForJob,
                              style: secondaryTextStyle()),
                          value: selectedService,
                          items: services
                              .map(
                                (s) => DropdownMenuItem<ServiceData>(
                                  value: s,
                                  child: Text(
                                    s.name.validate(),
                                    style: primaryTextStyle(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => selectedService = v),
                        ),
                      ),
                    ),
                  32.height,
                  AppButton(
                    text: languages.lblPostJobSave,
                    color: context.primaryColor,
                    width: context.width(),
                    onTap: () {
                      if (!saving) _submit();
                    },
                  ),
                  24.height,
                ],
              ),
            ),
          ),
          Observer(
            builder: (_) => LoaderWidget().visible(saving),
          ),
        ],
      ),
    );
  }
}
