@isTest
public class Test_CampaignMember_Promo_Push_SMS 
{ 
    
     static testMethod void test_Campaign_PUSH_Trigger()
    {
        Campaign CampTest = new Campaign();
        CampTest.id ='7010K000001hbn2';
        CampTest.Promo_PUSH_Text__c='Test PUSH';
        CampTest.Promo_SMS_Text__c='Test SMS';
        CampTest.Promo_SMS_Link__c='Test SMS link';
        Contact ConTest = new Contact();
        ConTest.id = '0030K00001atCxY';        
        ConTest.MobilePhone = '6583580841';
        ConTest.Device__c = '94b968a1eef6f8ca6d22f5688636341c7aa8260f61e035b1db0513332aa43ba8';
        
        CampaignMember cm = new CampaignMember();//(CampaignId='7015D000000BKjM',ContactId='0035D00000RPJLE',Status='PUSH');
        cm.CampaignId = CampTest.Id;
        cm.ContactId = ConTest.Id ;
        cm.Status='PUSH';
        upsert cm;
        
        //send_Push_SMS_CustomKeys.SENDAPP_PUSH_SMS('','','94b968a1eef6f8ca6d22f5688636341c7aa8260f61e035b1db0513332aa43ba8','NTU6MTE0OjA','Promo','7015D000000BKjM','Test PUSH_txt','',''); 
        //send_Push_SMS_CustomKeys.SENDAPP_PUSH_SMS('0035D00000RPJLE','6583580841','','MTg6Nzg6MA','Promo','7015D000000BKjM','','Test SMS','Test SMS link'); 
        
       
    }
}