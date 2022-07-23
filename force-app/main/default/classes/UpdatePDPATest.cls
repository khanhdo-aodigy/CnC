@isTest
private class UpdatePDPATest {
	@isTest
    private static void testUpdatePDPA(){     
        Account pa = Test_DataFactory.createPA(true, 'lastName', 'test@pdpa.com', 'Customer');
        pa = [ SELECT Id, PersonContactId FROM Account WHERE PersonEmail = 'test@pdpa.com'];
        Contact con = new Contact(Id = pa.PersonContactId);
        
        UpdatePDPA.updatePDPA(con, true);
        UpdatePDPA.updatePDPA(con, true, true, true);
        UpdatePDPA.updatePDPA(con, true, true, true, true);
        UpdatePDPA.updatePDPA(con, 'SMS;Call;Email');
        
        UpdatePDPA.updateConsentPDPA(pa, true);
        UpdatePDPA.updatePDPA(pa, true, true, true);
        UpdatePDPA.updatePDPA(pa, true, true, true, true);
    }
    
}