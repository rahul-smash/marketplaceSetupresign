
import 'package:restroapp/src/models/VersionModel.dart';

class BrandModel {

  final BrandVersionModel brandVersionModel;

  BrandModel({
    this.brandVersionModel,
  });

  static BrandModel _instance;

  static BrandModel getInstance({brandVersionModelObj}) {
    if(_instance == null) {
      _instance = BrandModel(brandVersionModel: brandVersionModelObj);
      return _instance;
    }
    return _instance;
  }
}