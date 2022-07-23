/** *****
 * Description : Trigger Handler for Transaction Object
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200623            HS@aodigy            Created Initial Version 
 * 
** *****/
public class Transactions extends ADGLIB_SObjectDomain{
    
    public Transactions(List<Transaction__c> sObjectList)
    {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable 
    {
        public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new Transactions(sObjectList);
		}
    }

    public override void onBeforeInsert()
    {
        TransactionService.linkACTrxnToRegVehAndContact( (List<Transaction__c>)Records );
    }
    
    public override void onAfterInsert() 
    {     
        TransactionService.processTransactionToReward( (List<Transaction__c>)Records );
    }

    public override void onBeforeUpdate(Map<Id,SObject> existingRecords)
    {
        // List<Transaction__c> lstUpdatedTrxns = getChangedRecords( new Set<String>{'Registered_Vehicle__c','Contact__c','Brand__c','Branch__c','Source__c','Type__c'} );
        // TransactionService.processTransactionCheck( lstUpdatedTrxns );
        TransactionService.linkACTrxnToRegVehAndContact( (List<Transaction__c>)Records );
    }


    public override void onAfterUpdate(Map<Id,SObject> existingRecords)
    {    
        // List<Transaction__c> lstUpdatedTrxns = getChangedRecords( new Set<String>{'Registered_Vehicle__c','Contact__c','Brand__c','Branch__c','Source__c','Type__c','Is_Error__c'} );
        List<Transaction__c> lstUpdatedTrxns = getChangedRecords( new Set<String>{'SRC__c','FRAN__c','REGN__c','CHASSIS__c','NRIC__c','DOCNUMBER__c','COST__c','NLCODE__c'} );
        TransactionService.processTransactionToReward( lstUpdatedTrxns );
    }
}