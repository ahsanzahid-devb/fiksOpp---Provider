import 'package:handyman_provider_flutter/models/pagination_model.dart';

class DocumentListResponse {
  Pagination? pagination;
  List<Documents>? documents;

  DocumentListResponse({this.pagination, this.documents});

  DocumentListResponse.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null ? new Pagination.fromJson(json['pagination']) : null;
    if (json['data'] != null) {
      documents = [];
      json['data'].forEach((v) {
        documents!.add(new Documents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.documents != null) {
      data['data'] = this.documents!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Documents {
  int? id;
  String? name;
  int? status;
  int? isRequired;
  String? filePath;

  Documents({this.id, this.name, this.status, this.isRequired, this.filePath});

  Documents.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    isRequired = json['is_required'];
    filePath = json['file_path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['status'] = this.status;
    data['is_required'] = this.isRequired;
    data['file_path'] = this.filePath;
    return data;
  }

  Documents copyWith({
    int? id,
    String? name,
    int? status,
    int? isRequired,
    String? filePath,
  }) {
    return Documents(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      isRequired: isRequired ?? this.isRequired,
      filePath: filePath ?? this.filePath,
    );
  }
}
