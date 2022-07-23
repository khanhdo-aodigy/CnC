@isTest
private class BulkFileUploadControllerTest {
   
    @isTest(SeeAllData=true) static void testBFUController(){
    
        // Get Files method
        BulkFileUploadController.getFiles();
        
        String path = 'bfu' + '.csv';
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'bfu',   
            PathOnClient = path,
            VersionData = Blob.valueOf(getBlob('bfu')),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
 		// Delete files method
        BulkFileUploadController.deleteFiles(contentVersionSelect.ContentDocumentId); 
        
        // File is already processed - ProcessData method
        	path = 'contacts' + '.csv';
        	contentVersionInsert = new ContentVersion(
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
       
        	contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        
       		try{
           		Integer recsize = BulkFileUploadController.processdata(contentVersionSelect.Id);
       		}catch(Exception e){
          	//throw new AuraHandledException(e.getMessage());
       		}
		
		    // file is empty - ProcessData method
        	path = 'contacts' + '.csv';
        	contentVersionInsert = new ContentVersion(
            	Title = 'contacts',   
            	PathOnClient = path,
            	VersionData = Blob.valueOf(getBlob1('contacts')),
            	IsMajorVersion = true
        	);
        	insert contentVersionInsert;
        
        	contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        
       		try{
           		Integer recsize = BulkFileUploadController.processdata(contentVersionSelect.Id);
       		}catch(Exception e){
          //throw new AuraHandledException(e.getMessage());
       		}    
        

			path = 'contacts' + '.csv';
        	contentVersionInsert = new ContentVersion(
            	Title = 'contacts',   
            	PathOnClient = path,
            	VersionData = Blob.valueOf(getBlob2('contacts')),
            	IsMajorVersion = true
        	);
        	insert contentVersionInsert;
        
        	contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        
       try{
           Integer recsize = BulkFileUploadController.processdata(contentVersionSelect.Id);
       }catch(Exception e){
          //throw new AuraHandledException(e.getMessage());
       }
        
        	path = 'contacts' + '.csv';
        	contentVersionInsert = new ContentVersion(
            	Title = 'contacts',   
            	PathOnClient = path,
            	VersionData = Blob.valueOf(getBlob4('contacts')),
            	IsMajorVersion = true
        	);
        	insert contentVersionInsert;
        
        	contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        
       try{
           Integer recsize = BulkFileUploadController.processdata(contentVersionSelect.Id);
       }catch(Exception e){
          //throw new AuraHandledException(e.getMessage());
       }
        
        // with invalid data
            path = 'contacts' + '.csv';
        	contentVersionInsert = new ContentVersion(
            	Title = 'contacts',   
            	PathOnClient = path,
            	VersionData = Blob.valueOf(getBlob5('contacts')),
            	IsMajorVersion = true
        	);
        	insert contentVersionInsert;
        
        	contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        
      		try{
           		Integer recsize = BulkFileUploadController.processdata(contentVersionSelect.Id);
       		}catch(Exception e){
          		//throw new AuraHandledException(e.getMessage());
       		}
        
        
        // with valid data
        	path = 'contacts' + '.csv';
        	contentVersionInsert = new ContentVersion(
            	Title = 'contacts',   
            	PathOnClient = path,
            	VersionData = Blob.valueOf(getBlob6('contacts')),
            	IsMajorVersion = true
        	);
        	insert contentVersionInsert;
        
        	contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        
       		try{
           		Integer recsize = BulkFileUploadController.processdata(contentVersionSelect.Id);
       		}catch(Exception e){
          	//throw new AuraHandledException(e.getMessage());
      		}
        
      // Invalid mobile, email etc.
          path = 'bulkfile' + '.csv';
        	contentVersionInsert = new ContentVersion(
            	Title = 'bulkfile',   
            	PathOnClient = path,
            	VersionData = Blob.valueOf(getBlob7('bulkfile')),
            	IsMajorVersion = true
        	);
        	insert contentVersionInsert;
        
        	contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        
       try{
           Integer recsize = BulkFileUploadController.processdata(contentVersionSelect.Id);
       }catch(Exception e){
          //throw new AuraHandledException(e.getMessage());
       }
      
        
            path = 'bulkfile' + '.csv';
        	contentVersionInsert = new ContentVersion(
            	Title = 'bulkfile',   
            	PathOnClient = path,
            	VersionData = Blob.valueOf(getBlob8('bulkfile')),
            	IsMajorVersion = true
        	);
        	insert contentVersionInsert;
        
        	contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        
       try{
           Integer recsize = BulkFileUploadController.processdata(contentVersionSelect.Id);
       }catch(Exception e){
          //throw new AuraHandledException(e.getMessage());
       }
        
        
            path = 'bulkfile1' + '.csv';
        	contentVersionInsert = new ContentVersion(
            	Title = 'bulkfile1',   
            	PathOnClient = path,
            	VersionData = Blob.valueOf(getBlob9('bulkfile1')),
            	IsMajorVersion = true
        	);
        	insert contentVersionInsert;
        
        	contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        
    		try{
           		Integer recsize = BulkFileUploadController.processdata(contentVersionSelect.Id);
       		}catch(Exception e){
          	//throw new AuraHandledException(e.getMessage());
       		}  
        
        
        
            path = 'bulkfile1' + '.csv';
        	contentVersionInsert = new ContentVersion(
            	Title = 'bulkfile1',   
            	PathOnClient = path,
            	VersionData = Blob.valueOf(getBlob10('bulkfile1')),
            	IsMajorVersion = true
        	);
        	insert contentVersionInsert;
        
        	contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        
    		try{
           		Integer recsize = BulkFileUploadController.processdata(contentVersionSelect.Id);
       		}catch(Exception e){
          	//throw new AuraHandledException(e.getMessage());
       		} 
      // fetch results method  
        path = 'contacts' + '.csv';
       	contentVersionInsert = new ContentVersion(
            Title = 'contacts',   
            PathOnClient = path,
            VersionData = Blob.valueOf(getBlob('contacts')),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        
       	contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
 		BulkFileUploadController.fetchResults(contentVersionSelect.ContentDocumentId);  
        
    }
    
    
    public static String getBlob(String type){
       //add the other file types sample below
            return 'LEAD SOURCE,FIRST NAME,LAST NAME,MOBILE,EMAIL,MODELS INTERESTED,EVENT DATE,EVENT TIME,BRANCH CODE,PREFERRED SALES CONSULTANT,SHOWROOM,NO OF PAX,EVENT NAME,COMMENTS\nDigital Leads,Lakshmi,lakshmi lN,99999999,gandhalas0044l@gmail.com,a0rp0000000lVTdAAM,13/09/2019,10:00,CCK,,Alexandra,10,701O0000001IenyIAC,TESTING comments'; 
	}

    public static String getBlob1(String type){
       //add the other file types sample below
            return 'LEAD SOURCE,FIRST NAME,LAST NAME,MOBILE,EMAIL,MODELS INTERESTED,EVENT DATE,EVENT TIME,BRANCH CODE,PREFERRED SALES CONSULTANT,SHOWROOM,NO OF PAX,EVENT NAME,COMMENTS'; 
	}
      
    
        public static String getBlob2(String type){
       //add the other file types sample below
            return 'LEAD SOURCE,FIRST NAME,LAST NAME,MOBILE,EMAIL,MODELS INTERESTED,EVENT DATE,EVENT TIME,BRANCH CODE,PREFERRED SALES CONSULTANT,SHOWROOM,NO OF PAX,EVENT NAME,COMMENTS\nDigital Leads,Lakshmi,lakshmi lN,99999999,gandhalasl@gmail.com,a0rp0000000lVTdAAM,13/09/2019,10:00,CCK,demo2@andomdemodomain.com,Alexandra,10,701O0000001IenyIAC,commm\nFacebook,Lakshmi,lakshmi lN,99999999,gandhalasl@gmail.com,a0rp0000000lVTdAAM,13/09/2019,10:00,CCK,demo2@andomdemodomain.com,Alexandra,10,701O0000001IenyIAC,comments22'; 
	}
       public static String getBlob4(String type){
       //add the other file types sample below
            return 'LEAD SOURCE,FIRST NAME,LAST NAME,MOBILE,EMAIL,MODELS INTERESTED,EVENT DATE,EVENT TIME,BRANCH CODE,PREFERRED SALES CONSULTANT,SHOWROOM,NO OF PAX,EVENT NAME,COMMENTS\nDigital Leads,Lakshmi,lakshmi lN,99999999,gandhalasl@gmail.com,a0rp0000000lVTdAAM,13/09/2019,10:00,CCK,,Alexandra,10,701O0000001IenyIAC,comments44\nFacebook,Lakshmi,lakshmi lN,99999999,gandhalasl@gmail.com,a0rp0000000lVTdAAM,13/09/2019,10:00,CCK,christiana.chang=cyclecarriage.com.sg@example.com,Alexandra,10,701O0000001IenyIAC,comments55'; 
	}
    public static String getBlob5(String type){
       //add the other file types sample below
            return 'LEAD SOURCE,FIRST NAME,LAST NAME,MOBILE,EMAIL,MODELS INTERESTED,EVENT DATE,EVENT TIME,BRANCH CODE,PREFERRED SALES CONSULTANT,SHOWROOM,NO OF PAX,EVENT NAME,COMMENTS\n,,,,,,,,CCK,,Alexandra,10,\nFacebook,Lakshmi,lakshmi lN,99999999,gandhalasl@gmail.com,a0rp0000000lVTdAAM,13/09/2019,10:00,,christiana.chang=cyclecarriage.com.sg@example.com,Alexandra,10,701O0000001IenyIAC,comments4455'; 
	}


	public static String getBlob6(String type){
       //add the other file types sample below
       return 'LEAD SOURCE,FIRST NAME,LAST NAME,MOBILE,EMAIL,MODELS INTERESTED,EVENT DATE,EVENT TIME,BRANCH CODE,PREFERRED SALES CONSULTANT,SHOWROOM,NO OF PAX,EVENT NAME,COMMENTS\nChat,namefn,nameln,96741063,gandhalasl@gmail.com,a0rp0000000lVTdAAM,13/9/2019,10:00,CCK,christiana.chang=cyclecarriage.com.sg@example.com,Alexandra,10,701O0000000SJMZIA4,comments\nFacebook,Lakshmi,lakshmi lN,96741063,gandhalasl@gmailcom,a0rp0000000lVTdAAM,12/10/2019,10:00,CCK,christiana.chan111g=cyclecarriage.com.sg@example.com,Alexandra,10,701O0000001IenyIAC,com'; 
	}
    
    public static String getBlob7(String type){
       //add the other file types sample below
      return 'LEAD SOURCE,FIRST NAME,LAST NAME,MOBILE,EMAIL,MODELS INTERESTED,EVENT DATE,EVENT TIME,BRANCH CODE,PREFERRED SALES CONSULTANT,SHOWROOM,NO OF PAX,EVENT NAME,COMMENTS\n,,,9674106,gandhalaslgmailcom,a0rp0000000lVTdAAM,,,,christiana.chang=cyclecarriage.com.sg@example.com,,,701O0000001IenyIAC,yyy\nFacebook,Lakshmi,lakshmi lN,6596741063,gandhalasl@gmailcom,a0rp0000000lVTdAAM,12/10/2019,10:00,CCA,,Alexandra,10,701O0000001IenyIAC,yytt\nFacebook,Lakshmi,lakshmi lN,6596741063,gandhalasl@gmailcom,a0rp0000000lVTdAAM,12/10/2019,10:00,CCK,vinc11e.ng@cyclecarriage.com.sg,Alexandra,10,701O0000001IenyIA,ggg'; 
	}
    
        
    public static String getBlob8(String type){
       //add the other file types sample below
      return 'LEAD SOURCE,FIRST NAME,LAST NAME,MOBILE,EMAIL,MODELS INTERESTED,EVENT DATE,EVENT TIME,BRANCH CODE,PREFERRED SALES CONSULTANT,SHOWROOM,NO OF PAX,EVENT NAME,COMMENTS\n,,,9674106,gandhalaslgmailcom,a0rp0000000lVTdAAM,,,,christiana.chang=cyclecarriage.com.sg@example.com,,,701O0000001IenyIAC,eee\nFacebook,Lakshmi,lakshmi lN,96741063,123499lakshmi122288@yopmail.com,a0rp0000000lVTdAAM,12/10/2019,10:00,CCK,,Alexandra,10,701O0000001IenyIAC,eeeee\nChat,Lakshmi,lakshmi lN,96741063,123499lakshmi122288@yopmail.com,a0rp0000000lVTdAAM,12/10/2019,10:00,CCK,christiana.chang=cyclecarriage.com.sg@example.com,Alexandra,10,701O0000001IenyIAC,eee\nDigital Leads,Lakshmi,lakshmi lN,96741063,123499lakshmi1@yopmail.com,a0rp0000000lVTdAAM,12/10/2019,10:00,CCK,christiana.chang1222=cyclecarriage.com.sg@example.com,Alexandra,10,701O0000001IenyIAC,ee'; 
	}
    
      public static String getBlob9(String type){
       //add the other file types sample below
            return 'LEAD SOURCE,FIRST NAME,LAST NAME,MOBILE,EMAIL,MODELS INTERESTED,EVENT DATE,EVENT TIME,BRANCH CODE,PREFERRED SALES CONSULTANT,SHOWROOM,NO OF PAX,EVENT NAME,COMMENTS\nDigital Leads,Lakshmi,lakshmi lN,99999999,gandhalas00000l@gmail.com,a0rp0000000lVTdAAM,13/09/2019,10:00,CCK,,Alexandra,10,701O0000001IenyIAC,ttt'; 
	}
    
    
      public static String getBlob10(String type){
       //add the other file types sample below
            return 'LEAD SOURCE,FIRST NAME,LAST NAME,MOBILE,EMAIL,MODELS INTERESTED,EVENT DATE,EVENT TIME,BRANCH CODE,PREFERRED SALES CONSULTANT,SHOWROOM,NO OF PAX,EVENT NAME,COMMENTS\nFacebook,Bulk,uploading,99999999,bfu3333@yopmail.com,a0rp0000000lVTfAAM,13/09/2019,10:00,CCK,,Alexandra,10,701O0000000SJMZIA4,rrr\nInstagram,Bulk,Upload Testing,90000000,bfu3333@yopmail.com,a0rp0000000lVTfAAM,10/9/2019,10:00,CCK,,1,1,701O0000000SJMZIA4,rrrr\nFacebook,Bulk,Upload Testing,90000000,bfu3333@yopmail.com,a0rp0000000lVVhAAM,,,CCA,,,701O0000000SJMZIA4,,\nFacebook,Bulk,Upload Testing,90000000,bfu3333@yopmail.com,a0rp0000000lVRJAA2,,,CCF,,,701O0000000SJMZIA4,,'; 
	}

}