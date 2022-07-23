@isTest
private class ReferralProgramBatchJobTest {
    
    @testSetup static void setup() {
 		//Preparing test data
       Contact testContact = new Contact (LastName = 'TestContact1');
       insert testContact;
       
       Date dt = Date.today() - 5;
        
        
       Registered_Vehicle__c testRegVehicle = new Registered_Vehicle__c( 	Registered_Date__c = dt,
                                                                       	 	Name = 'TestCar',
                                                                       		Branch__c = 'CCA',
                                                                       		Franchise__c = 'MITCV',
                                                                        	Registration_Number__c = '1232',
                                                                       		Contact__c = testContact.id);
        
        insert testRegVehicle;
        system.debug('Inserted DATE' + testRegVehicle.Registered_Date__c);  
    }
    
    static testmethod void schedulerTest(){
       
        String CRON_EXP = '0 0 0 15 3 ? *';

        Test.startTest();

            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new ScheduleReferralProgram());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();

    }
    
    static testmethod void batchExecuteTest(){
       
        String CRON_EXP = '0 0 0 15 3 ? *';

        Test.startTest();
          BatchReferralProgram batchJob = new BatchReferralProgram();
          database.executebatch(batchJob);
        Test.stopTest();
        
        LIST<Registered_Vehicle__c> result = [SELECT Id, Registered_Date__c, Reg_plus_5days__c from Registered_Vehicle__c];
  		System.assertEquals(true, result[0].Reg_plus_5days__c);
    }

}