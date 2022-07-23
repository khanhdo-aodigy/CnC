import { LightningElement, track, api, wire } from 'lwc';
import getRecords from '@salesforce/apex/FormsPanelController.getRecords';
import getRecordInfo from '@salesforce/apex/FormsPanelController.getRecordInfo';
import saveAttachment from '@salesforce/apex/FormsPanelController.saveAttachment';
import saveSignature from '@salesforce/apex/FormsPanelController.saveRecord';

export default class Sdp_formDetails extends LightningElement {
    @api recordId;
    @api formId;

    @track formDetails;
    @track recordInfo;
    @track formNm;
    @track formTitle;
    @track formBody;
    @track attachmentLink = '';
    @track buttonDisable = false;
    @track toastMessage = 'Test Toast Message';
    toastVariants = ['no', 'success', 'info', 'warning', 'danger'];
    toastVariant = '';

    showAttachmentLink = false;

    constructor() {
        super();
        this.template.addEventListener('signurl', this.onDataUrl.bind(this));
    }

    disconnectedCallback() {
        this.template.removeEventListener('signurl');
    }

    @wire(getRecordInfo, {
        recordId: '$recordId',
    })
    wiredProps(result) {
        result.error && console.log('Error! ' + result.error) && this.toast('danger', JSON.stringify(error), 0);;
        if (result.data) {
          this.recordInfo = result.data[0];
          this.getFormDetails();
        }
    }

    getFormDetails() {
        getRecords({
            objNm: 'Forms_Controller__c',
            fieldReference: 'Id',
            fieldValue: this.formId
        }).then(result => {
            this.formDetails = JSON.parse(JSON.stringify(result[0]));
            this.formNm = this.formDetails.Form_Name__c;
            this.formTitle = this.formDetails.Form_Title__c;
            this.formBody = this.handleMergeFieldsReplaced(this.formDetails.Form_Body__c);
            console.log('form details:: ' + JSON.stringify(this.formDetails));
        }).catch(error => {
            this.toast('danger', JSON.stringify(error), 0);
            console.log(error);
        })
    }

    handleGeneratePDF() {
        // Get Signature data from Signpad cmp and Generate PDF
        this.getSignatureData();
    }

    /**
     * Invoke api method on sign pad component to get image data
     */
    getSignatureData() {
        let signingPad = this.template.querySelector(`[data-id="sign_pad"]`);
        signingPad.toDataUrl();
    }

    /**
     * Handle when receive data URL from sign pad component
     * @param {any} payload : data URL
     */
    onDataUrl(payload) {
        let signature = '<img src="'+ payload.detail + '">';
        console.log('signature:: ' + signature);
        this.buttonDisable = true;
        this.toast('info', '... Saving Form as Attachment. Please wait ...', 0);
        saveSignature({
            recordId: this.recordId,
            fieldAPINm: this.formDetails.Signature_Placeholder_Field_API__c,
            fieldValue: signature
        }).then(result => {
            window.setTimeout(this.saveForm.bind(this), 3000); // wait 3 secs for DB update to take effect
        }).catch(error => {
            this.buttonDisable = false;
            this.toast('danger', JSON.stringify(error), 0);
        })
    }

    saveForm() {
        let fileNm = this.handleMergeFieldsReplaced(this.formDetails.File_Naming_Convention__c);            // Set File Name for the Attachment
        console.log(this.recordId);
        console.log(this.formId);
        console.log(fileNm);
        console.log(this.formDetails.Associated_Checkbox_Field_API_Name__c);
        this.attachmentLink = null;                                                                         // hide the link for default
        saveAttachment({
            recordId: this.recordId,
            formId: this.formId,
            fileName: fileNm,
            associatedFieldAPINm: this.formDetails.Associated_Checkbox_Field_API_Name__c
        }).then(result => {
            // Get form attachment id to create link
            this.attachmentLink = this.getAttachmentPreviewLink(result);
            this.showAttachmentLink = true;
            this.toast('success', 'Form has been saved as an attachment.', 0);
            this.buttonDisable = false;
        }).catch(error => {
            this.buttonDisable = false;
            this.toast('danger', JSON.stringify(error), 0);
            console.log('error in saving attachment:: ' + error);
        })
    }

    getAttachmentPreviewLink(attachmentID) {
        return "/lightning/r/ContentDocument/" + attachmentID + '/view';
    }

    openGeneratedAttachment() {
        window.open(this.attachmentLink, '_blank');
    }

    handleMergeFieldsReplaced(content) {
        let regex = new RegExp('\\{!(.*?)\\}','g');
        let allMatches = content.match(regex);
        if (allMatches != null && allMatches != undefined && allMatches.length != 0) {
            for (let match of allMatches) {
                let mergeField = match.substring(2, match.length - 1);
                let mergeFieldVal = this.recordInfo[mergeField];
                console.log('match === ' + match + ' ==== mergeField === ' + mergeField + ' ==== ' + mergeFieldVal);
                // content = content.replace(match, mergeFieldVal);
                if (mergeFieldVal == undefined || mergeFieldVal == null) {
                    this.toast('danger', 'Unavailable merge fields found. Fields either have no value or not exist in object. Please check again before generating PDF!', 0);
                    this.buttonDisable = true;
                } else {
                    content = content.replace(match, mergeFieldVal);
                }
            }
            console.log('content replaceddddd :: ' + content);
        }
        return content;
    }

    handleToast(variant = 'no', message = '') {
        // check variant in list
        if (!this.toastVariants.includes(variant)) return;

        // show/hide toast panel
        if (variant === 'no') {this.hideToast(); return}
        if (variant !== 'no') this.showToast();

        // change toast panel attribute
        let toastPanel = this.template.querySelector(`[data-id="toast-panel"]`);
        let attrList = toastPanel.classList;
        let removeAttr = '';
        for (let i = 0; i < attrList.length; i++) {
            if (attrList[i].includes('alert-') && attrList[i] !== 'alert-dismissible') {removeAttr = attrList[i]; break;}
        }
        this.toastMessage = message;
        this.toastVariant = variant.toUpperCase();
        toastPanel.classList.remove(removeAttr);
        toastPanel.classList.add('alert-' + variant);
    }

    /**
     * Show the toast panel
     */
    showToast() {
        let toastContainer = this.template.querySelector(`[data-id="toast-panel"]`);
        toastContainer.classList.add('visible-element');
        toastContainer.classList.remove('invisible-element');
    }

    hideToast() {
        let toastContainer = this.template.querySelector(`[data-id="toast-panel"]`);
        toastContainer.classList.add('invisible-element');
        toastContainer.classList.remove('visible-element');
        this.showAttachmentLink = false;
    }

    toast(variant, message, dismiss) {
        try {
            this.handleToast(variant, message);
            if (dismiss > 0) window.setTimeout(this.handleToast.bind(this), dismiss);
        } catch(e) {}
    }

    closePage() {
        window.close();
    }
}