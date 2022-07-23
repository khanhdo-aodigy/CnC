import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getButtonList from '@salesforce/apex/ActionPanelApp.getActiveButtonsFromMDT';
import { Navigation } from 'c/customNavigationUtil';
import getRecords from '@salesforce/apex/SDP_DefectFormController.getRelatedRecords';
// import { isEmptyValue } from 'c/dsp_customerConfiguration';

export default class ActionPanelLWC extends NavigationMixin(LightningElement) {
  @api componentTitleDA;
  @api componentIconDA;
  @api recordId;
  @api objectNameDA;
  @api actionTypeNavigation;
  @track currentRecord;
  @track wiredRecords;
  @track currentButtons = []; //This is what you should loop in HTML
  @wire(getButtonList, { objName: '$objectNameDA' }) buttons;

  @wire(getRecords, {
    fieldReferenceValue: '$recordId',
    objectName: 'Sales_Agreement__c',
    fieldName: 'Id'
  })
  wiredProps(result) {
    this.wiredRecords = result;
    result.error && console.log('Error! ' + result.error);
    if (result.data) {
      this.currentRecord = result.data[0];
      this.initialiseButtonValues();
    }
  }

  initialiseButtonValues() {
    this.buttons.data.forEach(eachButton => {
      let buttonDefaultValues = "";
      let checkDisabled = false;
      let checkDefaultValues = false;
      let checkCondition = false;
      if (eachButton.Default_Values__c !== undefined && eachButton.Default_Values__c.includes("SOQL[")) { //Check if the default value contains SOQL[ to be replaced
        let temporaryArray = eachButton.Default_Values__c.split("&");
        let temporaryArrayName = [];
        let temporaryArrayField = [];
        let temporaryArrayValue = [];

        temporaryArray.forEach(e => {
          let temp = e.split("SOQL[");
          temporaryArrayName.push(temp[0]);
          temporaryArrayField.push(temp[1]);
        });
        temporaryArrayField.forEach(e => {
          let temp = e.split("]");
          if (this.currentRecord[temp[0]]) {
            temporaryArrayValue.push(this.currentRecord[temp[0]].replace(/\s/g, "%20"));
          }
        });
        for (let i = 0; i < temporaryArrayName.length; i++) {
          if (i === 0) { buttonDefaultValues += temporaryArrayName[i] + temporaryArrayValue[i]; }
          else {
            buttonDefaultValues += "&" + temporaryArrayName[i] + temporaryArrayValue[i];
          }
        };
      }

      if (eachButton.Button_Condition_If_Any__c !== undefined && eachButton.Button_Condition_If_Any__c.includes("SOQL[")) { //Check if the default value contains SOQL[ to be replaced

        let rxp1 = /\[(.*?)\]/g;
        let rxp2 = /'(.*?)'/g;
        let rxp3 = /\](.*?)\'/g;
        let rxp4 = /{([^}]+)}/g;
        let tempRex1;
        let tempRex2;
        let tempRex3;
        let tempRex4;
        let temporaryArrayCompare = [];
        let temporaryArrayRepCompare = [];
        let temporaryArrayField = [];
        let temporaryArrayValue = [];
        let temporaryArrayOperator = [];
        let temporaryArrayCondition = [];
        let temporaryArraySOQL = [];
        let tempString = eachButton.Button_Condition_If_Any__c;

        while (tempRex1 = rxp1.exec(eachButton.Button_Condition_If_Any__c)) {
          temporaryArrayField.push(tempRex1[1]);
        }
        while (tempRex2 = rxp2.exec(eachButton.Button_Condition_If_Any__c)) {
          temporaryArrayCompare.push(tempRex2[1]);
        }
        while (tempRex3 = rxp3.exec(eachButton.Button_Condition_If_Any__c)) {
          temporaryArrayOperator.push(tempRex3[1]);
        }
        while (tempRex4 = rxp4.exec(eachButton.Button_Condition_If_Any__c)) {
          temporaryArraySOQL.push(tempRex4[1]);
        }

        temporaryArrayField.forEach(e => {
          if (this.currentRecord[e]) {
            temporaryArrayValue.push(this.currentRecord[e]);
          }
          else {
            temporaryArrayValue.push('null');
          }
        });

        temporaryArrayCompare.forEach(e => {
          if (e == "") {
            temporaryArrayRepCompare.push('null')
          } else {
            temporaryArrayRepCompare.push(e)
          }
        });

        for (let i = 0; i < temporaryArrayField.length; i++) {
          temporaryArrayCondition.push("'" + temporaryArrayValue[i] + "'" + temporaryArrayOperator[i] + "'" + temporaryArrayRepCompare[i] + "'")
          // console.log(temporaryArrayCondition[i]);
        }

        temporaryArrayCondition.forEach(function (e, index) {
          tempString = tempString.replace("{" + temporaryArraySOQL[index] + "}", eval(e));
        });

        tempString = tempString.replace(/AND/g, "&&");
        tempString = tempString.replace(/OR/g, "||");
        checkCondition = !eval(tempString);

      }
      (buttonDefaultValues.includes("undefined") ? checkDefaultValues = true : checkDefaultValues = false)

      if (checkCondition || checkDefaultValues) {
        checkDisabled = true;
      }
      this.currentButtons.push({
        Label_UI__c: eachButton.Label_UI__c,
        Default_Values__c: buttonDefaultValues,
        Disable: checkDisabled,
        Position__c: eachButton.Position__c,
        Action_Type__c: eachButton.Action_Type__c,
        Action_Callout_Name__c: eachButton.Action_Callout_Name__c + buttonDefaultValues,
        Target_Object__c: eachButton.Target_Object__c,
        Object__c: eachButton.Object__c,
        Id: eachButton.Id,
      });
    })
  }

  processButton(event) {
    let naviObj = new Navigation(this.recordId, event.target.value);
    let naviPath = naviObj.generateNavigationPath();

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