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
    // { label: 'Manufacturer Ref. No.', fieldName: 'Manufacturer_Ref_No__c', type: 'text', editable: true },
];

export default class Common_StockVehicleMasterSearching extends LightningElement
{
    @track columns = COLUMNS;
    @track spinner = false;

    @api conditions = '';

    // main inputs
    @track selectedVariantId;
    @track selectedColorId;
    @track selectedTrimId;

    @track stocks = [];

    @track variantCombinations = [];

    @track colorOptions = [];

    @track trimOptions = [];

    // @track disableColorSelect = true;
    // @track disableTrimSelect = true;

    @track objectName = VARIANT.objectApiName;

    @track searchFields = [
        VARIANT_NAME.fieldApiName,
        VARIANT_MODEL_DESCRIPTION.fieldApiName
    ];

    @track displayFields = [
        VARIANT_NAME.fieldApiName,
        VARIANT_MODEL_DESCRIPTION.fieldApiName,
    ];

    get hasData()
    {
        return this.stocks && this.stocks.length > 0;
    }

    variantSelected(e)
    {
        this.selectedVariantId_ = e.detail.Id;
        this.selectedVariantId && this.getVariantCombinations();

        // TODO: toast when !this.selectedVariantId
    }

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
                console.log(123);
                // TODO: have warning 
                this.showNotification('Sorry!', 'No Color and Trim can be found for this Variant! Please try another Variant or contact your Administrator!', 'warning', 'sticky');
            }
            
        })
        .catch(error => {
            console.error(error);
        })
    }

    getColorOptions()
    {
        this.colorOptions = [];

        // to filter duplicate color
        let optionIds = [];

        this.variantCombinations.forEach(combination => {
            if (combination.Color_Code__r)
            {
                if (!optionIds.includes(combination.Color_Code__r.Id))
                {
                    this.colorOptions.push({
                        label : `${combination.Color_Code__r.Color_Description__c} (${combination.Color_Code__r.ColorCode__c || ''})`,
                        value : combination.Color_Code__r.Id
                    })

                    optionIds.push(combination.Color_Code__r.Id);
                }
            }
        })

        // this.disableColorSelect = !(this.colorOptions.length > 0);
    }

    getTrimOptions()
    {
        this.trimOptions = [];

        // to filter duplicate trim
        let optionIds = [];

        this.variantCombinations.forEach(combination => {
            if (combination.Color_Code__r && combination.Trim_Code__r)
            {
                if (!optionIds.includes(combination.Trim_Code__r.Id) && combination.Color_Code__r.Id == this.selectedColorId)
                {
                    this.trimOptions.push({
                        label : `${combination.Trim_Code__r.Trim_Description__c} (${combination.Trim_Code__r.Name || ''})`,
                        value : combination.Trim_Code__r.Id
                    })

                    optionIds.push(combination.Trim_Code__r.Id);
                }
            }
        })

        console.log(this.trimOptions);

        // this.disableTrimSelect = !(this.trimOptions.length > 0);
    }

    colorSelected(e)
    {
        this.selectedColorId_ = e.currentTarget.value;
        this.getTrimOptions();
    }

    trimSelected(e)
    {
        this.selectedTrimId_ = e.currentTarget.value;
    }

    /**
     * get stock vehicle master eligible for shipment line item assigning
     * @param {*} e 
     */
    getStockVehicleMaster(e)
    {
        this.spinner = true;
        getStockVehicleMaster(
            {
                variantId : this.selectedVariantId,
                colorId : this.selectedColorId,
                trimId : this.selectedTrimId,
                conditions : this.conditions
            }
        )
        .then(result => {
            console.log(result);
            this.stocks = result;
            this.spinner = false;
        })
        .catch(error => {
            console.error('getStockVehicleMaster - error: ' + error);
            this.spinner = false;
            this.showNotification('Error!', 'An error has occured! Please contact your Administrator!', 'error', 'sticky');
        })
    }

    handleSelectedRow(e)
    {
        const selectedRows = e.detail.selectedRows;
        this.dispatchEvent(new CustomEvent('selected', {detail : selectedRows}));
    }

    // on new model selected: reset selected color / trim id and reset color / trim options
    set selectedVariantId_(value)
    {
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

    // on new color selected: reset selected trim id and reset trim options
    set selectedColorId_(value)
    {
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

    showNotification(title, message, variant, mode)
    {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });

        this.dispatchEvent(evt);
    }
}