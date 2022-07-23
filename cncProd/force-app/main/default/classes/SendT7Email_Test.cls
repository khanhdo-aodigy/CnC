@isTest
private class SendT7Email_Test {

    @isTest
    public static void SendT7EmailTest(){
    
        Test.startTest();
        
       	/*Contact ct1 = new Contact();
        ct1.FirstName = 'xyzFirst';
        ct1.LastName = 'XyZLast';
        ct1.Email = 'xyzmail@mail.com';
        ct1.NRIC_Passport_No__c='12345678';
        ct1.MobilePhone='81111111';
      
        insert ct1;*/
        
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name = 'Change Request (Ownership, Particulars, Vehicle Registration Number)'].Id;
        Case c11 = New Case(Status='Pending for Documents', Origin='Email', SuppliedEmail ='xyzmail@mail.com', Email_Sent_Date__c =  Date.today().addDays(-7),
                            Case_Category__c='Change of Particulars', /*contactid = ct1.id,*/
                            Franchise__c='MBP',  recordtypeid=strRecordTypeId);
         
        insert c11;
        
        
        Case c111 = New Case(Status='Pending for Documents', Origin='Email', SuppliedEmail ='xyzmail@mail.com', Email_Sent_Date__c= Date.today().addDays(-7),
                            Case_Category__c='Change of Ownership', /*contactid = ct1.id,*/
                            Franchise__c='MBP',  recordtypeid=strRecordTypeId);
         
        insert c111;
            
        Case c1111 = New Case(Status='Pending for Documents', Origin='Email', SuppliedEmail ='xyzmail@mail.com', Email_Sent_Date__c=Date.today().addDays(-7),
                            Case_Category__c='Change of Vehicle Registration Number', /*contactid = ct1.id,*/
                            Franchise__c='MBP',  recordtypeid=strRecordTypeId);
         
        insert c1111;
        
        Case c12 = New Case(Status='Pending for Documents', Origin='Email', SuppliedEmail ='xyzmail@mail.com', Email_Sent_Date__c= Date.today().addDays(-7),
                            Case_Category__c='Change of Particulars', /*contactid = ct1.id,*/
                            Franchise__c='CIT',  recordtypeid=strRecordTypeId);
         
        insert c12;
        
        
        Case c122 = New Case(Status='Pending for Documents', Origin='Email', SuppliedEmail ='xyzmail@mail.com', Email_Sent_Date__c= Date.today().addDays(-7),
                            Case_Category__c='Change of Ownership', /*contactid = ct1.id,*/
                            Franchise__c='CIT',  recordtypeid=strRecordTypeId);
         
        insert c122;
            
        Case c1222 = New Case(Status='Pending for Documents', Origin='Email', SuppliedEmail ='xyzmail@mail.com', Email_Sent_Date__c=Date.today().addDays(-7),
                            Case_Category__c='Change of Vehicle Registration Number', /*contactid = ct1.id,*/
                            Franchise__c='CIT',  recordtypeid=strRecordTypeId);
         
        insert c1222;
        
        SendT7Email sh1 = new SendT7Email();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
    }
}