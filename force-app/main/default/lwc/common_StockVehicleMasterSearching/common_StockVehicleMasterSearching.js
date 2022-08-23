import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import VARIANT from '@salesforce/schema/Model_Master__c';
import VARIANT_NAME from '@salesforce/schema/Model_Master__c.Name';
import VARIANT_MODEL_DESCRIPTION from '@salesforce/schema/Model_Master__c.Model_Description__c';
import getVariantCombinationsById from '@salesforce/apex/StockVehicleMasterSearchingController.getVariantCombinationsById';
import getStockVehicleMaster from '@salesforce/apex/StockVehicleMasterSearchingController.getStockVehicleMaster';

const COLUMNS = 
[
    { label: 'RVH Name', fieldName: 'Name', editable: false },
    { label: 'Vehicle Purchase Status', fieldName: 'Vehicle_Purchase_Status__c', editable: false },
    { label: 'Vehicle Status', fieldName: 'Vehicle_Status__c', editable: false },
    { label: 'Model Description', fieldName: 'Model_Description__c', editable: false },
    { label: 'Color Description', fieldName: 'Color_Description__c', editable: false },
    { label: 'Trim Description', fieldName: 'Trim_Description__c', editable: false },
    { label: 'Production Month', fieldName: 'Production_Month__c', editable: false },
    { label: 'Manufacturer Ref. No.', fieldName: 'Manufacturer_Ref_No__c', type: 'text', editable: false },
];

export default class Common_StockVehicleMasterSearching extends LightningElement
{
    /**
     * Conditions for vehicle stock master searching, can be set by parent
     */
    @api conditions = '';

    /**
     * Vehicle Stock Master table settings
     */
    @track columns = COLUMNS;

    /**
     * Flag for spinner
     */
    @track spinner = false;

    /**
     * Selected variant record
     */
    @track selectedVariant;

    /**
     * Selected variant id
     */
    @track selectedVariantId;

    /**
     * Selected color id
     */
    @track selectedColorId;

    /**
     * selected trim id
     */
    @track selectedTrimId;

    /**
     * Production Month input
     */
    @track productionMonth;

    /**
     * Stock Vehicle Master retrieved
     */
    @track stocks = [];

    /**
     * Combination of possible variant-color-trim options
     */
    @track variantCombinations = [];

    /**
     * Color options
     */
    @track colorOptions = [];

    /**
     * Trim options
     */
    @track trimOptions = [];

    /**
     * Flag to enable Stock Vehicle Master table
     */
    get hasData()
    {
        return this.stocks && this.stocks.length > 0;
    }

    /**
     * Handler for variant selected event
     * @param {*} e 
     */
    variantSelected(e)
    {
        // console.log('varian selected');
        if (!this.selectedVariant_ || (this.selectedVariant_.Id !== e.detail.Id))
        {
            this.selectedVariant_ = e.detail
        
            this.selectedVariantId && this.getVariantCombinations();
        }
    }

    /**
     * Handler for variant selected event
     * @param {*} e 
     */
    variantUnselected(e)
    {
        console.log('varian unselected');

        this.selectedVariant_ = null;
        
    }

    /**
     * Call backend to retrieve possible variant-color-trim combination for selected variant. These combinations are foundation for color & trim options
     */
    getVariantCombinations()
    {
        getVariantCombinationsById({
            variantId : this.selectedVariantId
        })
        .then(result => {
            this.variantCombinations = result;

            if (this.variantCombinations && this.variantCombinations.length > 0)
            {
                this.getColorOptions();
            }
            else
            {
                this.showNotification_('Warning', 'No Color and Trim can be found for this Variant! Please try another Variant or contact your Administrator!', 'warning', 'sticky');
            }
        })
        .catch(error => {
            console.error(error);
        })
    }

    /**
     * Get color options from variant-color-trim combinations
     */
    getColorOptions()
    {
        this.colorOptions = [];

        // to filter duplicate color
        let optionIds = [];

        this.variantCombinations.forEach(combination => {
            if (combination.Color_Code__r && combination.Color_Code__r.Color_Description__c)
            {
                if (!optionIds.includes(combination.Color_Code__r.Id))
                {
                    let colorDescription    = combination.Color_Code__r.Color_Description__c;
                    let colorCode           = combination.Color_Code__r.ColorCode__c? `(${combination.Color_Code__r.ColorCode__c})` : '';

                    this.colorOptions.push({
                        label : `${colorDescription} ${colorCode}`,
                        value : combination.Color_Code__r.Id
                    })

                    optionIds.push(combination.Color_Code__r.Id);
                }
            }
        })

        if (this.colorOptions.length === 0)
        {
            this.showNotification_('Warning', 'This variant do not have any color options', 'warning', 'sticky');
        }
    }

