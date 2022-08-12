@IsTest
private with sharing class AttachmentDomainTest
{
    @TestSetup
    private static void makeData()
    {
        // create model master
        Model_Master__c modelMaster = Test_DataFactory.createModelCode(true, 'Model Master');

        // create color master
        Color_Master__c colorMaster = Test_DataFactory.createColorCode(true, 'Color Master', 'CM', 'KIA', 'KIAPC');

        // create trim master
        Trim_Master__c trimMaster = Test_DataFactory.createTrimCode(true, 'Trim Master');

        // create model color trim master
        Model_Color_Trim_Master__c modelColorTrimMaster = new Model_Color_Trim_Master__c(
            Name = 'Model Color Trim Master',
            Branch_Code__c = 'KIA',
            Franchise_Code__c = 'KIAPC',
            Model_Code__c = modelMaster.Id,
            Color_Code__c = colorMaster.Id,
            Trim_Code__c = trimMaster.Id
        );
        insert modelColorTrimMaster;

        // create model year master
        Model_Year_Master__c modelYearMaster = Test_DataFactory.createModelYearCode(true, modelMaster.Id);

        // create non-admin user
        Profile salesManagerProfile = [SELECT Id FROM Profile WHERE Name = 'KIAPC Sales Manager'];

        User salesManagerUser = Test_DataFactory.createUserWithProfileID(true, 'Sample', 'SalesManager', 'salesmanager279831@gmail.com', salesManagerProfile.Id);
        
        System.runas(salesManagerUser)
        {
            // create supplier account
            Account supplier = Test_DataFactory.createAccount(true, 'Supplier Account');

            // create PO
            Vehicle_Purchase_Order__c order = new Vehicle_Purchase_Order__c(
                Franchise_Code__c = 'KIAPC',
                Production_Month__c = Date.today(),
                Supplier_Account__c = supplier.Id,
                Currency_Code__c = 'USD'
            );
            insert order;
            
            // insert attachment as sales manager so that this user can edit on test method later
            Attachment snapshot = new Attachment(
                Name = 'snapshot.txt',
                Description = '#snapshot',
                Body = Blob.valueOf('Sample Content'),
                ParentId = order.Id
            );
            insert snapshot;
        }
    }

    /**
     * test deleting snapshot attachment as non-admin user
     * expected: trigger prevent attachment from being deleted
     */
    @IsTest
    private static void deleteSnapShotAsNonAdmin()
    {
        User salesManagerUser = [SELECT Id FROM User WHERE LastName = 'SalesManager'];

        System.runAs(salesManagerUser)
        {
            try
            {
                delete [SELECT Id FROM Attachment WHERE Name = 'snapshot.txt'];
            }
            catch (Exception e)
            {
                System.assert(e.getMessage().contains('Only System Admin is allowed to delete snapshot attachment'), 'Actual exception: ' + e.getMessage());
            }
        }
    }

    /**
     * test deleting snapshot attachment as admin user
     * expected: attachment can be deleted
     */
    @IsTest
    private static void deleteSnapShotAsAdmin()
    {
        delete [SELECT Id FROM Attachment WHERE Name = 'snapshot.txt'];

        List<Attachment> remainings = [SELECT Id FROM Attachment];

        System.assert(remainings.size() == 0, 'Snapshot attachment is not deleted');
    }

    /**
     * test updating snapshot attachment as non-admin user
     * expected: trigger prevent attachment from being updated
     */
    @IsTest
    private static void updateSnapShotAsNonAdmin()
    {
        User salesManagerUser = [SELECT Id FROM User WHERE LastName = 'SalesManager'];

        System.runAs(salesManagerUser)
        {
            try
            {
                Attachment snapshot = [SELECT Id, Description FROM Attachment];

                snapshot.Description = '';
                update snapshot;
            }
            catch (Exception e)
            {
                System.assert(e.getMessage().contains('Only System Admin is allowed to edit snapshot attachment'), 'Actual exception: ' + e.getMessage());
            }
        }
    }

    /**
     * test updating snapshot attachment as non-admin user
     * expected: attachment can be updated
     */
    @IsTest
    private static void updateSnapShotAsAdmin()
    {
        // admin update
        Attachment snapshot = [SELECT Id, Description FROM Attachment];
        snapshot.Description = '';
        update snapshot;

        // assert
        snapshot = [SELECT Id, Description FROM Attachment];
        System.assert(String.isBlank(snapshot.Description), 'Actual snapshot description: ' + snapshot.Description);
    }
}