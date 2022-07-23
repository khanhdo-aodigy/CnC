public class GetCLBLRecordsBatch 
{
    Public class BookingList
    {
    	public BookingDtlResponse[] BookingDtlResponse;
    }
    
	class BookingDtlResponse 
    {
		public String recordid;	//150980
		public String RegistrationNo;	//SMD752M
		public String OwnerID;	//221268
		public String CustomerName;	//Allan
		public String MobileNo;	//96283344
		public String BookingType;	//Phone
		public String AppointmentDate;	//2019-01-25T07:30:00
		public String AppointmentTime;	//1/25/2019 7:30:00 AM
		public String ServiceCode;	//GMBNANO
		public String Location;	//MBEL
		public String Remarks;
		public String CSERemarks;
		public String Status;	//Cancelled
		public String DOK;	//0
		public String PKD;	//1
		public String PKDTime;
		public String Mileage;
		public String AdditionalJobsDesc;
		public String CreatedDate;	//2019-01-25T01:41:38
		public String CreatedTime;	//2019-01-25T01:41:38
		public String CreatedBy;	//Mycnc_ios
		public String LastEdittedDate;	//0001-01-01T00:00:00
		public String LastEdittedBy;
		public String LastEdittedTime;	//0001-01-01T00:00:00
		public String PickupLocation;	//38 LORONG 25A GEYLANG CENTRA SUITES 388242
		public String ReturnLocation;
		public String ChassisNo;	//WDD2384422F060893
		public String WIP_NO;
		public String ServiceCategory;	//Grooming
		public String ServiceCodeDesc;	//Mercedes-Benz Paint Protection System
		public String CancelledBy;	//Allan
		public String CancelledDatetime;	//2019-01-25T01:41:54
	}
	
    public static integer getfromcbsbatch(String FromDate, String ToDate, String svcctrs, String vBType, String vSCR, String SvcType, String IncTx, String filterby)
    {    
        List<String> vehicles = new List<String>();
  		List<Case> CaseRecs = new List<Case>();
        
        try 
        {    
            String queueIdCL = [select Id, Name, DeveloperName from Group where Type = 'Queue' and 
                                DeveloperName = 'Unassigned_CL_Queue' Limit 1].Id;
            
            String queueIdUnBL = [select Id, Name, DeveloperName from Group where Type = 'Queue' and 
                                  DeveloperName = 'Unassigned_BL_Queue' Limit 1].Id;
            
            String queueIdBL = [select Id, Name, DeveloperName from Group where Type = 'Queue' and 
                                DeveloperName = 'BL_Pending_SMS_Queue' Limit 1].Id;
            
            HttpRequest req = new HttpRequest();
            HttpResponse resInput = new HttpResponse();
            Http http = new Http();
        
            global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
            String cbsAPIurl = (String)JCC_GlobalVar.APIGateway_url__c;
            String cbsAPIKey = (String)JCC_GlobalVar.APIGateway_key__c;   
       
            req.setHeader('Content-Type', 'application/json');
       
            if(Test.isRunningTest())
            {
                req.setHeader('host', 'api.stg.cyclecarriage.com');   
                req.setHeader('apikey', '9-bMiOlUatsidmlzYSIsIm1hc3RlcmNhcmQiXX1H10JaPE54rGCPzpRFM016pybQvbGk5gOLRkYW15aFaQ14TbF94n5baYBX');
            }
            else
            {
                req.setHeader('host', 'api.cyclecarriage.com'); 
                req.setHeader('apikey', cbsAPIKey);
            }
         
            String requestvar = 'From=' + FromDate + '&' + 
                'To=' + ToDate + '&' + 
                'Svc=' + svcctrs + '&' + 
                'Btype=' + vBType + '&' + 
                'SCR=' + vSCR + '&' + 
                'SvcTy=' + SvcType + '&' + 
                'Incx=' + IncTx + '&' + 
                'filterBy=' + filterby;
            
            string ep = cbsAPIurl+'/CbsBookingsRpt/BookingRptDtls?'+requestvar;
       
            //  string ep = 'https://api.stg.cyclecarriage.com/CbsBookingsRpt/BookingRptDtls?'+requestvar;
            req.setEndpoint(ep);
            req.setTimeout(12000);  
            req.setMethod('GET');
            resInput = http.send(req);
            
            //system.debug('Request...' + req.getBody());
            //system.debug('Response...' + resInput.getBody());
                 
            CaseRecs = ProcessJSONResp(resInput,CaseRecs,filterby,vehicles);
            //system.debug('Request is ' + req);
            //system.debug('Response is ' + resInput);
            ServiceDataPool.buildServiceDataPoolHttp('getfromcbs', 'GetCLBLRecordsBatch', '', req, resInput);
        	    
            if (CaseRecs.size() > 0)
            {
                Map<String, Registered_Vehicle__c> vehIDS = new Map<String, Registered_Vehicle__c>();
                for(Registered_Vehicle__c veh : [Select id, Contact__c, Contact__r.MobilePhone, Registration_Number__c, Franchise__c, Branch__c 
                                                 From Registered_Vehicle__c Where Registration_Number__c In :vehicles]) 
                {
                    vehIDS.put(veh.Registration_Number__c, veh);
                }
                
                for(Integer i = 0; i < CaseRecs.size(); i++)
                {
                    Case SingleCase = CaseRecs[i];
                    
                    if(vehIDS.containsKey(SingleCase.Car_Registration_Number__c))
                    {
                        SingleCase.Registered_Vehicle__c = vehIDS.get(SingleCase.Car_Registration_Number__c).id;
                        SingleCase.ContactId = vehIDS.get(SingleCase.Car_Registration_Number__c).contact__c;  
                        SingleCase.Franchise__c = vehIDS.get(SingleCase.Car_Registration_Number__c).Franchise__c;
                        SingleCase.Branch__c = vehIDS.get(SingleCase.Car_Registration_Number__c).Branch__c;
                        
                        if(SingleCase.Case_Category__c == 'Booking List')
                        {
                            //system.debug('Contact Id-->' + SingleCase.ContactId);
                            SingleCase.OwnerId = queueIdBL;
                            
                            if(SingleCase.ContactId==NULL)	
                            { 
                                SingleCase.OwnerId = queueIdUnBL;  // if no contact    
                                //system.debug('No Contact!');
                            }
                            else
                            {
                                String vMobile = vehIDS.get(SingleCase.Car_Registration_Number__c).contact__r.MobilePhone;  
                                //system.debug('Mobile-->' + vMobile);
                                if(String.IsEmpty(vMobile))
                                {
                                    SingleCase.OwnerId = queueIdUnBL; 
                                    //system.debug('Mobile is Empty!');
                                }
                                else
                                {
                                    Integer vMobileLen = vMobile.length();    
                                    if(vMobileLen!=10)
                                    {    
                                        SingleCase.OwnerId = queueIdUnBL;
                                        //system.debug('Mobile is not 10-digits!');
                                    }else
                                    {
                                        if(vMobileLen==10)
                                        {
                                            //System.debug('Mobile is 10-digits');
                                            String s2 = vMobile.substring(0,2);
                                            if(s2!='65')
                                            {
                                                //system.debug('s2->' + s2);
                                                SingleCase.OwnerId = queueIdUnBL; 
                                                //system.debug('Mobile does not starts with 65');
                                            }
                                            else
                                            {
                                                String s4 = vMobile.substring(2,3);
                                                //system.debug('s4->' + s4);
                                                if(s4!='8' && s4!='9' )
                                                {
                                                    //system.debug('Mobile does not starts with 658/9');
                                                    SingleCase.OwnerId = queueIdUnBL; 
                                                }
                                            } 
                                        } 
                                    }
                                }         
                            }
                        }
                        if(SingleCase.Case_Category__c == 'Created List'){  SingleCase.OwnerId = queueIdCL; }    
                    }
                    
                    if(SingleCase.Registered_Vehicle__c == NULL)
                    {
                        if(SingleCase.Case_Category__c == 'Booking List'){ SingleCase.OwnerId = queueIdUnBL; }
                        if(SingleCase.Case_Category__c == 'Created List'){  SingleCase.OwnerId = queueIdCL; }  
                    }  
                }                    
                
                insert CaseRecs;
                //System.debug(CaseRecs.size());
                return CaseRecs.size();
            }
            else{/*return null;*/return 0;} //Modified by Thu Phan on 03 Feb 2021
        } 
        catch(exception ex1)
        {
            system.debug(ex1.getMessage());
            loggerDataPool.buildLogDataPool('GetCLBLRecordsBatch', ex1);
            return null;
            // throw new AuraHandledException(ex1.getMessage());
        }
    }
   
    public static List<Case> ProcessJSONResp(HttpResponse resInput, List<Case> CaseRecs, String filterby, List<String> vehicles)
    {
        //system.debug('Http Response-->' + resInput);
        //system.debug('Response Body-->'+ resInput.getBody());
        //system.debug('Http Response Status Code-->' + resInput.getStatusCode());
    
        if(resInput.getStatusCode() == 200 && resInput.getBody()!=NULL && resInput.getBody().trim()!='')
        {
            BookingList data =  (BookingList) System.JSON.deserialize(resInput.getBody(), BookingList.class);
            //system.debug('data...' + data);
            
            ID recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Servicing_and_Grooming').getRecordTypeId();
            
            String queueIdBL = [select Id, Name, DeveloperName from Group where Type = 'Queue' and 
                                DeveloperName = 'BL_Pending_SMS_Queue' Limit 1].Id;
            
            String queueIdCL = [select Id, Name, DeveloperName from Group where Type = 'Queue' and 
                                DeveloperName = 'Unassigned_CL_Queue' Limit 1].Id;
                    
            if (data.BookingDtlResponse != NULL)
            {
                for (BookingDtlResponse bkitem : data.BookingDtlResponse)
                {
                    Case SingleCase = New Case();
                    SingleCase.status='Open';
                    SingleCase.Priority='P4';
                    SingleCase.RecordTypeId = recordTypeID;
                
                if (filterby=='Create')
                {
              		SingleCase.Case_Category__c = 'Created List';
                    SingleCase.OwnerId = queueIdCL;
                }
                
          		if(filterby=='Booking')
                {
              		SingleCase.Case_Category__c = 'Booking List';
                    SingleCase.OwnerId = queueIdBL;
               	    SingleCase.SMS_Link_Expired__c=false;
                	SingleCase.SMS_Status__c='Not Sent';
                    SingleCase.SMS_Sent_Date_Time__c = DateTime.now();
                    SingleCase.FranchiseCode__c = 'P';
            	}
                     
               
                if(bkitem.recordid!=null){SingleCase.Booking_ID__c = decimal.valueof(bkitem.recordid);}
                
                if(bkitem.RegistrationNo != null)
                {
                    SingleCase.Car_Registration_Number__c = bkitem.RegistrationNo;
                    SingleCase.Subject = bkitem.RegistrationNo + ' ' + 'Servicing and Grooming';
                   	vehicles.add(bkitem.RegistrationNo);
                }
                
              	if(bkitem.OwnerID != null){SingleCase.CLBLOwnerID__c = bkitem.OwnerID;}
                
                if(bkitem.CustomerName != null)
                {
                    SingleCase.Customer_Name__c = bkitem.CustomerName;
                	//SingleCase.Customer_Name__c = 'BLCL';
                }
                if(bkitem.MobileNo != null){SingleCase.CLBL_Mobile_No__c = bkitem.MobileNo;}
                if(bkitem.BookingType != null){SingleCase.Origin = bkitem.BookingType;}
                
                if(bkitem.AppointmentDate != null)
                { 
                    SingleCase.CLBL_Appointment_Date__c = bkitem.AppointmentDate;                              						
                    SingleCase.Booking_Timestamp__c = bkitem.AppointmentDate;                              
                    SingleCase.Appointment_Date__c = bkitem.AppointmentDate.substring(8, 10) + '/' 
                        														+ bkitem.AppointmentDate.substring(5, 7) + '/' 
																				+ bkitem.AppointmentDate.substring(0, 4);
                      
/*                    SingleCase.Appointment_Date__c = '31'  + '/' +
                        															 bkitem.AppointmentDate.substring(5, 7) + '/' 
																				+ bkitem.AppointmentDate.substring(0, 4); */
				}
                     
                if(bkitem.AppointmentTime != null)
                {
                    SingleCase.CLBL_Appointment_Time__c = bkitem.AppointmentTime;
                    
					for(integer i=0; i<bkitem.AppointmentTime.length(); i++)
                    {
                        string a =bkitem.AppointmentTime.substring(i, i+1);
                        string asubstr;
                        if(string.isBlank(a)==true)
                        {
                            //system.debug('time->' + bkitem.AppointmentTime.substring(i+1, bkitem.AppointmentTime.length()));
                            asubstr = bkitem.AppointmentTime.substring(i+1, bkitem.AppointmentTime.length());
                            
                            integer asubstrLen = asubstr.length();
                            
                            if(asubstrLen==11)
                            {
                                string time1 = asubstr.substring(0,5);
                                string time2 = asubstr.substring(9,11);
                                SingleCase.Appointment_Time__c = time1 + ' ' + time2;
                                break;
                            }
                            
                            if(asubstrLen==10)
                            {
                                string time1 = asubstr.substring(0,4);
                                string time2 = asubstr.substring(8,10);
                                SingleCase.Appointment_Time__c = time1 + ' ' + time2;
                                break;
                            }
                        }
                    }
                }
                if(bkitem.ServiceCode !=null){SingleCase.Service_Code__c = bkitem.ServiceCode;}
                if(bkitem.Location !=null){SingleCase.Location__c = bkitem.Location;}
                if(bkitem.Remarks != null){SingleCase.Customer_Remarks__c = bkitem.Remarks;}
                if(bkitem.CSERemarks != null){SingleCase.CSE_Remarks__c = bkitem.CSERemarks;}
                if(bkitem.Status != null){SingleCase.Booking_Status__c = bkitem.Status;}                   
           		if(bkitem.DOK!=null){SingleCase.DOK__c = bkitem.DOK;}                   
                if(bkitem.PKD!=null){SingleCase.PKD__c = bkitem.PKD;}                   
                if(bkitem.PKDTime!=null){SingleCase.PKD_Time__c = bkitem.PKDTime;}                  
                if(bkitem.Mileage!=null){SingleCase.Mileage__c = Integer.valueof(bkitem.Mileage);}
                if(bkitem.AdditionalJobsDesc!=null){SingleCase.AdditionalJobsDesc__c = bkitem.AdditionalJobsDesc;}                  
                if(bkitem.CreatedDate!=null){SingleCase.CLBL_Created_Date__c = bkitem.CreatedDate;} 
                if(bkitem.LastEdittedDate!=null){SingleCase.CLBL_Created_Time__c = bkitem.CreatedTime;}                   
                if(bkitem.LastEdittedDate!=null){SingleCase.CLBL_Created_By__c = bkitem.CreatedBy;}                    
                if(bkitem.LastEdittedDate!=null){SingleCase.CLBL_Last_Editted_Date__c = bkitem.LastEdittedDate;}                   
                if(bkitem.LastEdittedBy!=null){SingleCase.CLBL_Last_Editted_By__c = bkitem.LastEdittedBy;}                     
                if(bkitem.LastEdittedTime!=null){SingleCase.CLBL_Last_Editted_Time__c = bkitem.LastEdittedTime;}
                if(bkitem.PickupLocation!=null){SingleCase.SCRS_PKD_Pickup_Location__c = bkitem.PickupLocation.toUpperCase();}                  
                if(bkitem.ReturnLocation!=null){SingleCase.SCRS_PKD_Return_Location__c = bkitem.ReturnLocation.toUpperCase();}                 
                if(bkitem.ChassisNo!=null){SingleCase.Chasis_Number__c = bkitem.ChassisNo;}            
                if(bkitem.WIP_NO!=null){SingleCase.WIP_No__c = bkitem.WIP_NO;}                    
                if(bkitem.ServiceCategory!=null){SingleCase.CLBL_Service_Category__c = bkitem.ServiceCategory;}                    
                if(bkitem.ServiceCodeDesc!=null){SingleCase.CLBL_Service_Code_Desc__c = bkitem.ServiceCodeDesc;}                   	
                if(bkitem.CancelledBy!=null){SingleCase.CLBL_Cancelled_By__c = bkitem.CancelledBy;}
                if(bkitem.CancelledDatetime!=null){SingleCase.CLBL_Cancelled_Date_Time__c = bkitem.CancelledDatetime;}          
                     
            	/*if(SingleCase.Booking_ID__c==766754){
                         System.debug('Booking Id->' + SingleCase.Booking_ID__c);
                         CaseRecs.add(SingleCase);
				}
                     
                if(SingleCase.Booking_ID__c==761748){
                    System.debug('Booking Id->' + SingleCase.Booking_ID__c);
                    CaseRecs.add(SingleCase);
                }  */
    
                CaseRecs.add(SingleCase);
               
                }
            }
        }
        
        return CaseRecs;
    }
}