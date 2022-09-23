/*==========================================================================================================================================================================
 * creditDebitNotesTest for creditDiebitNotes
 * Created By: Aodigy Team
 * Create Date: Aug 2022
 * History
 *          DATE::                              BY::                                TICKET::                                            CHANGELOG
 *          21 Sep 2022                         dong.nguyen@aodigy.com              US-PR-000027                                       init
 * ========================================================================================================================================================================== 
 */
@isTest
public with sharing class CreditDebitNotesTest { 
    @TestSetup
    static void makeData(){
         //create credit note
         Credit_Note__c credit = new Credit_Note__c(
            Credit_Debit__c = 'Credit',
            Credit_Debit_Note_Type__c = 'OTHER PAYMENT WITH GST',
            GST_Applicable__c = 'Yes',
            Update_AR__c = 'Yes'
        );
        insert credit;
    }
    @isTest
    public static void creditDebitNoteType_success() {

        Credit_Note__c create = [SELECT Id, Credit_Debit_Note_Type__c FROM Credit_Note__c];
        create.Credit_Debit_Note_Type__c = 'FULLY FORFEIT DEPOSIT (NOT UPDATE AR)';
        create.Update_AR__c = 'Yes';
        create.GST_Applicable__c = 'No';

        update create;
        System.assertNotEquals(null, create.Credit_Debit_Note_Type__c);
    }

    @isTest
    public static void creditDebitNoteType_null(){
        
        Credit_Note__c create = [SELECT Id, Credit_Debit_Note_Type__c FROM Credit_Note__c];
        create.Credit_Debit_Note_Type__c = null;

        update create;
        System.assertNotEquals('FULLY FORFEIT DEPOSIT (NOT UPDATE AR)', create.Credit_Debit_Note_Type__c);
    }

}