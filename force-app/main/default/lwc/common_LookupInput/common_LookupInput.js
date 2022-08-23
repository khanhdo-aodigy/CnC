import { LightningElement, track, api, wire } from 'lwc';
import search from '@salesforce/apex/common_LookupInputController.search';
import simpleSearch from '@salesforce/apex/common_LookupInputController.simpleSearch';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Common_LookupInput extends LightningElement
{
    /**
     * Object API Name
     */
    @api objectName;

    /**
     * Field API Name for searching
     */
    @api searchFields;

    /**
     * Field API Name for querying
     */
    @api displayFields;

    /**
     * Label for search box
     */
    @api label;

    /**
     * Indicate whether lookup input is required
     */
    @api required;

    /**
     * Indicate whether label is inline, above or hidden
     */
    @api labelStyle;

    /**
     * Lookup filter passed by parent component
     */
    @api conditions;

    /**
     * Default record from parent. If have default, set the options and selected record to be the defaulted record.
     */
    @api
    set defaultRecord(value)
    {
        if (value && value.Id && value.Name)
        {
            let value_ = JSON.parse(JSON.stringify(value));

            this.searchResults = [value_];
            this.selectedRecord_ = value_;
        }
        else
        {
            // this.showNotification_('Info', 'Default record for lookup input do not have either Name or Id', 'info', 'dismissible');
            this.searchResults = [];
            this.selectedRecord_ = null;
        }
    }

    get defaultRecord()
    {
        return this.searchResults;
    }

    /**
     * API method for parent to check lookup input validity
     * @returns 
     */
    @api
    reportValidity()
    {
        let inputElement = this.template.querySelector('[data-id="lookup-input"]');

        return inputElement.reportValidity();
    }

    /**
     * Handler for click event on document
     */
    _clickHandler;
    connectedCallback()
    {
        document.addEventListener('click', this._clickHandler = this.handleDocumentClick_.bind(this));
    }

    disconnectedCallback()
    {
        document.removeEventListener('click', this._clickHandler);
    }

    /**
     * Selected record
     */
    @track selectedRecord;

    /**
     * Search key from search box
     */
    @track searchKey = '';

    /**
     * Searching results
     */
    @track searchResults = [];


    @track selectedOptionId;

    /**
     * Flag for searching spinner inside search box
     */
    @track searching = false;

    /**
     * Flag for open dropdown options
     */
    @track opendropdown;

    /**
     * CSS for open/close dropdown options
     */
    @track dropDownClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';

    /**
     * update search key from text input
     * @param {*} e 
     */
    updateSearchKey(e)
    {
        this.searchKey = e.target.value;

        this.searching = true;

        this.debounce(this.doSearching, 500);
    }

    /**
     * debounce wrapper of @func
     * @param {*} func : function for debouncing
     */
    @track timerId;
    debounce(func, timeout = 300)
    {
        clearTimeout(this.timerId);

        this.timerId = setTimeout(() => {
            func.apply(this);
        }, timeout);
    }

    /**
     * Call server to make the searching
     * @param {*} e 
     */
    doSearching(e)
    {
        // TODO: implement full search
        simpleSearch({
            objectName : this.objectName,
            searchFields : this.searchFields,
            searchKey: this.searchKey,
            displayFields : this.displayFields,
            conditions : this.conditions
        })
        .then(result => {
            this.searchResults = result;
            this.opendropdown_ = true;
        })
        .catch(error => {
            this.showNotification_('Error', 'Unexpected error on searching', 'error', 'sticky');
            console.error(error);
            this.opendropdown_ = false;
        })
        .finally(() => {
            this.searching = false;
        })
    }

    /**
     * Handler for option selected event
     * @param {*} e 
     */
    selectOption(e)
    {
        let selectedRecord = this.searchResults.filter(result => {
            return result.Id == e.currentTarget.dataset.optionId;
        })[0];

        this.selectedRecord_ = selectedRecord;

        this.opendropdown_ = false;
    }

    /**
     * Handle commit event on lookup input. Commit event happen when: user press Enter on search box, search box lose focus or user click x button on search box
     * Check the search box value to differentiate between these scenarios
     * @param {*} e 
     */
    handleCommitEvent(e)
    {
        let searchBox = this.template.querySelector('[data-id="lookup-input"');

        // user click x button
        if (!searchBox.value)
        {
            this.searchResults = [];
            this.selectedRecord_ = null;
        }
        // user press Enter on search box, search box lose focus
        else
        {
            // reserved for future use
        }
    }

    /**
     * Handler for close button
     * @param {*} e 
     */
    handleSearchCancel(e)
    {
        this.searchResults = [];
        this.selectedRecord_ = null;
        this.opendropdown_ = false;
    }

    set opendropdown_(value)
    {
        this.dropDownClass = value? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        this.opendropdown = value;
    }

    get opendropdown_()
    {
        return this.opendropdown;
    }

    set selectedRecord_(value)
    {
        // console.log('new selected record', value);
        // console.log('old selected record', this.selectedRecord);

        // if selected record change, fire event to parent
        if (this.selectedRecord != value)
        {
            // console.log('different');

            // fire selected event if having value
            value && this.dispatchEvent(new CustomEvent('selected', {detail : value}));

            // fire unselected event if having no value
            !value && this.dispatchEvent(new CustomEvent('unselected'));
        }

        // set search key by selected record's name
        this.searchKey = value? value.Name || value.Id : '';

        this.selectedRecord = value;
    }
 
    get selectedRecord_()
    {
        return this.selectedRecord;
    }

    showNotification_(title, message, variant, mode)
    {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });

        this.dispatchEvent(evt);
    }

    /**
     * Check if click event is within lookup input or lookup options. If outside both components, close the dropdown
     * @param {*} e 
     */
    handleDocumentClick_(e)
    {
        let searchInput = this.template.querySelector(`[data-id="lookup-input"]`);
        let optionsPanel = this.template.querySelector(`[data-id="lookup-options"]`);
        
        if (this.isWithin_(searchInput, e) || this.isWithin_(optionsPanel, e)) this.openOptions_();
        else this.closeOptions_();
    }

    /**
     * checking whether @event happened inside @elem
     * @param {*} elem 
     * @param {*} event 
     */
    isWithin_(elem, event)
    {
        let ELEM_TOP = elem.getBoundingClientRect().top;
        let ELEM_BOTTOM = elem.getBoundingClientRect().bottom;
        let ELEM_LEFT = elem.getBoundingClientRect().left;
        let ELEM_RIGHT = elem.getBoundingClientRect().right;

        let MOUSE_X = event.clientX;
        let MOUSE_Y = event.clientY;

        let isWithinX = MOUSE_X >= ELEM_LEFT && MOUSE_X <= ELEM_RIGHT;
        let isWithinY = MOUSE_Y >= ELEM_TOP && MOUSE_Y <= ELEM_BOTTOM;

        // console.table([ELEM_LEFT, ELEM_RIGHT, ELEM_TOP, ELEM_BOTTOM]);
        // console.table([MOUSE_X, MOUSE_Y]);
        // console.table([isWithinX, isWithinY]);

        return isWithinX && isWithinY;
    }

    /**
     * Open dropdown options
     */
    openOptions_()
    {
        !this.opendropdown_ & (this.opendropdown_ = true);
    }

    /**
     * Close dropdown options
     */
    closeOptions_()
    {
        this.opendropdown_ && (this.opendropdown_ = false);
    }
}