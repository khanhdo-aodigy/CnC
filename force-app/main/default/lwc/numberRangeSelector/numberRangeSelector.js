import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, fireEvent, unregisterAllListeners } from 'c/pubsub';

const DELAY = 350;

export default class Reusepicklistinlwc extends LightningElement 
{
    @api filterName;
    @api filterOption;
    @api maxNumericNumber;
    @api label;
    @api isDraggedDropped = false;
    @api isInputField     = false;

    @track sFrom = '';
    @track sTo = '';
    @track options = [];
    
    @wire(CurrentPageReference) pageRef;

    filters = {};

    _isRendered;

    renderedCallback() 
    {
        if ( !this._isRendered)
        {          
            this._isRendered = true;

            if (!this.isInputField)
            {
                if( this.filterOption === 'Numeric Number')
                {
                    this.options = this.getNumericNumber();
                }
    
                if( this.filterOption === 'Calendar Month' )
                {
                    this.options = this.getMonths();
                }
            }

            registerListener( 'reset_Filters', this.resetFilters, this );
        }
    }

    disconnectedCallback() 
    {
        unregisterAllListeners(this);
    }

    resetFilters( event )
    {
        this.sFrom = '';
        this.sTo   = '';
    }

    handleValueChange = (evt) => 
    {
        var field_name = evt.target.name;
        var small;
        var big;
        var isValid = true;

        if(field_name === 'c_picklistFrom' || field_name === 'c_inputFrom')
        {
            small = evt.target.value;
            console.log('Small: ' + small);
            if( Number.parseInt(small) > Number.parseInt(this.sTo,10) )
            {
                evt.target.value = small = this.sTo;
                console.log('STO: ' + this.sTo);
            }
            this.sFrom = small;
            field_name === 'c_inputFrom' && (isValid = this.validateInputRange(null));
        }

        if(field_name === 'c_picklistTo')
        {
            big = evt.target.value;
            if( Number.parseInt(big,10) < Number.parseInt(this.sFrom,10) )
            {
                evt.target.value = big = this.sFrom;
            }
            this.sTo = big;
        }

        if(field_name === 'c_inputTo')
        {
            big = evt.target.value;
            isValid = this.validateInputRange(big);
        }

        console.log('#### sFrom = ' + this.sFrom + ' ---- sTo = ' + this.sTo );
        this.filters.minValue = this.sFrom;
        this.filters.maxValue = this.sTo;
        this.filters.filterName = this.filterName;
        console.log('#### allValid = ' + isValid);
        this.filters.isValid = isValid;
        this.delayedFireFilterChangeEvent();
    }

    validateInputRange(big)
    {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => { 
            if (inputCmp.name === 'c_inputTo' && big !== null)
            {
                if( Number.parseInt(big,10) < Number.parseInt(this.sFrom,10) )
                {    
                    inputCmp.setCustomValidity("To value cannot be smaller than From value.");         
                }
                else
                {
                    inputCmp.setCustomValidity("");
                    this.sTo = big;
                }
            }
            console.log('Sto 2: ' + this.sTo);
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        return allValid;
    }

    getNumericNumber()
    {
        let counter = this.maxNumericNumber;
        const numbers = [];
        numbers.push(  { label: '--None--', value: null } );
        if( counter )
        {
            for(let i=1 ; i<=counter ; i++)
            {
                numbers.push({ label : i.toString(), value : i.toString() });
            }
        }

        return numbers;
    }

    getMonths()
    {
        return [
            { label: '--None--', value: null },
            { label: 'Jan', value: '1' },
            { label: 'Feb', value: '2' },
            { label: 'Mar', value: '3' },
            { label: 'Apr', value: '4' },
            { label: 'May', value: '5' },
            { label: 'Jun', value: '6' },
            { label: 'Jul', value: '7' },
            { label: 'Aug', value: '8' },
            { label: 'Sep', value: '9' },
            { label: 'Oct', value: '10' },
            { label: 'Nov', value: '11' },
            { label: 'Dec', value: '12' },
        ];
    }

    delayedFireFilterChangeEvent() 
    {
        // Debouncing this method: Do not actually fire the event as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex
        // method calls in components listening to this event.
        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => 
        {
            fireEvent(this.pageRef, 'numberRangeChange', this.filters);
        }, DELAY);
    }
}