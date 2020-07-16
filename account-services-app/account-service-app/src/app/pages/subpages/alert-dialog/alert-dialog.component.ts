import { Component, Inject } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material';

@Component({
    selector: 'alert-dialog-component',
    templateUrl: './alert-dialog.component.html',
    styleUrls: ['./alert-dialog.component.css'],
})

export class AlertDialogComponent {

    constructor(
        public dialogRef: MatDialogRef<AlertDialogComponent>,
        @Inject(MAT_DIALOG_DATA) public data: any) { }

    onNoClick(): void {
        this.dialogRef.close();
    }

}