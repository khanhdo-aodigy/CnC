@isTest
private class AccessoriesMasterSelectorTest {
    @isTest
    static void testSelectAccessoriesBasedOnGroup() {
        Accessories_Master__c accMaster1 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                     ACM_ACCSDESC__c = 'Acc Master Test',
                                                                     ACM_ACCSCD__c = 'SER2000',
                                                                     Rate__c = 5000,
                                                                     ACM_ACCSTYPE__c = 'F',
                                                                     ACM_MNM_MAJGROUPCD__c = 'FREE_ACC',
                                                                     ACM_STATUS__c = 'A');
        insert accMaster1;
        List<String> accessoriesGroupList = new List<String>();
        accessoriesGroupList.add(accMaster1.AccessoriesGroup__c);
        AccessoriesMasterSelector aCMSel = new AccessoriesMasterSelector();
        aCMSel.selectAccessoriesBasedOnGroup(accessoriesGroupList, accMaster1.BranchCode__c, accMaster1.ACM_FRN_FRNCD__c, accMaster1.ACM_MDM_MODELCD__c, accMaster1.ACM_STATUS__c);
    }
    
    @isTest
    static void testSelectAccsMastersWithRateMastersByIds() {
         Accessories_Master__c accMaster1 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                    ACM_ACCSDESC__c = 'Acc Master Test',
                                                                    ACM_ACCSCD__c = 'SER2000',
                                                                    Rate__c = 5000,
                                                                    ACM_ACCSTYPE__c = 'F',
                                                                    ACM_MNM_MAJGROUPCD__c = 'FREE_ACC');
        insert accMaster1;
        Accs_Rate_Master__c accRateMaster1 = new Accs_Rate_Master__c(Accessories__c = accMaster1.Id,
                                                                    ARM_ACM_FRNCD__c = 'KIAPC',
                                                                    ARM_EFFDT__c = Date.today(),
                                                                    ARM_SALEPRICE__c = 1000);
        insert accRateMaster1;
        Accessories_Master__c accMaster2 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                    ACM_ACCSDESC__c = 'Acc Master Test',
                                                                    ACM_ACCSCD__c = 'SER2000',
                                                                    Rate__c = 5000,
                                                                    ACM_ACCSTYPE__c = 'F',
                                                                    ACM_MNM_MAJGROUPCD__c = 'LEA_SEAT');
        insert accMaster2;
        Accs_Rate_Master__c accRateMaster2 = new Accs_Rate_Master__c(Accessories__c = accMaster2.Id,
                                                                     ARM_ACM_FRNCD__c = 'KIAPC',
                                                                     ARM_EFFDT__c = Date.today(),
                                                                     ARM_SALEPRICE__c = 2000);
        insert accRateMaster2;
        
        Set<Id> accsMasterIds = new Set<Id>();
        accsMasterIds.add(accMaster1.Id);
        accsMasterIds.add(accMaster2.Id);

        AccessoriesMasterSelector aCMSel = new AccessoriesMasterSelector();
        aCMSel.selectAccsMastersWithRateMastersByIds(accsMasterIds);  
    }
    
    @isTest
    static void testSelectAccsMasterById() {
         Accessories_Master__c accMaster1 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                    ACM_ACCSDESC__c = 'Acc Master Test',
                                                                    ACM_ACCSCD__c = 'SER2000',
                                                                    Rate__c = 5000,
                                                                    ACM_ACCSTYPE__c = 'F',
                                                                    ACM_MNM_MAJGROUPCD__c = 'FREE_ACC');
        insert accMaster1;
        Accs_Rate_Master__c accRateMaster1 = new Accs_Rate_Master__c(Accessories__c = accMaster1.Id,
                                                                    ARM_ACM_FRNCD__c = 'KIAPC',
                                                                    ARM_EFFDT__c = Date.today(),
                                                                    ARM_SALEPRICE__c = 1000);
        insert accRateMaster1;

        AccessoriesMasterSelector aCMSel = new AccessoriesMasterSelector();
        aCMSel.selectAccsMasterById(accMaster1.Id);  
    }
    
    @isTest
    static void testSelectByBranchAndAccsCode() {
        Accessories_Master__c accMaster1 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                     ACM_ACCSDESC__c = 'Acc Master Test',
                                                                     ACM_ACCSCD__c = 'SER2000',
                                                                     Rate__c = 5000);
        insert accMaster1;
        
        AccessoriesMasterSelector aCMSel = new AccessoriesMasterSelector();
        aCMSel.selectByBranchAndAccsCode(accMaster1.BranchCode__c, accMaster1.ACM_ACCSCD__c);  
    }
    
    @isTest
    static void testSelectByVSMSCompoundPrimaryKey() {
        Accessories_Master__c accMaster1 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                     ACM_ACCSDESC__c = 'Acc Master Test',
                                                                     ACM_ACCSCD__c = 'SER3000',
                                                                     ACM_BRM_UNIQUEBRCD__c = 'CCLCCKSGDCCK003',
                                                                     Rate__c = 5000);
        insert accMaster1;
        
        AccessoriesMasterSelector aCMSel = new AccessoriesMasterSelector();
        aCMSel.selectByVSMSCompoundPrimaryKey(accMaster1.ACM_FRN_FRNCD__c, accMaster1.ACM_ACCSCD__c, accMaster1.ACM_BRM_UNIQUEBRCD__c);
    }
}