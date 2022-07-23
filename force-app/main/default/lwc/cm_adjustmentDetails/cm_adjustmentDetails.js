import { LightningElement, track, api } from 'lwc';
import createAdjustment from '@salesforce/apex/CMDebitUsageService.createAdjustment';

export default class Cm_adjustmentDetails extends LightningElement {
  @api recordId;

  @track amount;
  @track requestBy;
  @track dsaNo;
  @track remarks;
  @track requestByName;
  @track errorMsg = '';

  isEdit = false;

  get detailStyle()
  {
    return this.isEdit ? 'slds-col slds-size_1-of-1 slds-grid_align-center padding' : 'slds-col slds-size_1-of-1 slds-grid_align-center';
  }

  get lookUpStyle()
  {
    return this.errorMsg == '' ? 'slds-form-element slds-form-element_horizontal' : 'slds-form-element slds-form-element_horizontal slds-has-error'
  }

  onValueChanged(event) 
  {
    this[event.target.name] = event.target.value;  

    if (event.target.name === 'amount')
    {
      const amount = this.template.querySelector(".amount");
      if ( amount.value > 0)
      {
        amount.setCustomValidity("");
        amount.reportValidity();
      }
    }
  }

  onValueChangedDetected(event)
  {
    let data;
    event.detail && (data = event.detail.data);
    if (data)
    {
      for (let [key, value] of Object.entries(data)) 
      { 
        if(key === 'Id')
        {
          this.requestBy = value;
          this.errorMsg = '';
        }
        else 
        {
          this.requestByName = value;
        }
      }
    }
    else
    {
      this.requestBy = '';
    } 
    console.log('RequestBy: ' + this.requestBy);
  }

  @api
  validateInput()
  {
      const amount = this.template.querySelector(".amount");
      const dsaNo = this.template.querySelector(".dsaNo");
      const remarks = this.template.querySelector(".remarks");
      if (amount.value == '' || dsaNo.value == '' || remarks.value == '' || this.requestBy == '') 
      {
          amount.reportValidity();
          dsaNo.reportValidity();
          remarks.reportValidity();
          this.errorMsg = "Complete this field.";
          return false;
      }
      else
      {
          if (amount.value <= 0) 
          {
              amount.setCustomValidity("Amount Must Be Greater Than 0.");
              amount.reportValidity();
              return false;
          }
      }

      return true;
  }
 
  @api
  onCreate()
  {
    createAdjustment({
      rewardProfileId: this.recordId,
      amount: this.amount,
      requestBy: this.requestBy,
      dsaNo: this.dsaNo,
      remarks: this.remarks
    }).then((result)=>{
        this.dispatchEvent(new CustomEvent('submitrecord', 
          {
            detail: { 'message': 'SUCCESS' },
          }));
        this.isEdit = true;
    }).catch(error=>{
        this.dispatchEvent(new CustomEvent('submitrecord', {
          detail: { 'message': error.body.message },
        }));
    });                 
  }
}