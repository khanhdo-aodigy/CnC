@isTest
public class VSMS_CalloutToDeleteSOAccTest {
    @IsTest
    private static void testCalloutToDeleteSOAcc() {
        
        Test.setMock(HttpCalloutMock.class, new VSMS_CalloutToDeleteSoAccMock());
        Test.startTest();
        VSMS_CallOutToDeleteSOAcc.callOutToVSMSToDeleteSOAcc('CCLCCFSGDCCF005', 'CITPC', 'AC19110063', '1');
        Test.stopTest();
    }
    
    @IsTest
    private static void testCalloutToDeleteSOAcc_Error() {
        
        
        Test.setMock(HttpCalloutMock.class, new VSMS_CalloutToDeleteSoAccMock());
        try {
            Test.startTest();
            VSMS_CallOutToDeleteSOAcc.callOutToVSMSToDeleteSOAcc('CCLCCFSGDCCF005', 'CITPC', 'AC19110063', '');
            Test.stopTest();
        } catch (Exception e ) {
            System.assertEquals('false', e.getMessage());
        }
    }
}