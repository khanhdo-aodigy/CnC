import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

import getColorMasters from '@salesforce/apex/VPO_VPOLIController.getColorMasters';
import getTrimMasters from '@salesforce/apex/VPO_VPOLIController.getTrimMasters';
import getModelYearMasters from '@salesforce/apex/VPO_VPOLIController.getModelYearMasters';
import upsertVPOLI from '@salesforce/apex/VPO_VPOLIController.upsertVPOLI';

import FRANCHISE_CODE from '@salesforce/schema/Vehicle_Purchase_Order__c.Franchise_Code__c';
import VARIANT from '@salesforce/schema/Model_Master__c';
import VARIANT_NAME from '@salesforce/schema/Model_Master__c.Name';
import VARIANT_MODEL_DESCRIPTION from '@salesforce/schema/Model_Master__c.Model_Description__c';

export default class Vpo_createVPOLIDetails extends LightningElement 
{
    @api parentId;
    
    @track details         = {};
    @track trimMasterList  = [];
    @track colorMasterList = [];

    @track objectName = VARIANT.objectApiName;

    @track searchFields = 
    [
        VARIANT_NAME.fieldApiName,
        VARIANT_MODEL_DESCRIPTION.fieldApiName
    ];

    @track displayFields = 
    [
        VARIANT_NAME.fieldApiName,
        VARIANT_MODEL_DESCRIPTION.fieldApiName,
    ];

    franchiseCode = '';
    conditions    = '';
    spinner       = false;
    isError       = false;
    errorMessage;  
    
    @wire(getRecord, {recordId: '$parentId', fields: [FRANCHISE_CODE]}) 
    wiredVPO({error, data}) 
    {
        if (data) 
        { 
            this.franchiseCode = data.fields.Franchise_Code__c.value;
            this.conditions    = 'Active__c = True AND Franchise_Code__c = \'' + this.franchiseCode + '\'';
        }
    }

    @wire (getColorMasters, { modelMasterId: '$details.Model_Master__c', franchiseCode: '$franchiseCode', branchCode: ''}) 
    wiredColorMasters(result)
    {
        if (result.data && result.data.length > 0)
        {
            this.colorMasterList = result.data;
        }
        else
        {
            if (this.details.Model_Master__c !== '' && this.details.Model_Master__c !== undefined && this.details.Model_Master__c !== null)
            {
                this.showNotification('Sorry!', 'The choosen Variant doesn\'t have any related Color and Trim. Please choose another Variant or contact your Administrator.', 'warning', 'sticky');
            }
        }
    }

    @wire (getModelYearMasters, { modelMasterId: '$details.Model_Master__c'}) modelYearMasterList;
    
    get colorMasters()
    {
        let colorMasterOptions = [];
        let uniqueColorOptions = [];
        
        this.colorMasterList.length > 0 
            && this.colorMasterList.forEach(el => colorMasterOptions.push({label: el.Color_Code__r.Color_Description__c, 
                                                                           value: el.Color_Code__c}));

        uniqueColorOptions = this.getUniqueListBy(colorMasterOptions, 'value');

        return uniqueColorOptions;
    }

    get isColorDisabled()
    {
        return this.colorMasterList.length > 0 ? false : true;
    }

    get trimMasters()
    {
        let trimMasterOptions = [];
        this.trimMasterList.length > 0 
            && this.trimMasterList.forEach(el => trimMasterOptions.push({label: el.Trim_Code__r.Trim_Description__c, 
                                                                         value: el.Trim_Code__c}));

        return trimMasterOptions;
    }

    get isTrimDisabled()
    {
        return this.trimMasterList.length > 0 ? false : true;
    }

    get modelYearMasters()
    {
        let modelYearMastersOptions = [];
        this.modelYearMasterList.data 
            && this.modelYearMasterList.data.length > 0 
                && this.modelYearMasterList.data.forEach(el => modelYearMastersOptions.push({label: el.Name, value: el.Id}));

        return modelYearMastersOptions;
    }

    get isModelYearDisabled()
    {
        return this.modelYearMasterList.data && this.modelYearMasterList.data.length > 0 ? false : true;
    }

    getTrimMasters()
    {
        getTrimMasters({
            modelMasterId: this.details.Model_Master__c,
            colorMasterId: this.details.Color_Master__c
        }).then((result) =>
        {
            if (result)
            {
                this.trimMasterList = result;
            }
        }).
        catch((error) =>
        {
            console.log('getTrimMasters - Error: ' + error.body.message);  
        })
    }

    variantSelected(e)
    {
        this.details.Model_Master__c = e.detail.Id;
    }

    variantUnselected(e)
    {
        this.details.Model_Master__c = '';
        this.refreshAllValues();
    }

