import { LightningElement, track, api, wire } from 'lwc';
import init from '@salesforce/apex/VPO_LineItemsHistoryDashboardController.init';

const actions = [
    { label: 'Show details', name: 'show_details' },
    { label: 'Compare', name: 'compare' },
];

export default class Vpo_LineItemsHistoryDashboard extends LightningElement
{
    @api recordId;

    @track lineItems = [];

    @track snapshotLineItems = [];

    @track histories = {};

    @track history = [];

    @track compare = [];

    @track displayHistoryTracking;

    @track displaySnapshotCompare;

    @track ready;

    @wire(init, {recordId : '$recordId'})
    initHandler({error, data})
    {
        if (data)
        {
            console.log('data', data);
            
            this.processLineItems(data.order.Vehicle_Purchase_Order_Line_Items__r);

            if (data.snapshot)
            {
                this.processSnapshotLineItems(data.snapshot?.Vehicle_Purchase_Order_Line_Items__r);
                this.getLineItemStatus();
            }
            else
            {
                console.error(error);
                // TODO: handle when no snapshot found
            }

            this.processHistory(data.historiesByLineItemId);
            
            this.ready = true;

            // this.processCompare(data.compareWithSnapshotVersion);


        }
        else if (error)
        {
            console.error(error);
        }
    }

    processLineItems(lineItems)
    {
        this.lineItems = JSON.parse(JSON.stringify(lineItems));;
    }

    processSnapshotLineItems(lineItems)
    {
        this.snapshotLineItems = JSON.parse(JSON.stringify(lineItems));
    }

    /**
     * compare the snapshot version vs current line items and put into Status_ field so that the lightning data table can use
     */
    getLineItemStatus()
    {
        // set default status NO CHANGE
        for (let lineItem of this.lineItems)
        {
            lineItem.Status_ = 'NO CHANGE';
        }

        // get Id of current line items and snapshot line items
        let lineItemIds = [];
        let snapshotLineItemIds = [];

        this.lineItems.forEach(lineItem => lineItemIds.push(lineItem.Id));
        this.snapshotLineItems.forEach(snapshotLineItem => snapshotLineItemIds.push(snapshotLineItem.Id));

        // get added line item
        for (let lineItem of this.lineItems)
        {
            if (!snapshotLineItemIds.includes(lineItem.Id))
            {
                lineItem.Status_ = 'ADDED';
            }
        }

        // get deleted line item
        for (let snapshotLineItem of this.snapshotLineItems)
        {
            if (!lineItemIds.includes(snapshotLineItem.Id))
            {
                snapshotLineItem.Status_ = 'DELETED';
                this.lineItems.push(snapshotLineItem);
            }
        }

        // get modified line item
        for (let lineItem of this.lineItems)
        {
            if (snapshotLineItemIds.includes(lineItem.Id))
            {
                let snapshotLineItem = this.snapshotLineItems.filter(snapshotLineItem => snapshotLineItem.Id == lineItem.Id)[0];

                for (let field in lineItem)
                {
                    if (field.endsWith('_')) continue;

                    if (lineItem[field] !== snapshotLineItem[field])
                    {
                        lineItem.Status_ = 'MODIFIED';
                        break;
                    }
                }
            }
        }
    }

    processHistory(history)
    {
        this.histories = JSON.parse(JSON.stringify(history));

        // bring the owner name onto outer object so that lighting data table can use it
        for (let lineItem of this.lineItems)
        {
            let historiesByLineItem = this.histories[lineItem.Id];

            if (!historiesByLineItem) continue;

            for (let history of historiesByLineItem)
            {
                history.CreatedBy_ = history.CreatedBy.Name;
            }
        }
    }
    // processCompare(compare){
        //put id of row
    // }

    handleRowAction(event)
    {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        switch (actionName)
        {
            case 'show_details':
                this.showHistoryOfSelectedLineItem(row);
                break;
            case 'compare':
                this.compareWithSnapshotVersion(row);
                break;
            default:
        }
    }

    showHistoryOfSelectedLineItem(row)
    {
        this.history = this.histories[row.Id];

        this.displayHistoryTracking = !!this.history;

        // console.log('history', this.history);
        // console.log('displayHistoryTracking', this.displayHistoryTracking);
    }

    compareWithSnapshotVersion(row)
    {
        // TODO: check if selected line item have snapshot version
        console.log("recordid",recordId);
        
        // TODO: if have snapshot version, show a table with left column is snapshot version and right column is current version
        this.displaySnapshotCompare = true;

        // TODO: if have no snapshot version, show a warning to user that this line item have no snapshot version
        
    }

    lineItemColumns = [
        { label: 'Status', fieldName: 'Status_' , cellAttributes:{class:{fieldName:'Status_CSSClass'}}},{Status_ : 'ADDED', Status_CSSClass : 'status-col'},
        
        { label: 'Name', fieldName: 'Name' },
        // { label: 'Model Master', fieldName: 'Model_Master__c', type: 'url' },
        // { label: 'Trim Master', fieldName: 'Trim_Master__c', type: 'url' },
        // { label: 'Color Master', fieldName: 'Color_Master__c', type: 'url' },
        { label: 'Units Ordered', fieldName: 'Units_Ordered__c', type: 'number' },
        { label: 'Units Confirmed', fieldName: 'Units_Confirmed__c', type: 'number' },
        { type: 'action', typeAttributes: { rowActions: actions } }
    ];

    historyColumns = [
        { label: 'Field', fieldName: 'Field', type: 'text' },
        { label: 'Changed By', fieldName: 'CreatedBy_', type: 'text' },
        { label: 'Changed Date', fieldName: 'CreatedDate', type: 'text' },
        { label: 'Old Value', fieldName: 'OldValue', type: 'text' },
        { label: 'New Value', fieldName: 'NewValue', type: 'text' },
    ];
    compareColumns = [
        { label: 'Field', fieldName: 'Field', type: 'text' },
        { label: 'Snapshot Value', fieldName: 'SnapshotValue', type: 'text' },
        { label: 'Current Value', fieldName: 'CurrentValue', type: 'text' },        
    ];
    
}