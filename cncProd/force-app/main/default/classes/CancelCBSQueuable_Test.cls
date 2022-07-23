@IsTest
public class CancelCBSQueuable_Test {

    static testmethod void test4CancelUpd()    
	{
        List<Case> CasesForCBS = New List<Case>();
        Case c = New Case();
    	c.subject ='case 1';
        c.Case_Category__c = 'Booking List';
    	c.SMS_Status__c='Cancel Appointment';
    	c.Status='Open';
    	insert c;
        CasesForCBS.add(c);
     
        Case c1 = New Case();
    	c1.subject ='case 11';
        c1.Case_Category__c = 'Booking List';
    	c1.SMS_Status__c='Confirm Appointment';
    	c1.Status='Open';
    	insert c1;
        CasesForCBS.add(c1);
     
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new externalMock());
        
            ID jobId = System.enqueueJob(New CancelCBSQueuable(CasesForCBS));
        Test.stopTest();
    }
    

    @isTest
    static void testBookingCancellation2()
    {
        Case cs = New Case();
    	cs.subject           = 'Dummy Test';
        cs.Case_Category__c  = 'Booking List';
    	cs.SMS_Status__c     = 'Cancel Appointment';
        cs.Status            = 'Open';
        cs.RecordTypeId      = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Servicing_and_Grooming' ).getRecordTypeId(); 
    	insert cs;

        System.Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CBSFailureMock());
            System.enqueueJob(new CancelCBSQueuable( new List<Case>{ cs }));
        System.Test.stopTest();
        System.assert( ([SELECT Id, Status FROM Case WHERE ID = :cs.Id AND Status = 'Closed']).size() == 1 );
    }


    public class CBSFailureMock implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String body = '{"data":{},"error":{"code":540,"message":"The booking cannot be cancelled again"}}';
            HttpResponse respond = new HttpResponse();
            respond.setHeader('Content-Type', 'application/json');
            respond.setBody(body);
            respond.setStatusCode(200);
            respond.setStatus('200');
            return respond;
        }
    }
    
}