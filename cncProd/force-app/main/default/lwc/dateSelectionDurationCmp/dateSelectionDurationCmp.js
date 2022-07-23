import { LightningElement,api, track} from 'lwc';

export default class DateSelectionDurationCmp extends LightningElement {
    @api objectName;
    @api fieldAPIName;
    @api startLabel;
    @api startDateApiName;
    @api startDateInputValue;

    @api endLabel;
    @api endDateApiName;
    @api endDateInputValue;

    @track isError = false;
    @track errorMSg;

    @track startDatePicklist = [];
    @track endDatePicklist = [];
    @track startDateValue;
    @track endDateValue;
    @track hideEndDatePicklist = false;
    initialRender = true;
    durationFromStartToEnd = 1;
    displayMonthRange = 12; 
    
    renderedCallback(){
  

        if(this.initialRender){
            const today = new Date();

            this.startDateValue = this.startDateInputValue === null ? 
                                        today.toISOString().slice(0,10) :
                                        this.startDateInputValue;
            this.endDateValue = this.endDateInputValue === null ? 
                                null : this.endDateInputValue; 
            
            this.processDateDurationAsObject(new Date(this.startDateValue) , this.startDatePicklist);
            this.endDateValue && this.processDateDurationAsObject(new Date(this.endDateValue) , this.endDatePicklist);
            
            this.initialRender = false;
        }

        this.hideEndDatePicklist = this.endDatePicklist.length < 1 ? true : false;
        
    }
    
    @api setErrorMsg(errorList){
        if(errorList === undefined) return;

        this.isError = true;
        this.errorMsg = errorList.errorMsg;

        this.template.querySelectorAll('label').forEach(elem=>{
            elem.classList.add('errorStyle');
        })
    }
    clearErrorStyle(){
        this.isError = false;
        this.errorMsg = '';

        this.template.querySelectorAll('label').forEach(elem=>{
            elem.classList.remove('errorStyle');
        })
    }
    /*
    picklistChange(event){
        let detail = {};
        this.isNullAtStart = false; //Detected user select on the picklist
        for (let [key, value] of Object.entries(event.detail)) {
            this.startDateValue = key.includes("From") ? value : this.startDateValue;
            //this.endDateValue = key.includes("To") ? value : this.endDateValue;
            this.alignStartAndEndDate(this.startDateValue, this.endDateValue, key.includes("From"));
            detail[key] = value;

            console.log(`${key}: ${value}`);
          }

        const selectEvent = new CustomEvent('valuechanged', {
            detail: detail });
        this.dispatchEvent(selectEvent);
    }

    alignStartAndEndDate(startDate, endDate, fromFromDate){
        
        if(endDate === null || fromFromDate){
           endDate = new Date(startDate);
           endDate.setMonth(endDate.getMonth()+3);
           this.endDateValue = endDate.toISOString().slice(0,10);
           console.log('Update EndDate ' + this.endDateValue);
           return;
        }

        console.log('Start Date ' + this.dateRangeInMonth);
        console.log('Start Date ' + startDate);
        console.log('End Date ' + endDate);
    }
    */

    onSelectStartDate(event){
        this.clearErrorStyle();

        event.preventDefault();        
        this.startDateValue = event.target.value;
        this.setPickListValue(this.startDateValue, this.startDatePicklist);

        //Reset end date range
        this.endDateValue = this.processEndDate(this.startDateValue);
        this.endDatePicklist = [];

        //Generate new UI end date selection
        this.processDateDurationAsObject(new Date(this.endDateValue) , this.endDatePicklist);


        const detailChanged = { [this.startDateApiName] : this.startDateValue,
                                [this.endDateApiName]   : this.endDateValue };

        this.fireEventForUpdate(detailChanged);
    }

    onSelectEndDate(event){
        event.preventDefault();        
        this.endDateValue = event.target.value;
        this.setPickListValue(this.endDateValue, this.endDatePicklist);

        const detailChanged = { [this.endDateApiName] : this.endDateValue };
        this.fireEventForUpdate(detailChanged);
    }


    setPickListValue(selectedValue, picklistValueDate)
    {
        //const returnValue = data.map(obj=> ({ ...obj, style: 'btn btn-radio-tick', default: 'false'}));
        const rowFoundIndex = picklistValueDate.findIndex(rowObj => rowObj.apiValue === selectedValue);
        picklistValueDate.forEach((element, index) => {
            element.fieldStyle = index === rowFoundIndex ? 'btn btn-radio-tick active' : 'btn btn-radio-tick';
        });
        
    }

    processEndDate(startDate){
        let newEndDate = new Date(startDate);
        newEndDate.setMonth(newEndDate.getMonth() + this.durationFromStartToEnd);
        return newEndDate.toISOString().slice(0,10);
    }

    fireEventForUpdate(changeValueObj){
        const selectEvent = new CustomEvent('valuechanged', {
            detail: changeValueObj
        });
        this.dispatchEvent(selectEvent);
    }

    processDateDurationAsObject(selectedDate, displayPickListValue){
        
        if(selectedDate === null){
            displayPickListValue = null;
            return;
        }

        let i = 0; 
        selectedDate = selectedDate.toISOString().slice(0,10);
        
        let dateProcessing = new Date(selectedDate);

        do{
            
             dateProcessing = i === 0 ? new Date(dateProcessing.setMonth(dateProcessing.getMonth())) : 
                                             new Date(dateProcessing.setMonth(dateProcessing.getMonth()+1));
            const display = `${dateProcessing.toLocaleString('default', { month: 'short' })} ${dateProcessing.getFullYear().toString().substr(2,2)}`;
            const value = dateProcessing.toISOString().slice(0,10);
            const fieldStyleDisplay = selectedDate === value ? 
                                        (this.startDateInputValue === null ? 'btn btn-radio-tick': 'btn btn-radio-tick active') : 'btn btn-radio-tick';
            displayPickListValue.push({   key : `picklist${i}`,
                                            apiValue : value, 
                                            displayValue : display,
                                            fieldStyle : fieldStyleDisplay// selectedDate === value ? 'btn btn-radio-tick active' : 'btn btn-radio-tick'
                                        });                      
            i++;

        }while(i < this.displayMonthRange);
    }



}