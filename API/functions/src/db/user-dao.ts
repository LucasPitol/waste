import { User } from "../models/user";
import { db } from "../index";


export class UserDao {
    usersCollectionName = User.collectionName

    async createNewUser(name: string, email: string, password: string) {
        let now = new Date()

        const batch = db.batch()

        const userDocRef = db.collection(this.usersCollectionName).doc()

        var uid = userDocRef.id

        batch.set(userDocRef, {
            id: uid,
            displayName: name,
            password: password,
            email: email,
            lastUpdate: now,
            creationDate: now,
            privacyPolicyCheckedAt: now,
        })

        await batch.commit()

        return uid
    }

    async changePassword(uid: string, password: string) {
        let now = new Date()

        const batch = db.batch()

        const userDocRef = db.collection(this.usersCollectionName).doc(uid)

        batch.set(userDocRef, {
            password: password,
            lastUpdate: now,
        }, { merge: true })

        await batch.commit()

        return uid
    }

    async getUserById(id: string) {

        var snapshot = await db
            .collection(this.usersCollectionName)
            .where('id', '==', id)
            .get()

        if (snapshot.empty) {
            return null
        } else {
            var user

            for (const doc of snapshot.docs) {
                user = new User(doc)
            }
        }

        return user
    }

    async getUserByEmail(email?: string) {

        var snapshot = await db
            .collection(this.usersCollectionName)
            .where('email', '==', email)
            .get()

        if (snapshot.empty) {
            return null
        } else {
            var user

            for (const doc of snapshot.docs) {
                user = new User(doc)
            }
        }

        return user
    }

    async auth(email: string, password: string) {

        var snapshot = await db
            .collection(this.usersCollectionName)
            .where('email', '==', email)
            .where('password', '==', password)
            .get()

        if (snapshot.empty) {
            return null
        } else {
            var user

            for (const doc of snapshot.docs) {
                user = new User(doc)
            }
        }

        return user
    }

}