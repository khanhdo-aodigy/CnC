//<!-- This is not in used anymore. Check with JMT -->
import { LightningElement,api, track} from 'lwc';

export default class DateSelectionInMonthButtonCmp extends LightningElement {
    @api objectName;
    @api apiName;
    @api label;
    @api defaultValue;
    @api dateRange;
    @api isNullAtStart;

    @track picklistValueDate = [];
    @track selectedPicklistValue;
    defaultValueAsDate;
    initialRender = true;
    renderedCallback(){

        if(this.initialRender){
            this.defaultValueAsDate = new Date(this.defaultValue);
            this.processDateDurationAsObject(this.defaultValueAsDate);
            this.initialRender = false;
        }
        console.log(`Render from ${this.apiName} ${this.defaultValue}` );
    }

 

    processDateDurationAsObject(selectedDate){
        let i = 0; 
        const defaultValue = selectedDate.toISOString().slice(0,10);
        this.selectedPicklistValue = defaultValue;

        do{
            
            const dateProcessing = i === 0 ? new Date(selectedDate.setMonth(selectedDate.getMonth())) : 
                                             new Date(selectedDate.setMonth(selectedDate.getMonth()+1));
            const display = `${dateProcessing.toLocaleString('default', { month: 'short' })} ${dateProcessing.getFullYear().toString().substr(2,2)}`;
            const value = dateProcessing.toISOString().slice(0,10);

            this.picklistValueDate.push({   key : `picklist${i}`,
                                            apiValue : value, 
                                            displayValue : display,
                                            fieldStyle : defaultValue === value && this.isNullAtStart === false ? 'btn btn-radio-tick active' : 'btn btn-radio-tick'
                                        });                      
            i++;
        }while(i < this.dateRange);
    }

    onSelectPickList(event){    
        console.log('onSelectPickList ' + event.target.value);

        event.preventDefault();        
        this.setPickListValue(event.target.value);
        
       const selectEvent = new CustomEvent('valuechanged', {
           detail: { [this.apiName] : this.selectedPicklistValue}
       });
       this.dispatchEvent(selectEvent);
    
    }

    setPickListValue(selectedValue)
    {
        //const returnValue = data.map(obj=> ({ ...obj, style: 'btn btn-radio-tick', default: 'false'}));
        const rowFoundIndex = this.picklistValueDate.findIndex(rowObj => rowObj.apiValue === selectedValue);
        this.picklistValueDate.forEach((element, index) => {
            if(index === rowFoundIndex) {
                element.fieldStyle = 'btn btn-radio-tick active';
                this.selectedPicklistValue = selectedValue;
            }else{
                element.fieldStyle = 'btn btn-radio-tick';
            }
        });
        
    }

}