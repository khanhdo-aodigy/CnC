public class BulkFileUploadController {

	@AuraEnabled  
    public static List<ContentDocument> getFiles(){ 
        return [SELECT Id,Title,LatestPublishedVersionId, CreatedDate, LastModifiedDate, FileType FROM ContentDocument where FileType='CSV' order by CreatedDate];  
    } 
    
    @AuraEnabled  
    public static void deleteFiles(string sdocumentId){ 
        delete [SELECT Id,Title,FileType from ContentDocument WHERE id=:sdocumentId];       
    } 
    
    @AuraEnabled
    public static Integer processdata(Id sversionId)
    {
    	try{
        	ContentVersion cv = [Select Id, Title, VersionData From ContentVersion Where Id = :sversionId];
       		
        	List<BulkFileUpload__c> bfu = [select DocumentId__c FROM BulkFileUpload__c WHERE DocumentId__c =:cv.Id AND Type__c='S' LIMIT 1];
        	if(bfu.size()==1){
          		String errMsg = 'The Selected File was Already Processed';
            	AuraHandledException e = New AuraHandledException(errMsg);
            	e.setMessage(errMsg);
            	throw e;    
        	}
            
            List<BulkFileUpload__c> BulkrecsToCreate = new List<BulkFileUpload__c>();
        	Blob cvFileBody = cv.VersionData;
        	String cvFileBodyAsString = cvFileBody.toString();
        	String[] cvFileLines = cvFileBodyAsString.split('\n');
        	System.debug(cvFileLines.size());
        	if(cvFileLines.size()==1){
                String errMsg = 'The Selected File is Empty';
                AuraHandledException e = New AuraHandledException(errMsg);
                e.setMessage(errMsg);
            	throw e;
        	}
            
            if(cvFileLines.size()>1)
            {
                Integer FailedRecs = 0;
       			Integer OKRecs = 0;
                Integer TotalNoofRecs = cvFileLines.size()-1; // Exclude header record
                
                // Process the content here
                for(Integer i = 0; i < cvFileLines.size(); i++) 
                {
                	system.debug(cvFileLines[i]);
                	if (i!=0)
                	{                  
                        Boolean errLeadSource=false;
                   		Boolean errFirstName = false;
                    	Boolean errLastName=false;
                    	Boolean errMobile=false;
			        	Boolean errEmail=false;
 						Boolean errEventName=false;
                    	Boolean errEventDate=false;
                    	Boolean errEventTime=false;
                    	Boolean errBranchCode = false;
                    
                    	String Col0Err='';
                    	String Col1Err='';
                    	String Col2Err='';
                    	String Col3Err='';
                    	String Col4Err='';
                    	String Col6Err='';
                    	String Col7Err='';
                    	String Col12Err='';
                    	String Col8Err='';
                    	
                        BulkFileUpload__c c = new BulkFileUpload__c();
                    	String[] cvRecordData = cvFileLines[i].split(','); 
                    	system.debug(cvRecordData);
					
                    	c.documentId__c = cv.Id; 
                        c.Document_Name__c = cv.Title;
                    
                    	// validate each column value ---
   						// Column 1 - Lead Source is required
                    	if ( String.isBlank(cvRecordData[0]) ){
        			   	 errLeadSource=true;
                       	 Col0Err = 'Lead Source is required';
                    	}else{
                        	c.Lead_Source__c = cvRecordData[0];
                         }
                        
                    // Column 2 - First Name is required
        				if ( String.isBlank(cvRecordData[1]) ){
            				errFirstName=true;
                        	Col1Err = 'First Name is required';
                    	}else{c.First_Name__c = cvRecordData[1];}
                    
                    // Column 3 - Last Name is required
        				if ( String.isBlank(cvRecordData[2]) ){
            				errLastName=true;
                       		Col2Err = 'Last Name is required';
                    	}else{c.Last_Name__c = cvRecordData[2];}
                    
                    // Column 4 - Mobile is required
                    	if( String.isBlank(cvRecordData[3]) ){
        			    	errMobile = true;
                        	Col3Err = 'Mobile Number is Required';
		        		}else if( cvRecordData[3].length() < 8){
            				errMobile = true;
                        	Col3Err = 'Invalid Mobile Number';
                    	} else if( String.isNotBlank(cvRecordData[3]) ){
       				     //append 65 if do not have
            			if(!cvRecordData[3].startsWith('65')){
                			c.Mobile__c = '65' + cvRecordData[3];
                        }else{c.Mobile__c = cvRecordData[3];}
                     	} 
                        
                    // Column 5 - Email is required
                    	if ( String.isBlank(cvRecordData[4]) ){
            				errEmail=true;
                        	Col4Err = 'Email Address is required';
        				}else{
            			//Updated Regex for Email Address Checking
            			if(!Pattern.matches('^([0-9a-zA-Z+_.-]*[0-9a-zA-Z]+[@][0-9a-zA-Z+_.-]+\\.[0-9a-zA-Z+_.-]*)$', cvRecordData[4])){
                			errEmail=true;
                			Col4Err = 'Invalid Email Address';
                        }else{c.Email__c = cvRecordData[4];}
			        	}
                                        
       				// Column 6 - Models Interested 
        				if ( !String.isBlank(cvRecordData[5]) ){
            				c.Models_Interested__c = cvRecordData[5];	
        				}
                        
                    // Column 13 - Event Name is required
                           if ( !String.isBlank(cvRecordData[12]) ){
                        		c.Event_Name__c = cvRecordData[12];
                           }

                        if(c.Event_Name__c<>NULL){
                    	// Column 7 - Event Date 
        				//	if ( String.isBlank(cvRecordData[6]) ){
                    	//		errEventDate=true;
                       	//		Col6Err = 'Event Date is required';
                	    //	}else{c.Event_Date__c = cvRecordData[6];
                        //        c.EventDate__c = Date.parse(cvRecordData[6]);}
                                          
                            if ( !String.isBlank(cvRecordData[6]) ){
                                c.Event_Date__c = cvRecordData[6];
                                c.EventDate__c = Date.parse(cvRecordData[6]);
                            	}
                        // Column 8 - Event Time 
        				//if ( String.isBlank(cvRecordData[7]) ){
                    	//	errEventTime=true;
                       	//	Col7Err = 'Event Time is required';	
                        //}else{c.Event_Time__c = cvRecordData[7];}	
                        	if ( !String.isBlank(cvRecordData[7]) ){
        						c.Event_Time__c = cvRecordData[7];
                        	}
                            
                    	// Column 11 - Showroom
							if ( !String.isBlank(cvRecordData[10]) ){
                            	c.Showroom__c = cvRecordData[10];
                            }
        
                    	// Column 12 - No of Pax
                    		if ( !String.isBlank(cvRecordData[11]) ){
								c.No_of_Pax__c = cvRecordData[11];
                            }
                    	}
        
                     // Column 9 - Branch Code 
        				if ( String.isBlank(cvRecordData[8]) ){
                    		errBranchCode = true;
                       		Col8Err = 'Branch Code is required';
                        }else{c.Branch_Code__c = cvRecordData[8];}
        
                    // Column 10 - Preferred Sales Consultant
        				if ( !String.isBlank(cvRecordData[9]) ){
                    		c.Preferred_Sales_Consultant__c = cvRecordData[9];
        				}
                    
                    // Column 14 - Comments
                        if ( !String.isBlank(cvRecordData[13]) ){
                        		c.Comments__c = cvRecordData[13];
                           }
                
					System.debug('Size +++ ' + cvRecordData.size());
					if(cvRecordData.size()>14)
					{
						// Column 15 - PDPA Email
							if (string.valueOf(cvRecordData[14]).contains('1')){
                        			c.isEmail__c = true;
							   }
						// Column 16 - PDPA SMS
							if (string.valueOf(cvRecordData[15]).contains('1')){
                        			c.sms__c = true;
							   }
						// Column 17 - PDPA Call
							if (string.valueOf(cvRecordData[16]).contains('1')){
                        			c.Call__c = true;
							   }
						// Column 18 - PDPA Fax
							if (string.valueOf(cvRecordData[17]).contains('1')){
                        			c.Fax__c = true;
							   }	
					}					   						   						   				        
					
                    // Any error with uploaded data...
                    if (errLeadSource || errFirstName || errLastName || errMobile || errEmail || errBranchCode)
                    {
                        String nullString = NUll;
                        String[] stringsToConcat = New String[]{Col0Err, nullString, Col1Err, nullString, Col2Err, nullString, Col3Err, nullString, Col4Err, nullString, Col8Err};
   
                        String joinedText = String.join(stringsToConcat, ' ');    
                        c.Reason__c = joinedText;
                        c.Status__c = 'F';                        
                        BulkrecsToCreate.add(c);
                        FailedRecs = FailedRecs + 1;
                        //process next record
                    }
                    else
                    {
                        c.Status__c = 'O';                        
                        BulkrecsToCreate.add(c);
                        OKRecs = OKRecs + 1;
                    }
                 }
                }

                if(BulkrecsToCreate.size()>0){
                    insert BulkrecsToCreate;
                    
                    // Inserting the summary record
                    BulkFileUpload__c s = new BulkFileUpload__c();  
                	s.DocumentId__c = cv.Id;
                	s.Type__c = 'S';
                	s.Total_No_of_Recs__c = TotalNoofRecs;
                	s.No_of_Recs_Failed__c = FailedRecs;
                	s.No_of_OK_Records__c = OKRecs;
                	insert s;
                    
                    // All OK Records for batch job
                    List<BulkFileUpload__c> listBFU = [Select Id, Branch_Code__c, Name, DocumentId__c, 
                                                       Email__c, EventDate__c, Event_Name__c, Event_Time__c,
                                                       First_Name__c, Last_Name__c, Lead_Source__c, Mobile__c,
                                                       Models_Interested__c, No_of_Pax__c, Preferred_Sales_Consultant__c,
                                                       Showroom__c,Comments__c, isEmail__c, SMS__c,Fax__c, Call__c
                                                       from BulkFileUpload__c 
                                                       where DocumentId__c =:cv.Id AND Status__c='O'];
                    system.debug('List BFU' + listBFU);
                   	Database.executeBatch(new BFUBatchUpdate(listBFU, cv.Id), 10);
                	return listBFU.size();
                }
            } 
            return Null;
        }catch(Exception e){throw new AuraHandledException(e.getMessage());}
        
        
    }    
        
    
//   public static void executeBatch(List<BulkFileUpload__c> listBFU) {
    //    Database.executeBatch(new BFUBatchUpdate(listBFU), 200);
  // }

    @AuraEnabled  
    public static List<BulkFileUpload__c> fetchResults(string sdocumentId){ 
        List<BulkFileUpload__c> bfuList = New List<BulkFileUpload__c>();
         bfuList = [SELECT DocumentId__c, Name, Lead_Source__c, First_Name__c, Last_Name__c, Mobile__c, Email__c,
                    Models_interested__c, Event_Date__c, Event_Time__c, Branch_Code__c, Preferred_Sales_Consultant__c,
                    Showroom__c, No_of_Pax__c, Event_Name__c, Reason__c, Comments__c,isEmail__c, SMS__c,Fax__c, Call__c
                    FROM BulkFileUpload__c 
                    where Type__c<>'S' 
                    AND DocumentID__c=:sdocumentId 
                    AND Status__c='F'];
        system.debug(bfuList);
        return bfuList;
    } 
    
    
}