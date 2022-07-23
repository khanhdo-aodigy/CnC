@isTest
public class Test_BatchManager {
    @istest public static void testbatch(){         
        JSONGenerator jsonGen = JSON.createGenerator(true);//Pass empty JSON if parameter is not required.
        jsonGen.writeStartObject();
        jsonGen.writeNumberField('abc', 1.21);
        jsonGen.writeStringField('def', 'xyz');
        jsonGen.writeEndObject();
        test.startTest();
        BatchManager bm = new BatchManager('BatchToUpdateSRToVSMS', jsonGen);
        BatchManager bmSendTDNoShow = new BatchManager('BatchSendTestDriveNoShowEmail', jsonGen);
        BatchManager convertLead = new BatchManager('LeadToContactConverter', null);
        BatchManager deleteShare = new BatchManager('DeleteLeadShareRecord', null);
        BatchManager updOppswithConvertedCon= new BatchManager('BatchUpdConvertedLeads', null);
        test.stopTest();
        
    }
    
}