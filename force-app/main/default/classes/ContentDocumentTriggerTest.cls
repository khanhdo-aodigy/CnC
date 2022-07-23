@isTest
private class ContentDocumentTriggerTest {

    @testSetup
    static void setUp() {
        User sysAdminUser = Test_DataFactory.createUserWithProfileID(
            true, 'SysAdm', 'LastName', 'test@sysadmin.com', [Select Id From Profile Where Name = 'System Administrator'].Id
        );
        User bsdUser = Test_DataFactory.createUserWithProfileID(
            true, 'BSDUsr', 'LastName', 'test@bsd.com', [Select Id From Profile Where Name = 'BSD'].Id
        );         
        
        Account acc = Test_DataFactory.createAccount(true, 'test account');
        /*Account acc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        acc.PersonEmail = 'patest@mail.com';
        insert acc;
        acc = [SELECT Id, PersonContactId FROM Account WHERE ID =: acc.Id];*/

        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun', acc.Id);
        oppt.Branch_Code__c = 'CCA';
        oppt.Opportunity_Score__c = 40;
        oppt.Account__c = acc.Id;
        //oppt.Person_Account__c = acc.Id;
        oppt.Contact_Person__c = acc.PersonContactId;
        insert oppt;

        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        // Create Package Header
        Package_Header__c pckHeader = new Package_Header__c(Model_Master__c = modelCode.Id, PKH_FRN_FRNCD__c = 'KIAPC', PKH_STATUS__c='A', PKH_PKGPRICE__c=1000000);
        insert pckHeader;

        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelCode.Id, colorCode.Id, trimCode.Id, modelYearCode.Id); 
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        stockReservation.Opportunity__c = oppt.Id;
        insert stockReservation;

        // Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                          ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;

        // Package Addtional Charges
        List<Package_Additional_Charges__c> pckAddnlChargeList = new List<Package_Additional_Charges__c>();
        Package_Additional_Charges__c pckAddnlCharge1 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIAPC',
                                                                                          Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                          Package_Header__c = pckHeader.Id,
                                                                                          PKC_ADM_CHRGCD__c ='R004',
                                                                                          PKC_CHARGES__c = 100);
        pckAddnlChargeList.add(pckAddnlCharge1);
        Package_Additional_Charges__c pckAddnlCharge2 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIAPC',
                                                                                          Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                          Package_Header__c = pckHeader.Id,
                                                                                          PKC_ADM_CHRGCD__c ='R002',
                                                                                          PKC_INCPRICE__c = 'INC',
                                                                                          PKC_CHARGES__c = 100);
        pckAddnlChargeList.add(pckAddnlCharge2);
        insert pckAddnlChargeList;

		Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(true, 'CCK', 'NO9999', stockReservation.Id, 'test customer');
        
        System.runAs(sysAdminUser) {
            Test_DataFactory.attachFilesToRecord(
                new Map<Id, List<Blob>>{acc.Id => new List<Blob>{Blob.valueOf('Acc File')}},
                'Acc File',
                'pdf'
			);
        }
        
        System.runAs(bsdUser) {
            Test_DataFactory.attachFilesToRecord(
                new Map<Id, List<Blob>>{
                    acc.Id => new List<Blob>{Blob.valueOf('Account File')},
                    salesAgreement.Id => new List<Blob>{Blob.valueOf('Other File')}    
                },
                new Map<Blob, String>{
                    Blob.valueOf('Account File') => 'Account File',
                    Blob.valueOf('Other File') => 'Other File'    
				},
                new Map<Blob, String>{
                    Blob.valueOf('Account File') => 'pdf',
                    Blob.valueOf('Other File') => 'pdf'    
				}
            );             
        }       
    }
    
    @isTest
    static void Test_beforeDelete_userProfileIsAuthorizedToDeleteFiles() {
        System.runAs([Select Id From User Where FirstName = 'SysAdm' Order By CreatedDate Desc Limit 1][0]) {
            delete [Select Id From ContentDocument];
        }
    } 
    
    @isTest
    static void Test_beforeDelete_blockUnauthorizedDeletionOfAccountFile() {
        System.runAs([Select Id From User Where FirstName = 'BSDUsr' Order By CreatedDate Desc Limit 1][0]) {
            Boolean exceptionThrownOnInsufficientPrivileges = false;
            try {
                delete [Select Id From ContentDocument Where Description = 'Account File'];
            } catch(Exception e) {
                exceptionThrownOnInsufficientPrivileges = e.getMessage().contains(
                    'You are not authorized to delete this file. Please upload a new version instead.'
				);
            } finally {
                System.assert(exceptionThrownOnInsufficientPrivileges);
            }
        }
    }       
    
    @isTest
    static void Test_beforeDelete_blockUnauthorizedDeletionOfSalesAgreementFile() {
        System.runAs([Select Id From User Where FirstName = 'BSDUsr' Order By CreatedDate Desc Limit 1][0]) {
            Boolean exceptionThrownOnInsufficientPrivileges = false;
            try {
                delete [Select Id From ContentDocument Where Description = 'Other File'];
            } catch(Exception e) {
                exceptionThrownOnInsufficientPrivileges = e.getMessage().contains(
                    'You are not authorized to delete this file. Please upload a new version instead.'
				);
            } finally {
                System.assert(exceptionThrownOnInsufficientPrivileges);
            }
        }
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('ContentDocument', true);
        System.runAs([Select Id From User Where FirstName = 'SysAdm' Order By CreatedDate Desc Limit 1][0]) {
            delete [Select Id From ContentDocument];
        }      
        TriggerExclusion.excludeTrigger('ContentDocument', false);
    }
}