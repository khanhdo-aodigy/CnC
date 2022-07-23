/** ******
* Description: 
* Change History:
* Date(YYYYMMDD)       Name                Description
* 20210714             Thang               Created Initial Version. 
** ******/
public class DeliveryBayBookings extends ADGLIB_SObjectDomain {
    
    public DeliveryBayBookings(List<Delivery_Bay_Booking__c> sObjectList) {
        super(sObjectList);
    }
    
    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
        public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
            return new DeliveryBayBookings(sObjectList);
        }
    }
    
    
    public override void onAfterInsert() {
        validateDBB();
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        validateDBB();
        sendingEmailAfterBooking(existingRecords);
        sendingEmailAfterCancelBooking(existingRecords);
    }
    
    private void validateDBB(){
        Set<Id> salesAgreements = new Set<Id>();
        Set<Id> mbSalesAgreements = new Set<Id>();
        Set<Id> salesAgreementsCheck = new Set<Id>();
        Set<Id> mbSalesAgreementsCheck = new Set<Id>();
        for(Delivery_Bay_Booking__c dbb : (List<Delivery_Bay_Booking__c>)Records) { 
            salesAgreements.add(dbb.Sales_Agreement__c);
            mbSalesAgreements.add(dbb.MB_Sales_Agreement__c);
            
        }
        List<Delivery_Bay_Booking__c > dbbs = [Select Id, Status__c, Sales_Agreement__c, MB_Sales_Agreement__c from Delivery_Bay_Booking__c where (Sales_Agreement__c IN: salesAgreements OR MB_Sales_Agreement__c IN: mbSalesAgreements) And Status__c ='Booked'];
        
        for(Delivery_Bay_Booking__c dbb: dbbs){
            if(!salesAgreementsCheck.contains(dbb.Sales_Agreement__c) || !salesAgreementsCheck.contains(dbb.MB_Sales_Agreement__c)){
                salesAgreementsCheck.add(dbb.Sales_Agreement__c);
                salesAgreementsCheck.add(dbb.MB_Sales_Agreement__c);
            }else{
                dbb.addError('Delivery bay have been booked, Please check!');
            } 
        }
    }
    
    public static void setExpriedForDBB(List<Delivery_Bay_Booking__c > dbbs){
        for(Delivery_Bay_Booking__c dbb: dbbs){
            dbb.Status__c = 'Expired'; 
        }
        update dbbs;
    }
    
    public static void sendingEmailForBookingNewSlot(Set<Id> salesAgreements, Set<Id> mbSalesAgreements){
        
        OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName 
                                   FROM OrgWideEmailAddress 
                                   WHERE Address = 'do-not-reply@ccc.cyclecarriage.com.sg' 
                                   LIMIT 1];
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        Map<String,String> mapNameByEmail = new Map<String, String>();
        if(salesAgreements != NULL){
            List<Sales_Agreement__c> salesAgreementList = new List<Sales_Agreement__c>([SELECT id, Name, Owner.Email FROM Sales_Agreement__c where Id IN: salesAgreements]);
            for(Sales_Agreement__c sa: salesAgreementList){
                mapNameByEmail.put(sa.Name, sa.Owner.Email);
            }
        }else if(mbSalesAgreements != NULL){
            List<MB_Sales_Agreement__c> mbSalesAgreementList = new List<MB_Sales_Agreement__c>([SELECT id, Name, Owner.Email FROM MB_Sales_Agreement__c where Id IN: mbSalesAgreements]);
            for(MB_Sales_Agreement__c mb: mbSalesAgreementList){
                mapNameByEmail.put(mb.Name, mb.Owner.Email);
            }
        }
        
        if(Test.isRunningTest()){
            mapNameByEmail.put('sa.Name', 'test@gmail.com');
        }
        Delivery_Bay_Configuration__c dbbCf = Delivery_Bay_Configuration__c.getValues('Delivery Bay Booking Config');
        //get Email Template Ready For Delivery from Custom Setting
        String emailTemplateReadyForDelivery = '';
        if(dbbCf != Null){
            emailTemplateReadyForDelivery = dbbCf.Email_Template_Ready_for_Delivery__c;
        }
        
        if(String.isNotBlank(emailTemplateReadyForDelivery)){
            EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate  WHERE Name = :emailTemplateReadyForDelivery LIMIT 1];
            String eSub, eBody ;
            if(!mapNameByEmail.isEmpty() && template != NULL){
                for(String name : mapNameByEmail.keySet()){
                    Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id, null, null);
                    mail.setOrgWideEmailAddressId(owa.Id);
                    mail.setSubject(mail.getSubject().replace('{{NAME}}', name));
                    mail.setHtmlBody(mail.getHtmlBody().replace('{{NAME}}', name));
                    String customerEmail = Test.isRunningTest() ? 'test@gmail.com' :mapNameByEmail.get(name); 
                    mail.setToAddresses(new List<String>{customerEmail});
                    mails.add(mail);
                }
            }
            
            if (mails.size() > 0){
                try {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false);
                } catch (EmailException e) {
                    loggerDataPool.buildLogDataPool('DeliveryBayBookings.sendingEmailForBookingNewSlot', e);
                }
            }
        }
    }
    
    public void sendingEmailAfterBooking(Map<Id, SObject> existingRecords){
        Set<Delivery_Bay_Booking__c> dbbs = new Set<Delivery_Bay_Booking__c>();
        for(Delivery_Bay_Booking__c dbb : (List<Delivery_Bay_Booking__c>)Records) {
            Delivery_Bay_Booking__c oldDBB = (Delivery_Bay_Booking__c)existingRecords.get(dbb.Id);
            if(dbb.Status__c  != oldDBB.Status__c  && dbb.Status__c  == 'Booked'){  
                dbbs.add(dbb);
            }
        }
        
        OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName 
                                   FROM OrgWideEmailAddress 
                                   WHERE Address = 'do-not-reply@ccc.cyclecarriage.com.sg' 
                                   LIMIT 1];
        Delivery_Bay_Configuration__c dbbCf = Delivery_Bay_Configuration__c.getValues('Delivery Bay Booking Config');
        //get Email Template Delivery Bay Booking from Custom Setting
        String emailTemplateBooked = '';
        if(dbbCf != Null){
            emailTemplateBooked = dbbCf.Email_Template_Delivery_Bay_Booking__c;
        }
        if(String.isNotBlank(emailTemplateBooked)){
            EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate  WHERE Name = :emailTemplateBooked LIMIT 1];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<Delivery_Bay_In_Charge__c> dbbInCharges = [SELECT id, Franchise_Code__c, Email__c   FROM Delivery_Bay_In_Charge__c WHERE  Active__c  = TRUE];
            for(Delivery_Bay_Booking__c dbb :  dbbs){
                List<String> toAddressesList = getRecipients(dbbInCharges, dbb.FranchiseCode__c);
                if(!toAddressesList.isEmpty() && template != NULL){
                    Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id, null, dbb.Id);
                    mail.setOrgWideEmailAddressId(owa.Id);
                    mail.setToAddresses(toAddressesList);
                    mails.add(mail);
                }
            }
            if (mails.size() > 0){
                try {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false);
                } catch (EmailException e) {
                    loggerDataPool.buildLogDataPool('DeliveryBayBookings.sendingEmailAfterBooking', e);
                }
                
            }
        }
        
    }
    
    public void sendingEmailAfterCancelBooking(Map<Id, SObject> existingRecords){
        Set<Delivery_Bay_Booking__c> dbbs = new Set<Delivery_Bay_Booking__c>();
        for(Delivery_Bay_Booking__c dbb : (List<Delivery_Bay_Booking__c>)Records) {
            Delivery_Bay_Booking__c oldDBB = (Delivery_Bay_Booking__c)existingRecords.get(dbb.Id);
            if(dbb.Status__c  != oldDBB.Status__c  && dbb.Status__c  == 'Cancelled'){  
                dbbs.add(dbb);
            }
        }
        
        OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName 
                                   FROM OrgWideEmailAddress 
                                   WHERE Address = 'do-not-reply@ccc.cyclecarriage.com.sg' 
                                   LIMIT 1];
        
        Delivery_Bay_Configuration__c dbbCf = Delivery_Bay_Configuration__c.getValues('Delivery Bay Booking Config');
        //get Email Template Cancel Delivery from Custom Setting
        String emailTemplateCancel = '';
        if(dbbCf != Null){
            emailTemplateCancel = dbbCf.Email_Template_Cancel_Delivery__c;
        }
        if(String.isNotBlank(emailTemplateCancel)){
            EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = :emailTemplateCancel LIMIT 1];
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<Delivery_Bay_In_Charge__c> dbbInCharges = [SELECT id, Franchise_Code__c, Email__c   FROM Delivery_Bay_In_Charge__c WHERE  Active__c  = TRUE];
            
            for(Delivery_Bay_Booking__c dbb :  dbbs){
                List<String> toAddressesList = getRecipients(dbbInCharges, dbb.FranchiseCode__c);
                if(!toAddressesList.isEmpty() && template != NULL){
                    Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id, null, dbb.Id);
                    mail.setOrgWideEmailAddressId(owa.Id);
                    mail.setToAddresses(toAddressesList);
                    mails.add(mail);
                }
            }
            if (mails.size() > 0){
                try {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false);
                } catch (EmailException e) {
                    loggerDataPool.buildLogDataPool('DeliveryBayBookings.sendingEmailAfterCancelBooking', e);
                }
                
            }
        }
        
    }
    private List<String> getRecipients(List<Delivery_Bay_In_Charge__c> dbbInCharges, String franchiseCode){
        List<String> recipients = new List<String>();
        for(Delivery_Bay_In_Charge__c dbbInCharge : dbbInCharges){
            if(dbbInCharge.Franchise_Code__c.contains(franchiseCode)){
                recipients.add(dbbInCharge.Email__c);
            }
        }
        return recipients;
    }
    
    
}