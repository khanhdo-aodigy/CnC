@istest
public with sharing class ADGLIB_FileReaderTest {
    @TestSetup
    static void makeData(){
        // create supplier account
        Account supplier = Test_DataFactory.createAccount(true, 'Supplier Account');

        //create PO
        Vehicle_Purchase_Order__c order = Test_DataFactory.createVehiclePurchaseOrder(true, supplier.Id);

        //create ContentVersion
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Id,Name,Model_Code__r.Name,Color_Code__r.ColorCode__c,Color_Description__c,Trim_Code__r.Name,Trim_Description__c,Manufacturer_Ref_No__c\na0K0T000005WOoPUAW,RVH-202208-153643,STINGER3.3ARED,C4S,CERAMIC SILVER,WK,SATURN BLACK,888\na0K0T000005WOoUUAW,RVH-202208-153644,STINGER3.3ARED,C4S,CERAMIC SILVER,WK,SATURN BLACK,999'),
            IsMajorVersion = true
        );
        insert contentVersion_1;
       
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink
        ContentDocumentLink contentlink = new ContentDocumentLink(
            contentdocumentid = contentVersion_2.contentdocumentid,
            ShareType = 'V',
            LinkedEntityId = order.Id
        );
        insert contentlink; 
    }

    @istest
    public static void withHeaderTrue(){

        ContentVersion con = [SELECT Id, VersionData FROM ContentVersion];
        // Blob d = con.VersionData;
        ADGLIB_CommaSeparatedValuesFileReader comaSeparated_1 = new ADGLIB_CommaSeparatedValuesFileReader(con.VersionData.toString(), true);
        comaSeparated_1.withHeader();
        comaSeparated_1.withStrictMode();
        comaSeparated_1.read();
        List<List<String>> listString = comaSeparated_1.exportResult();
        System.debug('listString :: ' + JSON.serialize(listString));

        List<Map<String, String>> listMapString = comaSeparated_1.exportResultAsMap();
        System.assertEquals(2, listMapString.size());
    }

    @istest
    public static void withHeaderTrueAndDoubleQuote(){

        ContentDocument cd = [SELECT Id FROM ContentDocument];

        //create ContentVersion
        ContentVersion contentVersion_2 = new ContentVersion(
            Title = 'Emperor Penguins',
            PathOnClient = 'Emperor Penguins.jpg',
            VersionData = Blob.valueOf('Id,Name,Model_Code__r.Name,Color_Code__r.ColorCode__c,Color_Description__c,Trim_Code__r.Name,Trim_Description__c,Manufacturer_Ref_No__c\na0K0T000005WOoPUAW,RVH-202208-153643,STINGER3.3ARED,C4S,CERAMIC SILVER,WK,SATURN BLACK,888\na0K0T000005WOoUUAW,RVH-202208-153644,STINGER3.3ARED,C4S,CERAMIC SILVER,WK,"SATURN, BLACK",999'),
            IsMajorVersion = true,
            contentDocumentId = cd.Id
        );
        insert contentVersion_2;
        
        ADGLIB_CommaSeparatedValuesFileReader comaSeparated_1 = new ADGLIB_CommaSeparatedValuesFileReader(contentVersion_2.VersionData.toString(), true);
        comaSeparated_1.withHeader();
        comaSeparated_1.withStrictMode();
        comaSeparated_1.read();
        List<List<String>> listString = comaSeparated_1.exportResult();
        System.debug('listString :: ' + JSON.serialize(listString));
        System.assertEquals(3, listString.size()); 

        List<Map<String, String>> listMapString = comaSeparated_1.exportResultAsMap();
        System.debug('listMapString :: ' + JSON.serialize(listMapString));
        System.assertEquals(2, listMapString.size());
    }


    @isTest
    public static void withHeaderFalse(){
        ContentVersion con = [SELECT Id, VersionData FROM ContentVersion];
        // Blob d = con.VersionData;
        ADGLIB_CommaSeparatedValuesFileReader comaSeparated_2 = new ADGLIB_CommaSeparatedValuesFileReader(con.VersionData.toString());
        comaSeparated_2.withoutHeader();
        comaSeparated_2.withoutStrictMode();
        comaSeparated_2.read();
        List<List<String>> listString = comaSeparated_2.exportResult();

        System.debug('listString :: ' + JSON.serialize(listString));
        System.assertEquals(3, listString.size());    
    }
}