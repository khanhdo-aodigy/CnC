global class ExtractCBSBookingList  implements Schedulable 
{
    global void execute(SchedulableContext ctx)
    {
        getBookingList();
    }
   
    //Creat future call out method for http call    
    @future (callout=true)
    public static void getBookingList()            
    {             
        String FromDate, ToDate;
        string svcctrs;
        string vBType; // 'All';
        string vSCR; 
        string SvcType, IncTx;
        string filterby;  // 'Booking';
   
    	// FromDate and ToDate are same values
    	// Calculated as ToDay + Next Two Working Days.
   
        // Retrieve CBS Booking List Report Parameters values from Custom Metadata      
        CLBLReportParm__mdt BookingParams = [select DeveloperName, BType__c, Service_Centres__c, SCR__c, Last_Sync_Date__c,
                                                 	Incx__c, FilterBy__c, Service_Type__c From CLBLReportParm__mdt 
                                             		where DeveloperName='Booking_List'];
    	
        DateTime StartDate = DateTime.now(); // Datetime.newInstance(2021,01,04,10,0,0);
        Integer NoofDays = 2;
       	DateTime EndDate = BusinessHoursUtility.addWorkingDays(startDate, NoofDays);
        System.debug('End Date ---> ' + EndDate);
        
        FromDate = EndDate.format('yyyy-MM-dd');
		system.debug('From Date-->' + FromDate);
        
        ToDate = FromDate;
		system.debug('To Date-->' + ToDate);
        
        svcctrs = BookingParams.Service_Centres__c;
        vBtype = BookingParams.BType__c;
        vSCR = BookingParams.SCR__c;
        SvcType = BookingParams.Service_Type__c;
        if(SvcType==NULL){SvcType='';}
    	IncTx = BookingParams.Incx__c;
        filterby = BookingParams.FilterBy__c;
        
        /************ Modified by Thu Phan on 03 Feb 2021 ***************/
        Integer NoofRecs;
        if (EndDate <> BookingParams.Last_Sync_Date__c)
        {
            NoofRecs = GetCLBLRecordsBatch.getfromcbsbatch(FromDate, ToDate, svcctrs, vBType, vSCR, SvcType, IncTx, filterby);
        } 
        system.debug('No. of records-->' + NoofRecs);
        if (NoofRecs <> null)
        {
			System.enqueueJob(new CBSUpdateLastSyncDateQueueable(EndDate));
        }
        /*************************** END *****************************/
    }
}