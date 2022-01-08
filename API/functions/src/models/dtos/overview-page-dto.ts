export class OverviewPageDto {
    balance: number
    income: number
    spends: number
    spendsByCategoryMap: Map<string, number>
    pieChartDataMap: Map<string, number>

    constructor() {
        this.balance = 0.0
        this.income = 0
        this.spends = 0
        this.spendsByCategoryMap = new Map<string, number>()
        this.pieChartDataMap = new Map<string, number>()
    }
}
