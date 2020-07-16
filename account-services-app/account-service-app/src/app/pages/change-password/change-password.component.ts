import { Component, OnInit } from '@angular/core';
import { Utils } from 'src/app/utils/utils';
import { Router, ActivatedRoute } from '@angular/router';
import { UserService } from 'src/app/services/user-service';
import { FormControl, Validators } from '@angular/forms';
import { UserVerificationDto } from 'src/app/models/user-verification';
import { emailMatchValidation, passwordMatchValidation } from 'src/app/utils/custom-validators';
import { MatDialog } from '@angular/material';
import { AlertDialogComponent } from '../subpages/alert-dialog/alert-dialog.component';

@Component({
    selector: 'change-password-component',
    templateUrl: './change-password.component.html',
    styleUrls: ['./change-password.component.css']
})

export class ChangePasswordComponent implements OnInit {

    loading = true
    userMail = ''
    uid: string
    user: UserVerificationDto

    emailFormControl: FormControl
    passwordFormControl: FormControl
    rePasswordFormControl: FormControl

    constructor(
        private activatedRoute: ActivatedRoute,
        private router: Router,
        private userService: UserService,
        public alertDialog: MatDialog,
    ) {
        this.uid = this.activatedRoute.snapshot.paramMap.get("uid")
    }

    ngOnInit() {
        this.getUserData()
    }

    buildFormValidators() {
        this.emailFormControl = new FormControl('', [
            Validators.required,
            Validators.email,
            Validators.maxLength(200),
            emailMatchValidation(this.user.email),
        ]);

        this.passwordFormControl = new FormControl('', [
            Validators.required,
            Validators.minLength(6),
            Validators.maxLength(100),
        ]);

        this.rePasswordFormControl = new FormControl('', [
            Validators.required,
            passwordMatchValidation(this.passwordFormControl),
        ]);
    }

    getUserData() {
        this.toggleLoading(true)
        this.userService.getUserData(this.uid)
            .subscribe(
                res => {
                    if (res.creationDate == undefined) {
                        this.goHome()
                    }
                    this.user = res
                    this.buildFormValidators()
                    this.toggleLoading(false)
                },
                erro => {
                    console.error(erro)
                    this.toggleLoading(false)
                    this.goHome()
                })
    }

    validateForm() {
        return (this.emailFormControl.valid && this.passwordFormControl.valid && this.rePasswordFormControl.valid)
    }

    openSuccessDialog()
    {
        var title = 'Oss!'
        var text = 'Sua senha foi alterada'
        var subText = 'Faça login no app com sua nova senha'

        const alertDialog = this.alertDialog.open(AlertDialogComponent, {
            data: {
                title: title,
                text: text,
                subText: subText
            }
        })

        alertDialog.afterClosed().subscribe(result => {
            this.goHome()
        })
    }

    changePassword() {
        this.toggleLoading(true)

        var valid = this.validateForm()

        if (valid) {
            var password = this.passwordFormControl.value

            var userAndPasswordDto = {
                uid: this.uid,
                password: password
            }

            this.userService.changeUserPassword(userAndPasswordDto)
            .subscribe( res => {
                    if (res)
                    {
                        // modal de sucesso
                        this.openSuccessDialog()
                    } else {
                        // modal de erro
                    }
                },
                error => {
                    console.error(error)
                })
        }
        else
        {
            this.toggleLoading(false);
        }
    }

    toggleLoading(value: boolean) {
        this.loading = value
    }

    goHome() {
        Utils.goHome(this.router)
    }

}