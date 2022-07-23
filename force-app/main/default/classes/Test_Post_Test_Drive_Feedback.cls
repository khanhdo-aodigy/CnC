@isTest
public class Test_Post_Test_Drive_Feedback {                                                                
    static Account ac = Test_DataFactory.createAccount(true,'testData');   
    static Opportunity oppInsCon = Test_DataFactory.createOpportunity(true,'testData', ac.Id);
   	static Contact TestCon = Test_DataFactory.createContact(true,'testRun','testRun',ac.Id);
    static Model__c TestMod1 = Test_DataFactory.createmodelId(true,'testRun','CCK','KIAPC');
    
    public static testMethod void testHandleAfterUpdateTestDrive(){  
        List<Test_Drive__c> tdUpate = new List<Test_Drive__c>();
        Map<id, Test_Drive__c>  mapTD=new Map<id, Test_Drive__c>();  
        Vehicle_Master__c vm = Test_DataFactory.createVehicleMaster(true, 'test vm', null, TestMod1.id);
        
        //test drive mistubishi
        Test_Drive__c TestDriv   = Test_DataFactory.createTestDrive(true,oppInsCon.Id);             
        TestDriv.Franchise_Code__c = 'MITPC';
        TestDriv.Branch_Code__c = 'CCA';
        TestDriv.SendPostTestDrive__c = true;
        TestDriv.Opportunity__c = oppInsCon.id;
        tdUpate.add(TestDriv);
        mapTD.put(TestDriv.id,TestDriv);
        
        //test drive with Kia
        Test_Drive__c TestDriv1 = Test_DataFactory.createTestDrive(true,oppInsCon.Id);
        TestDriv1.Franchise_Code__c = 'KIAPC';
        TestDriv1.Branch_Code__c = 'CCK';
        TestDriv1.SendPostTestDrive__c = true;
        TestDriv1.Prospect__c= TestCon.id;
        TestDriv1.Model__c = vm.id;
        tdUpate.add(TestDriv1);
        mapTD.put(TestDriv1.id,TestDriv1);
        
         //test drive with CIT
        Test_Drive__c TestDriv2 = Test_DataFactory.createTestDrive(true, oppInsCon.Id);
        TestDriv2.Franchise_Code__c = 'CITPC';
        TestDriv2.Branch_Code__c = 'CCF';
        TestDriv2.SendPostTestDrive__c = true;
        TestDriv2.Prospect__c= TestCon.id;
        tdUpate.add(TestDriv2);
        mapTD.put(TestDriv2.id,TestDriv2);
    	// updation of fields for the tdlist
    	
        /** PA MIGRATION: Newly Added -- Start **/
        Account dummyAccount = Test_DataFactory.createPerson(false, 'FakeName', 'Customer');
        dummyAccount.PersonEmail = 'dummyEmail@fakedomain.com';
        insert dummyAccount;
        
        // Test Drive with CCK - KIA
        Test_Drive__c cckTestDrive = Test_DataFactory.createTestDrive(true, oppInsCon.Id);
        cckTestDrive.Franchise_Code__c = 'KIAPC';
        cckTestDrive.Branch_Code__c = 'CCK';
        cckTestDrive.SendPostTestDrive__c = true;
        cckTestDrive.Account__c = dummyAccount.Id;
        tdUpate.add(cckTestDrive);
        mapTD.put(cckTestDrive.Id, cckTestDrive);
        
        // Test Drive with CCA - Mitsubishi
        Test_Drive__c ccaTestDrive = Test_DataFactory.createTestDrive(true, oppInsCon.Id);
        ccaTestDrive.Franchise_Code__c = 'MITPC';
        ccaTestDrive.Branch_Code__c = 'CCA';
        ccaTestDrive.SendPostTestDrive__c = true;
        ccaTestDrive.Account__c = dummyAccount.Id;
        tdUpate.add(ccaTestDrive);
        mapTD.put(ccaTestDrive.Id, ccaTestDrive);
        
        // Test Drive with CCF - CIT
        Test_Drive__c ccfTestDrive = Test_DataFactory.createTestDrive(true, oppInsCon.Id);
        ccfTestDrive.Franchise_Code__c = 'CITPC';
        ccfTestDrive.Branch_Code__c = 'CCF';
        ccfTestDrive.SendPostTestDrive__c = true;
        ccfTestDrive.Account__c = dummyAccount.Id;
        tdUpate.add(ccfTestDrive);
        mapTD.put(ccfTestDrive.Id, ccfTestDrive);
        
        // Test Drive with DS
        Test_Drive__c dsTestDrive = Test_DataFactory.createTestDrive(true, oppInsCon.Id);
        dsTestDrive.Franchise_Code__c = 'CITPC';
        dsTestDrive.Branch_Code__c = 'DS';
        dsTestDrive.SendPostTestDrive__c = true;
        dsTestDrive.Account__c = dummyAccount.Id;
        tdUpate.add(dsTestDrive);
        mapTD.put(dsTestDrive.Id, dsTestDrive);
        
        /** PA MIGRATION: Newly Added -- End **/
        
        update tdUpate;
        Test.startTest();    
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,'{"accessToken": "Successful"}'));
        Post_Test_Drive_Feedback.hanldeAfterUpdate(tdUpate, mapTD);
        Test.stopTest();
    }
}