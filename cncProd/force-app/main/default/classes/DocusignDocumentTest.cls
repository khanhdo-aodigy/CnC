@isTest
private class DocusignDocumentTest {
	@isTest
    private static void testConstructor() {
        DocusignDocument o = new DocusignDocument('Document', 'pdf', '1');
        system.assertEquals('Document', o.name);
        system.assertEquals('pdf', o.fileExtension);
        system.assertEquals('1', o.documentId);
    }
}