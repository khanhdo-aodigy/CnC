import { LightningElement, track, api, wire } from 'lwc';

/**
 * Display toast notification on screen
 */
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * Retrieve shipment details on component init
 */
import init from '@salesforce/apex/ShipmentLineItemsMatchingController.init';

/**
 * Auto match all shipment line items
 */
import shipmentsAutoMatching from '@salesforce/apex/ShipmentLineItemsMatchingController.shipmentsAutoMatching';

/**
 * Manual match or re-match selected shipment line item with selected stock vehicle master
 */
import shipmentManualMatchById from '@salesforce/apex/ShipmentLineItemsMatchingController.shipmentManualMatchById';

/**
 * Refresh wired attribute / function
 */
import { refreshApex } from '@salesforce/apex';

export default class ncl_ShipmentLineItemMatching extends LightningElement
{
    /**
     * Vehicle Shipment Id
     */
    @api recordId;

    /**
     * Default condition for retrieving eligible Stock Vehicle Master for matching
     */
    @track conditions = `Vehicle_Purchase_Status__c != 'In Shipment' AND Vehicle_Purchase_Status__c != 'Arrived' AND Vehicle_Purchase_Status__c != 'SCL_Cancel' ${this.franchiseCodeCondition_}`;

    /**
     * Indicate the server trip is done
     */
    @track ready = true;

    /**
     * Disable the manual assign button
     */
    @track disableManualAssignButton = true;

    /**
     * Disable the auto assign button
     */
     @track disableAutoAssignButton;

    /**
     * Stock Vehicle Master Id for manual matching
     */
    @track selectedStockVehicleMasterId;

    /**
     * Shipment Line Item Id for manual matching
     */
    @track selectedLineItemId;

    /**
     * Result of wired init method
     */
    @track wiredVehicleShipmentDetail;

    /**
     * Shipment details
     */
    @track shipment = {};

    /**
     * Shipment Line Items
     */
    @track shipmentLineItems = [];

    /**
     * Matched Stock Vehicle Master
     */
    @track shipmentMatchedStocks = [];

    /**
     * Flag to open manual assigning modal
     */
    @track startManualAssigning;

    /**
     * On component init, call server to get Vehicle Shipment details include all line items and matched stock vehicle master
     * @param {*} result 
     */
    @wire(init, {
        vehicleShipmentId : '$recordId'
    })
    ProcessVehicleShipmentDetail(result)
    {
        // store wired result for refreshing
        this.wiredVehicleShipmentDetail = result;

        if (result.data)
        {
            this.shipmentLineItems_     = result.data.shipmentLineItems;
            this.shipmentMatchedStocks_ = result.data.shipmentMatchedStocks;
            console.log('shipment', result.data.shipment);
            this.detectMatchedStocks_();
        }
        else
        {
            this.showNotification_('Unexpected error', 'Unexpected error on launching matching component. Please contact System Administrator.', 'error', 'sticky');
            console.error(result.error);
        }
    }

    /**
     * Handler for manual assign and re-assign button click event
     * @param {*} e 
     */
    beginManualAssign(e)
    {
        this.selectedLineItemId_ = e.currentTarget.dataset.lineItemId;
    }

    /**
     * Handler for manual modal cancel button click event
     * @param {*} e 
     */
    endManualAssign(e)
    {
        this.selectedLineItemId_ = null;
    }

    /**
     * Handler for manual assign and re-assign button click event
     * @param {*} e 
     * @returns 
     */
    doManualAssigning(e)
    {
        // do final check of input data as a last line of defense
        if (!this.selectedLineItemId)
        {
            this.showNotification_('Info', 'No selected line item for manual assigning', 'info', 'sticky');
            return;
        }

        if (!this.selectedStockVehicleMasterId)
        {
            this.showNotification_('Info', 'No selected stock vehicle master for manual assigning', 'info', 'sticky');
            return;
        }
        
        this.ready = false;

        // call server to do the assigning
        shipmentManualMatchById({
            shipmentLineItemId : this.selectedLineItemId,
            stockVehicleMasterId : this.selectedStockVehicleMasterId
        })
        .then(result => {
            this.showNotification_('Success', 'Successfully assign selected stock to shipment line item', 'success', 'dismissible');
            this.endManualAssign();
            refreshApex(this.wiredVehicleShipmentDetail);
        })
        .catch(error => {
            this.showNotification_('Unexpected error', 'Unexpected error on manual assigning. Please contact System Administrator.', 'error', 'sticky');
            console.error(error);
        })
        .finally(() => {
            this.ready = true;
        })
    }

