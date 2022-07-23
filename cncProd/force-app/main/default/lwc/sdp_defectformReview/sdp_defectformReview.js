import { LightningElement, track, api, wire } from 'lwc';
import sendEmail from '@salesforce/apex/DefectFormTemplateCtrl.sendEmail';

export default class Sdp_defectformReview extends LightningElement {
    @api recordId;
    @api franchise;
    @track editMode = false;
    @track initialRender = true;
    @track mainContainerStyle = '';
    @track subContainerStyle = '';
    @track currentHeight;
    @track spinner;

    renderedCallback() {
        if (this.initialRender) {
            this.initialRender = false;
        }
    }

    onscrollstatus(event) {
        let status = event.detail.status;
        let marginleft = 0.045* window.screen.width;

        if (status === 'Enable') {
            //console.log('------ Scroll Enabled: ' + this.currentHeight + ' ------');
            this.mainContainerStyle = '';
            this.subContainerStyle = '';
            window.scrollTo(0, this.currentHeight);
        } else {
            //console.log('------ Scroll Disabled: '+ window.pageYOffset + ' ------');
            this.mainContainerStyle = 'position:fixed;left:0;right:0;top:-' + window.pageYOffset + 'px';
            //this.subContainerStyle = 'margin-left:' + marginleft + 'px';
            this.currentHeight = window.pageYOffset;
        }
    }

    triggerChanges() {
        this.template.querySelector('c-sdp_defectform-Select-Service-Center').refreshComponentRecords();
    }

    PreviousPage() {
        this.dispatchEvent(new CustomEvent('activitychanged', {
            detail: { stage: 'SelectServiceCenter' }
        }));
    }

    CancelCommit() {
        window.close()
    }

    SubmitForm() {
        this.spinner = true;
        sendEmail({ recordID: this.recordId })
            .then(result => {
                this.dispatchEvent(new CustomEvent('activitychanged', {
                    detail: { stage: 'Submitted' }
                }));
                this.spinner = false;
            })
            .catch(error => {
                this.spinner = false;
                console.log('Error: ' + error.body.message);
            })
    }
}