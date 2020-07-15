import { AbstractControl, ValidatorFn } from "@angular/forms";


export function emailMatchValidation(strToCompare: string): ValidatorFn {

    return (control: AbstractControl): { [key: string]: boolean } | null => {

        if (control.value !== strToCompare) {
            return { 'emailMatchValidation': true };
        }
        return null;
    }
}