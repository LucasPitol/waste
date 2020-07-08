import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Utils } from 'src/app/utils/utils';
import { UserService } from 'src/app/services/user-service';

@Component({
    selector: 'delete-user-component',
    templateUrl: './delete-user.component.html',
    styleUrls: ['./delete-user.component.css']
})

export class DeleteUserComponent implements OnInit {

    loading = true
    uid: string

    constructor(
        private activatedRoute: ActivatedRoute,
        private router: Router,
        private userService: UserService,
    ) {
        this.uid = this.activatedRoute.snapshot.paramMap.get("uid")
    }

    ngOnInit() {
        this.getUserData()
    }

    getUserData() {
        this.toggleLoading(true)
        this.userService.getUserData(this.uid)
            .subscribe(
                res => {
                    console.log(res)
                    this.toggleLoading(false)
                }
            ),
            erro => {
                console.error(erro)
                this.toggleLoading(false)
            }
    }

    toggleLoading(flag: boolean) {
        this.loading = flag
    }

    goHome() {
        Utils.goHome(this.router)
    }
}