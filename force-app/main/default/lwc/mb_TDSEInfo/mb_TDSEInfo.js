import { LightningElement, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';


export default class Mb_TDSalesInfo extends LightningElement {
    userNm;
    userEmail;
    isError = false;
    errorMsg;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD, EMAIL_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            isError = true;
            errorMsg = error;
        } else if (data) {
            this.userNm = data.fields.Name.value;
            this.userEmail = data.fields.Email.value;
        }
    }
}