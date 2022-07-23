//Apex class for  first serice and appt reminder

global class firstServiceNoticeReminder implements Schedulable
{
    //Variable declaration 
    public static list <Registered_Vehicle__c> firstServiceObj {get;set;}
    public static list <Registered_Vehicle__c> firstServiceNoticeObj {get;set;}
    public static Date today            = date.today();
    public static DateTime todaytime    = datetime.now();
    public static Date passedThreeDays  = today.addDays(-3);
    public static Date nextFourteenDays = today.addDays(14);
    public static Date nextSevenDays    = today.addDays(7);
    public static List <CustomerAlerts__c> customerAlertList  = new  List<CustomerAlerts__c>(); 

    global void execute(SchedulableContext ctx){
        firstServiceNoticeNReminder();
        firstServiceSecondReminder();
    }
    
    //function for first service reminder  
    public static void firstServiceNoticeNReminder()
    {

        Set<String> setServiceCode = new Set<String>();           
        for(Service_Code__mdt scode : [SELECT Service_Description__c FROM Service_Code__mdt])
		{
            setServiceCode.add(scode.Service_Description__c);
        }           

        try
        {
            List <Service_Appointment__c> lstServiceAppt = new  List <Service_Appointment__c>();
            
            //fetching list of all registered vehicle with today or future service appointments    
            lstServiceAppt = [SELECT Registered_Vehicle__c 
                              FROM Service_Appointment__c
                              WHERE Service_Appointment_Date_Time__c >= today
                              AND Action__c != 'Cancel'
                              AND Service_Code__c in: setServiceCode];

            List<String> regNoList = new List<String>();
            for(Service_Appointment__c svcAppt : lstServiceAppt) {
                if( svcAppt.Registered_Vehicle__c != null ) {
                    regNoList.add(svcAppt.Registered_Vehicle__c);  
                }
            }    

            //soql query for first service reminder 3 days after delivery date .          
            firstServiceObj = [SELECT Registration_Number__c, Contact__c , Id, Branch__c, Registered_Date__c, Account__c /** PA MIGRATION : Added Account__c */
                                FROM Registered_Vehicle__c 
                                WHERE Last_Service_Booking_Date__c =:null  
                                AND Registered_Date__c = :passedThreeDays 
                                AND Id NOT IN :regNoList ];
            
            if( firstServiceObj.size()>0 ) 
            {
                for(Registered_Vehicle__c rvc : firstServiceObj)
                {
                    if( (rvc.Branch__c =='CCA' || rvc.Branch__c == 'CCK' ) && (rvc.Registered_Date__c == passedThreeDays ) )
                    {
                        String registrationnumber =  rvc.Registration_Number__c ;
                        //String message = 'The first servicing is due soon for your car '+ registrationnumber +'.';       
                        String message = 'Your car '+ registrationnumber +' is due for its first servicing at 1,000km. Book your appointment for Lubrication (Service A) now!';      
                        CustomerAlerts__c cAlert = new CustomerAlerts__c();
                        cAlert.Name = 'First service notice';
                        cAlert.Alert_Description__c = message ;
                        cAlert.Contact__c           = rvc.Contact__c;  /** PA Migration : To Remove */
                        cAlert.Date__c              = today;
                        cAlert.Datetime__c          = todaytime;
                        cAlert.isAlert__c           = true;
                        cAlert.isPush__c            = true;
                        cAlert.isSMS__c             = false;
                        cAlert.isEmail__c           = false;
                        cAlert.Type__c              = 'First Service';
                        cAlert.SubType__c           = 'Notice';
                        cAlert.Status__c            = 'unread';
                        cAlert.Account__c           = rvc.Account__c;  /** PA Migration : Newly Added */
                        cAlert.Registered_Vehicle__c = rvc.Id ;
                        customerAlertList.add( cAlert );
                    }
                }
            }
            
            //first service notice reminder for 14 days prior first service 
            firstServiceNoticeObj  = [SELECT Registration_Number__c, Contact__c ,Id, Branch__c, Next_Service_Booking_Date__c, Account__c  /** PA MIGRATION : Added Account__c */
                                      FROM Registered_Vehicle__c 
                                      WHERE Last_Service_Booking_Date__c =:null  
                                      AND Next_Service_Booking_Date__c =:nextFourteenDays 
                                      AND Id NOT IN :regNoList];
            
            if(firstServiceNoticeObj.size()>0) 
            {
                for(Registered_Vehicle__c rvc : firstServiceNoticeObj)
                {
                    //Service_Appointment__c theAppointment = new Service_Appointment__c (Registered_Vehicle__c = rvc.Id);
                    //1st first-Servicing Appt Reminder - Alert(app)
                    if( (rvc.Next_Service_Booking_Date__c == nextFourteenDays) && (rvc.Branch__c =='CCA' || rvc.Branch__c == 'CCK' ||  rvc.Branch__c =='CCI' || rvc.Branch__c == 'CCF'))
                    {
                        String registrationnumber =  rvc.Registration_Number__c ;
                        String message = '';
                        if(rvc.Branch__c =='CCI'){
                            message = 'Your car '+ registrationnumber + ' is due for its first servicing in 14 days. Book your appointment for Lubrication Service now!';
                        }
                        else{
                            message = 'Your car '+ registrationnumber + ' is due for its first servicing in 14 days. Book your appointment for Lubrication (Service A) now!';
                        }
                        //String message = 'The first servicing is due in 14 days for your car '+ registrationnumber +'.';
                        CustomerAlerts__c cAlert = new CustomerAlerts__c();
                        cAlert.Name                 = '1st First Servicing Appt Reminder';
                        cAlert.Alert_Description__c = message ;
                        cAlert.Contact__c           = rvc.Contact__c;		/** PA Migration : To Remove */
                        cAlert.Date__c              = today;
                        cAlert.Datetime__c          = todaytime;
                        cAlert.isAlert__c           = true;
                        cAlert.isPush__c            = true;
                        cAlert.isSMS__c             = false;
                        cAlert.isEmail__c           = true;
                        cAlert.Type__c              = 'First Service';
                        cAlert.SubType__c           = 'Due 1st Reminder';
                        cAlert.Status__c            = 'unread';
                        cAlert.Account__c = rvc.Account__c;  /** PA Migration : Newly Added */
                        cAlert.Registered_Vehicle__c = rvc.Id ;
                        customerAlertList.add( cAlert );
                    }  
                }
            } 
            
            //pass customer list to updert function  create customer alert 
            insertCreateCustomerAlert( customerAlertList ) ; 
            
        }
        catch(Exception e)
        {
            loggerDataPool.buildLogDataPool('firstServiceNoticeNReminder', e);
        }
    }
    

    //function for first service second reminder  
    public static void firstServiceSecondReminder()
    {
        Set<String> setServiceCode = new Set<String>();           
        for(Service_Code__mdt scode : [SELECT Service_Description__c FROM Service_Code__mdt])
		{
            setServiceCode.add(scode.Service_Description__c);
        }    

        try
        {
            List <Service_Appointment__c> lstServiceAppt = new  List <Service_Appointment__c>();
            
            //fetching list of all registered vehicle with today or future service appointments             
            lstServiceAppt = [ SELECT Registered_Vehicle__c 
                               FROM Service_Appointment__c 
					           WHERE Service_Appointment_Date_Time__c >= today 
					           AND Action__c != 'Cancel'
					           AND Service_Code__c IN :setServiceCode];						

            List<String> regNoList = new List<String>();
            for(Service_Appointment__c svcAppt:lstServiceAppt) {
                if(svcAppt.Registered_Vehicle__c!=null) {
                    regNoList.add(svcAppt.Registered_Vehicle__c);  
                }        
            }                                          
            
            //Second service notice reminder for 7 days prior first service 
            
            firstServiceNoticeObj  = [SELECT Registration_Number__c, Contact__c ,Id , Branch__c, Next_Service_Booking_Date__c, Account__c /** PA Migration : Added Account__c */
                                      FROM  Registered_Vehicle__c 
                                      WHERE Last_Service_Booking_Date__c =:null 
                                      AND Next_Service_Booking_Date__c =:nextSevenDays 
                                      AND Id NOT IN :regNoList];

            if(firstServiceNoticeObj.size()>0) 
            {
                for(Registered_Vehicle__c rvc : firstServiceNoticeObj)
                {
                    String registrationnumber =  rvc.Registration_Number__c ;
                    //String message = 'The first servicing is due next week for your car '+ registrationnumber +'.';
                    String message = '';
                    if(rvc.Branch__c =='CCI'){
                        message = 'Your car '+ registrationnumber + ' is due for its first servicing next week. Book your appointment for Lubrication Service now!';
                    }
                    else{
                        message = 'Your car '+ registrationnumber + ' is due for its first servicing next week. Book your appointment for Lubrication (Service A) now!';
                    }
                    CustomerAlerts__c cAlert = new CustomerAlerts__c();
                    cAlert.Name                 = '2nd First Servicing Appt Reminder';
                    cAlert.Alert_Description__c = message ;
                    cAlert.Contact__c           = rvc.Contact__c;			/** PA Migration : To Remove */
                    cAlert.Date__c              = today;
                    cAlert.Datetime__c          = todaytime;
                    cAlert.isAlert__c           = true;
                    cAlert.isPush__c            = true;
                    if(rvc.Branch__c == 'CCI') {
                        cAlert.isSMS__c = true;
                    }
                    else {
                        cAlert.isSMS__c = false;
                    }
                    
                    cAlert.isEmail__c           = true;
                    cAlert.Type__c              = 'First Service';
                    cAlert.SubType__c           = 'Due 2nd Reminder';
                    cAlert.Status__c            = 'unread';
                    cAlert.Account__c           = rvc.Account__c;  /** PA Migration : Newly Added */
                    cAlert.Registered_Vehicle__c = rvc.Id ;
                    customerAlertList.add( cAlert );
                }
            } 
            
            //pass customer list to updert function  create customer alert 
            insertCreateCustomerAlert( customerAlertList ) ; 
            
        }
        catch(Exception e)
        {
            loggerDataPool.buildLogDataPool('firstServiceNoticeNReminder', e);
        }
    }
    
    /*
    public static void firstServiceNoticeNReminderTEST()
    {

        Set<String> setServiceCode = new Set<String>();           
        for(Service_Code__mdt scode : [SELECT Service_Description__c FROM Service_Code__mdt])
		{
            setServiceCode.add(scode.Service_Description__c);
        }    

        try
        {
            Set<String> regVehIds = new Set<String>();
           
            for(AlertsRegisteredVehicle__mdt art : [SELECT DeveloperName FROM AlertsRegisteredVehicle__mdt]){
                regVehIds.add(art.DeveloperName);
            }                  
            
            
            List <Service_Appointment__c> tempId = new  List <Service_Appointment__c>();
            
            //fetching list of all registered vehicle with today or future service appointments             
            tempId=[Select Registered_Vehicle__c from Service_Appointment__c 
					where Service_Appointment_Date_Time__c >= today 
					and Action__c != 'Cancel'
					and Service_Code__c in: setServiceCode];

            List<String> regNoList = new List<String>();
            for(Service_Appointment__c svcAppt:tempId) 
            {
                if(svcAppt.Registered_Vehicle__c!=null)
                {
                    regNoList.add(svcAppt.Registered_Vehicle__c);  
                }        
                
            }                                          
            //soql query   for first service reminder  3 days after delivery date .          
           //PA Migration : Newly Added 
            firstServiceObj  = [Select Registration_Number__c,Contact__c ,Id, Branch__c, Registered_Date__c, Account__c
                                from Registered_Vehicle__c where Last_Service_Booking_Date__c=:null  
                                AND Registered_Date__c =:passedThreeDays AND Id NOT in : regNoList AND Name IN: regVehIds];// Id IN: regVehIds];
            
            if(firstServiceObj.size()>0) 
            {
                for(Registered_Vehicle__c rvc : firstServiceObj)
                {
                    
                    if((rvc.Branch__c =='CCA' || rvc.Branch__c == 'CCK' ) && (rvc.Registered_Date__c == passedThreeDays ))
                    {
                        String registrationnumber =  rvc.Registration_Number__c ;
                        //String message = 'The first servicing is due soon for your car '+ registrationnumber +'.';       
                        String message = 'Your car '+ registrationnumber +' is due for its first servicing at 1,000km. Book your appointment for Lubrication (Service A) now!';      
                        CustomerAlerts__c cAlert = new CustomerAlerts__c();
                        cAlert.Name = 'First service notice';
                        cAlert.Alert_Description__c = message ;
                        cAlert.Contact__c = rvc.Contact__c;			// PA Migration : To Remove 
                        cAlert.Date__c = today;
                        cAlert.Datetime__c = todaytime;
                        cAlert.isAlert__c = True;
                        cAlert.isPush__c = True;
                        cAlert.isSMS__c = False;
                        cAlert.isEmail__c = False;
                        cAlert.Type__c = 'First Service';
                        cAlert.SubType__c = 'Notice';
                        cAlert.Status__c = 'unread';
                        cAlert.Registered_Vehicle__c = rvc.Id ;
                        cAlert.Account__c = rvc.Account__c;  //PA Migration : Newly Added 
                        customerAlertList.add(cAlert);
                    }
                }
            }
            // end  
            
            //first service notice reminder for 14 days prior first service 
             //PA Migration : Newly Added 
            firstServiceNoticeObj  = [Select Registration_Number__c,Contact__c ,Id, Branch__c, Next_Service_Booking_Date__c, Account__c from Registered_Vehicle__c where Last_Service_Booking_Date__c=:null  AND  Next_Service_Booking_Date__c =:nextFourteenDays AND Id NOT in : regNoList AND Name IN: regVehIds ];//Id IN: regVehIds];
            if(firstServiceNoticeObj.size()>0) 
            {
                for(Registered_Vehicle__c rvc : firstServiceNoticeObj)
                {
                    //Service_Appointment__c theAppointment = new Service_Appointment__c (Registered_Vehicle__c = rvc.Id);
                    //1st first-Servicing Appt Reminder - Alert(app)
                    if((rvc.Next_Service_Booking_Date__c == nextFourteenDays) && (rvc.Branch__c =='CCA' || rvc.Branch__c == 'CCK' ||  rvc.Branch__c =='CCI' || rvc.Branch__c == 'CCF'))
                    {
                        String registrationnumber =  rvc.Registration_Number__c ;
                        String message = '';
                        if(rvc.Branch__c =='CCI'){
                            message = 'Your car '+ registrationnumber + ' is due for its first servicing in 14 days. Book your appointment for Lubrication Service now!';
                        }else{
                            message = 'Your car '+ registrationnumber + ' is due for its first servicing in 14 days. Book your appointment for Lubrication (Service A) now!';
                        }
                        //String message = 'The first servicing is due in 14 days for your car '+ registrationnumber +'.';
                        CustomerAlerts__c cAlert = new CustomerAlerts__c();
                        cAlert.Name = '1st First Servicing Appt Reminder';
                        cAlert.Alert_Description__c = message ;
                        cAlert.Contact__c = rvc.Contact__c;				//PA Migration : To Remove
                        cAlert.Date__c = today;
                        cAlert.Datetime__c = todaytime;
                        cAlert.isAlert__c = True;
                        cAlert.isPush__c = True;
                        cAlert.isSMS__c = False;
                        cAlert.isEmail__c = True;
                        cAlert.Type__c = 'First Service';
                        cAlert.SubType__c = 'Due 1st Reminder';
                        cAlert.Status__c = 'unread';
                        cAlert.Registered_Vehicle__c = rvc.Id ;
                        cAlert.Account__c = rvc.Account__c;  //PA Migration : Newly Added 
                        customerAlertList.add(cAlert);
                    }  
                }
            } 
            // end 
            
            //pass customer list to updert function  create customer alert 
            insertCreateCustomerAlert(customerAlertList) ; 
            
        }
        catch(Exception e)
        {
            loggerDataPool.buildLogDataPool('firstServiceNoticeNReminder', e);
        }
    }
    */

    //function for first service second reminder  
    /*
    public static void firstServiceSecondReminderTEST()
    {

        Set<String> setServiceCode = new Set<String>();           
        for(Service_Code__mdt scode : [SELECT Service_Description__c FROM Service_Code__mdt])
		{
            setServiceCode.add(scode.Service_Description__c);
        }    
		        
        try
        {
            Set<String> regVehIds = new Set<String>();
           
            for(AlertsRegisteredVehicle__mdt art : [SELECT DeveloperName FROM AlertsRegisteredVehicle__mdt]){
                regVehIds.add(art.DeveloperName);
            }   
            
            List <Service_Appointment__c> tempId = new  List <Service_Appointment__c>();
            
            //fetching list of all registered vehicle with today or future service appointments             
            tempId=[Select Registered_Vehicle__c from Service_Appointment__c 
					where Service_Appointment_Date_Time__c >= today
					and Action__c != 'Cancel'
					and Service_Code__c in: setServiceCode];		

            List<String> regNoList = new List<String>();
            for(Service_Appointment__c svcAppt:tempId) 
            {
                if(svcAppt.Registered_Vehicle__c!=null)
                {
                    regNoList.add(svcAppt.Registered_Vehicle__c);  
                }        
                
            }                                          
            
            //Second service notice reminder for 7 days prior first service 
             //PA Migration : Newly Added 
            firstServiceNoticeObj  = [SELECT Registration_Number__c, Contact__c ,Id, Branch__c, Next_Service_Booking_Date__c, Account__c
                                      FROM Registered_Vehicle__c 
                                      WHERE Last_Service_Booking_Date__c =:null 
                                      AND  Next_Service_Booking_Date__c =:nextSevenDays 
                                      AND Id NOT in : regNoList
                                      AND Name IN: regVehIds];//and id in: regVehIds];
            if(firstServiceNoticeObj.size()>0) 
            {
                for(Registered_Vehicle__c rvc : firstServiceNoticeObj)
                {
                    
                    String registrationnumber =  rvc.Registration_Number__c ;
                    //String message = 'The first servicing is due next week for your car '+ registrationnumber +'.';
                    String message = '';
                    if(rvc.Branch__c =='CCI'){
                        message = 'Your car '+ registrationnumber + ' is due for its first servicing next week. Book your appointment for Lubrication Service now!';
                    }else{
                        message = 'Your car '+ registrationnumber + ' is due for its first servicing next week. Book your appointment for Lubrication (Service A) now!';
                    }
                    CustomerAlerts__c cAlert = new CustomerAlerts__c();
                    cAlert.Name = '2nd First Servicing Appt Reminder';
                    cAlert.Alert_Description__c = message ;
                    cAlert.Contact__c = rvc.Contact__c;			 //PA Migration : To Remove
                    cAlert.Date__c = today;
                    cAlert.Datetime__c = todaytime;
                    cAlert.isAlert__c = True;
                    cAlert.isPush__c = True;
                    if(rvc.Branch__c == 'CCI')
                    {
                        cAlert.isSMS__c = True;
                    }
                    else
                    {
                        cAlert.isSMS__c = False;
                    }
                    
                    cAlert.isEmail__c = True;
                    cAlert.Type__c = 'First Service';
                    cAlert.SubType__c = 'Due 2nd Reminder';
                    cAlert.Status__c = 'unread';
                    cAlert.Registered_Vehicle__c = rvc.Id ;
                    cAlert.Account__c = rvc.Account__c;  //PA Migration : Newly Added 
                    customerAlertList.add(cAlert);
                }
                
            } 
            
            // end 
            
            //pass customer list to updert function  create customer alert 
            insertCreateCustomerAlert(customerAlertList) ; 
            
        }
        catch(Exception e)
        {
            loggerDataPool.buildLogDataPool('firstServiceNoticeNReminder', e);
        }
    }    
    */
    
    
    //function for upsert and create customer alert 
    public static void insertCreateCustomerAlert( List <CustomerAlerts__c> newCustomerAlerts )
    {
        //insert newCustomerAlerts;
        Database.UpsertResult[] results = Database.upsert( newCustomerAlerts );  
        for(Integer index = 0, size = results.size(); index < size; index++) 
        {
            if(results[index].isSuccess()) {
                if(results[index].isCreated()) {
                    System.debug(newCustomerAlerts[index].id +' was created');
                } 
            }
            else {
                system.debug(newCustomerAlerts[index].id +' had error');
            }
        }
    }
    
}