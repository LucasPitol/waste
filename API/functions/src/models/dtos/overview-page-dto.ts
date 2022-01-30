import { Tuple } from "../tuple"

export class OverviewPageDto {
    balance: number
    income: number
    spends: number
    spendsByCategory: Tuple[]
    pieChartData: Tuple[]

    constructor() {
        this.balance = 0.0
        this.income = 0
        this.spends = 0
        this.spendsByCategory = []
        this.pieChartData = []
    }
}
