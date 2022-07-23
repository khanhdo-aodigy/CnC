/** ******
 * Description: Trigger for Test_Drive__c custom object
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		        Description
 * 20151118            Billy Cheng              Created Initial Version. 
 * 20200221			   HS					    Added isBypassTriggerExecution to perform additional check based on mdt data setup to bypass Trigger execution
 * 20200310            HS                       Refactored the code; Remove SOQL inside Loop; Added PA Migration Changes 
 * 20200908            KD                       Added PA Migration - Phase 2 Changes. Removed Lead Reference
 * 20210706            KD                       Added bypass trigger via custom setting
 * 
** ******/
trigger smsAfterTestDrive on Test_Drive__c (before update,after update,after insert)
{
    //Trigger exclusion check
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
    if( TriggerExclusion.isTriggerExclude('TestDrive') 
        || TriggerExclusion.isTriggerExclude('Test_Drive__c') 
            || TriggerExclusion.isBypassTriggerExecution('Test_Drive__c') 
                || automationSetting.Bypass_Triggers__c
    ){
        return;
    }
    
    String contactName;
    String testDriveID;
    String modelID;
    String variantID;
    String branch_code;
    String BookingDate;
    String booking_time;
    Datetime dateValue;
    String showroomID;
    String subcriberKey;
    String emailAddress;
    String Contactid ;
    String hourMinutes ;
    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults(); 
    String  triggeredSendMessageId = (String)JCC_GlobalVar.TestDrive_Confirm_Email_MC_TriggerId__c;
    
    
    if (Trigger.isUpdate && Trigger.isBefore)
    {
        Set<Id> setTDOwnerIds = new Set<Id>();
        Set<Id> setTDCustomerIds = new Set<Id>();

        for(Test_Drive__c theTest : Trigger.new)
        {
            setTDOwnerIds.add( theTest.OwnerID );
            setTDCustomerIds.add( theTest.Prospect__c );
        }
       
        Map<Id,User> mapUser       = new Map<Id,User>( [SELECT Name, MobilePhone FROM User WHERE ID IN: setTDOwnerIds ]);
        Map<Id,Contact> mapContact = new Map<Id,Contact>( [SELECT Name, MobilePhone FROM Contact WHERE ID IN : setTDCustomerIds ]); 
        
        for(Test_Drive__c theTest : Trigger.new){
            
            if (theTest.Check_In__c!=null) {
                theTest.sms_date_trigger__c = theTest.Check_In__c.addMinutes(5);
            }
            
            Boolean oldValue = Trigger.oldMap.get(theTest.Id).send_Sms__c;
            String theText = '';

            if (theTest.Franchise_Code__c=='MITPC') {
                theText='Thank you for test driving the Mitsubishi with me. Feel free to contact me anytime if you have any queries. Regards, ';
            }
            if (theTest.Franchise_Code__c=='KIAPC') {
                theText='Thank you for test driving the KIA car earlier with me. I will be happy to answer any of your queries. Feel free to contact me anytime. Regards, ';
            }
            if (theTest.Franchise_Code__c=='CITPC') {
                theText='Thank you for test driving the Citroen car earlier with me. I will be happy to answer any of your queries. Feel free to contact me anytime. Regards, ';
            }
			if(theTest.Model_Group__c != null) {
				if(theTest.Model_Group__c.contains('DS'))
				{
					theText='Thank you for test driving the DS car earlier with me. I will be happy to answer any of your queries. Feel free to contact me anytime. Regards, ';
				}
            }

            if ( theTest.Send_SMS__c == true && oldValue == false && theTest.status__c == 'In' ){

                String theSRepName  = ( mapUser <> null && mapUser.containsKey( theTest.OwnerID ) ) ? mapUser.get( theTest.OwnerID ).Name : '';
                String theSRepPhone = ( mapUser <> null && mapUser.containsKey( theTest.OwnerID ) ) ? mapUser.get( theTest.OwnerID ).MobilePhone : '';
                
                if( theTest.Prospect__c != null )
                { 
                    Contact theContact = ( mapContact <> null && mapContact.containsKey( theTest.Prospect__c ) ) ? mapContact.get( theTest.Prospect__c ) : null;
                    if (!Test.isRunningTest() && theContact <> null ) {
                        sendSmsClass.sendSms2( theContact.MobilePhone, theText + theSRepName, theSRepPhone );
                    }
                }
            }
        }
    }


    if (Trigger.isUpdate && Trigger.isAfter)
    { 
        Post_Test_Drive_Feedback.hanldeAfterUpdate(trigger.new, trigger.oldmap);
        
        Set<Id> setTDOwnerIds = new Set<Id>();
        for(Test_Drive__c theTest : Trigger.new) 
        {
            setTDOwnerIds.add( theTest.OwnerID );
        }

        Map<Id,User> mapUser = new Map<Id,User>( [SELECT Id, Name, Username2__c FROM User WHERE ID IN: setTDOwnerIds ]);

        for(Test_Drive__c theTest : Trigger.new){
            User theSalesRep = ( mapUser <> null && mapUser.containsKey( theTest.OwnerID ) ) ? mapUser.get( theTest.OwnerID ) : null;

            if( theSalesRep <> null ) {
                if (!Test.isRunningTest()) {
                    
                    if( System.IsBatch() == true && System.isFuture() == false )
                    {
                        if( theTest.Prospect__c <> null ) {
                            VSMSHelperClass.pushData( theTest.Prospect__c, theSalesRep.Username2__c, theTest.NRIC__c); /** PA MIGRATION : To Remove */
                        }
                    }
                }
            }
        }
    }


    if (Trigger.isInsert && Trigger.isAfter)
    {
        Set<Id> setTDIds = new Set<Id>();
        Set<Id> setTDOwnerIds = new Set<Id>();

        for(Test_Drive__c theTest : Trigger.new)
        {   
            setTDIds.add( theTest.Id );
            setTDOwnerIds.add( theTest.OwnerID );
        }

        Map<Id,User> mapUser = new Map<Id,User>( [SELECT Id, Name, Username2__c, MobilePhone 
                                                  FROM User 
                                                  WHERE ID IN: setTDOwnerIds ]);

        Map<Id,Test_Drive__c> mapTestDrive = new Map<Id,Test_Drive__c>( [   SELECT Id, IsWalkin__c, TModel__c, TVariant__c, Booking_Time__c, Date__c, Showroom__c, Branch_Code__c, 
                                                                                Prospect__c, Prospect__r.Email, Prospect__r.FirstName, Prospect__r.LastName
                                                                            FROM Test_Drive__c 
                                                                            WHERE Id IN :setTDIds ] );

        for(Test_Drive__c theTest : Trigger.new)
        {
            User theSalesRep = ( mapUser <> null && mapUser.containsKey( theTest.OwnerID ) ) ? mapUser.get( theTest.OwnerID ) : null;
            Test_Drive__c thisTD = ( mapTestDrive <> null && mapTestDrive.containsKey( theTest.Id ) ) ? mapTestDrive.get( theTest.Id ) : null;

            if( thisTD <> null && theSalesRep <> null ){

                if ( !Test.isRunningTest() ) {
                    
                    if( System.IsBatch() == true && System.isFuture() == false )
                    {
                        VSMSHelperClass.pushData( theTest.Prospect__c, theSalesRep.Username2__c, theTest.NRIC__c); /** PA MIGRATION : To Remove */
                    }
                }
                
                try
                {
                    testDriveID  = thisTD.Id;
                    modelID      = thisTD.TModel__c ;
                    variantID    = thisTD.TVariant__c ; 
                    dateValue    = thisTD.Date__c ; 
                    booking_time = thisTD.Date__c.format('hh:mm a');  
                    showroomID   = thisTD.Showroom__c;
                    branch_code  = thisTD.Branch_Code__c;

                    if( thisTD.Prospect__c != null )
                    {
                        emailAddress = thisTD.Prospect__r.Email ;
                        
                        if( thisTD.Prospect__r.FirstName == null) {
                            contactName = thisTD.Prospect__r.LastName;
                        }
                        if( thisTD.Prospect__r.LastName == null) {
                            contactName = thisTD.Prospect__r.FirstName ;
                        }
                        if(thisTD.Prospect__r.FirstName != null  && thisTD.Prospect__r.LastName != null ) {
                            contactName = thisTD.Prospect__r.FirstName+' '+thisTD.Prospect__r.LastName;
                        }                 
                    }

                    if(thisTD!=null && !thisTD.IsWalkin__c){
                        TestDriveAckSendEmail.sendEmail( testDriveID, modelID, variantID, branch_code,
                                                         booking_time, dateValue, showroomID, emailAddress, triggeredSendMessageId, contactName );
                    }
                }
                catch(Exception e)
                {
                    loggerDataPool.buildLogDataPool('smsAfterTestDrive', e);
                } 
            }    
        }
    }

}