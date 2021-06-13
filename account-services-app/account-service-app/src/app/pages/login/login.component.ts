import { AlertDialogComponent } from "../subpages/alert-dialog/alert-dialog.component";
import { Component, EventEmitter, OnInit, Output } from "@angular/core";
import { FormControl, Validators } from "@angular/forms";
import { MatDialog } from "@angular/material";
import { Router } from "@angular/router";

@Component({
    selector: 'login-component',
    templateUrl: './login.component.html',
    styleUrls: ['./login.component.css']
})

export class LoginComponent implements OnInit {

    @Output() childToParent= new EventEmitter<any>()

    emailFormControl: FormControl
    passwordFormControl: FormControl

    userEmail: string
    loading = false

    user: any

    constructor(
        // private encarregadoService: EncarregadoService,
		private router: Router,
        public dialog: MatDialog,
    ) { }

    ngOnInit() {
        this.buildFormValidators()
    }

    buildFormValidators() {
        this.emailFormControl = new FormControl('', [
            Validators.required,
            Validators.email,
            Validators.maxLength(200),
        ]);

        this.passwordFormControl = new FormControl('', [
            Validators.required,
            Validators.minLength(6),
            Validators.maxLength(100),
        ]);
    }

    validateForm() {
        return (this.emailFormControl.valid && this.passwordFormControl.valid)
    }

    toggleLoading(value: boolean) {
        this.loading = value
    }

    isAuthenticated() {
        return ((this.user != null) && (this.user.id != null) && (this.user.id.length > 0))
    }

    async login() {

        var valid = this.validateForm()

        if (valid) {
            this.toggleLoading(true)

            var userMail = this.emailFormControl.value
            var password = this.passwordFormControl.value

            // this.encarregadoService.login(userMail, password).subscribe(res => {

            //     if (res.success) {

            //         this.user = res.data

            //         this.sendUserToParentComponent()

            //     } else {
            //         var title = 'Ops...'
            //         var content = res.errorMsgList[0]

            //         this.openErrorDialog(title, content)
            //     }

            //     this.toggleLoading(false)
            // })

            this.router.navigate(['payment'])
        }

    }

    sendUserToParentComponent() {
        this.childToParent.emit(this.user)
    }

    openErrorDialog(title: string, msg: string) {
        const dialogRef = this.dialog.open(AlertDialogComponent, {
            data: {
                msg: msg,
                title: title
            }
        })
    }
}
