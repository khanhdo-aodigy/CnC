import { LightningElement, track, api, wire } from 'lwc';
// import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import matchingById from '@salesforce/apex/ShipmentLineItemsMatchingController.matchingById';
import init from '@salesforce/apex/ShipmentLineItemsMatchingController.init';
import shipmentsAutoMatching from '@salesforce/apex/ShipmentLineItemsMatchingController.shipmentsAutoMatching';
import { refreshApex } from '@salesforce/apex';

export default class ncl_ShipmentLineItemMatching extends LightningElement
{
    @api recordId;

    @track dataLoaded = true;

    @track disableAssignButton = true;

    @track shipmentLineItems = [];

    @track selectedLineItemId;
    @track selectedStockVehicleMasterId;

    set shipmentLineItems_(value)
    {
        this.shipmentLineItems = JSON.parse(JSON.stringify(value));

        // this.detectMatchedStocks();
    }

    get shipmentLineItems_()
    {
        return this.shipmentLineItems;
    }

    @track shipmentMatchedStocks = [];

    set shipmentMatchedStocks_(value)
    {
        this.shipmentMatchedStocks = JSON.parse(JSON.stringify(value));

        // this.detectMatchedStocks();
    }

    get shipmentMatchedStocks_()
    {
        return this.shipmentMatchedStocks;
    }

    @track shipment;

    @track assigning;

    @track wiredVehicleShipmentDetail;

    @wire(init, {
        vehicleShipmentId : '$recordId'
    })
    ProcessVehicleShipmentDetail(result)
    {
        this.wiredVehicleShipmentDetail = result;
        if (result.data)
        {
            // console.log(result.data);
            this.shipmentLineItems_     = result.data.shipmentLineItems;
            this.shipmentMatchedStocks_ = result.data.shipmentMatchedStocks;
            this.shipment               = result.data.shipment;
            this.detectMatchedStocks();
        }
        else
        {
            console.error(result.error);
        }
    }

    // @wire(getRelatedListRecords, {
    //     parentRecordId : '$recordId',
    //     relatedListId : 'Shipment_Line_Items__r',
    //     fields :[
    //         'Shipment_Line_Item__c.Name',
    //         'Shipment_Line_Item__c.Model__c',
    //         'Shipment_Line_Item__c.Model_Year__c',
    //         'Shipment_Line_Item__c.Colour_Code__c',
    //         'Shipment_Line_Item__c.Trim__c',
    //         'Shipment_Line_Item__c.Engine_No__c',
    //         'Shipment_Line_Item__c.Chassis_No__c',
    //         'Shipment_Line_Item__c.Franchise_Code__c',
    //         'Shipment_Line_Item__c.Manufacturer_Ref_No__c',
    //         'Shipment_Line_Item__c.Production_Month__c',
    //     ]
    // })shipmentLineItem({ error, data })
    // {
    //     if (data && data.records)
    //     {
    //         this.shipmentLineItems_ = data.records;
            
    //     }
    //     else
    //     {
    //         // TODO: warning
    //         console.error('error', error);
            
    //     }
    // }

    // @wire(getRelatedListRecords, {
    //     parentRecordId : '$recordId',
    //     relatedListId : 'Stock_Vehicle_Masters__r',
    //     fields :[
    //         'Vehicle_Master2__c.Name',
    //         'Vehicle_Master2__c.Model_Code__c',
    //         'Vehicle_Master2__c.Model_Year_Code__c',
    //         'Vehicle_Master2__c.Color_Description__c',
    //         'Vehicle_Master2__c.Trim_Description__c',
    //         'Vehicle_Master2__c.Engine_No__c',
    //         'Vehicle_Master2__c.Chassis__c',
    //         'Vehicle_Master2__c.Franchise_Code__c',
    //         'Vehicle_Master2__c.Manufacturer_Ref_No__c',
    //         'Vehicle_Master2__c.ProductionMonth__c',
    //         'Vehicle_Master2__c.Shipment_Line_Item__c',
    //     ]
    // })shipmentMatchedStocks({ error, data })
    // {
    //     // console.log(JSON.stringify(data));
    //     if (data && data.records)
    //     {
    //         this.shipmentMatchedStocks_ = data.records;
    //     }
    //     else
    //     {
    //         // TODO: warning
    //         console.error('error', error);
    //     }
    // }

    /**
     * detect matched stock and link to shipment line items
     */
    detectMatchedStocks()
    {
        if (!this.shipmentLineItems || !this.shipmentMatchedStocks) return;

        for (let stock of this.shipmentMatchedStocks)
        {
            if (stock.Shipment_Line_Item__c)
            {
                this.shipmentLineItems.forEach(lineItem => {
                    if (lineItem.Id === stock.Shipment_Line_Item__c)
                    {
                        lineItem.matched_ = true;
                        lineItem.matchStockId_ = stock.Id;
                        lineItem.matchStockUrl_ = `//${window.location.host}/${stock.Id}`;
                        lineItem.matchStockName_ = stock.Name;
                    }
                })
            }
        }

        // console.log(this.shipmentLineItems);
    }

    startAssigning(e)
    {
        this.assigning = true;
        this.selectedLineItemId = e.currentTarget.dataset.id;

    }

    endAssigning(e)
    {
        this.assigning = false;
    }

    doAssigning(e)
    {
        
        this.dataLoaded = false;

        // call server to do the assigning
        matchingById({
            lineItemId : this.selectedLineItemId,
            stockVehicleMasterId : this.selectedStockVehicleMasterId
        })
        .then(result => {
            refreshApex(this.wiredVehicleShipmentDetail);
            this.endAssigning(e);
            // TODO: toast success
        })
        .catch(error => {
            console.error(error);
            // TODO: toast error
        })
        .finally(() => {
            this.dataLoaded = true;
        })
        
    }

    doAutoAssigning(e)
    {
        this.dataLoaded = false;

        // call server to do the assigning
        shipmentsAutoMatching({
            vehicleShipmentId : this.recordId
        })
        .then(result => {
            refreshApex(this.wiredVehicleShipmentDetail);
            // TODO: toast success
        })
        .catch(error => {
            console.error(error);
            // TODO: toast error
        })
        .finally(() => {
            this.dataLoaded = true;
        })
    }

    stockSelected(e)
    {
        console.log('Stock Selected', e.detail);
        if (e.detail && e.detail.length > 0)
        {
            this.selectedStockVehicleMasterId = e.detail[0].Id;
            this.disableAssignButton = false;
        }
    }
}