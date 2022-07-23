/* eslint-disable no-console */
import { LightningElement, api, track , wire} from 'lwc';
export default class DualListAsCmp extends LightningElement {

    @api duallistApiFieldName;
    @api duallistOptions;
    @api duallistName;
    @api duallistLabel;
    @api duallistSourceLabel;
    @api duallistSelectedLabel;
    @api duallistFieldLevelHelp;
    @api duallistsize = "4";
    @api disableReorder = false;
    @api duallistVariant;
    @api addBtnLabel;
    @api removeBtnLabel;
    @api upBtnLabel;
    @api downBtnLabel;
    @api duallistStyle = "font-size: x-small;"

    @track _options;
    @track _selected;
    
    initialRender = true;
    renderedCallback() {

        if( !this.initialRender ) return;
        if (typeof(this.duallistOptions === 'string') && this.isValidJSON(this.duallistOptions) )
            {this._options = JSON.parse(this.duallistOptions);}
        else 
            {this._options = this.duallistOptions;}

        this.initialRender = this.initialRender === true && false;
        // console.log('####DEBUG DualListAsCmp >> renderedCallback -- input_name = ' + this.input_name );
        // console.log('####DEBUG DualListAsCmp >> renderedCallback -- _options = ' + this._options  ) ;
    }

    @api
    refreshComponent() {
        this.initialRender = true;
        this.renderedCallback()
    }

    @api
    setOptions( param ) {
        this._options = param;

        if( this._options && this._options.length == 0 ) {
            this._selected = [];
        }
    }

    get selected() {
        return this._selected.length ? this._selected : 'none';
    }

    onValueChanged( event ) {
        event.preventDefault();
        this._selected = event.detail.value;
        this.dispatchChanges(event.target.value);
    }

    dispatchChanges( value ) {//valueChanged
        this.dispatchEvent(new CustomEvent('DualPickilistValueChanged', {
            detail: { [this.duallistApiFieldName]: value },
            bubbles: true,
            composed: true
        }));
    }

    isValidJSON = str => {
        try {
            JSON.parse(str);
            return true;
        } 
        catch (e) {
            return false;
        }
    }
}