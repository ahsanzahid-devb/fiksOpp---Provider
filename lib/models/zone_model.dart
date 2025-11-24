class ProviderZoneResponse {
  List<ZoneModel> data;

  ProviderZoneResponse({this.data = const <ZoneModel>[]});

  factory ProviderZoneResponse.fromJson(Map<String, dynamic> json) {
    var zoneDataList = json['data']?['data']; // <- nested under 'data' inside 'data'
    return ProviderZoneResponse(
      data: zoneDataList is List
          ? List<ZoneModel>.from(zoneDataList.map((x) => ZoneModel.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class ZoneModel {
  int? id;
  String? name;

  ZoneModel({this.id, this.name});

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'name': this.name,
    };
  }
}

