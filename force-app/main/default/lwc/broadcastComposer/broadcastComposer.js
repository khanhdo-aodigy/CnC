import { LightningElement, track, wire } from 'lwc';
import createBroadcastAlert from '@salesforce/apex/BroadcastController.createBroadcastAlert';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import CUSTALERT_OBJECT from '@salesforce/schema/CustomerAlerts__c';
export default class BroadcastComposer extends LightningElement 
{
	@track disableBtn = true;
	@track alertName = '';
	@track alertMsg = '';
	@track selectedCampaignId = '';
	@track selectedSubType = '';
	@track deepLinkingURL = '';
	@track errorMsg;
	@track isError = false;
	
	@track _title = '';
	@track _message = '';
	@track _variant = '';
	@track _messageData = null;

    @wire(CurrentPageReference) pageRef;

    @track filters = {};
	
	@track broadcastRecordTypeId;
	@wire(getObjectInfo, { objectApiName: CUSTALERT_OBJECT })
    objectInfo({data,error})
	{
		if( data )
		{
			var recordtypeinfo = data.recordTypeInfos;
			for(var eachRecordtype in recordtypeinfo)
			{
				if(recordtypeinfo.hasOwnProperty(eachRecordtype))
				{
					if( recordtypeinfo[eachRecordtype].name == 'Broadcast' )
					{
						this.broadcastRecordTypeId = recordtypeinfo[eachRecordtype].recordTypeId;
					}
				}
			}
		}
		else if( error )
		{
			console.log('objectInfo error = ' + error );
		}
	}

	connectedCallback() 
	{
		registerListener( 'filterChange', this.handleFilterChange, this );
	}
	
	disconnectedCallback() 
	{
        unregisterAllListeners(this);
	}
	
	validateInput()
	{
		return ( this.alertMsg === undefined || this.alertMsg == '' || this.alertName == '');
	}

    createAlert()
	{

		if( this.validateInput() )
		{
			return;
		}

		if ( confirm('Are you confirm to proceed ?') )
		{
			console.log('####DEBUG createAlert :: filters = ' + JSON.stringify( this.filters ) );
			createBroadcastAlert({
				filters : this.filters,
				alertMessage : this.alertMsg,
				subType : this.selectedSubType,
				campaignRefId : this.selecselectedSubTypetedCampaignId,
				deepLinkingURL : this.deepLinkingURL,
				alertName : this.alertName
			}).then((result)=>
				{
					let resultObj = JSON.parse( result );
					this.selectedCampaignId = '';
					this.alertMsg = '';
					this.selectedSubType = '';
					this.alertName = '';
					this.deepLinkingURL = '';
					this.disableBtn = ( this.alertMsg ) ? false : true; 
					console.log('####DEBUG createAlert :: result = ' + result   );

					this._title = 'Total of ' + resultObj.totalitem + ' records have been processing ...';
					this._message = 'You will receive an email notifcation shortly once the data processing is completed. ';
					this._variant = 'success';
					this.showNotification();
				}).catch(error=>
				{
					this.isError = true;
					this.errorMsg = error.body.message;
					this.error = error;
					
					this._title = 'Customer Alerts Broadcast creation failure';
					this._message = this.errorMsg;
					this._variant = 'error';
					this.showNotification();
				})
		}	
	}
	
	handleCampaignChange( event )
	{
		this.selectedCampaignId = event.target.value;
		this.disableButton();
	}

	handleSubTypeChange( event )
	{
		this.selectedSubType = event.target.value;
		console.log('#### handleSubTypeChange --> selectedSubType = ' + this.selectedSubType );
		this.disableButton();
	}

	handleAlertNameChange( event ) 
	{
		this.alertName = event.target.value;
		this.disableButton();
	}

    handleAlertMsgChange( event ) 
	{
		this.alertMsg = event.target.value;
		this.disableButton();
	}

	handleDeepLinkingUrlChange( event ) 
	{
		this.deepLinkingURL = event.target.value;
		this.disableButton();
	}

	disableButton() 
	{
		this.disableBtn = ( this.alertMsg &&  this.selectedSubType && this.deepLinkingURL ) ? false : true; 
	}

    showNotification() 
	{
        const evt = new ShowToastEvent({
            title: this._title,
			message: this._message,
			messageData: this._messageData,
			variant: this._variant,
			mode: "sticky"
        });
        this.dispatchEvent(evt);
	}

	handleFilterChange( filters ) 
	{
		this.filters = filters;
		this.filters = { ...this.filters, ...filters };
		console.log('####DEBUG handleFilterChange :: this.filters = ' + this.filters + ' --- ' + JSON.stringify( this.filters ) );
	}
}