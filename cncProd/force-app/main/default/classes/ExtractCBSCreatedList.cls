global class ExtractCBSCreatedList  implements Schedulable {

     global void execute(SchedulableContext ctx)
    {
        getCreatedList();
    }
   
     //Creat future call out method for http call    
    @future (callout=true)
     public static void getCreatedList()            
    {        
         
    String FromDate, ToDate;
    string svcctrs;
    string vBType; // AndriodApp,iOSApp,Internet;
    string vSCR; 
   	string SvcType, IncTx;
    string filterby;  // 'Create';
   
    	// FromDate and ToDate are same values
    	// Calculated as ToDay - Previous Working Day.
   
        // Retrieve CBS Created List Report Parameters values from Custom Metadata
        
        CLBLReportParm__mdt BookingParams = [select DeveloperName, BType__c, Service_Centres__c, SCR__c, 
                                                 	Incx__c, FilterBy__c, Service_Type__c From CLBLReportParm__mdt 
                                             		where DeveloperName='Created_List'];
    	DateTime StartDate = DateTime.now();
        
        StartDate = StartDate.addDays(-1); // Getting previous day
        
    	DateTime PrvBusinessDtTm = BusinessHoursUtility.getPreviousWorkingDay(StartDate);
        system.debug('Today Date-->' + StartDate.date());
        system.debug('Prev Business Date -->' + PrvBusinessDtTm.date());
        	
		FromDate = PrvBusinessDtTm.format('yyyy-MM-dd');
		system.debug('From Date-->' + FromDate);
        
        ToDate = FromDate;
		system.debug('From Date-->' + ToDate);
        
        svcctrs = BookingParams.Service_Centres__c;
        vBtype = BookingParams.BType__c;
        vSCR = BookingParams.SCR__c;
        SvcType = BookingParams.Service_Type__c;
        if(SvcType==NULL){SvcType='';}
    	IncTx = BookingParams.Incx__c;
        filterby = BookingParams.FilterBy__c;
        
        Integer NoofRecs = GetCLBLRecordsBatch.getfromcbsbatch(FromDate, ToDate, svcctrs, vBType, vSCR, SvcType, IncTx, filterby);
        system.debug('No. of records-->' + NoofRecs);
    }
}