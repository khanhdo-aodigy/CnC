import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import  getVPOLIDetail from '@salesforce/apex/VPO_VPOLIController.getVPOLIDetail'

export default class Vpo_getVPOLIDetails extends LightningElement 
{
    @track items;
    @api parentId;
    wiredRecords;

    cols = [
        {label:'Vehicle Purchase Order Line Items Name', fieldName:'Name' , type:'text'} ,
        {label:'Model Master', fieldName:'model_Master_Name_' , type:'text'} ,
        {label:'Colour Description', fieldName:'Colour_Description__c' , type:'text'},
        {label:'Trim Master', fieldName:'trim_Master_Description_' , type:'text'} ,
        {label:'Units Ordered', fieldName:'Units_Ordered__c' , type:'text'} ,
        {label:'Units Confirmed', fieldName:'Units_Confirmed__c' , type:'text'},
        {label:'FOB Price', fieldName:'Unit_Price__c' , type:'text'} ,
        {label:'Total Price', fieldName:'Total_Price__c' , type:'text'} ,
        {label:'Remarks', fieldName:'Remarks__c' , type:'text'}       
    ]

    get showTable()
    {
        return this.items?.length > 0;
    }
    
    @wire (getVPOLIDetail, {parentId: '$parentId'}) 
    wiredProps(result)
    {
        this.wiredRecords = result;
        if(result.data)
        {
            this.items = [];
            if(result.data.length > 0)
            {
                this.items = JSON.parse(JSON.stringify(result.data));
                this.items && this.items.forEach(element => 
                {
                    element.model_Master_Name_ = element.Model_Master__r.Name;
                    element.trim_Master_Description_ = element.Trim_Master__r.Trim_Description__c

                });
            }
        }
    }
    
    @api refreshTable()
    {
        refreshApex(this.wiredRecords);
    }
}