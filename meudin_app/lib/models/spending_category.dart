
import 'abstract_model.dart';

class SpendingCategory extends AbstractModel {
  late String name;
  late String value;

  SpendingCategory() {}

  SpendingCategory.fromJson(Map<String, dynamic> spendingCategoryMap) {
    
    this.id = spendingCategoryMap['id'];
    this.name = spendingCategoryMap['name'];
    this.value = spendingCategoryMap['value'];
    this.creationDate = DateTime.parse(spendingCategoryMap['creationDate']);
    this.lastUpdate = DateTime.parse(spendingCategoryMap['lastUpdate']);
  }  
}
