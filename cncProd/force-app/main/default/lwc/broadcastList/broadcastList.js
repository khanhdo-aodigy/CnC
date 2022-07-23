/* eslint-disable no-console */
/* eslint-disable no-alert */
import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getVehicles from '@salesforce/apex/BroadcastController.getFilteredRegVehicles';
import { registerListener, unregisterAllListeners } from 'c/pubsub';

export default class EshopBroadcast extends NavigationMixin(LightningElement) 
{

    @track pageNumber = 1;
	@track pageSize;
    @track totalItemCount = 0;

	@track filters = {vehicleType: 'Registered_Vehicle__c'};
	@track vehicles = {};
	@track tableTitle = '';
	@track data = [];
	@track spinner = false;
	@wire(CurrentPageReference) pageRef;
    
	connectedCallback() 
	{
		registerListener( 'filterChange', this.handleFilterChange, this );
	}
	
	disconnectedCallback() 
	{
        unregisterAllListeners(this);
	}

	@wire( getVehicles, { filters: '$filters', pageNumber: '$pageNumber' })
    wiredVehicles({error, data}) 
	{
        if(data) 
		{			
			this.vehicles = data;
			this.tableTitle = this.vehicles.dataTableTitle;
			let currentData = [];
			if (data.records)
			{
				data.records.forEach(row => 
				{
					const rowData = {}
					let rowIndexes = Object.keys(row); 
					rowIndexes.forEach((rowIndex) => 
					{
						if (data.lstDataTableColumns.filter(e => e.fieldName.includes(rowIndex)).length > 0) 
						{
							const relatedFieldValue = row[rowIndex];
							if(relatedFieldValue.constructor === Object)
							{
								this._flattenTransformation(relatedFieldValue, rowData, rowIndex)        
							}
							else
							{
								rowData[rowIndex] = relatedFieldValue;
							}
						}                   
					});
	
					currentData.push(rowData);
				});
				console.log('Currentdata: ' + JSON.stringify(currentData));
				this.data = currentData;
			}
        }
        else if(error) 
		{
			// this.vehicles.error =  {...error};
            window.console.log(error);
		}

		this.spinner = false;
	}

	_flattenTransformation = (fieldValue, finalSobjectRow, fieldName) => 
    {        
        let rowIndexes = Object.keys(fieldValue);
        rowIndexes.forEach((key) => 
        {
            let finalKey = fieldName + '.'+ key;
			finalSobjectRow[finalKey] = fieldValue[key];
			if (finalSobjectRow[finalKey].constructor === Object)
			{
				this._flattenTransformation(finalSobjectRow[finalKey], finalSobjectRow, finalKey);        
			}
        })
    }
	
	handleRowActions(event) 
	{
		var row = event.detail.row;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.recordid,
                //objectApiName: 'optional',
                actionName: 'view'
            }
        });
	}


	handleFilterChange( filters ) 
	{
		this.spinner = true;
		
		this.filters = filters;
		this.filters = { ...this.filters, ...filters };

		this.pageNumber = 1;
		console.log('####DEBUG handleFilterChange :: filters = ' + JSON.stringify( filters ) );
		console.log('####DEBUG handleFilterChange :: this.filters = ' + JSON.stringify( this.filters ) );
		console.log('####DEBUG handleFilterChange :: spinner ------------------ ' + this.spinner );
	}

	handlePreviousPage() 
	{
        this.pageNumber = this.pageNumber - 1;
    }


    handleNextPage() 
	{
        this.pageNumber = this.pageNumber + 1;
	}
}