import { Tuple } from "../models/tuple"

export class Utils {

    static sortTupleByB(tupleList: Tuple[]): Tuple[] {

        let sorteredList: Tuple[] = []

        if (tupleList.length > 0) {
            let sortered = tupleList.sort((n1, n2) => {
                if (n1.b! > n2.b!) {
                    return 1
                }

                if (n1.b! < n2.b!) {
                    return -1
                }

                return 0
            })

            sorteredList = sortered
        }

        return sorteredList
    }
}