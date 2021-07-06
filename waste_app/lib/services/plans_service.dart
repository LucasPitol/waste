import 'package:waste_app/models/dtos/plan_specs_dto.dart';
import 'package:waste_app/models/dtos/response_dto.dart';
import 'package:waste_app/utils/constants.dart';

class PlansService {
  getPlans() async {
    ResponseDto res = ResponseDto();
    List<PlanSpecsDto> plans = [];

    PlanSpecsDto p1 = PlanSpecsDto();
    p1.planId = '1';
    p1.name = 'Plano Consagrado';
    p1.price = 9.90;
    p1.displayPrice = 'R\$ ' + Constants.getAmountFormated(p1.price) + ' por mês';
    p1.descriptionList.add('Crie até 3 carteiras');
    p1.descriptionList.add('Adicione até 3 membros por carteira');
    p1.descriptionList.add('Filtros de até 1 ano');
    p1.descriptionList.add('Visualize mais de 30 transações');

    PlanSpecsDto p2 = PlanSpecsDto();
    p2.planId = '2';
    p2.name = 'Plano Burguês';
    p2.price = 12.90;
    p2.displayPrice = 'R\$ ' + Constants.getAmountFormated(p2.price) + ' por mês';
    p2.descriptionList.add('Plano anterior');
    p2.descriptionList.add('Crie até 4 carteiras');
    p2.descriptionList.add('Adicione até 5 membros por carteira');
    p2.descriptionList.add('Filtros de até 2 anos');

    plans.add(p1);
    plans.add(p2);

    await Future.delayed(Duration(milliseconds: 1000), () {
      res.success = true;
      res.data = plans;
    });

    return res;
  }
}
