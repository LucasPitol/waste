import { Component, OnInit } from '@angular/core';
import { Utils } from 'src/app/utils/utils';
import { Router, ActivatedRoute } from '@angular/router';
import { UserService } from 'src/app/services/user-service';
import { FormControl, Validators, FormGroup, AbstractControl } from '@angular/forms';
import { UserVerificationDto } from 'src/app/models/user-verification';
import { emailMatchValidation, passwordMatchValidation } from 'src/app/utils/custom-validators';

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
    ) {
        this.uid = this.activatedRoute.snapshot.paramMap.get("uid")
    }

    ngOnInit() {
        this.getUserData()
    }

    buildFormValidators()
    {
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
            passwordMatchValidation(this.passwordFormControl),
        ]);
    }

    getUserData()
    {
        this.toggleLoading(true)
        this.userService.getUserData(this.uid)
            .subscribe(
                res => {
                    if (res.creationDate == undefined)
                    {
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

    validateForm()
    {
        var valid = true;

        return valid
    }

    changePassword()
    {
        var valid = this.validateForm()
    }

    toggleLoading(value: boolean) {
        this.loading = value
    }

    goHome() {
        Utils.goHome(this.router)
    }

}