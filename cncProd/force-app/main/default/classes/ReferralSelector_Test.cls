/** ******
 * Description : Test Class for ReferralSelector.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name        Description
 * 20200407             HS          Created Initial Version. 
 * 
** ******/
@isTest
private class ReferralSelector_Test {
    
    @TestSetup
    static void makeData(){
        
        Integer count = 10;
        
        Account jccAccount = Test_DataFactory.createAccount(false, 'jccTestAccount' );
        insert jccAccount;

        List<Contact> lstContact = new List<Contact>();
        for( Integer i = 0 ; i < count ; i++ ){
            lstContact.add( Test_DataFactory.createContact( false, 'REFERRER_CNT_'+i, 'TEST', String.valueOf(jccAccount.Id) ) );
        }
        if( !lstContact.isEmpty() ){
            insert lstContact;
        }

        List<Lead> lstLead = new List<Lead>();
        for( Integer k = 0 ; k < count ; k++ ){
            lstLead.add( Test_DataFactory.createLead(false, jccAccount.Name, 'REFEREE_LEEAD_'+k) );
        }
        if( !lstLead.isEmpty() ){
            insert lstLead;
        }

        List<Account> lstPACustomer = new List<Account>();
        List<Account> lstPAProspect = new List<Account>();
        List<Account> lstPersonAccount = new List<Account>();
        for( Integer j = 0 ; j < count ; j++ ){
            lstPACustomer.add( Test_DataFactory.createPerson( false, 'REFERRER_PA_CUST'+j, 'Customer') );
            lstPAProspect.add( Test_DataFactory.createPerson( false, 'REFEREE_PA_PROP'+j, 'Prospect') );
        }
        lstPersonAccount.addAll( lstPACustomer );
        lstPersonAccount.addAll( lstPAProspect );
        if( !lstPersonAccount.isEmpty() ){
            insert lstPersonAccount;
        }


        if( lstPACustomer.size() == count 
                && lstPAProspect.size() == count 
                     && lstContact.size() == count 
                            && lstLead.size() == count )
        {
            List<Referral__c> lstReferrals = new List<Referral__c>();
            for( Integer i = 0 ; i < 10 ; i++ ){
                Referral__c tempReff = Test_DataFactory.createReferral( false, String.valueOf(lstContact.get(i).Id), String.valueOf(lstLead.get(i).Id) );
                tempReff.Referrer_Account__c = lstPACustomer.get(i).Id;
                tempReff.Referee_Account__c = lstPAProspect.get(i).Id;
                lstReferrals.add( tempReff );
            }
            if( !lstReferrals.isEmpty() ){
                insert lstReferrals;
            }
        }
    }

    @isTest
    static void selectByReferrerContactIdsAndStagesTM() {
        Map<Id,Contact> mapContact = new Map<Id,Contact>([SELECT ID FROM Contact WHERE IsPersonAccount = false]);
        Set<String> setStrCntIds = (Set<String>)JSON.deserialize(JSON.serialize(mapContact.keySet()), Set<String>.class);

        System.assert( setStrCntIds.size() == 10 );
        System.Test.startTest();
            ReferralSelector selector = new ReferralSelector();
            System.assert( selector.selectByReferrerContactIdsAndStages( setStrCntIds , new Set<String>{'Opened'} ).size() == 10 );
            System.assert( selector.selectByReferrerContactIdsAndStages( setStrCntIds , new Set<String>{'DUMMYSTAGE'} ).isEmpty() );
        System.Test.stopTest();
    }

    @isTest
    static void selectByReferrerPersonAccountIdsAndStagesTM() {
        Map<Id,Account> mapPACustomer = new Map<Id,Account>([SELECT ID FROM Account WHERE IsPersonAccount = true and RecordType.DeveloperName = 'Customer']);
        Set<String> setReferrerPAIds = (Set<String>)JSON.deserialize(JSON.serialize(mapPACustomer.keySet()), Set<String>.class);

        System.assert( setReferrerPAIds.size() == 10 );
        System.Test.startTest();
            ReferralSelector selector = new ReferralSelector();
            System.assert( selector.selectByReferrerPersonAccountIdsAndStages( setReferrerPAIds , new Set<String>{'Opened'} ).size() == 10 );
            System.assert( selector.selectByReferrerPersonAccountIdsAndStages( setReferrerPAIds , new Set<String>{'DUMMYSTAGE'} ).isEmpty() );
        System.Test.stopTest();
    }


    @isTest
    static void selectByRefereeEmailsTM(){
        Set<String> setStrEmail = new Set<String>();
        for( Lead ld : [SELECT ID, Email FROM Lead ]){
            setStrEmail.add( ld.Email );
        } 
        System.assert( !setStrEmail.isEmpty() && setStrEmail.size() == 10 );
        System.Test.startTest();
            ReferralSelector selector = new ReferralSelector();
			Set<string> setStrBrands = new Set<string>();
			setStrBrands.add('MIT');
            List<Referral__c> lstReff = selector.selectByRefereeEmails( setStrEmail,setStrBrands );
            //System.assert( !selector.selectByRefereeEmails( setStrEmail ,setStrBrands).isEmpty() );
        System.Test.stopTest();

    }
}