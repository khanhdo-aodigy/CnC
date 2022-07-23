/* eslint-disable no-console */
import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, fireEvent, unregisterAllListeners } from 'c/pubsub';

/** The delay used when debouncing event handlers before firing the event. */
const DELAY = 350;

export default class RangeSelector extends LightningElement 
{
    today = new Date();

    @api label;
    @api filterName;
    @api start_date_min;
    @api start_date_max;
    @api end_date_min;
    @api end_date_max;
    @api isDraggedDropped = false;
    @api isNormalDate     = false;

    @track from_date_min;
    @track from_date_max;
    @track to_date_min;
    @track to_date_max;

    @track start_date;
    @track end_date;
    @track range;

    filters = {};

    @wire(CurrentPageReference) pageRef;

    _isRendered

    renderedCallback() 
    {
        if ( !this._isRendered)
        { 
            this._isRendered = true;

            if (!this.isNormalDate)
            {
                this.from_date_min = this.start_date_min ? this.addYears( this.today, this.start_date_min ).toJSON().slice(0,10) : '';
                this.from_date_max = this.start_date_max ? this.addYears( this.today, this.start_date_max ).toJSON().slice(0,10) : '';
                this.to_date_min   = this.end_date_min   ? this.addYears( this.today, this.end_date_min ).toJSON().slice(0,10)   : '';
                this.to_date_max   = this.end_date_max   ? this.addYears( this.today, this.end_date_max ).toJSON().slice(0,10)   : '';
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
        console.log('####dateRangeSelector : resetFilters');
        this.start_date = '';
        this.end_date   = '';
    }

    addYears = (sd,years) => 
    {
        const d = new Date( sd );
        d.setFullYear(d.getFullYear() + Number( years ) );
        return d;
    }

    addDays = (sd,days) => 
    {
        const d = new Date(Number(sd));
        d.setDate(sd.getDate() + days);
        return d;
    }

    diff = (sdate,edate) => 
    {
        let diffTime = Math.abs(new Date(edate).getTime() - new Date(sdate).getTime());
        return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    }

    valid_date = (sdate,edate) => 
    {
        return new Date(edate) >= new Date(sdate);
    }

    handleDateChange = (evt) =>
    {
        var field_name = evt.target.name;
        var sd_value;
        var ed_value;
        var isValid = true;

        if(field_name === 'startdate')
        {
            sd_value = evt.target.value;
            if( evt.target.value > this.end_date && this.end_date !== "")
            {
                evt.target.value = sd_value = this.end_date;
            }
            this.start_date = sd_value;
        }

        if(field_name === 'enddate')
        {
            ed_value = evt.target.value;
            if( ed_value < this.start_date && this.start_date !== "")
            {
                evt.target.value = ed_value = this.start_date;
            }
            this.end_date = ed_value;
        }

        isValid = this.validateInput();
        console.log('check date --- start = ' + this.start_date + ' --- end = ' + this.end_date );

        this.filters.minValue = this.start_date;
        this.filters.maxValue = this.end_date;
        this.filters.filterName = this.filterName;
        this.filters.isValid    = isValid;
        
        this.delayedFireFilterChangeEvent();
    }

    validateInput()
    {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        return allValid;
    }

    delayedFireFilterChangeEvent() 
    {
        // Debouncing this method: Do not actually fire the event as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex
        // method calls in components listening to this event.
        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            fireEvent(this.pageRef, 'dateRangeChange', this.filters);
        }, DELAY);
    }
}