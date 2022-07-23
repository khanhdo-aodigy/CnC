import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { CurrentPageReference } from 'lightning/navigation';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import MB_DAILY_LOG_OBJECT from '@salesforce/schema/MB_Test_Drive_Daily_Log__c';
import PETROL_FIELD from '@salesforce/schema/MB_Test_Drive_Daily_Log__c.Petrol__c';
import retrieveCourtesyVehiclesForMBTestDrive from '@salesforce/apex/MB_TestDriveController.retrieveCourtesyVehiclesForMBTestDrive';
import upsertMBTDDailyLogs from '@salesforce/apex/MB_TestDriveController.upsertMBTDDailyLogs';

const currentTime = new Date().getTime();
const timeToUpdate = new Date().setHours(12,0,0);

export default class Mb_TDDailyLog extends LightningElement 
{
    @track courtesyVehicles = [];
    @track wiredRecords;
    @track newDailyLogs = [];
    @track vehIdForUpdatingLog;

    spinner = false;
    isReadOnly = false;
    isNewLogCreated = false;
    isNewLogUpdated = false;
    isLogUpdatedAfterClosed = false;
    isEditable = false;
    tabName = 'one';
    petrolPL;

    @wire( CurrentPageReference )
    currentPageReference;

    connectedCallback() {
        if (Object.keys(this.currentPageReference.state).length !== 0) {
            this.vehIdForUpdatingLog = this.currentPageReference.state.c__vehicleId;
        }
    }

