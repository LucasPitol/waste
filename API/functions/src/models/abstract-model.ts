export abstract class AbstractModel {
    id: string
    creationDate: Date
    lastUpdate: Date

    constructor(docMap: any) {
        this.id = ''
        
        // Handle both Firestore Timestamps and regular Date objects/strings
        this.creationDate = this.parseDate(docMap?.creationDate)
        this.lastUpdate = this.parseDate(docMap?.lastUpdate) || this.parseDate(docMap?.creationDate)
    }

    private parseDate(dateValue: any): Date {
        if (!dateValue) {
            return new Date()
        }
        
        // Firestore Timestamp (has toDate method)
        if (dateValue && typeof dateValue.toDate === 'function') {
            return dateValue.toDate()
        }
        
        // Already a Date object
        if (dateValue instanceof Date) {
            return dateValue
        }
        
        // String timestamp (Supabase format)
        if (typeof dateValue === 'string') {
            return new Date(dateValue)
        }
        
        // Fallback
        return new Date()
    }
}
