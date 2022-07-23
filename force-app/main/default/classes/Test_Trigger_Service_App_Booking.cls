@isTest(seeAllData=true)
public class Test_Trigger_Service_App_Booking
{
    static testMethod void testInsertTrigger()
    {
        Test.startTest();
        Date today = date.today();
        Service_Appointment__c sa = new Service_Appointment__c(Name='Production Deployment',Action__c='Create',Booking_ID__c='ProdDeployment1',Car_Registration_No__c='KA101',Contact__c='0030K00001atCxY',Registered_Vehicle__c='a0s0K000005fyV5',Service_Appointment_Date_Time__c= today,Service_Centre_Location__c='Delhi');
        insert sa;
        List<Service_Appointment__c> saq = [Select Contact__r.Email,Registered_Vehicle__r.Branch__c,Registered_Vehicle__r.Variant__r.Name,Contact__r.MobilePhone,Contact__r.Device__c,Non_Owner_Email__c,Non_Owner_Name__c,Non_Owner_Phone_Number__c,Is_Non_Owner__c from Service_Appointment__c where Name =: 'Production Deployment'];  
        system.assert(saq.size()>0, true);
        Test.stopTest();
    }
    
   
}