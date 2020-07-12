import { Component, OnInit } from '@angular/core';
import { Utils } from 'src/app/utils/utils';
import { Router, ActivatedRoute } from '@angular/router';

@Component({
    selector: 'change-password-component',
    templateUrl: './change-password.component.html',
    styleUrls: ['./change-password.component.css']
})

export class ChangePasswordComponent implements OnInit {

    loading = true
    uid: string

    constructor(
        private activatedRoute: ActivatedRoute,
        private router: Router,
    ) {
        this.uid = this.activatedRoute.snapshot.paramMap.get("uid")
     }

    ngOnInit() {
        this.toggleLoading(false)
    }

    toggleLoading(value: boolean) {
        this.loading = value
    }

    goHome() {
        Utils.goHome(this.router)
    }

}