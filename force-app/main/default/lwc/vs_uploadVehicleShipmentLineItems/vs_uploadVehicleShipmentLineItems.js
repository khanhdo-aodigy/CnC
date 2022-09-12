import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import strUserId from '@salesforce/user/Id';
import readCSV from '@salesforce/apex/VS_UploadShipmentLineItemsController.readCSVFile';

export default class vs_uploadVehicleShipmentLineItems extends LightningElement 
{
    @api recordId;

    spinner = false;
    userId  = strUserId; 

    get acceptedFormats() 
    {
        return ['.csv'];
    }

    handleUploadFinished(event) 
    {
        this.spinner = true;
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;

        // calling apex class
        readCSV({
            contentDocumentId : uploadedFiles[0].documentId,
            parentRecordId : this.recordId
        })
        .then(result => 
        {
            this.spinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'SUCCESS!',
                    message: 'Uploaded file successfully! ' + result + ' Shipment Line Items have been created.',
                    variant: 'success',
                    mode: 'sticky'
                }),
            );
            eval("$A.get('e.force:refreshView').fire();");
        })
        .catch(error => 
        {
            this.spinner = false;
            console.log('readCSV Error: ' + error.body.message);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'UPLOAD FAILED!',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'sticky'
                }),
            )
        })
    }
}