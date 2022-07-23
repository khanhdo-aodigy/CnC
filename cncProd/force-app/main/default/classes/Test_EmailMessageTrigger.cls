@isTest
public class Test_EmailMessageTrigger {

    @isTest
    public static void testTriggerinsert1(){
        Case c = New Case(Status='Open', Origin='Email', Is_Case_Assigned_to_SA__c=TRUE, 
                          Is_First_Response_Completed__c = FALSE);
        insert c;
        
        EmailMessage em = New EmailMessage(RelatedToId=c.id,Status='3',Incoming=false,
                                          subject='Email');
        insert em;
    }
}