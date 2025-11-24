import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../models/selectZoneModel.dart';

class ServiceAddressComponent extends StatefulWidget {
  final List<int>? selectedList;
  final Function(List<int> val) onSelectedList;

  ServiceAddressComponent({this.selectedList, required this.onSelectedList, });

  @override
  State<ServiceAddressComponent> createState() => _ServiceAddressComponentState();
}

class _ServiceAddressComponentState extends State<ServiceAddressComponent> {
  List<ZoneResponse> zoneList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    getSelectedZone();
  }

  Future<void> getSelectedZone() async {
    await selectedZones(providerId: appStore.userId).then((value) {
      zoneList = value.zoneListResponse.validate();

      if (widget.selectedList != null) {
        zoneList.forEach((element) {
          log("${element.id}" + "${element.name.validate()}");

          element.isSelected = widget.selectedList!.contains(element.id.validate());
        });

        widget.onSelectedList.call(zoneList.where((element) => element.isSelected == true).map((e) => e.id.validate()).toList());
      }

      setState(() {});
    }).catchError((e) {
      log(e.toString());
    });
  }

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: radius(),
            color: context.scaffoldBackgroundColor,
          ),
          child: Theme(
            data: ThemeData(dividerColor: Colors.transparent),
            child: ExpansionTile(
              iconColor: context.iconColor,
              tilePadding: EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: EdgeInsets.symmetric(horizontal: 16),
              initiallyExpanded: widget.selectedList.validate().isNotEmpty,
              title: Text(languages.selectServiceZones, style: secondaryTextStyle()),
              onExpansionChanged: (value) {
                isExpanded = value;
                setState(() {});
              },
              trailing: AnimatedCrossFade(
                firstChild: Icon(Icons.arrow_drop_down),
                secondChild: Icon(Icons.arrow_drop_up),
                crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: 200.milliseconds,
              ),
              children: zoneList.map((data) {
                return Container(
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Theme(
                    data: ThemeData(
                      unselectedWidgetColor: appStore.isDarkMode ? context.dividerColor : context.iconColor,
                    ),
                    child: CheckboxListTile(
                      checkboxShape: RoundedRectangleBorder(borderRadius: radius(4)),
                      autofocus: false,
                      activeColor: context.primaryColor,
                      checkColor: appStore.isDarkMode ? context.iconColor : context.cardColor,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        data.name.validate(),
                        style: secondaryTextStyle(color: context.iconColor),
                      ),
                      value: data.isSelected ?? false,
                      onChanged: (bool? val) {
                        data.isSelected = val ?? false;
                        widget.onSelectedList.call(
                          zoneList.where((element) => element.isSelected == true).map((e) => e.id.validate()).toList(),
                        );
                        setState(() {});
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}