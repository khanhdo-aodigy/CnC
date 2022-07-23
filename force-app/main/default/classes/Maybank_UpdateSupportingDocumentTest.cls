/** *****
 * Description : Test Class for Maybank_UpdateSupportingDocument.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20201229            HS@aodigy            Created Initial Version 
 * 
** *****/
@isTest(seeAllData=false)
private class Maybank_UpdateSupportingDocumentTest {
    
   
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
    static void updateAllSupportingDocumentTM() 
    {
        Sales_Agreement__c saObj = [SELECT Id, SOH_SONO__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'TR0507' ];
        System.assert( saObj <> null );

        InsertContentDoc( saObj.Id, saObj.SOH_SONO__c, 'Sales_Tax_Invoice;Cover_Note;Acknowledgement_Page' );

        Maybank_UpdateSupportingDocument.FlowInputs fInput = new Maybank_UpdateSupportingDocument.FlowInputs();
        fInput.salesAgreementNo = saObj.SOH_SONO__c;
        fInput.salesAgrementId  = saObj.Id;
        fInput.fileRequirementsName = 'Sales_Tax_Invoice;Cover_Note;Acknowledgement_Page';

        Test.setMock(HttpCalloutMock.class, new UpdateSupportingDocumentMock());
        System.Test.startTest();
            List<Maybank_UpdateSupportingDocument.FlowOutputs> lstFlwOutputs = new List<Maybank_UpdateSupportingDocument.FlowOutputs>();
            lstFlwOutputs = Maybank_UpdateSupportingDocument.updateSupportingDocument( new List<Maybank_UpdateSupportingDocument.FlowInputs>{ fInput } );
            // System.assert( !lstFlwOutputs.isEmpty() );
            // System.assert( lstFlwOutputs.get(0).api_returned_code == 'S' );
            // System.assert( lstFlwOutputs.get(0).fileCount == 3 );
        System.Test.stopTest();
    }


    @isTest
    static void updatePartialSupportingDocumentTM() 
    {
        Sales_Agreement__c saObj = [SELECT Id, SOH_SONO__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'TR0507' ];
        System.assert( saObj <> null );

        InsertContentDoc( saObj.Id, saObj.SOH_SONO__c, 'Sales_Tax_Invoice;Cover_Note' );

        Test.setMock(HttpCalloutMock.class, new UpdateSupportingDocumentMock());
        System.Test.startTest();
            Maybank_UpdateSupportingDocument.FlowInputs fInput = new Maybank_UpdateSupportingDocument.FlowInputs();
            fInput.salesAgreementNo = saObj.SOH_SONO__c;
            fInput.salesAgrementId  = saObj.Id;
            fInput.fileRequirementsName = 'Sales_Tax_Invoice;Cover_Note;Acknowledgement_Page';
            List<Maybank_UpdateSupportingDocument.FlowOutputs> lstFlwOutputs = new List<Maybank_UpdateSupportingDocument.FlowOutputs>();
            lstFlwOutputs = Maybank_UpdateSupportingDocument.updateSupportingDocument( new List<Maybank_UpdateSupportingDocument.FlowInputs>{ fInput } );
            // System.assert( !lstFlwOutputs.isEmpty());
            // System.assert( String.isBlank(lstFlwOutputs.get(0).api_returned_code) );
            // System.assert( lstFlwOutputs.get(0).fileCount == 2 );
        System.Test.stopTest();
    }


    public class UpdateSupportingDocumentMock implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            string body = '{"Data":{"LOSRefNumber":"LW05050505","SalesAgreementNumber":"TR0507"},"Status":{"Code":"S","ErrorCode":"","ErrorDescription":""}}';
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