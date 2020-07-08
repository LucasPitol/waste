import { Injectable } from '@angular/core';
import * as firebase from 'firebase';
import { Observable } from 'rxjs';
import { UserVerificationDto } from 'src/models/user-verification';

@Injectable()
export class UserService {

    private db = firebase.firestore()
    
    getUserData(uid): Observable<any>
    {
        var user = new UserVerificationDto()

        var userCollectionRef = this.db.collection('user').doc(uid)

        return new Observable(observer => {
            userCollectionRef.get()
            .then(doc => {
                
                var userData = doc.data()
                user.creationDate = userData.creationDate
                user.displayName = userData.displayName
                user.email = userData.email

                observer.next(user)
            }).catch(err => {
                console.error(err)
            })
        })
    }

}