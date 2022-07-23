public class InvoiceEmail_RV_VIN {

    public String rv_id{get;set;}
    
    public String VIN_Val{
        get
        {
            List<Registered_Vehicle__c> RVList = [SELECT Chasis_Number__c FROM Registered_Vehicle__c WHERE Registration_Number__c=:rv_id];
            if(RVList <> null && RVList.size()>0)
            {
                VIN_Val = RVList[0].Chasis_Number__c;
            }
            else
            {
                VIN_Val = '';
            }
                
            return VIN_Val;
        }
        set;
    }   

    public void InvoiceEmail_RV_VIN() {}
    
}