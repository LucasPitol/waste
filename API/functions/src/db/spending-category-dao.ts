import { SpendingCategory } from "../models/spending-category";
import { db } from "../index";

export class SpendingCategoryDao {
    spendingCategoryCollectionName = SpendingCategory.collectionName

    async createNewSpendingCategory(name: string, value: string) {
        let now = new Date()

        const batch = db.batch()

        const userDocRef = db.collection(this.spendingCategoryCollectionName).doc()

        var uid = userDocRef.id

        batch.set(userDocRef, {
            id: uid,
            displayNamePt: name,
            value: value,
            lastUpdate: now,
            creationDate: now,
        })

        await batch.commit()

        return uid
    }

    async getByValue(value: string) {
        var snapshot = await db
            .collection(this.spendingCategoryCollectionName)
            .where('value', '==', value)
            .get()

        if (snapshot.empty) {
            return null
        } else {
            var spendingCategory

            for (const doc of snapshot.docs) {
                spendingCategory = new SpendingCategory(doc)
            }
        }

        return spendingCategory
    }

    async getSpendingCategories(): Promise<SpendingCategory[]> {
        var spendingCategories: SpendingCategory[] = []

        var snapshot = await db
            .collection(this.spendingCategoryCollectionName)
            .get()

        if (snapshot.empty) {
            return spendingCategories
        } else {
            var spendingCategory

            for (const doc of snapshot.docs) {
                spendingCategory = new SpendingCategory(doc)

                spendingCategories.push(spendingCategory)
            }
        }

        return spendingCategories
    }
}
