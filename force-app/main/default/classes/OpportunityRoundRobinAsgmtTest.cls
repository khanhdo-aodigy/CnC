/** *****
 * Description : Test Class for OpportunityRoundRobinAsgmt.cls
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                         Description
 * 20201104            HS@aodigy                    Created Initial Version.
 * 
** *****/ 
@isTest(seeAllData=false)
private class OpportunityRoundRobinAsgmtTest {

    @TestSetup
    static void makeData(){
    
        Set<String> setRoleNames = new Set<String>{ 'KIAPC Sales Consultant','MITPC Sales Consultant','MBP Sales Consultant','CITPC Sales Consultant','Management' };
        List<UserRole> lstUserRole = new List<UserRole>();
        for( String rName : setRoleNames ){
            lstUserRole.add( new UserRole( Name = rName ) );
        }
        Database.insert( lstUserRole );
        
        List<User> lstUser = new List<User>();
        Integer index = 900;
        for(UserRole ur : lstUserRole ){
            User tempUsr = new User( Alias = 'xyz'+index, email='dummyTestUsrCNC'+index+'@XYZtesting.com', userroleid = ur.Id,
                                     emailencodingkey='UTF-8', lastname='dummyTest', FirstName = 'UsrCNC'+index, languagelocalekey='en_US', 
                                     localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                     timezonesidkey='America/Los_Angeles', username='dummyTestUsrCNC'+index+'@XYZtesting.com',
                                     Is_Eligible_Opp_Owner__c = true);
            lstUser.add( tempUsr );
            index++;
        }
        Database.insert( lstUser );
    }

    @isTest
    static void testRoundRobin(){
        System.Test.startTest();
            Set<String> setBranches = new Set<String>{'CCK::KIAPC','CCF::CITPC','CCA::MITPC','CCI::MBC'};

            List<Opportunity> lstOppoToInsert = new List<Opportunity>();
            for( String strVal : setBranches ){
                Opportunity tempOppo       = new Opportunity();
                tempOppo.Franchise_Code__c = strVal.split('::').get(1);
                tempOppo.Branch_Code__c    = strVal.split('::').get(0);
                tempOppo.StageName         = 'Open';
                tempOppo.LeadSource        = 'PriceAlert';
                tempOppo.Name              = 'TestOpp'; 
                tempOppo.Rating__c         = 'Hot';
                tempOppo.CloseDate         = Date.today().addDays(9);  
                lstOppoToInsert.add( tempOppo );
            }
            insert lstOppoToInsert;

        System.Test.stopTest();

        List<Opportunity> lstOppo = [SELECT Id, Branch_Code__c, OwnerId FROM Opportunity ];
        System.assert( lstOppo <> null && lstOppo.size() == 4 );

        for( Opportunity opp : [SELECT Id, Name, Branch_Code__c, OwnerId, Owner.Name FROM Opportunity ]){
            System.assert( opp.OwnerId <> UserInfo.getUserId() );
        }
    }
}