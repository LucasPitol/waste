import 'package:meudin_ai_app/models/abstract_model.dart';

class Wallet extends AbstractModel {
  late List<String> membersIds;
  late String name;
  late String ownerId;

  Wallet() {
    membersIds = [];
  }
}
