public without sharing class JITController {
    private static final List<String> SALES_ADMIN_PROFILES      = new List<String>{'KIAPC Sales Admin', 'CITPC Marketing', 'System Administrator'};
    private static final List<String> SALES_CONSULTANT_PROFILES = new List<String>{'KIAPC Sales', 'MITPC Sales', 'CITPC Sales'};

    @AuraEnabled(cacheable=true)
    public static JITWrapper constructWrapper(String objAPINm, String recordId)
    {
        JITWrapper wrapper = new JITWrapper();
        wrapper.curRecInfo = getRecords(objAPINm, 'Id', recordId, null)[0];

        if ((Date)wrapper.curRecInfo.get('JIT_Date__c') == null)
        {
            // throw new AuraHandledException('JIT Date is currently empty. Please check again!');
            AuraHandledException e = new AuraHandledException('JIT Date is currently empty. Please check again!');
            e.setMessage('JIT Date is currently empty. Please check again!');
            system.debug(e);
            throw e;
        }

        if (String.isNotBlank((Id)wrapper.curRecInfo.get('JIT_Day__c')))
        {
            wrapper.bookedJIT = new JITDaysSelector().selectById((Id)wrapper.curRecInfo.get('JIT_Day__c'));
        }

        wrapper.jitDaysList = new JITDaysSelector().selectByJITDate((Date)wrapper.curRecInfo.get('JIT_Date__c'));

        Profile authorizedProfile = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        wrapper.isSalesAdmin      = SALES_ADMIN_PROFILES.contains(authorizedProfile.Name);
        wrapper.isSalesConsultant = SALES_CONSULTANT_PROFILES.contains(authorizedProfile.Name);

        return wrapper;
    }

    /*
    ** 1. Increment JIT Day "Utilised Slots" field by 1.
    ** 2. Update "JIT Day" lookup field on Stock Vehicle Master (SVM) of SA to look up to the same JIT Day record as SA.
    */
    @AuraEnabled 
    public static void lookUpJITDayRecord(String sObjectName, Id recordId, Id JIT_recordId)
    {
        Savepoint sp = Database.setSavepoint();

        List<sObject> records = getRecords(sObjectName, 'Id', recordId, null);
        records[0].put('JIT_Day__c', JIT_recordId);

        system.debug(records[0]);

        JIT_Day__c jitDay = new JITDaysSelector().selectById(JIT_recordId);
        if(jitDay != null)
        {
            jitDay.Utilised_Slots__c += 1;
        }
        

        Vehicle_Master2__c svm;
        if (sObjectName == 'Sales_Agreement__c')
        {
            Sales_Agreement__c sa  = SalesAgreementService.getSalesAgrmnt(recordId);

            svm = (Vehicle_Master2__c)getRecords('Vehicle_Master2__c', 'Id', sa.Stock_Reservation__r.Vehicle_Master__r.Id, null)[0];
            svm.JIT_Day__c  = JIT_recordId;
            svm.JIT_Date__c = jitDay.JIT_Date__c;
        }

        try
        {
            update records;
            update jitDay;
            if (svm != null)
            {
                update svm;
            }
        }
        catch(Exception e)
        {
            Database.rollback(sp);

            throw e;
        }
    }

    @AuraEnabled
    public static void cancelSlot(String objAPINm, String recordId)
    {
        Savepoint sp = Database.setSavepoint();

        List<sObject> records = getRecords(objAPINm, 'Id', recordId, null);
        Id jitRecordId        = (Id)records[0].get('JIT_Day__c');
        records[0].put('JIT_Day__c', null);

        JIT_Day__c jitDay = new JITDaysSelector().selectById(jitRecordId);
        if (jitDay.Utilised_Slots__c < 0)
        {
            // throw new AuraHandledException('Oops! Something wrong with Utilised Slot. Please check again!');
            AuraHandledException e = new AuraHandledException('Oops! Something wrong with Utilised Slot. Please check again!');
            e.setMessage('Oops! Something wrong with Utilised Slot. Please check again!');
            system.debug(e);
            throw e;
        }

        jitDay.Utilised_Slots__c -= 1;

        Vehicle_Master2__c svm;
        if (objAPINm == 'Sales_Agreement__c')
        {
            Sales_Agreement__c sa  = SalesAgreementService.getSalesAgrmnt(recordId);

            if(sa.JIT_Status__c == 'Pending')
            {
                svm = (Vehicle_Master2__c)getRecords('Vehicle_Master2__c', 'Id', sa.Stock_Reservation__r.Vehicle_Master__r.Id, null)[0];
                svm.JIT_Day__c = null;                
                sendEmailToNCLUsers(sa.SOH_SONO__c, svm.Agreement_No__c, sa.Sales_Consultant__c, svm.Chassis__c, svm.Name);
            }
            else
            {
                // throw new AuraHandledException('JIT SLot can not be cancelled. Please check JIT Status!');
                AuraHandledException e = new AuraHandledException('JIT SLot can not be cancelled. Please check JIT Status!');
                e.setMessage('JIT SLot can not be cancelled. Please check JIT Status!');
                system.debug(e);
                throw e;

            }
        }

        try
        {
            update records;
            update jitDay;
            if (svm != null)
            {
                update svm;
            }
            
        }
        catch (Exception e)
        {
            Database.rollback(sp);

            throw e;
        }
    }
    
    @testVisible
    private static List<sObject> getRecords(String objectName, String conditionField, String conditionValue, String additionalCondition) 
    {
        String mainQueryCondition = conditionField + ' = ' + '\'' + conditionValue + '\'';

        if (additionalCondition != null && String.isNotBlank(additionalCondition)) 
        {
            mainQueryCondition += ' ' + additionalCondition;
        }

        List<SObject> result = ADGLIB_UtilityHelper.getSObjectRecords(objectName, mainQueryCondition, false); 

        return result;
    }

    @testVisible
    private static void sendEmailToNCLUsers(String saNo, String svmNo, String scName, String chassic, String svmName)
    {
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'New Car Logistic'];
        
        List<Id> profileIds = new List<Id>();
        for(Profile profile : profiles){
            profileIds.add(profile.Id);
        }

        List<User> newCarLogistics = [SELECT Id, Email FROM User WHERE ProfileId IN :profileIds];

        List<String> emailAddress = new List<String>();

        if(newCarLogistics.size()>0)
        {
            for(User NCLUser : newCarLogistics)
            {
                emailAddress.add(NCLUser.Email);
            }
        }
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        mail.setToAddresses(emailAddress);        
        mail.setSubject('JIT Slot has beeb cancelled');
        mail.setPlainTextBody('Dear User \nJIT Slot has beeb cancelled as below info: \n SA No.: ' + saNo +'\nSVM No.: ' + svmNo + '\nSC Name: ' + scName + '\nVehicle Chassic: ' + chassic + '\nSVM Name: ' + svmName);
        System.debug('Send to Email Address :' + mail.getToAddresses());
        mails.add(mail);        

        if (mails.size() > 0) 
        {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false);       
            
            for (Messaging.SendEmailResult rs : results) 
            {
                if (!rs.isSuccess()) 
                {
                    for(Messaging.SendEmailError err : rs.getErrors()) 
                    {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                    }
                }
                else
                {
                    System.debug('Successfull send email to NCL');  
                }
            }  
        }
    }

    public class JITWrapper {
        @AuraEnabled public sObject curRecInfo           { get; set; }
        @AuraEnabled public List<JIT_Day__c> jitDaysList { get; set; }
        @AuraEnabled public JIT_Day__c bookedJIT         { get; set; }
        @AuraEnabled public Boolean isSalesAdmin         { get; set; }
        @AuraEnabled public Boolean isSalesConsultant    { get; set; }
    }
}