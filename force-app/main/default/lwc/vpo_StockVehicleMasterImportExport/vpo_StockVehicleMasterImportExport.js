import { LightningElement, track, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import getStockVehicleMaster from '@salesforce/apex/vpo_StockVehicleMasterIOController.getStockVehicleMaster';
import updateStockVehicleMaster from '@salesforce/apex/vpo_StockVehicleMasterIOController.updateStockVehicleMaster';

const columns = 
[
    { label: 'RVH Name', fieldName: 'Name', editable: false },
    { label: 'Vehicle Purchase Status', fieldName: 'Vehicle_Purchase_Status__c', editable: false },
    { label: 'Vehicle Status', fieldName: 'Vehicle_Status__c', editable: false },
    { label: 'Model Description', fieldName: 'Model_Description__c', editable: false },
    { label: 'Color Description', fieldName: 'Color_Description__c', editable: false },
    { label: 'Trim Description', fieldName: 'Trim_Description__c', editable: false },
    { label: 'Manufacturer Ref. No.', fieldName: 'Manufacturer_Ref_No__c', type: 'text', editable: false },
];

export default class vpo_StockVehicleMasterImportExport extends LightningElement
{
    @api recordId;

    @track csv;

    @track retrievedStockVehicleMasters;

    set csv_(value)
    {
        this.csv = value;

        this.csvReady = !!value;
    }

    get csv_()
    {
        return this.csv;
    }

    @track ready;

    @track csvReady;

    @track enableReportUploader;

    @wire(getStockVehicleMaster, {
        orderId : '$recordId',
    })
    retrivedStockVehicleMasterHandler(result)
    {
        this.retrievedStockVehicleMasters = result;

        if (result.error)
        {
            console.error(result.error);
        }
        else if (result.data)
        {
            this.parseToCsvFormat(result.data);
        }

        this.ready = true;
    }

    parseToCsvFormat(data)
    {
        let csvContent = [];

        let HEADER = [
            'Id',
            'Name',
            'Model_Code__r.Name',
            'Color_Code__r.ColorCode__c',
            'Color_Description__c',
            'Trim_Code__r.Name',
            'Trim_Description__c',
            'Manufacturer_Ref_No__c'
        ];

        csvContent.push(HEADER);

        for (let svm of data)
        {
            csvContent.push([
                svm.Id || '',
                svm.Name || '',
                svm.Model_Code__r.Name || '',
                svm.Color_Code__r.ColorCode__c || '',
                svm.Color_Description__c || '',
                svm.Trim_Code__r.Name || '',
                svm.Trim_Description__c || '',
                svm.Manufacturer_Ref_No__c || ',',
            ]);
        }

        // console.log(csvContent);

        this.generateCsvFile(csvContent);
    }

    generateCsvFile(rows)
    {
        this.csv_ = 'data:text/csv;charset=utf-8,' + rows.map(row => row.join(",")).join("\n");
    }

    openDownloadWindow(e)
    {
        this.template.querySelector('[data-id="hidden-link"]').click();
    }

    openReportUploader(e)
    {
        this.enableReportUploader = true;
    }

    handleUploadFinished(e)
    {
        const uploadedFiles = e.detail.files;

        this.ready = false;

        updateStockVehicleMaster({
            orderId : this.recordId,
            contentDocumentId : uploadedFiles[0]['documentId'],
            contentVersionId : uploadedFiles[0]['contentVersionId']
        })
        .then(success => {
            this.notifyChangeOnStockVehicleMaster_();
            refreshApex(this.retrievedStockVehicleMasters);
            this.showNotification_('Success', 'SVM Manufacturer Ref No successfully updated', 'success', 'sticky');
        })
        .catch(error => {
            // show system assert error message to guide user on next step
            if (error.body && error.body.exceptionType === 'System.AssertException')
            {
                this.showNotification_('Error', error.body.message, 'error', 'sticky');
            }
            // show custom exception message to guide user on next step
            else if (error.body && error.body.isUserDefinedException)
            {
                this.showNotification_('Error', error.body.message, 'error', 'sticky');
            }
            // technical exception do not need to show. A generic message will be pop up
            else
            {
                this.showNotification_('Error', 'Unexpected error on Stock Vehicle Master updating', 'error', 'sticky');
            }
            console.error(error);
        })
        .finally(() => {
            this.enableReportUploader = false;
            this.ready = true;
        })
    }

    get acceptedFormats_() {
        return ['.csv'];
    }

    @track columns_ = columns;

    showNotification_(title, message, variant, mode)
    {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });

        this.dispatchEvent(evt);
    }

    notifyChangeOnStockVehicleMaster_()
    {
        let notifyChangeTargets = [];

        for (let svm of this.retrievedStockVehicleMasters.data)
        {
            notifyChangeTargets.push({
                recordId : svm.Id
            });
        }

        getRecordNotifyChange(notifyChangeTargets);
    }
    
}