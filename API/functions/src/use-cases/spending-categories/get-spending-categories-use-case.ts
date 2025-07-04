import { ResponseDto } from "../../models/dtos/response-dto";
import { SpendingCategoryService } from "../../services/spending-category-service";

export class GetSpendingCategoriesUseCase {
  spendingCategoryService: SpendingCategoryService;

  constructor() {
    this.spendingCategoryService = new SpendingCategoryService();
  }

  async execute(): Promise<ResponseDto> {
    return await this.spendingCategoryService.getSpendingCategoriesRes();
  }
}
