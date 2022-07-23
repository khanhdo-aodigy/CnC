import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordInformation from '@salesforce/apex/ADGLIB_UtilityHelper.getSObjectRecords';
import qrcode from 'c/qrcode';

export default class QrCodeGenerator extends LightningElement {
    @api generationMode;
    @api customURL;
    @api objectName;
    @api fieldName;
    @api visible;
    @api recordId;
    @api recordToRead;
    @api styleCSS;
    @track initialRender = true;
    @track visibleStatus;
    @track finalLink;
    

    renderedCallback() {
        if (this.initialRender) {
            this.visibleStatus = this.visible;
            this.styleCSS = this.styleCSS != null ? this.styleCSS : "height:200px;width:200px;display:block;margin-left:auto;margin-right:auto;";
            if (this.generationMode === 'Read from Record') {
                this.processReadFromRecord();
            }
            if (this.generationMode === 'Custom URL') {
                this.processCustomURL();
            }
            if (this.generationMode === 'JSON') {
                this.processJSON();
            }
            this.initialRender = false;
        }
    }

    processCustomURL() {
        setTimeout(() => {
            this.generateQRCode(this.customURL); //Ensuring that QR is loaded successfully
        }, 1000);
    }

    processReadFromRecord() {
        let SOQLCondition;
        if (this.recordToRead == 'CurrentRecord') {
            SOQLCondition = 'Id = \'' + this.recordId + '\'';
        } else {
            SOQLCondition = 'Id = \'' + this.recordToRead + '\'';
        }

        getRecordInformation({
            SObject_API_Name: this.objectName,
            condition: SOQLCondition,
            onlyOne: true
        })
            .then(result => {
                if (result[0][this.fieldName] == undefined) {
                    console.log('### QR Code Status = Field of the record cannot be found ###');
                    this.visibleStatus = false;
                } else {
                    this.generateQRCode(result[0][this.fieldName]);
                }
            })
            .catch(error => {
                console.log(error);
            });
    }

    processJSON() {
        //this.generateQRCode();
    }

    generateQRCode(QRLink) {
        this.finalLink = QRLink;
        const qrCodeGenerated = new qrcode(0, 'H');
        qrCodeGenerated.addData(QRLink);
        qrCodeGenerated.make();
        let element = this.template.querySelector(".qrcode2");
        element.innerHTML = qrCodeGenerated.createSvgTag({});
    }

    navigateToURL() {
        const evt = new ShowToastEvent({
            title: "Opening QR Code",
            message: "A new tab will be opened shortly!",
            variant: "success"
        });
        this.dispatchEvent(evt);
        window.open(this.finalLink, "_blank");
    }
}