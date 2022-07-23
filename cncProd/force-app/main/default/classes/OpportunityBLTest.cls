/*****************************************************
* Class Name: OpportunityBLTest
* Description: Test class for Opportunity logic.
*
* Revision History
* Developer Name        Date            Description
* Christian Gaylan      25-Mar-2019     Created.
*****************************************************/
@isTest
private class OpportunityBLTest {
    //create initial test data
    @testSetUp
    static void createData(){
        Test.startTest();
        Account acc = Test_DataFactory.createAccount(true, 'Acc ' + UserInfo.getLastName());
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'Opp for ' + UserInfo.getLastName(), acc.Id);
        opp.OwnerId = UserInfo.getUserId();
        insert opp;
        Test.stopTest();
    }
    
    /*************************************************************
     * Method Name: testReassignment
     * Description: Verify if a To-Do (Task) 
     *              will be added assigned to the Opp Owner
     *************************************************************/ 
    static testMethod void testReassignment(){
        Test.startTest();
        //Other owner
        String otherOwner = [SELECT Id 
                             FROM User 
                             WHERE isActive=true 
                             AND Profile.Name ='System Administrator' 
                             LIMIT 1].Id;
        
        //fetch Opp assigned to the running user
        Opportunity opp = [SELECT Id, OwnerId 
                           FROM Opportunity 
                           WHERE OwnerId=:UserInfo.getUserId() 
                           LIMIT 1];
        
        //Create initial task (to check if completed)
        Task tk = Utility.createTask(opp.Id, opp.OwnerId, Label.OppAssignment);
        insert tk;
        
        //re-assign
        opp.OwnerId = otherOwner;
        
        update opp;
        Test.stopTest();
        
        //Verify Task is assigned to the new Opp Owner
        System.assertEquals(1, [SELECT COUNT() 
                                FROM Task 
                                WHERE OwnerId=:otherOwner AND Status='Open']);
    } 
    
    /*************************************************************
     * Method Name: testBranchCodes
     * Description: Verify if a Branch and Francise Code 
     *              will reflect on the Opportunity
     *************************************************************/ 
    static testMethod void testBranchCodes(){
        Test.startTest();
        //Update Branch and Franchise Code
        User u = new User(Id=UserInfo.getUserId(), 
                          Branch_Code__c = 'CCA', 
                          Franchise_Code__c='MITPC');
        update u;
        
        Opportunity opp;
        System.runAs(u){
            //Create a new Opportunity where Owner = running user
            opp = Test_DataFactory.createOpportunity(false,'Opp for ' + UserInfo.getLastName(), 
                                                                 [SELECT Id FROM Account LIMIT 1].Id);
            opp.OwnerId = UserInfo.getUserId();
            insert opp;
        }

        
        Opportunity oppAfterUpd = [SELECT Branch_Code__c, Franchise_Code__c
                                   FROM Opportunity 
                                   WHERE Id=:opp.Id 
                                   LIMIT 1];
        
        //Verify Opportunity Branch and Franchise Codes are the same with the Owner upon insert
        System.assertEquals('CCA', oppAfterUpd.Branch_Code__c);
        System.assertEquals('MITPC', oppAfterUpd.Franchise_Code__c);
        Test.stopTest();
    }  
    
    /*************************************************************
     * Method Name: testClashOps
     * Description: Verify if a Clash Opportunity will be marked
     *              successfully once the trigger runs.
     *************************************************************/ 
    static testMethod void testClashOps(){
        Test.startTest();
        //Update Branch and Franchise Code
        User u = new User(Id=UserInfo.getUserId(), 
                          Branch_Code__c = 'CCA', 
                          Franchise_Code__c='MITPC');
        update u;
        
        String accId;
        Contact con;
        System.runAs(u){
            accId = [SELECT Id FROM Account LIMIT 1].Id;
            con = Test_DataFactory.createContact(false, 'Test', 'Test', accId);
            insert con;
            
            //Create a new Opportunity where Owner = running user
            List<Opportunity> oppList = new List<Opportunity>();
            for(Integer i=0; i<5;i++){
                Opportunity opp = Test_DataFactory.createOpportunity(false, 'Opp for ' + UserInfo.getLastName(), 
                                                                     accId
                                                                    );
                opp.OwnerId = UserInfo.getUserId();
                opp.Contact_Person__c = con.Id;
                opp.StageName = 'Open'; 
                oppList.add(opp);
            }
            insert oppList;
            
            TriggerHandlerOpportunity.isAfterInsertRun = false;
            TriggerHandlerOpportunity.isAfterUpdateRun = false;
            Opportunity oppNew = Test_DataFactory.createOpportunity(false, 
                                                                    'Opp for ' + UserInfo.getLastName(), 
                                                                    accId
                                                                   );
            oppNew.OwnerId = UserInfo.getUserId(); 
            oppNew.StageName = 'Open'; 
            //oppNew.Clash_Opportunity__c = true;
            oppNew.Contact_Person__c = con.Id;

            insert oppNew;            
        }

        
        Test.stopTest();

    } 
    static testMethod void testClashOpsForPA(){
        Test.startTest();
        //Update Branch and Franchise Code
        User u = new User(Id=UserInfo.getUserId(), 
                          Branch_Code__c = 'CCA', 
                          Franchise_Code__c='MITPC');
        update u;
        
        String accId;
        Contact con;
        System.runAs(u){
            accId = [SELECT Id FROM Account LIMIT 1].Id;
            
            Account acc = Test_DataFactory.createPerson(true, UserInfo.getLastName(), 'Prospect');
            //Create a new Opportunity where Owner = running user
            List<Opportunity> oppList = new List<Opportunity>();
            for(Integer i=0; i<5;i++){
                Opportunity opp = Test_DataFactory.createOpportunity(false, 
                                                                     'Opp for ' + i, 
                                                                     acc.Id
                                                                    );
                opp.OwnerId = UserInfo.getUserId();
                opp.StageName = 'Open'; 
                opp.Account__c = acc.Id;
                oppList.add(opp);
            }
            insert oppList;
            TriggerHandlerOpportunity.isAfterInsertRun = false;
            TriggerHandlerOpportunity.isAfterUpdateRun = false;
            Opportunity oppNew = Test_DataFactory.createOpportunity(false, 
                                                                    'Opp for ' + UserInfo.getLastName(), 
                                                                    acc.Id
                                                                   );
            oppNew.OwnerId = UserInfo.getUserId(); 
            oppNew.StageName = 'Open'; 
            oppNew.Account__c = acc.Id;
            insert oppNew;
        }
        
        
        Test.stopTest();
        
    }      
    
    /*************************************************************
     * Method Name: testClashOps
     * Description: Verify if a Clash Opportunity will be marked
     *              successfully once the trigger runs.
     *************************************************************/ 
    static testMethod void testClashOpsforLead(){
        Test.startTest();
        //Update Branch and Franchise Code
        User u = new User(Id=UserInfo.getUserId(), 
                          Branch_Code__c = 'CCA', 
                          Franchise_Code__c='MITPC');
        update u;
        
        System.runAs(u){
            String accId = [SELECT Id FROM Account LIMIT 1].Id;
            Lead ld = Test_DataFactory.createLead(false, 'Test', 'Test');
            insert ld;
            
            //Create a new Opportunity where Owner = running user
            List<Opportunity> oppList = new List<Opportunity>();
            for(Integer i=0; i<5;i++){
                Opportunity opp = Test_DataFactory.createOpportunity(false, 
                                                                     'Opp for ' + UserInfo.getLastName(), 
                                                                     accId
                                                                    );
                opp.OwnerId = UserInfo.getUserId();
                opp.Lead__c = ld.Id;
                opp.StageName = 'Open'; 
                oppList.add(opp);
            }
            insert oppList;
            
            TriggerHandlerOpportunity.isAfterInsertRun = false;
            TriggerHandlerOpportunity.isAfterUpdateRun = false;
            Opportunity oppNew = Test_DataFactory.createOpportunity(false, 
                                                                    'Opp for ' + UserInfo.getLastName(), 
                                                                    accId
                                                                   );
            oppNew.OwnerId = UserInfo.getUserId(); 
            oppNew.StageName = 'Open';
            oppNew.Lead__c = ld.Id;
            insert oppNew;
        }

        Test.stopTest();
    }  
    
    /*************************************************************
     * Method Name: checkSharing
     * Description: Verify if Lead and Contact will be shared upon
     *              Opportunity reassignment
     *************************************************************/ 
    static testMethod void checkSharing(){
        Test.startTest();
        //Other owner
        String otherOwner = [SELECT Id 
                             FROM User 
                             WHERE isActive=true 
                             AND Profile.Name ='System Administrator' 
                             AND Id != :UserInfo.getUserId() 
                             LIMIT 1].Id;        
        
        //Create Lead and Contact
        String accId = [SELECT Id FROM Account LIMIT 1].Id;
        Contact con = Test_DataFactory.createContact(false, 'Test', 'Test', accId);
        insert con;
        
        Lead ld = Test_DataFactory.createLead(false, 'Test', 'Test');
        insert ld;
        
        Account acc = Test_DataFactory.createPerson(true, UserInfo.getName(), 'Customer');
        
        TriggerHandlerOpportunity.isAfterUpdateRun = false; 
        Opportunity opp = [SELECT Id, Lead__c, 
                           Contact_Person__c, OwnerId, Account__c 
                           FROM Opportunity 
                           WHERE OwnerId=: UserInfo.getUserId() 
                           LIMIT 1];
        opp.Lead__c = ld.Id;
        opp.Contact_Person__c = con.Id;
        opp.OwnerId = otherOwner; 
        opp.Account__c = acc.Id;
        update opp;
        Test.stopTest();
        
        //Verify a share record will be created on both Lead and Contact records
        System.assert([SELECT COUNT() FROM Share__c 
                             WHERE 
                             Record_Id__c IN (:con.Id,:ld.Id) 
                             AND User_or_Group_Name__c=:otherOwner] >= 0 );
    }
}