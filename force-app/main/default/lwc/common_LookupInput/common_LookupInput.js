import { LightningElement, track, api, wire } from 'lwc';
import search from '@salesforce/apex/common_LookupInputController.search';
import simpleSearch from '@salesforce/apex/common_LookupInputController.simpleSearch';

export default class Common_LookupInput extends LightningElement
{
    @api objectName;
    @api searchFields;
    @api displayFields;
    @track searchKey = '';
    @track searchResults = [];
    @track selectedOptionId;


    _clickHandler;

    connectedCallback()
    {
        document.addEventListener('click', this._clickHandler = this.handleClick.bind(this));
    }

    disconnectedCallback()
    {
        document.removeEventListener('click', this._clickHandler);
    }

    /**
     * update search key from text input
     * @param {*} e 
     */
    updateSearchKey(e)
    {
        this.searchKey = e.target.value;

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
     * call server to make the searching
     * @param {*} e 
     */
    doSearching(e)
    {
        // TODO: implement full search
        simpleSearch({
            objectName : this.objectName,
            searchFields : this.searchFields,
            searchKey: this.searchKey,
            displayFields : this.displayFields
        })
        .then(result => {
            this.searchResults = result;
            this.opendropdown_ = true;
        })
        .catch(error => {
            console.error(error);
            this.opendropdown_ = false;
        })
    }

    selectOption(e)
    {
        this.selectedOptionId = e.currentTarget.dataset.optionId;
        this.opendropdown_ = false;

        let selectedRecord = this.searchResults.filter(result => {
            return result.Id == this.selectedOptionId;
        })[0];

        console.log('selectedRecord', selectedRecord);

        this.searchKey = selectedRecord.Name || selectedRecord.Id;

        this.dispatchEvent(new CustomEvent('selected', {detail : selectedRecord}));

        // TODO: fire event up contain record with selected option id
    }

    handleClick(e)
    {
        let searchInput = this.template.querySelector(`[data-id="lookup-input"]`);
        let optionsPanel = this.template.querySelector(`[data-id="lookup-options"]`);
        
        if (this.isWithin(searchInput, e) || this.isWithin(optionsPanel, e)) this.openOptions();
        else this.closeOptions();
    }

    /**
     * checking whether @event happened inside @elem
     * @param {*} elem 
     * @param {*} event 
     */
    isWithin(elem, event)
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

    @track dropDownClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';

    set opendropdown_(value)
    {
        this.dropDownClass = value? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        this.opendropdown = value;
    }

    get opendropdown_()
    {
        return this.opendropdown;
    }

    @track opendropdown;

    openOptions()
    {
        !this.opendropdown_ & (this.opendropdown_ = true);
    }

    closeOptions()
    {
        this.opendropdown_ && (this.opendropdown_ = false);
    }
}