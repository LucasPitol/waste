import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/services/smart_error_service.dart';

class RevenuesDao {
  final dbReference = Firestore.instance;
  SmartErrorService smartErrorService = SmartErrorService();
}