public with sharing class SAAdditionalChargesUpsertUOW implements ADGLIB_SObjectUnitOfWork.IDoWork {

    public Database.UpsertResult[] Results {get; private set;}
    private List<SA_Additional_Charge__c> m_records;

    public SAAdditionalChargesUpsertUOW() {
        m_records = new List<SA_Additional_Charge__c>();
    }

    public void registerSAAdditionalCharge(SA_Additional_Charge__c record)
    {
        m_records.add(record);
    }
    public void registerSAAdditionalCharge(LIST<SA_Additional_Charge__c> records)
    {
        for (SA_Additional_Charge__c record : records)
        {
            registerSAAdditionalCharge(record);
        }
    } 
    public void doWork()
    {
        Results = Database.upsert(m_records, false);                
    }

}