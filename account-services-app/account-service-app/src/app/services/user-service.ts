import { Injectable } from '@angular/core';
import * as firebase from 'firebase';
import { Observable } from 'rxjs';

@Injectable()
export class UserService {

    private db = firebase.firestore()
    
    getUserData(uid): Observable<any>
    {
        var userCollectionRef = this.db.collection('user').doc(uid)

        return new Observable(observer => {
            userCollectionRef.get()
            .then(doc => {
                
                var user = doc.data()

                observer.next(user)
            }).catch(err => {
                console.error(err)
            })
        })
    }

}