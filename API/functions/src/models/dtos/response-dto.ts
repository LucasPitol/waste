export class ResponseDto {

    success?: boolean
    data?: any
    errorMsg: string

    constructor() {
        this.success = false
        this.errorMsg = ''
    }
}
