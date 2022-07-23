/** *****
 * Description : Test Class for Maybank_RequestReleaseLetter.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20201229            HS@aodigy            Created Initial Version 
 * 
** *****/
@isTest(seeAllData=false)
private class Maybank_RequestReleaseLetterTest {

    @TestSetup
    static void makeData()
    {
        Test_DataFactory.createGlobalOrfDefaults(true);

        Model_Master__c modelMaster = Test_DataFactory.createModelCode(false, 'Test Model Code');
        modelMaster.Branch_Code__c = 'CCK';
        modelMaster.Franchise_Code__c = 'KIAPC';
        insert modelMaster;

        Model_Year_Master__c modelYearMaster = Test_DataFactory.createModelYearCode( false, modelMaster.Id);
        modelYearMaster.Branch_Code__c = 'CCK';
        modelYearMaster.Franchise_Code__c = 'KIAPC';
        insert modelYearMaster;

        Color_Master__c colorMaster = Test_DataFactory.createColorCode(false, 'Test Color Code', 'zCode', 'CCK', 'KIAPC');
        insert colorMaster;

        Trim_Master__c trimMaster = Test_DataFactory.createTrimCode(false, 'Test Trim Code');
        trimMaster.Branch_Code__c = 'CCK';
        trimMaster.Franchise_Code__c = 'KIAPC';
        insert trimMaster;

        Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC', Model_Master__c = modelMaster.Id, PKH_STATUS__c = 'A');
        insert pckHeader;

        Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test', ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;

        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelMaster.Id, colorMaster.Id, trimMaster.Id, modelYearMaster.Id);
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        insert stockReservation;

        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', 'TR0507', stockReservation.Id, 'Test Customer');
        salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.COE_Expiry_Date__c = Date.today().addDays(30);
        insert salesAgreement;

        Loan_Application__c loanAppl = Test_DataFactory.createLoanApplication(false, null, salesAgreement.Id);
        loanAppl.DealerID__c = 'testDealerId';
        insert loanAppl;
    }


    @isTest
    static void requestReleaseLetterWithAttchTM() 
    {
        Sales_Agreement__c saObj = [SELECT Id, SOH_SONO__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'TR0507' ];
        System.assert( saObj <> null );

        InsertContentDoc( saObj.Id, saObj.SOH_SONO__c, 'Release_Letter' );

        Maybank_RequestReleaseLetter.FlowInputs fInput = new Maybank_RequestReleaseLetter.FlowInputs();
        fInput.salesAgreementNo = saObj.SOH_SONO__c;
        fInput.salesAgrementId  = saObj.Id;

        Test.setMock(HttpCalloutMock.class, new RequestReleaseLetterMock());
        System.Test.startTest();
            Maybank_RequestReleaseLetter.requestReleaseLetter( new List<Maybank_RequestReleaseLetter.FlowInputs>{ fInput } );
        System.Test.stopTest();
    }


    @isTest
    static void requestReleaseLetterWithouAttchTM() 
    {
        Sales_Agreement__c saObj = [SELECT Id, SOH_SONO__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'TR0507' ];
        System.assert( saObj <> null );

        Maybank_RequestReleaseLetter.FlowInputs fInput = new Maybank_RequestReleaseLetter.FlowInputs();
        fInput.salesAgreementNo = saObj.SOH_SONO__c;
        fInput.salesAgrementId  = saObj.Id;

        Test.setMock(HttpCalloutMock.class, new RequestReleaseLetterMock());
        System.Test.startTest();
            Maybank_RequestReleaseLetter.requestReleaseLetter( new List<Maybank_RequestReleaseLetter.FlowInputs>{ fInput } );
        System.Test.stopTest();
    }


    public class RequestReleaseLetterMock implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            string body = '{"Data":{"LOSWaaNumber":"LW0001","SalesAgreementNumber":"SA0001"},"Status":{"Code":"S","ErrorCode":"","ErrorDescription":""},"DocumentData":{"DocData": "abcdef"}}';
            HttpResponse respond = new HttpResponse();
            respond.setHeader('Content-Type', 'application/json');
            respond.setBody(body);
            respond.setStatusCode(200);
            respond.setStatus('200');
            return respond;
        }
    }
    

    public static void InsertContentDoc( String saID, String saNumber, String fileName )
    {
        //Insert ContentVersion
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        for( File_Requirements__mdt fileMdt : [ SELECT Id, DeveloperName, Document_Name__c, Naming_Convention__c
                                                FROM File_Requirements__mdt
                                                WHERE DeveloperName IN :fileName.split(';') ]){
            
            String file_naming_pattern = fileMdt.Naming_Convention__c;   
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.PathOnClient    = '/' + file_naming_pattern.replaceAll('\\{!(.*?)\\}', saNumber )+'.pdf';
            cv.Origin          = 'C';
            cv.Title           = file_naming_pattern.replaceAll('\\{!(.*?)\\}', saNumber );
            cv.VersionData     = Blob.valueOf('Testing'); 

            lstContentVersion.add(cv);
        }
        insert lstContentVersion;

        //Insert ContentDocumentLink
        List<ContentDocumentLink> lstContentDocLink = new List<ContentDocumentLink>();
        for( ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE ID IN:lstContentVersion] ){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId    = (Id)saID;
            cdl.ShareType         = 'I';
            cdl.Visibility        = 'AllUsers';

            lstContentDocLink.add( cdl );
        }     
        Insert lstContentDocLink;        
    }
   
}