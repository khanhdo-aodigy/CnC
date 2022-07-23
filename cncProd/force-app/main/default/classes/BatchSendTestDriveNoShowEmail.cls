/** *******
 * Class Name: BatchSendTestDriveNoShowEmail
 * Description: Batch class to invoke Test Drive No Show Email
 *              Marketing Cloud Triggered send.
 *              Maximum Number of Callout is 100 per batch run.
 *              Batch Size must be set to a max of 1.
 *
 * Change History:
 * Date(YYYYMMDD)       Developer                   Description
 * 20190416             Christian Gaylan            Created Initial version
 * 20200831             khanh.do@aodigy.com         Added PA Migration - Phase 2 Changes
 * 
 ******* **/
public without sharing class BatchSendTestDriveNoShowEmail implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable{
    
    //execute Schedule
    public void execute (SchedulableContext ctx)
    {   
        //Set Initial Test Run
        //Batch Size set to 1 to control callouts execution
        //Error "You have uncommitted work pending. Please commit or rollback before calling out"
        try{
            BatchManager bm = new BatchManager('BatchSendTestDriveNoShowEmail',null);
        }
        catch(Exception e){
            loggerDataPool.buildLogDataPool('BatchSendTestDriveNoShowEmail', e);
        }
    }    


    //Query Test Drives which are still Pending but the Booking date has lapsed (scheduled for yesterday)
    public Database.QueryLocator start(Database.BatchableContext db)
    {
        return Database.getQueryLocator( [SELECT Id, 
                                            Prospect__c,                           
                                            //Lead__r.Name,                          
                                            //Lead__r.Email,   
                                            //Lead__c,                        
                                            Prospect__r.Name,                      
                                            Prospect__r.Email,  
                                            Branch_Code__c,                        
                                            Model__r.Name, 
                                            Opportunity__c,
                                            Opportunity__r.Owner.Name,
                                            Opportunity__r.Owner.MobilePhone
                                            //Account__c,                     
                                            //Account__r.Name,                
                                            //Account__r.PersonEmail,         
                                            //Account__r.RecordTypeId         
                                            FROM Test_Drive__c 
                                            WHERE Date__c >= YESTERDAY
                                            AND Date__c < TODAY 
                                            AND Model__c != null    
                                            AND Status__c = 'Pending']);
    }
    

    public void execute(Database.BatchableContext db, List<Test_Drive__c> scope)
    {
        if(scope != null && !scope.isEmpty())
        {
            try{
                for(Test_Drive__c tdrive : scope){
                    String emailAddr = '';
                    String contactName = '';
                    String contactId = '';
                    //String leadId =  ''; 

                    /** PA MIGRATION : Newly Added Part-1 Start 
                    if( tdrive.Account__c != null ){
                        emailAddr   = tdrive.Account__r.PersonEmail;
                        contactName = tdrive.Account__r.Name;
                        
                        if( AccountUtil.isCustomer( tdrive.Account__r.RecordTypeId, null ) ) {
                            contactId = tdrive.Account__c;
                        }
                        else if( AccountUtil.isProspect( tdrive.Account__r.RecordTypeId , null ) ) {
                            leadId = tdrive.Account__c;
                        }                        
                    }
                    /** PA MIGRATION : Newly Added Part-1 End */

                    if(tdrive.Prospect__c != null){
                        contactId   = tdrive.Prospect__c;
                        emailAddr   = tdrive.Prospect__r.Email;
                        contactName = tdrive.Prospect__r.Name; 
                    }
                    // else if(tdrive.Lead__c != null){
                    //     leadId =  tdrive.Lead__c;
                    //     emailAddr =  tdrive.Lead__r.Email;
                    //     contactName = tdrive.Lead__r.Name; 
                    // } 
                    /** PA MIGRATION : To Remove Part-1 End */
                    
                   send_NoShowTriggeredEmail.sendNoShowEmailOverride( emailAddr, 
                                                                      tdrive.Branch_Code__c, 
                                                                      tdrive.Model__r.Name, 
                                                                      tdrive.Opportunity__r.Owner.Name,
                                                                      tdrive.Opportunity__r.Owner.MobilePhone,
                                                                      contactId,
                                                                      //leadId,
                                                                      contactName );
                     
                }
            }
            catch(Exception e){
                loggerDataPool.buildLogDataPool('BatchSendTestDriveNoShowEmail', e);
            }

        }     
    }
    
    public void finish(Database.BatchableContext db){
        batchDataPool.buildBatchDataPool('BatchSendTestDriveNoShowEmail', db.getJobId());
    }
}