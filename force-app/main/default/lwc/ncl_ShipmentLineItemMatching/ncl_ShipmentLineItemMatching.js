import { LightningElement, track, api, wire } from 'lwc';

/**
 * Notify record change
 */
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

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

const LINE_ITEM_HEADERS = [
    {
        label: 'Shipment Line Item',
        fieldName: 'lineItemUrl_',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Name'
            },
            target: '_blank'
        },
        wrapText: true
    },
    { label: 'Prod Mth', fieldName: 'Production_Month__c', wrapText: true },
    { label: 'Variant', fieldName: 'Model__c', wrapText: true },
    { label: 'Color', fieldName: 'Colour_Code__c', wrapText: true },
    { label: 'Trim', fieldName: 'Trim__c', wrapText: true },
    { label: 'Engine No', fieldName: 'Engine_No__c', wrapText: true },
    { label: 'Chassis No', fieldName: 'Chassis_No__c', wrapText: true },
    { label: 'Manufacturer Ref No', fieldName: 'Manufacturer_Ref_No__c', wrapText: true },
    {
        label: 'Stock Vehicle Master',
        fieldName: 'matchStockUrl_',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'matchStockName_'
            },
            target: '_blank'
        }
        , wrapText: true 
    },
    {
        type: 'action',
        typeAttributes: {
            rowActions: [
                {
                    label: 'Manual Assign',
                    name: 'manual_assign'
                }
            ]
        }
    }
];

export default class ncl_ShipmentLineItemMatching extends LightningElement
{
    /**
     * Vehicle Shipment Id
     */
    @api recordId;

    /**
     * Default condition for retrieving eligible Stock Vehicle Master for matching
     */
    @track ignoreEligibilityChecking_ = false;
    @track stockIsUnmatched_ = `Shipment_Line_Item__c = NULL`;
    @track stockIsConfirmed_ = `(Vehicle_Purchase_Order_Line_Items__c != NULL AND Vehicle_Purchase_Status__c = 'Confirmed')`;
    @track stockIsReserved = `(Vehicle_Status__c = 'RESRV')`;
    @track conditions = this.ignoreEligibilityChecking? this.stockIsUnmatched_ : `${this.stockIsUnmatched_} AND (${this.stockIsConfirmed_} OR ${this.stockIsReserved})`;

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

    // constructor()
    // {
    //     super();
    //     // dynamic row action
    //     this.headers_ = this.headers_.concat({
    //         type: 'action',
    //         typeAttributes: {
    //             rowActions: this.getRowActions_
    //         }
    //     });
    // }

    // renderedCallback()
    // {
    //     console.log(this.headers_);
    // }

    // getRowActions_(row, doneCallback)
    // {
    //     const actions = [];

    //     // re-assign action
    //     if (row.matched_)
    //     {
    //         actions.push({
    //             'label': 'Re-assign',
    //             'name': 'reassign'
    //         });
    //     }
    //     // manual assign action
    //     else
    //     {
    //         actions.push({
    //             'label': 'Manual Assign',
    //             'name': 'manual_assign'
    //         });
    //     }

    //     setTimeout(() => {
    //         doneCallback(actions);
    //     }, 200);
    // }

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
            this.shipment_              = result.data.shipment;
            this.detectMatchedStocks_();
            this.refreshStockVehicleMasterRelatedList_();
        }
        else
        {
            this.showNotification_('Unexpected error', 'Unexpected error on launching matching component. Please contact System Administrator.', 'error', 'sticky');
            console.error(result.error);
        }
    }

    handleRowAction(event)
    {
        const actionName = event.detail.action.name;

        const row = event.detail.row;

        switch (actionName) {
            case 'manual_assign':
                this.beginManualAssign(row);
                break;
            default:
        }
    }

    /**
     * Handler for manual assign and re-assign button click event
     * @param {*} row selected row for manual assign 
     */
    beginManualAssign(row)
    {
        // this.selectedLineItemId_ = e.currentTarget.dataset.lineItemId;
        this.selectedLineItemId_ = row.Id;
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

        for (let shipmentLineItem of this.shipmentLineItems)
        {
            shipmentLineItem.lineItemUrl_ = `//${window.location.host}/${shipmentLineItem.Id}`;
        }
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

        this.modelFilters_ = this.shipment?.Franchise_Code__c? `Franchise_Code__c = '${this.shipment.Franchise_Code__c}'` : '';
    }

    get shipment_()
    {
        return this.shipment;
    }

    @track modelFilters_ = '';

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

    /**
     * fire event to refresh stock vehicle master related list
     */
    refreshStockVehicleMasterRelatedList_()
    {
        // let recipients = [];

        // for (let shipmentMatchedStock of this.shipmentMatchedStocks)
        // {
        //     recipients.push({
        //         recordId: shipmentMatchedStock.Id
        //     });
        // }

        // console.log('recipients', recipients);
        // getRecordNotifyChange(recipients);

        this.dispatchEvent(new CustomEvent('refresh'));
    }

    errorCallback()
    {
        this.showNotification_('Warning', 'Unexpected error on Vehicle Shipment module rendering', 'warning', 'sticky');
    }

    @track headers_ = LINE_ITEM_HEADERS;
}