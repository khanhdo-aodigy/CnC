/**
 * @File Name          : RegisteredVehicleUOWHelper.cls
 * @Description        : 
 * @Author             : jmt@aodigy.com
 * @Group              : 
 * @Last Modified By   : jmt@aodigy.com
 * @Last Modified On   : 2/24/2020, 10:48:46 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/24/2020   jmt@aodigy.com     Initial Version
**/
public with sharing class RegisteredVehicleUOWHelper implements ADGLIB_SObjectUnitOfWork.IDoWork{

    public  Database.SaveResult[] Results {get; private set;}
    private List<Registered_Vehicle__c> m_records;

    public RegisteredVehicleUOWHelper() {
        m_records = new List<Registered_Vehicle__c>(); 
    }

    public void registerRegVehicle(Registered_Vehicle__c record)
    {
        m_records.add(record);
    }
    public void registerRegVehicle(LIST<Registered_Vehicle__c> records)
    {
        for (Registered_Vehicle__c record : records)
        {
            registerRegVehicle(record);
        }
    }

    public void doWork()
    {
        Results = Database.update(m_records, false);                
    }

    public void logServiceDataPool(){
       // Iterate through each returned result
       LIST<Logger_Data_Pool__c> errorList = new LIST<Logger_Data_Pool__c>();
        for (Database.SaveResult sr : Results) {
            if(!sr.isSuccess()){
                errorList.add(new Logger_Data_Pool__c(
                    Instance__c = 'UpdateRegisteredVehicle',
                    Cause__c = String.valueOf(sr.getErrors()),
                    Type__c = 'System.DmlException'
                ));
            }
        }

        if(!(errorList.isEmpty())){
            Database.insert(errorList, false);
        }
    }
}