    @wire(getObjectInfo, { objectApiName: MB_DAILY_LOG_OBJECT })
    objectInfo;
    
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: PETROL_FIELD
    }) reasonPicklist({ data, error }) {
        if (data) {
            this.petrolPL = data.values;
        } else if (error) {
            this.petrolPL = undefined;
        }
    }

    @wire(retrieveCourtesyVehiclesForMBTestDrive, {})
    wiredProps(result) 
    {
        this.wiredRecords = result;
        if (result.error) 
        { 
            console.log(result.error); 
            this.showNotification('Error!', 'An error has occurred. Please contact your System Administrator.', 'error');
        }
        if (result.data) 
        {
            this.courtesyVehicles = JSON.parse(JSON.stringify(result.data.courtesyVehicles));;
            this.courtesyVehicles.forEach(veh => {
                if (veh.courtesyVehicleId == this.vehIdForUpdatingLog && !this.isLogUpdatedAfterClosed) {
                    this.isLogUpdatedAfterClosed = true;
                    veh.readOnly = false;
                } else {
                    veh.readOnly = currentTime >= timeToUpdate ? result.data.isClosedLog : true;
                }
            })
            this.isReadOnly = this.isNewLogCreated = result.data.isNewLog;
            this.isNewLogUpdated = result.data.isClosedLog;
           
            for (let rcd of this.courtesyVehicles)
            {
                this.newDailyLogs.push({'Id': rcd.dailyLogId, 'Courtesy_Vehicle__c' : rcd.courtesyVehicleId, 'Opening_Mileage__c': rcd.openingMileage, 'Closing_Mileage__c': rcd.closingMileage, 'Status__c': 'Opened'});
            }
        }
        console.log('@@@vehicles onStart: ' + JSON.stringify(this.courtesyVehicles));
        console.log('@@@newDailyLogs onStart: ' + JSON.stringify(this.newDailyLogs));
    }

    onValueChanged(event)
    {
        this.onValidate(event.target.getAttribute('data-id'));
        this.newDailyLogs.forEach(el => {if (el.Courtesy_Vehicle__c === event.target.getAttribute('data-id')) el[event.target.name] = event.target.value});
    }

    onValidate(eventName)
    {
        const els = eventName !== null ? [...this.template.querySelectorAll(`lightning-input[data-id = '${eventName}']`)] : [...this.template.querySelectorAll('lightning-input')];
        const allValid = els.reduce((validSoFar, inputCmp) => 
        { 
            if (inputCmp.value === undefined || inputCmp.value === '' || inputCmp.value === null)
            {
                if (this.isNewLogCreated && inputCmp.name === 'Opening_Mileage__c')
                {
                    inputCmp.setCustomValidity("");
                }
                else
                {
                    inputCmp.setCustomValidity("Please input a valid number.");
                }
            }
            else if (inputCmp.name === 'Closing_Mileage__c')
            {
                this.courtesyVehicles.forEach(el => 
                { 
                    if (el.courtesyVehicleId === eventName) 
                    {
                        if (Number.parseFloat(el.openingMileage) > Number.parseFloat(inputCmp.value))
                        {
                            inputCmp.setCustomValidity('Closing mileage can\'t be smaller than Opening Mileage.');
                        }
                        else if (el.previousMileage && Number.parseFloat(el.previousMileage) > Number.parseFloat(inputCmp.value))
                        {
                            inputCmp.setCustomValidity('Closing mileage can\'t be smaller than previous Opening/Closing Mileage.');
                        }
                        else
                        {
                            inputCmp.setCustomValidity("");
                        }
                    }
                });
            }
            else if (inputCmp.name === 'Opening_Mileage__c')
            {
                this.courtesyVehicles.forEach(el => 
                    { 
                        if (el.courtesyVehicleId === eventName) 
                        {
                            if (el.previousMileage && Number.parseFloat(inputCmp.value) < Number.parseFloat(el.previousMileage))
                            {
                                inputCmp.setCustomValidity('Opening mileage can\'t be less than previous Opening/Closing Mileage.');
                            }
                            else
                            {
                                inputCmp.setCustomValidity("");
                            }
                        }
                    });
            }
            else
            {
                inputCmp.setCustomValidity("");
            }

            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        const allCbbValid = [...this.template.querySelectorAll('lightning-combobox')]
        .reduce((validSoFar, input) => {
                    input.reportValidity();
                    return validSoFar && input.checkValidity();
        }, true);
        return allValid && allCbbValid;
    }

    showNotification(title, message, variant)
    {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'sticky'
        });

        this.dispatchEvent(evt);
    }

    handleActive(event)
    {
        this.tabName = event.target.value;
        switch (this.tabName) 
        {
            case 'one':
                (this.isNewLogCreated && !this.isReadOnly) && (this.isReadOnly = true);
                (!this.isNewLogCreated && this.isReadOnly) && (this.isReadOnly = false);
                break;
            case 'two':
                (this.isNewLogUpdated && !this.isReadOnly) && (this.isReadOnly = true);
                this.isEditable = currentTime >= timeToUpdate;
                (!this.isNewLogUpdated && this.isReadOnly && this.isEditable) && (this.isReadOnly = false);
                break;
            default:
                break;
        }
    }

    onSave()
    {
        if ((this.tabName === 'one' && this.isNewLogCreated) || (this.tabName === 'two' && this.isNewLogUpdated && !this.isLogUpdatedAfterClosed)) {this.showNotification('Error!', 'Today logs have been already created/updated. You can\'t create/update anymore.', 'error'); return; }
        if (this.tabName === 'two' && !this.isNewLogUpdated && this.isNewLogCreated && !this.isEditable) { this.showNotification('Error!', 'Sorry! You can only log closing mileage after 12:00 PM.', 'error'); return; }
        if (this.tabName === 'two' && !this.isNewLogCreated) { this.showNotification('Error!', 'Sorry! You have to create opening logs first.', 'error'); return; }
        if (!this.onValidate(null)) return;

        (this.tabName === 'two' && (!this.isNewLogUpdated || this.isLogUpdatedAfterClosed)) && this.newDailyLogs.forEach(el => {el.Status__c = 'Closed'});

        console.log('@@@newDailyLogs onSave: ' + JSON.stringify(this.newDailyLogs));
        this.spinner = true;
        upsertMBTDDailyLogs({
            records: this.newDailyLogs
        }).then((result) =>
        {
            console.log('Result: ' + JSON.stringify(result));
            if (result)
            {
                this.spinner         = false;
                this.isReadOnly      = true;
                this.showNotification('Success!', 'New Test Drive Daily Logs have been successfully created/updated!', 'success');
                if (this.tabName === 'one')
                {
                    this.isNewLogCreated = true;
                    this.newDailyLogs = [];
                }
                else
                {
                    this.isNewLogUpdated = true;
                }
            }
            refreshApex(this.wiredRecords);
        }).
        catch((error) =>
        {
            console.log('Error: ' + error.body.message);  
            this.showNotification('Error!', 'An error has occurred. Please contact your System Administrator.', 'error');
        })
    }
}