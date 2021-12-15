export abstract class AbstractModel {
    id: string
    creationDate: Date
    lastUpdate: Date

    constructor(docMap: any) {
        this.id = ''
        this.creationDate = docMap?.creationDate != null ? (docMap?.creationDate).toDate() : null
        this.lastUpdate = docMap?.lastUpdate != null ? (docMap?.lastUpdate).toDate() : (docMap?.creationDate).toDate()
    }
}
