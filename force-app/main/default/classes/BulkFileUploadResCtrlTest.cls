@IsTest
private class BulkFileUploadResCtrlTest {

     public static String getBlob(String type){
       //add the other file types sample below
            return 'LEAD SOURCE,FIRST NAME,LAST NAME,MOBILE,EMAIL,MODELS INTERESTED,EVENT DATE,EVENT TIME,BRANCH CODE,PREFERRED SALES CONSULTANT,SHOWROOM,NO OF PAX,EVENT NAME\nDigital Leads,Lakshmi,lakshmi lN,99999999,gandhalas00000l@gmail.com,a0rp0000000lVTdAAM,13/09/2019,10:00,CCK,,Alexandra,10,701O0000001IenyIAC'; 
	}
    
     @isTest
     private static void testgetResults(){
         try{
             String path = 'contacts' + '.csv';
        	 ContentVersion contentVersionInsert = new ContentVersion(
            	Title = 'contacts',   
            	PathOnClient = path,
            	VersionData = Blob.valueOf(getBlob('contacts')),
            	IsMajorVersion = true
        	);
        	insert contentVersionInsert;
        
       		BulkFileUpload__c s = new BulkFileUpload__c();  
            s.DocumentId__c = contentVersionInsert.Id;
            s.Type__c = 'S';
            insert s;	
         	bulkfileuploadResController.getResults(s.DocumentId__c);     
         }catch(Exception e){
             throw new AuraHandledException(e.getMessage());
         }
     }
    
}