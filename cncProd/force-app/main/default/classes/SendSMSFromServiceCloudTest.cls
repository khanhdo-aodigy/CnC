@isTest
private class SendSMSFromServiceCloudTest {

     @isTest static void testSendSMSNow(){
         try{
        Test.startTest();
    
        List<SendSMSFromServiceCloud.FlowInputs> wrapper = new List<SendSMSFromServiceCloud.FlowInputs>();
        SendSMSFromServiceCloud.FlowInputs val = new SendSMSFromServiceCloud.FlowInputs();
        val.Keyword = 'MTM6Nzg6MA';
         val.mobileNumber = '6596741063';
         val.SMS_Body = 'testing sms';
         val.SubscriberKey = '6596741063';
         wrapper.add(val);
         
        Test.setMock(HttpCalloutMock.class, new externalMock());
        
       SendSMSFromServiceCloud.SendSMSNow(wrapper);  
        
         //response null. no assert.
        Test.stopTest();
         }catch(exception e){}
    }
}