global class helperClass
{
    WebService static String sendSMSMarketing(String campID){
        List<Contact> contacts = [ SELECT Id, Name, MobilePhone
                                   FROM Contact 
                                   WHERE Id IN ( SELECT ContactId 
                                                 FROM CampaignMember 
                                                 WHERE CampaignId = :campID 
                                                 AND ContactId != null 
                                                 AND SMS_Status__c = 'New' 
                                                 AND Contact.IsPersonAccount = true ) ];
        if ( contacts.size() > 0 )
        {
            Campaign camp = [SELECT Id, Name, Campaign_Code_Key__c, Marketing_Message__c, IsActive 
                             FROM Campaign 
                             WHERE Id =: campID 
                             LIMIT 1];

            if ( camp.IsActive == false ){ 
                return 'Campaign is Not Active. Please make it Active if you want to send out SMS';
            }

            String theText = camp.Marketing_Message__c;
            for (Contact ct:contacts){
                String thePhone = ct.MobilePhone;
                sendSmsClass.sendSms2( thePhone, theText, '6583323967');
            }
            
            List<CampaignMember> cml = [ SELECT Id, ContactId, SMS_Status__c
                                         FROM CampaignMember
                                         WHERE CampaignId = :campID 
                                         AND ContactId != null 
                                         AND SMS_Status__c = 'New'];
            
            List<CampaignMember> updateCml = new List<CampaignMember>();
            if (cml.size()>0)
            {
                for (CampaignMember cm : cml){
                    cm.SMS_Status__c = 'Sent';
                    updateCml.add(cm);
                }
                update updateCml;
            }
            return 'SMS Marketing send ' + theText;
        }
        return 'No Campaign Member to be sent';
    }
}