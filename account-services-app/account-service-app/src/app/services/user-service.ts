import { Injectable } from '@angular/core';
import * as firebase from 'firebase';
import { merge, Observable } from 'rxjs';
import { UserVerificationDto } from '../models/user-verification';

@Injectable()
export class UserService {

    private db = firebase.firestore()

    changeUserPassword(userAndPasswordDto: any): Observable<any> {
        var uid = userAndPasswordDto.uid
        var password = userAndPasswordDto.password

        var passwordEncrypt = btoa(password)

        var userCollectionRef = this.db.collection('user').doc(uid)

        return new Observable(observer => {
            userCollectionRef.set({
                password: passwordEncrypt,
                lastUpdate: new Date
            },
                {
                    merge: true
                }).then(onValue => {
                    observer.next(true)
                    //enviar email
                }).catch(onError => {
                    console.error(onError)
                    observer.next(false)
                })
        })
    }

    async removeMemberAccessToOtherWallets(uid: string) {
        var walletsRef = await this.db
            .collection('wallets')
            .where('membersId', 'array-contains', uid)
            .onSnapshot(querySnapshot => {
                var walletsDocs = querySnapshot.docs

                walletsDocs.forEach(async doc => {
                    var walletId = doc.id

                    console.log('wallet id: ' + walletId)

                    var data = doc.data()

                    var oldMembersList = data.membersId

                    console.log('oldMembersList')
                    console.log(oldMembersList)

                    var newMembersId = oldMembersList.filter(item => item != uid)

                    console.log('newMembersId')
                    console.log(newMembersId)

                    var walletCollectionRef = this.db.collection('wallets').doc(walletId)

                    walletCollectionRef.set({
                        membersId: newMembersId
                    },{merge: true})
                })
            })
    }

    async deleteUser(uid: string) {
        //get wallets
        var walletsRef = await this.db
            .collection('wallets')
            .where('ownerId', '==', uid)
            .onSnapshot(querySnapshot => {
                var walletsDocs = querySnapshot.docs

                walletsDocs.forEach(async wallet => {
                    var walletId = wallet.id

                    // get spends
                    this.db
                        .collection('spends')
                        .where('walletId', '==', walletId)
                        .onSnapshot(spendsSnapshot => {
                            var spendsDocs = spendsSnapshot.docs

                            // delete spends
                            spendsDocs.forEach(async spend => {
                                var spendId = spend.id
                                await this.db.collection('spends').doc(spendId).delete()
                            })
                        })
                    //delete wallets
                    await this.db.collection('wallets').doc(walletId).delete()
                })
            })
        //delet user
        await this.db.collection('user').doc(uid).delete()

        this.removeMemberAccessToOtherWallets(uid)
    }

    getUserData(uid): Observable<any> {
        var user = new UserVerificationDto()

        var userCollectionRef = this.db.collection('user').doc(uid)

        return new Observable(observer => {
            userCollectionRef.get()
                .then(doc => {

                    var userData = doc.data()

                    if (userData != undefined) {
                        user.creationDate = userData.creationDate
                        user.displayName = userData.displayName
                        user.email = userData.email
                    }

                    observer.next(user)
                }).catch(err => {
                    console.error(err)
                })
        })
    }

}