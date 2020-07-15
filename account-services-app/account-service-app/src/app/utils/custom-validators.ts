import { AbstractControl, ValidatorFn } from "@angular/forms";


export function matches(strToCompare: string): ValidatorFn {

    return (control: AbstractControl): { [key: string]: boolean } | null => {

        if (control.value !== strToCompare) {
            return { 'matches': true };
        }
        return null;
    }
}