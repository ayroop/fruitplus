import 'package:flutter/material.dart';

import '../services/index.dart';

class FilterAttributeModel with ChangeNotifier {
  List<FilterAttribute> lstProductAttribute = [];
  Services _service = Services();
  List<SubAttribute> currentAttr = [];
  bool isLoading = false;

  Future<void> getFilterAttributes() async {
    try {
      lstProductAttribute = await _service.getFilterAttributes();
    } catch (err) {
      print('getFilterAttributes: $err');
    }
  }

  Future<void> getAttr({int id}) async {
    try {
      isLoading = true;
      notifyListeners();
      currentAttr = await _service.getSubAttributes(id: id);

      print('getAttr: ${currentAttr.length}');
    } catch (err) {
      print('getAttr: $err');
    }
    isLoading = false;
    notifyListeners();
  }
}

class FilterAttribute {
  int id;
  String slug;
  String name;

  FilterAttribute.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    slug = parsedJson['slug'];
    name = parsedJson['name'];
  }
}

class SubAttribute {
  int id;
  String name;

  SubAttribute.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    name = parsedJson['name'];
  }
}