    /**
     * Handler for auto matching button click event
     * @param {*} e 
     */
    doAutoMatching(e)
    {
        this.ready = false;

        // call server to do the assigning
        shipmentsAutoMatching({
            vehicleShipmentId : this.recordId
        })
        .then(result => {
            
            // toast on all line items matched
            result == 'FULL' && this.showNotification_('Success', 'Auto matching successfully', 'success', 'dismissible');

            // toast on part of line items matched
            result == 'PARTIAL' && this.showNotification_('Warning', 'Auto matching partially success. Unmatched line item can be assigned manually', 'warning', 'dismissible');

            // toast on no line item matched
            (!result || result == 'FAIL') && this.showNotification_('Error', 'Auto matching failed. Unmatched line item can be assigned manually', 'error', 'dismissible');
            
            // refresh line items
            refreshApex(this.wiredVehicleShipmentDetail);
        })
        .catch(error => {
            this.showNotification_('Unexpected error', 'Unexpected error on auto matching. Please contact System Administrator.', 'error', 'sticky');
            console.error(error);
        })
        .finally(() => {
            this.ready = true;
        })
    }

    /**
     * Handler for selected event from stock vehicle master searching event
     * @param {*} e 
     */
    stockSelected(e)
    {
        this.selectedStockVehicleMasterId_ = e.detail[0]?.Id;
    }

    /**
     * Handler for unselected event from stock vehicle master searching event
     * @param {*} e 
     */
    stockUnselected(e)
    {
        this.selectedStockVehicleMasterId_ = null;
    }

    /**
     * Handler for quit button click event
     * @param {*} e 
     */
    quitMatching(e)
    {
        this.dispatchEvent(new CustomEvent('close'));
    }


    set selectedStockVehicleMasterId_(value)
    {
        this.selectedStockVehicleMasterId = value;

        this.disableManualAssignButton = !value;
    }

    get selectedStockVehicleMasterId()
    {
        return this.selectedStockVehicleMasterId;
    }

    set selectedLineItemId_(value)
    {
        this.selectedLineItemId = value;

        // enable manual assigning modal if have selected line item id
        this.selectedLineItemId && this.enableManualAssigningModal_();

        // disable manual assigning modal if do not have selected line item id
        !this.selectedLineItemId && this.disableManualAssigningModal_();
    }

    get selectedLineItemId_()
    {
        return this.selectedLineItemId;
    }

    set shipmentLineItems_(value)
    {
        if (!value || value.length == 0)
        {
            this.disableAutoAssignButton = true;
            return;
        }

        this.shipmentLineItems = JSON.parse(JSON.stringify(value));
    }

    get shipmentLineItems_()
    {
        return this.shipmentLineItems;
    }

    set shipmentMatchedStocks_(value)
    {
        this.shipmentMatchedStocks = JSON.parse(JSON.stringify(value));
    }

    get shipmentMatchedStocks_()
    {
        return this.shipmentMatchedStocks;
    }

    set startManualAssigning_(value)
    {
        // if start manual assigning change value reset the selected stock vehicle master id
        this.startManualAssigning !== value && (this.selectedStockVehicleMasterId_ = null);

        this.startManualAssigning = value;
    }

    get startManualAssigning_()
    {
        return this.startManualAssigning;
    }

    set shipment_(value)
    {
        this.shipment = value;

        this.franchiseCodeCondition_ = this.shipment?.Franchise_Code__c? `AND Franchise_Code__c ${this.shipment.Franchise_Code__c}` : '';
    }

    get shipment_()
    {
        return this.shipment;
    }

    @track franchiseCodeCondition_ = '';

    /**
     * Auto detect which line item has been matched
     */
    detectMatchedStocks_()
    {
        if (!this.shipmentLineItems || this.shipmentLineItems.length == 0)
        {
            this.showNotification_('Warning', 'Vehicle shipment do not have any line items', 'warning', 'sticky');
            return;
        }

        if (!this.shipmentMatchedStocks || this.shipmentMatchedStocks.length == 0)
        {
            return;
        }

        for (let stock of this.shipmentMatchedStocks)
        {
            if (stock.Shipment_Line_Item__c)
            {
                this.shipmentLineItems.forEach(lineItem => {
                    if (lineItem.Id === stock.Shipment_Line_Item__c)
                    {
                        lineItem.matched_           = true;
                        lineItem.matchStockId_      = stock.Id;
                        lineItem.matchStockUrl_     = `//${window.location.host}/${stock.Id}`;
                        lineItem.matchStockName_    = stock.Name;
                        lineItem.matchStockStatus_  = stock.Vehicle_Status__c;
                    }
                })
            }
        }

        let allMatch = this.shipmentLineItems.every(lineItem => {
            return lineItem.matched_;
        });

        allMatch && (this.disableAutoAssignButton = true);
    }

     /**
     * Display toast on screen
     * @param {*} title 
     * @param {*} message 
     * @param {*} variant 
     * @param {*} mode 
     */
    showNotification_(title, message, variant, mode)
    {
        (variant === 'error' || variant === 'warning') && (this.error = true);

        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });

        this.dispatchEvent(evt);
    }

    /**
     * Enable manual assigning modal
     */
    enableManualAssigningModal_()
    {
        this.startManualAssigning_ = true;
    }

    /**
     * Disable manual assigning modal
     */
    disableManualAssigningModal_()
    {
        this.startManualAssigning_ = false;
    }
}