    onValueChanged(event)
    {
        if (event.target.name === 'Color_Master__c')
        {   this.details.Color_Master__c = event.target.value;
            this.details.Trim_Master__c = '';
            this.trimMasterList         = [];
            this.template.querySelectorAll('lightning-combobox').forEach(el => {if (el.name === "Trim_Master__c") el.value = ''});
            this.getTrimMasters();
        } 
        else
        {
            this.details[event.target.name] = event.target.value;
        }
    }

    onValidate()
    {
        let isValid = true;

        const inputFieldValid = 
        [
            ...this.template.querySelectorAll('lightning-input')
        ]
        .reduce((validSoFar, inputCmp) => 
        { 
            if (inputCmp.name !== 'Remarks__c' 
                && (inputCmp.value === ''  
                    || inputCmp.value === undefined 
                        || inputCmp.value === null)) 
            {
                isValid = false;
                inputCmp.reportValidity();
            }
                        
            if (inputCmp.name === 'Units_Ordered__c')
            {
                if (inputCmp.value !== ''
                    && inputCmp.value !== undefined 
                        && inputCmp.value !== null
                            && inputCmp.value <= 0)
                {
                    isValid = false;
                    inputCmp.setCustomValidity('Units Ordered must be larger than 0.');
                }
                else
                {
                    inputCmp.setCustomValidity('');
                }
                
                inputCmp.reportValidity();
            } 

            return validSoFar && isValid;
        }, true);

        const comboboxValid = 
        [
            ...this.template.querySelectorAll('lightning-combobox')
        ]
        .reduce((validSoFar, inputCmp) => 
        { 
            inputCmp.reportValidity();
            
            return validSoFar && inputCmp.checkValidity();
        }, true);

        const lookupFieldValid = 
        [
            ...this.template.querySelectorAll('c-common_-lookup-input')
        ]
        .reduce((validSoFar, inputCmp) => 
        { 
            isValid = inputCmp.reportValidity();
            return validSoFar && isValid
        }, true);

        return inputFieldValid && comboboxValid && lookupFieldValid;
    }

    onSave()
    {
        if (!this.onValidate()) return;
        if (this.colorMasterList.length === 0 || this.trimMasterList.length === 0)
        {
            this.showNotification('Sorry', 'Color and Trim must be choosen. Please choose another Variant or contact your Admistrator!', 'warning', 'sticky');
            return;
        }        

        this.spinner = true;
        this.details.Vehicle_Purchase_Order__c = this.parentId;
        this.trimMasterList.map(el => {
            if (el.Trim_Code__c === this.details.Trim_Master__c 
                && el.Color_Code__c === this.details.Color_Master__c 
                    && el.Model_Code__c === this.details.Model_Master__c) 
                        return this.details.Model_Color_Trim_Master__c = el.Id;
        });

        upsertVPOLI({
            vPOLItem: this.details,
            checkStage: true
        }).then((result) =>
        {
            if (result === true)
            {
                this.isError      = false;
                this.errorMessage = '';

                this.refreshAllValues();
                
                this.showNotification('Success!', 'New Vehicle Purchase Order Line Item has been successfully created!', 'success', 'dismissible');
                this.spinner = false;
            }
        }).
        catch((error) =>
        {
            this.refreshAllValues();
            
            if (error.body.message === 'Invalid Stage')
            {
                this.showNotification('Sorry!', 'You can\'t create new Vehicle Purchase Order Line Items when Vehicle Purchase Order stage is Closed or Cancelled or Submitted for Approval! Please contact your Administrator.', 'warning', 'sticky');
                this.dispatchEvent(new CustomEvent('close', {}));
                this.isError = false;
                this.spinner = false;
            }
            else
            {
                this.showNotification('Error!', 'An error has occurred! Please contact your Administrator. Reason: ' + error.body.message, 'error', 'dismissible');
                this.isError      = true;
                this.spinner      = false;
            }
        })
    }

    @api refreshAllValues()
    {
        this.details         = {};
        this.colorMasterList = this.trimMasterList = this.modelYearMasterList = [];
        this.template.querySelectorAll('lightning-combobox')?.forEach(el => el.value = '');
        this.template.querySelectorAll('lightning-input')?.forEach(el => {el.value = ''; el.setCustomValidity('');});
        this.template.querySelectorAll('c-common_-lookup-input')?.forEach(el => {el.defaultRecord = '';});
        this.template.querySelector('c-vpo_get-V-P-O-L-I-Details')?.refreshTable();
    }

    showNotification(title, message, variant, mode)
    {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });

        this.dispatchEvent(evt);
    }

    getUniqueListBy(arr, key) 
    {
        return [...new Map(arr.map(item => [item[key], item])).values()]
    }
    
}