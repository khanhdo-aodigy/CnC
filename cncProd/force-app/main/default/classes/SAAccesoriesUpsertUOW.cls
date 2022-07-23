public class SAAccesoriesUpsertUOW implements ADGLIB_SObjectUnitOfWork.IDoWork
{       
    public Database.UpsertResult[] Results {get; private set;}
     
    private List<SA_Accessory__c> m_records;
     
    public SAAccesoriesUpsertUOW()
    {  
        m_records = new List<SA_Accessory__c>();
    }
     
    public void registerSAAccessories(SA_Accessory__c record)
    {
        m_records.add(record);
    }
    public void registerSAAccessories(LIST<SA_Accessory__c> records)
    {
        for (SA_Accessory__c record : records)
        {
            registerSAAccessories(record);
        }
    } 
    public void doWork()
    {
        Results = Database.upsert(m_records, false);                
    }
}