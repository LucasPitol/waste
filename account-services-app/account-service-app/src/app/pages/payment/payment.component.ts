import { Component, OnInit } from "@angular/core";
import { Router } from "@angular/router";
import { UserService } from "src/app/services/user-service";
import { Utils } from "src/app/utils/utils";

@Component({
    selector: 'payment-component',
    templateUrl: './payment.component.html',
    styleUrls: ['./payment.component.css']
})

export class PaymentComponent implements OnInit {

    constructor(
        private router: Router,
        private userService: UserService,
    ) { }

    options: { title: string, value: string, action: Function }[] = [
        {
            title: 'Alterar plano',
            value: 'Plano free',
            action: this.goToChangePlanPage,
        },
        {
            title: 'Forma de pagamento',
            value: 'Credito: **** **** **** 1234',
            action: this.goToChangePlanPage,
        },
        {
            title: 'Detalhes de cobrança',
            value: 'Proxima fatura: 10/10/2021',
            action: this.goToChangePlanPage,
        },
        {
            title: 'Sair',
            value: 'Encerrar sessão',
            action: this.goToChangePlanPage,
        },
    ]

    ngOnInit() {
        this.verifyAuth()
    }

    goToChangePlanPage() {
        console.log('Change plan')
    }

    verifyAuth() {
        var auth: boolean = this.userService.verifyAuth()

        if (!auth) {
            Utils.goHome(this.router)
        }
    }
}