    /**
     * Get color options from variant-color-trim combinations and selected variant + color
     */
    getTrimOptions()
    {
        this.trimOptions = [];

        // to filter duplicate trim
        let optionIds = [];

        this.variantCombinations.forEach(combination => {
            if (combination.Color_Code__r && combination.Trim_Code__r && combination.Trim_Code__r.Trim_Description__c)
            {
                if (!optionIds.includes(combination.Trim_Code__r.Id) && combination.Color_Code__r.Id == this.selectedColorId)
                {
                    let trimDescription    = combination.Trim_Code__r.Trim_Description__c;
                    let trimCode           = combination.Trim_Code__r.Name? `(${combination.Trim_Code__r.Name})` : '';

                    this.trimOptions.push({
                        label : `${trimDescription} ${trimCode}`,
                        value : combination.Trim_Code__r.Id
                    })

                    optionIds.push(combination.Trim_Code__r.Id);
                }
            }
        })

        if (this.trimOptions.length === 0)
        {
            this.showNotification_('Warning', 'This variant and color do not have any trim options', 'warning', 'sticky');
        }
    }

    /**
     * Handler for color selected event
     * @param {*} e 
     */
    colorSelected(e)
    {
        this.selectedColorId_ = e.currentTarget.value;
        this.getTrimOptions();
    }

    /**
     * Handler for trim selected event
     * @param {*} e 
     */
    trimSelected(e)
    {
        this.selectedTrimId_ = e.currentTarget.value;
    }

    /**
     * Handler for production month updated
     * @param {*} e 
     */
    updateProductionMonth(e)
    {
        this.productionMonth_ = e.currentTarget.value;
    }

    /**
     * get stock vehicle master eligible for shipment line item assigning
     * @param {*} e 
     */
    getStockVehicleMaster(e)
    {
        // check input validity
        let inputs = [...this.template.querySelectorAll('[data-node-type="input"]')];

        let isValid = inputs.reduce((validSoFar, input) => {
            return validSoFar && input.reportValidity();
        }, true);

        if (!isValid)
        {
            return;
        }

        this.spinner = true;

        getStockVehicleMaster(
            {
                variantId : this.selectedVariantId,
                colorId : this.selectedColorId,
                trimId : this.selectedTrimId,
                productionMonth : this.productionMonth,
                conditions : this.conditions
            }
        )
        .then(result => {
            this.stocks = result;
        })
        .catch(error => {
            this.showNotification_('Error!', 'An error has occured! Please contact your Administrator!', 'error', 'sticky');
            console.error(error);
        })
        .finally(() => {
            this.spinner = false;
        })
    }

    /**
     * Handler for Stock Vehicle Master row selected
     * @param {*} e 
     */
    handleSelectedRow(e)
    {
        const selectedRows = e.detail.selectedRows;

        this.dispatchEvent(new CustomEvent('selected', {detail : selectedRows}));
    }

    /**
     * Clear selected stock and fire event to parent
     * @param {*} e 
     */
    clearSelectedStocks(e)
    {
        let table = this.template.querySelector('lightning-datatable');

        if (table)
        {
            table && (table.selectedRows = []);
            this.dispatchEvent(new CustomEvent('unselected'));
        }
    }

    set selectedVariant_(value)
    {
        this.selectedVariant = value? value : {};
        this.selectedVariantId_ = value? value.Id : null;
    }

    get selectedVariant_()
    {
        return this.selectedVariant;
    }

    set selectedVariantId_(value)
    {
        // on new model selected: reset selected color / trim id and reset color / trim options
        if (this.selectedVariantId != value)
        {
            this.selectedVariantId = value;
            this.colorOptions = [];
            this.trimOptions = [];
            this.selectedColorId = null;
            this.selectedTrimId = null;
        }
    }

    get selectedVariantId_()
    {
        return this.selectedVariantId;
    }

    set selectedColorId_(value)
    {
        // if selected color change, reset trim option and selected trim id
        if (this.selectedColorId != value)
        {
            this.selectedColorId = value;
            this.trimOptions = [];
            this.selectedTrimId = null;
        }
    }

    get selectedColorId_()
    {
        return this.selectedColorId;
    }

    set selectedTrimId_(value)
    {
        this.selectedTrimId = value;
    }

    get selectedTrimId_()
    {
        return this.selectedTrimId
    }

    set productionMonth_(value)
    {
        this.productionMonth = value;
    }

    get productionMonth_()
    {
        return this.productionMonth;
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

    @track objectName = VARIANT.objectApiName;

    @track searchFields = [
        VARIANT_NAME.fieldApiName,
        VARIANT_MODEL_DESCRIPTION.fieldApiName
    ];

    @track displayFields = [
        VARIANT_NAME.fieldApiName,
        VARIANT_MODEL_DESCRIPTION.fieldApiName,
    ];

    @track isVariantRequired_ = true;
    @track variantLookupLabel_ = 'Model Master (Variant)';
}