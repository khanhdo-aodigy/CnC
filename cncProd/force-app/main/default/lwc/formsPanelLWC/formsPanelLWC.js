import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { Navigation } from 'c/customNavigationUtil';
import getForms from '@salesforce/apex/FormsPanelController.getActiveForms';

export default class FormsPanelLWC extends NavigationMixin(LightningElement) {
    @api recordId;
    @api componentTitle;
    @api componentIcon;

    @track currentRecordInfo;
    @track formButtons;                              // To keep original data from DB
    @track currentButtons = [];                      // To show in UI

    @wire(getForms, {
        recordId: '$recordId',
    })
    wiredProps(result) {
        result.error && console.log('Error! ' + JSON.stringify(result.error));
        if (result.data) {
          this.currentRecordInfo = result.data.objInfo;
          this.formButtons = result.data.forms;
          this.initialiseFormButtons(this.formButtons);
        }
    }

    initialiseFormButtons(formButtons) {
        formButtons.forEach(form => {
            let showed = true;
            if (form.Active__c) {
                if (form.Button_Condition_Field_API_Name__c != null && form.Button_Condition_Field_API_Name__c != undefined) {
                    // Check value of the field in Button Condition with value in Record Info from DB
                    showed = this.currentRecordInfo[form.Button_Condition_Field_API_Name__c];
                }
            } else {
                showed = false;
            }

            if (showed) {
                this.currentButtons.push({
                    Id: form.Id,
                    Form_Name__c: form.Form_Name__c,
                    Display_Order__c: form.Display_Order__c,
                    Action_Type__c: 'navLightningApp',                                      // This is for Navigation from Button to Lighting Page App
                    Action_Callout_Name__c: '/c/SDP_FormControllerApp.app'                  // This is for Navigation from Button to Lighting Page App
                });
            }
        })
        console.log('list form btns:: ' + JSON.stringify(this.currentButtons));
    }

    handleButtonClicked(event) {
        let paramFormId = '&formID=' + event.target.value.Id;
        let naviObj = new Navigation(this.recordId, event.target.value);
        console.log('naviObj:: ' + JSON.stringify(naviObj));
        let naviPath = naviObj.generateNavigationPath();
        console.log('naviPath before:: ' + JSON.stringify(naviPath));
        naviPath.attributes.url += paramFormId; 
        console.log('naviPath after:: ' + JSON.stringify(naviPath));
        
        if (naviPath.type !== 'None') {
          this[NavigationMixin.Navigate](naviPath);
        } else {
          this.showToastMessage({ title: 'Navigation Failed', msg: 'No navigation mapped' });
        }
    }

    showToastMessage(msgContainter) {
        const event = new ShowToastEvent({
                                            title: msgContainter.title,
                                            message: msgContainter.msg,
                                        })
        this.dispatchEvent(event);
      }
}