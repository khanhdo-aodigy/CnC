import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

import getColorMasters from '@salesforce/apex/VPO_VPOLIController.getColorMasters';
import getTrimMasters from '@salesforce/apex/VPO_VPOLIController.getTrimMasters';
import getModelYearMasters from '@salesforce/apex/VPO_VPOLIController.getModelYearMasters';
import upsertVPOLI from '@salesforce/apex/VPO_VPOLIController.upsertVPOLI';

import Id from '@salesforce/user/Id';
import BRANCH_CODE from '@salesforce/schema/User.Branch_Code__c';
import FRANCHISE_CODE from '@salesforce/schema/User.Franchise_Code__c';

export default class Vpo_createVPOLIDetails extends LightningElement 
{
    @api parentId;
    
    @track details        = {};
    @track trimMasterList = [];

    franchiseCode = '';
    branchCode    = '';
    spinner       = false;
    isError       = false;
    errorMessage;  

    @wire(getRecord, {recordId: Id, fields: [BRANCH_CODE, FRANCHISE_CODE]}) 
    wiredUser({error, data}) 
    {
        if (data) 
        {
            this.branchCode    = data.fields.Branch_Code__c.value;        
            this.franchiseCode = data.fields.Franchise_Code__c.value;
        }
    }

    @wire (getColorMasters, { modelMasterId: '$details.Model_Master__c', franchiseCode: '$franchiseCode', branchCode: '$branchCode'}) colorMasterList;

    @wire (getModelYearMasters, { modelMasterId: '$details.Model_Master__c'}) modelYearMasterList;
    
    get colorMasters()
    {
        let colorMasterOptions = [];
        this.colorMasterList.data && this.colorMasterList.data.length > 0 && this.colorMasterList.data.forEach(el => colorMasterOptions.push({label: el.Color_Code__r.Color_Description__c, value: el.Color_Code__c}));

        return colorMasterOptions;
    }

    get isColorDisabled()
    {
        return this.colorMasterList.data && this.colorMasterList.data.length > 0 ? false : true;
    }

    get modelYearMasters()
    {
        let modelYearMastersOptions = [];
        this.modelYearMasterList.data && this.modelYearMasterList.data.length > 0 && this.modelYearMasterList.data.forEach(el => modelYearMastersOptions.push({label: el.Name, value: el.Id}));

        return modelYearMastersOptions;
    }

    get isModelYearDisabled()
    {
        return this.modelYearMasterList.data && this.modelYearMasterList.data.length > 0 ? false : true;
    }


    get trimMasters()
    {
        let trimMasterOptions = [];
        this.trimMasterList.length > 0 && this.trimMasterList.forEach(el => trimMasterOptions.push({label: el.Trim_Code__r.Trim_Description__c, value: el.Trim_Code__c}));

        return trimMasterOptions;
    }

    get isTrimDisabled()
    {
        return this.trimMasterList.length > 0 ? false : true;
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

    onValueChanged(event)
    {
        if (event.detail.name === 'Trim_Master__c' || event.detail.name === 'Model_Year_Master__c')
        {
            this.details[event.detail.name] = event.detail.value;
        }
        else if (event.detail.name === 'Color_Master__c')
        {   
            this.details[event.detail.name] = event.detail.value;
            this.getTrimMasters();
        } 
        else
        {
            this.details[event.target.fieldName] = event.target.value;
        }

        if (this.details.Color_Master__c === '')
        {
            this.details.Trim_Master__c = '';
            this.trimMasterList         = [];
            this.template.querySelectorAll('c-custom-combobox').forEach(el => {if (el.name==="Trim_Master__c" ) el.refreshSelectedValue()});
        }
        
        if (this.details.Model_Master__c === '')
        {
           this.refreshAllValues();
        } 
    }

    onValidate()
    {
        let isValid = true;

        const inputFieldValid = 
        [
            ...this.template.querySelectorAll('lightning-input-field')
        ]
        .reduce((validSoFar, inputCmp) => 
        { 
            if (inputCmp.fieldName !== 'Remarks__c' 
                && (inputCmp.value === ''  
                    || inputCmp.value === undefined 
                        || inputCmp.value === null)) 
            {
                isValid = false;
                inputCmp.reportValidity();
            }
                        
            if (inputCmp.fieldName === 'Units_Ordered__c')
            {
                if (inputCmp.value !== ''  
                        && inputCmp.value !== undefined 
                            && inputCmp.value !== null
                                && inputCmp.value <= 0)
                {
                    isValid = false;
                    inputCmp.setErrors({'body':{'output':{'fieldErrors':{'Units_Ordered__c':[{'message':'Units Ordered must be bigger than 0.'}]}}}});
                }
                else
                {
                    inputCmp.setErrors({'body':{'output':{'fieldErrors':{'Units_Ordered__c':[{'message':''}]}}}});
                }    
            } 

            return validSoFar && isValid;
        }, true);

        const comboboxValid = 
        [
            ...this.template.querySelectorAll('c-custom-combobox')
        ]
        .reduce((validSoFar, inputCmp) => 
        { 
            isValid = inputCmp.checkValidity();
            return validSoFar && isValid
        }, true);

        return inputFieldValid && comboboxValid;
    }

    onSave()
    {
        if (!this.onValidate()) return;

        this.spinner = true;
        this.details.Vehicle_Purchase_Order__c = this.parentId;
        this.trimMasterList.map(el => {
            if (el.Trim_Code__c === this.details.Trim_Master__c 
                && el.Color_Code__c === this.details.Color_Master__c 
                    && el.Model_Code__c === this.details.Model_Master__c) 
                        return this.details.Model_Color_Trim_Master__c = el.Id;
        });

        upsertVPOLI({
            vPOLItem: this.details
        }).then((result) =>
        {
            if (result === true)
            {
                this.isError      = false;
                this.errorMessage = '';
                this.refreshAllValues();
                this.showNotification('Success!', 'New Vehicle Purchase Order Line Item has been successfully created!', 'success', 'dismissible');
                this.template.querySelector('c-vpo_get-V-P-O-L-I-Details').refreshTable();
                this.spinner = false;
            }
        }).
        catch((error) =>
        {
            console.log('upsertVPOLI - Error: ' + error.body.message);  
            this.showNotification('Error!', 'An error has occurred! Please contact your Administrator.', 'error', 'dismissible');
            this.isError      = true;
            this.errorMessage = error.body.message;
            this.spinner = false;
        })
    }

    refreshAllValues()
    {
        this.details         = {};
        this.colorMasterList = this.trimMasterList = this.modelYearMasterList = [];
        this.template.querySelectorAll('c-custom-combobox').forEach(el => el.refreshSelectedValue());
        this.template.querySelectorAll('lightning-input-field').forEach(el => el.reset());
    }

    @api showNotification(title, message, variant, mode)
    {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });

        this.dispatchEvent(evt);
    }
}