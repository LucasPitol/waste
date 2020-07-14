import { Component, OnInit } from '@angular/core';
import { Utils } from 'src/app/utils/utils';
import { Router, ActivatedRoute } from '@angular/router';
import { UserService } from 'src/app/services/user-service';
import { UserVerificationDto } from 'src/models/user-verification';
import { FormControl, Validators, FormGroup } from '@angular/forms';

@Component({
    selector: 'change-password-component',
    templateUrl: './change-password.component.html',
    styleUrls: ['./change-password.component.css']
})

export class ChangePasswordComponent implements OnInit {

    loading = true
    uid: string
    user: UserVerificationDto

    changePaswordForm = {
		email: '',
		password: '',
		rePassword: '',
    }

    emailFormControl = new FormControl('', [
        Validators.required,
        Validators.email,
    ]);
    
    profileForm = new FormGroup({
        email: this.emailFormControl,
        lastName: new FormControl(''),
    });

    

    constructor(
        private activatedRoute: ActivatedRoute,
        private router: Router,
        private userService: UserService,
    ) {
        this.uid = this.activatedRoute.snapshot.paramMap.get("uid")
     }

    ngOnInit() {
        // this.getUserData()
        this.toggleLoading(false)
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

        console.log(this.emailFormControl.value)
    }

    toggleLoading(value: boolean) {
        this.loading = value
    }

    goHome() {
        Utils.goHome(this.router)
    }

}