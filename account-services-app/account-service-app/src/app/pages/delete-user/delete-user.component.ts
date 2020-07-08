import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Utils } from 'src/app/utils/utils';
import { UserService } from 'src/app/services/user-service';
import { UserVerificationDto } from 'src/models/user-verification';
import { MatDialog } from '@angular/material';
import { ConfirmDialogComponent } from '../subpages/confirm-dialog/confirm-dialog.component';

@Component({
    selector: 'delete-user-component',
    templateUrl: './delete-user.component.html',
    styleUrls: ['./delete-user.component.css']
})

export class DeleteUserComponent implements OnInit {

    loading = true
    uid: string
    user: UserVerificationDto

    constructor(
        private activatedRoute: ActivatedRoute,
        private router: Router,
        private userService: UserService,
        public confirmDialog: MatDialog,
    ) {
        this.uid = this.activatedRoute.snapshot.paramMap.get("uid")
    }

    ngOnInit() {
        this.getUserData()
    }

    openDeleteAccountModal() {
        var title = 'Tem certeza que deseja excluir essa conta?'
        var text = 'Todos os dados relacionados a essa conta tambem serão apagados.'
        var subText = 'Não será possivel recuperar depois de excluir.'

        const confirmDialog = this.confirmDialog.open(ConfirmDialogComponent, {
            data: {
                title: title,
                text: text,
                subText: subText
            }
        })

        confirmDialog.afterClosed().subscribe(result => {

            if (result != null && result != undefined && result != false)
            {
                this.deleteAccount()
            }

        })
    }

    deleteAccount()
    {
        console.log('ledeto')
    }

    getUserData() {
        this.toggleLoading(true)
        this.userService.getUserData(this.uid)
            .subscribe(
                res => {
                    this.user = res
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