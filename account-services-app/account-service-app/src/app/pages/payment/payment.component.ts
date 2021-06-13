import { Component, OnInit } from "@angular/core";

@Component({
    selector: 'payment-component',
    templateUrl: './payment.component.html',
    styleUrls: ['./payment.component.css']
})

export class PaymentComponent implements OnInit {

    options: {title: string, value: string}[] = [
        {
            title: 'Alterar plano',
            value: 'Plano free',
        },
        {
            title: 'Forma de pagamento',
            value: 'Credito: **** **** **** 1234',
        },
        {
            title: 'Detalhes de cobrança',
            value: 'Proxima fatura: 10/10/2021',
        },
    ]

    ngOnInit() {
        this.verifyAuth()
    }

    verifyAuth() {

    }
}