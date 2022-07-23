@isTest
private class ContentVersionSelectorTest {
	@testSetup
    private static void setUp() {
    	list<ContentVersion> cvs = new list<ContentVersion>{};
        for (integer i = 0; i < 10; i++) {
            cvs.add(new ContentVersion(Title = 'Test Title ' + string.valueOf(i), PathOnClient = '/' + 'Test Title ' + string.valueOf(i) + '.pdf', VersionData = Blob.valueOf('Test Content')));    
        }
        insert cvs;
    }
    
    @isTest
    private static void selectById_Test() {
        ContentVersionSelector selectorInstance = new ContentVersionSelector();
        ContentVersion cv = [SELECT id FROM ContentVersion WHERE Title = 'Test Title 1'];
        list<ContentVersion> cvs = selectorInstance.selectById(cv.id);
        system.assertEquals(1, cvs.size());
    }
    
    @isTest
    private static void getFilesByParentId_TestNoParent() {
        ContentVersionSelector selectorInstance = new ContentVersionSelector();
        list<ContentVersion> cvs = selectorInstance.getFilesByParentId('a1qO000000204umIAA');
        system.assertEquals(0, cvs.size());
    }
    
    @isTest
    private static void getFilesByParentId_TestParent() {
        ContentVersionSelector selectorInstance = new ContentVersionSelector();
        ContentVersion cv = [SELECT id FROM ContentVersion WHERE Title = 'Test Title 1'];
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Open', CloseDate = Date.today().addDays(10));
        insert opp;
        ID cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE id = :cv.id].ContentDocumentID;
        
        ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = opp.id, ContentDocumentId = cdId, ShareType = 'V');
        insert cdl;
        list<ContentVersion> cvs = selectorInstance.getFilesByParentId(opp.ID);
        system.assertEquals(1, cvs.size());
    }
}