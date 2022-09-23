/*==========================================================================================================================================================================
 * Domain class for Attachment Entity
 * Created By: Aodigy Team
 * Create Date: Aug 2022
 * History
 *          DATE::                              BY::                                TICKET::                                            CHANGELOG
 *          16 Sep 2022                         dong.nguyen@aodigy.com              US-PR-000027                                       init
 * ========================================================================================================================================================================== 
 */
public with sharing class CreditDebitNotes extends ADGLIB_SObjectDomain{
    public CreditDebitNotes(List<Credit_Note__c> sObjectList) 
    {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable 
    {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) 
        {
			return new CreditDebitNotes(sObjectList);
		}
	}

    public override void onBeforeInsert()
    {
        List<Credit_Note__c> listCreditNotes = (List<Credit_Note__c>) Trigger.new;
        
        this.defaultValues(null, listCreditNotes);
        
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
    {
        Map<Id, Credit_Note__c> existingCreditNotes = (Map<Id, Credit_Note__c>) existingRecords;
        List<Credit_Note__c> updatingCreditNotes = Records;
		
        this.defaultValues(existingCreditNotes, updatingCreditNotes);
    }
 
    /**
    * Populate value GST Applicable & Update AR based on credit debit note type.
    */
    @testVisible
    private void defaultValues(Map<Id, Credit_Note__c> oldCreditNotes, List<Credit_Note__c> newCreditNotes)
    {
        Map<String,List<String>> dependentPicklistValuesMap = ADGLIB_UtilityHelper.getPicklistDependentMatrix(Credit_Note__c.GST_Applicable__c); 
        
        Map<String, List<String>> dependentPicklistValuesMap_1 = ADGLIB_UtilityHelper.getPicklistDependentMatrix(Credit_Note__c.Update_AR__c);
        
        for (Credit_Note__c creditNote : newCreditNotes)
        {
            String newCreditNoteType = creditNote.Credit_Debit_Note_Type__c;
            
            // check if oldCreditNotes is null (before insert), if yes set oldCreditNoteType to be null, else set to be old value of Credit_Debit_Note_Type__c field
            String oldCreditNoteType = oldCreditNotes != null ? oldCreditNotes.get(creditNote.Id).Credit_Debit_Note_Type__c : null;
            
            if (newCreditNoteType != oldCreditNoteType)
            {
                if (String.isNotBlank(newCreditNoteType))
                {
                    // populate value GST_Applicable__c
                    List<String> listGstApplicable =  dependentPicklistValuesMap.get(newCreditNoteType);
                    
                    if (listGstApplicable == null || listGstApplicable.size() == 0) 
                    {
                        return;
                    }
                    creditNote.GST_Applicable__c = listGstApplicable.get(0);

                    // populate value Update_AR__c
                    List<String> listUpdateAR = dependentPicklistValuesMap_1.get(newCreditNoteType);
                    if (listUpdateAR == null || listUpdateAR.size() == 0) 
                    {
                        return;
                    }
                    creditNote.Update_AR__c = listUpdateAR.get(0);
                }
                else
                {
                    creditNote.GST_Applicable__c = '';
                    creditNote.Update_AR__c = '';
                }
            }
        }
    }
}