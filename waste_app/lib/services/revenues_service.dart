import 'package:waste_app/db/revenues_dao.dart';
import 'package:waste_app/models/forms/new_revenue_form.dart';

class RevenuesService {
  RevenuesDao dao = RevenuesDao();

  Future<bool> saveNewRevenue(NewRevenueForm form) async {
    bool success = false;

    success = await this.dao.saveNewRevenue(form);

    return success;
  }
}
