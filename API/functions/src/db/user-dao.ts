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

  async getUsersByIds(ids: string[]) {

    var users: User[] = []

    var snapShot = await db
      .collection(this.usersCollectionName)
      .where('id', 'in', ids)
      .get()

    if (snapShot.empty) {
      return users
    } else {
      for (const doc of snapShot.docs) {
        var user = new User(doc)

        users.push(user)
      }
    }

    return users
  }

  async getUserById(id: string): Promise<User | null> {
    var user: User | null = null

    const userRef = db.collection(this.usersCollectionName).doc(id);

    const snapShot = await userRef.get()

    if (snapShot.exists) {
      user = new User(snapShot)
    }

    return user
  }

  async getUserByEmail(email?: string): Promise<User | null> {
    var user: User | null = null

    var snapshot = await db
      .collection(this.usersCollectionName)
      .where('email', '==', email)
      .get()

    if (snapshot.empty) {
      return null
    } else {
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