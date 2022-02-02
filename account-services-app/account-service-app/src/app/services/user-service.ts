import { Injectable } from '@angular/core';
import { UserModel } from '../models/user-model';

@Injectable()
export class UserService {

    static currentUser: UserModel

    verifyAuth(): boolean {
        var auth: boolean = ((UserService.currentUser != null) && (UserService.currentUser.id != null))

        return auth
    }

}