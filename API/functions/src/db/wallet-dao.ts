import { Wallet } from "../models/wallet";
import { db } from "../index";

export class WalletDao {
    walletsCollectionName = Wallet.collectionName

    async getWalletsByUserId(userId: string): Promise<Wallet[]> {
        let walletList: Wallet[] = []

        var snapshot = await db
            .collection(this.walletsCollectionName)
            .where('membersId', 'array-contains', userId)
            .get()

        for (const doc of snapshot.docs) {
            let wallet = new Wallet(doc)
            walletList.push(wallet)
        }

        return walletList
    }

    async getById(walletId: string): Promise<Wallet | null> {
        let wallet: Wallet | null = null

        var snapshot = await db
            .collection(this.walletsCollectionName)
            .doc(walletId)
            .get()

        if (snapshot.exists) {
            wallet = new Wallet(snapshot)
        }

        return wallet
    }

    async getWalletByNameAndOwnerId(walletName: string, userId: string): Promise<Wallet | null> {
        let wallet: Wallet | null = null

        var snapshot = await db
            .collection(this.walletsCollectionName)
            .where('ownerId', '==', userId)
            .where('name', '==', walletName)
            .get()

        if (!snapshot.empty) {
            for (const doc of snapshot.docs) {
                wallet = new Wallet(doc)
            }
        }

        return wallet
    }

    async updateMemberIdList(members: string[], wallet: Wallet) {
        const batch = db.batch()

        var walletId = wallet.id

        const walletDocRef = db.collection(this.walletsCollectionName).doc(walletId)

        let now = new Date()

        batch.set(walletDocRef, {
            membersId: members,
            lastUpdate: now,
        }, { merge: true })

        await batch.commit()

        return walletId
    }

    async createNewWallet(userId: string, walletName: string) {
        let now = new Date()

        const batch = db.batch()

        const walletDocRef = db.collection(this.walletsCollectionName).doc()

        var uid = walletDocRef.id

        let membersId: string[] = [userId];

        batch.set(walletDocRef, {
            id: uid,
            name: walletName,
            ownerId: userId,
            membersId: membersId,
            creationDate: now,
        })

        await batch.commit()

        return uid
    }
}