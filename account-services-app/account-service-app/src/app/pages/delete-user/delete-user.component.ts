import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Utils } from 'src/app/utils/utils';

@Component({
    selector: 'delete-user-component',
    templateUrl: './delete-user.component.html',
    styleUrls: ['./delete-user.component.css']
})

export class DeleteUserComponent implements OnInit {

    uid: string

    constructor(
        private activatedRoute: ActivatedRoute, 
        private router: Router,) 
    {
        this.uid = this.activatedRoute.snapshot.paramMap.get("uid")
    }

    ngOnInit() {
        console.log(this.uid)
    }

    goHome() 
    {
        Utils.goHome(this.router)
    }
}