public class GetCLBLRecords {   
   
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
	
 
    @Auraenabled
    public static integer getfromcbs(String FromDate, String ToDate, String svcctrs, String vBType1, String vBType2, String vBType3, String vBType4, String vSCR, String SvcType, String IncTx, String filterby)
    {    
        List<String> vehicles = new List<String>();
  		List<Case> CaseRecs = new List<Case>();
        List<String> values = New List<String>();
        List<HttpRequest> reqlist = New List<HttpRequest>();
        List<HttpResponse> reslist = New List<HttpResponse>();

        try 
        {                  
            values.add(vBType1);
			values.add(vBType2); 
			values.add(vBType3); 
			values.add(vBType4);
            system.debug(values);
            
           for (string val:values)
		   {
            	String vBType = val;      
               	system.debug(val);    
               	if(val != NULL && val != '')
				{
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
                	System.debug('Request: ' + requestvar);
       		 	 	string ep = cbsAPIurl+'/CbsBookingsRpt/BookingRptDtls?'+requestvar;
                
     			 	//string ep = 'https://api.stg.cyclecarriage.com/CbsBookingsRpt/BookingRptDtls?'+requestvar;
					req.setEndpoint(ep);
					req.setTimeout(12000);  
					req.setMethod('GET');
					resInput = http.send(req);
                 
					system.debug('Request...' + req.getBody());
					system.debug('Response...' + resInput.getBody());
                 
               	 	CaseRecs = ProcessJSONResp(resInput,CaseRecs,filterby,vehicles);
                
					reqlist.add(req);
					reslist.add(resInput);
				}
			}           
            
			for (Integer i=0; i< reqlist.size(); i++)
			{
				system.debug('Request is ' + reqlist[i]);
				system.debug('Response is ' + reslist[i]);
				ServiceDataPool.buildServiceDataPoolHttp('getfromcbs', 'GetCLBLRecords', '', reqlist[i], reslist[i]);
			}
                          
            if (CaseRecs.size() > 0)
			{
                Map<String, Registered_Vehicle__c> vehIDS = new Map<String, Registered_Vehicle__c>();
				for(Registered_Vehicle__c veh : [Select id, Contact__c,Registration_Number__c, Franchise__c, Branch__c From Registered_Vehicle__c Where Registration_Number__c In :vehicles]) 
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
					}
				}

				insert CaseRecs;
				System.debug(CaseRecs.size());
				return CaseRecs.size();
			}
			else {return null;}
        } 
		catch(exception ex1)
        {
            system.debug(ex1.getMessage());
           	loggerDataPool.buildLogDataPool('GetCLBLRecords', ex1);
            throw new AuraHandledException(ex1.getMessage());
        }
    }
   
	public static List<Case> ProcessJSONResp(HttpResponse resInput, List<Case> CaseRecs, String filterby, List<String> vehicles)
	{
		if(resInput.getStatusCode() == 200 && resInput.getBody()!=NULL && resInput.getBody().trim()!='')
		{
			BookingList data =  (BookingList) System.JSON.deserialize(resInput.getBody(), BookingList.class);
			system.debug('data...' + data);
			ID recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Servicing_and_Grooming').getRecordTypeId();
				
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
					}
					
					if(filterby=='Booking')
					{
						SingleCase.Case_Category__c = 'Booking List';
					}
				
					if(bkitem.recordid!=null) {SingleCase.Booking_ID__c = decimal.valueof(bkitem.recordid);}
					
					if(bkitem.RegistrationNo != null)
					{
						SingleCase.Car_Registration_Number__c = bkitem.RegistrationNo;
						SingleCase.Subject = bkitem.RegistrationNo + ' ' + 'Servicing and Grooming';
						vehicles.add(bkitem.RegistrationNo);
					}
					
					if(bkitem.OwnerID != null){SingleCase.CLBLOwnerID__c = bkitem.OwnerID;}
					if(bkitem.CustomerName != null){SingleCase.Customer_Name__c = bkitem.CustomerName;}
					if(bkitem.MobileNo != null){SingleCase.CLBL_Mobile_No__c = bkitem.MobileNo;}
					if(bkitem.BookingType != null){SingleCase.Origin = bkitem.BookingType;}
					if(bkitem.AppointmentDate != null){ SingleCase.CLBL_Appointment_Date__c = bkitem.AppointmentDate;
													SingleCase.Booking_Timestamp__c = bkitem.AppointmentDate;}
					if(bkitem.AppointmentTime != null){SingleCase.CLBL_Appointment_Time__c = bkitem.AppointmentTime;}
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
					if(bkitem.PickupLocation!=null){SingleCase.SCRS_PKD_Pickup_Location__c = bkitem.PickupLocation;}                  
					if(bkitem.ReturnLocation!=null){SingleCase.SCRS_PKD_Return_Location__c = bkitem.ReturnLocation;}                 
					if(bkitem.ChassisNo!=null){SingleCase.Chasis_Number__c = bkitem.ChassisNo;}            
					if(bkitem.WIP_NO!=null){SingleCase.WIP_No__c = bkitem.WIP_NO;}                    
					if(bkitem.ServiceCategory!=null){SingleCase.CLBL_Service_Category__c = bkitem.ServiceCategory;}                    
					if(bkitem.ServiceCodeDesc!=null){SingleCase.CLBL_Service_Code_Desc__c = bkitem.ServiceCodeDesc;}                   	
					if(bkitem.CancelledBy!=null){SingleCase.CLBL_Cancelled_By__c = bkitem.CancelledBy;}
					if(bkitem.CancelledDatetime!=null){SingleCase.CLBL_Cancelled_Date_Time__c = bkitem.CancelledDatetime;}          
					
					CaseRecs.add(SingleCase);				
				}
			}
		}
		
		return CaseRecs;
	}
}