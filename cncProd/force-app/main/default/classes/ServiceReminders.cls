global class ServiceReminders implements Schedulable{
    //void execute method
    global void execute (SchedulableContext ctx){   
        ServiceReminders.serviceReminders(); 
    } 
    static  List <CustomerAlerts__c> customerAlerts  = new  List<CustomerAlerts__c>();   
    static Date today = date.today();
    static Datetime todaytime       = datetime.now(); 
    public static Date yesterday    = today.addDays(-1);
    public static Date before10days = today.addDays(-10);
    public static Date before30days = today.addDays(-30);
    public static Date before60days = today.addDays(-60) ;
    public static Date next14days   = today.addDays(14) ;
    public static Date next1week    = today.addDays(7) ;
    
    public static void serviceReminders()
    {   
        Set<String> setServiceCode = new Set<String>();           
        for(Service_Code__mdt scode : [SELECT Service_Description__c FROM Service_Code__mdt])
        {
            setServiceCode.add(scode.Service_Description__c);
        }    
        
        try {
            //Return list of all booked Services which are before today
            List <Service_Appointment__c> tempIdO = new  List <Service_Appointment__c>();
            tempIdO =[SELECT Registered_Vehicle__c 
                      FROM Service_Appointment__c 
                      WHERE Service_Appointment_Date_Time__c >= today
                      AND Action__c != 'Cancel'
                      AND Service_Code__c IN: setServiceCode];	
            
            List<String> regNoList = new List<String>();
            for(Service_Appointment__c rv:tempIdO) {
                if( rv.Registered_Vehicle__c != null ){
                    regNoList.add(rv.Registered_Vehicle__c); 
                }        
            }
            
            
            List <Registered_Vehicle__c> registeredVehicle  = new  List<Registered_Vehicle__c>(); 
            // List of registeredVehicle data
            registeredVehicle  = [SELECT Last_Service_Booking_Date__c,Branch__c,Id,Name,Registration_Number__c , Next_Service_Booking_Date__c, 
                                        Contact__c, Account__c 
                                  FROM Registered_Vehicle__c 
                                  WHERE ( Next_Service_Booking_Date__c = :yesterday OR 
                                          Next_Service_Booking_Date__c = :before10days OR 
                                          Next_Service_Booking_Date__c = :before30days OR 
                                          Next_Service_Booking_Date__c = :before60days)
                                  AND Last_Service_Booking_Date__c = null 
                                  AND Id NOT IN : regNoList];

            if(registeredVehicle.size()>0)
            {
                for(Registered_Vehicle__c rvcOverDue : registeredVehicle)
                {
                    //if the first service is overdue by 1 day for all commercials - 1st reminder
                    if (rvcOverDue.Next_Service_Booking_Date__c==yesterday)
                    {
                        CustomerAlerts__c cAlert = new CustomerAlerts__c();
                        cAlert.Name = '1st Service Overdue 1st Reminder';
                        if(rvcOverDue.Branch__c =='CCI'){
                            cAlert.Alert_Description__c = 'Your car '+ rvcOverDue.Registration_Number__c + ' is overdue for its first servicing. Book your appointment for Lubrication Service now!';
                        }
                        else{
                            cAlert.Alert_Description__c = 'Your car '+ rvcOverDue.Registration_Number__c + ' is overdue for its first servicing. Book your appointment for Lubrication (Service A) now!';    
                        }
                        cAlert.Contact__c        = rvcOverDue.Contact__c;            
                        cAlert.Account__c        = rvcOverDue.Account__c;	 
                        cAlert.Date__c           = today;
                        cAlert.Datetime__c       = todaytime;
                        cAlert.Status__c         = 'unread';
                        cAlert.Registered_Vehicle__c = rvcOverDue.Id;
                        cAlert.isAlert__c        = true;
                        cAlert.isPush__c         = false;
                        cAlert.isSMS__c          = true;
                        cAlert.isEmail__c        = false;
                        cAlert.Type__c           = 'First Service';
                        cAlert.SubType__c        = 'Overdue 1st Reminder';
                        
                        customerAlerts.add(cAlert);
                    }
                    //commented the below portion as this is added in 30days message - 11/6/2019
                    //if the first service is overdue by 10 days for MB - 2nd reminder
                    else if (rvcOverDue.Next_Service_Booking_Date__c==before10days && rvcOverDue.Branch__c =='CCI'){
                        CustomerAlerts__c cAlert = new CustomerAlerts__c();
                        cAlert.Name              = '1st Service Overdue 2nd Reminder after 10days';
                        cAlert.Alert_Description__c = 'Your car '+ rvcOverDue.Registration_Number__c + ' is 10 days overdue for its first servicing. Book your appointment for Lubrication Service now!';
                        cAlert.Contact__c        = rvcOverDue.Contact__c;            
                        cAlert.Account__c        = rvcOverDue.Account__c;	 
                        cAlert.Date__c           = today;
                        cAlert.Datetime__c       = todaytime;
                        cAlert.Status__c         = 'unread';
                        cAlert.Registered_Vehicle__c = rvcOverDue.Id;
                        cAlert.isAlert__c        = true;
                        cAlert.isPush__c         = false;
                        cAlert.isSMS__c          = true;
                        cAlert.isEmail__c        = false;
                        cAlert.Type__c           = 'First Service';
                        cAlert.SubType__c        = 'Overdue 2nd Reminder';
                        
                        customerAlerts.add(cAlert);
                    }
                    //if the first service is overdue by 30 days for Mitsubishi and Kia - 2nd reminder  
                    //added citreon with KIA and MIT as a 30 days 2nd reminder - 11/6/2019
                    else if (rvcOverDue.Next_Service_Booking_Date__c==before30days && (rvcOverDue.Branch__c =='CCA' || rvcOverDue.Branch__c =='CCK' /*|| rvcOverDue.Branch__c =='CCI'*/)){
                        CustomerAlerts__c cAlert = new CustomerAlerts__c();
                        cAlert.Name                 = '1st Service Overdue 2nd Reminder after 30days';
                        cAlert.Alert_Description__c = 'Your car '+ rvcOverDue.Registration_Number__c + ' is 1 month overdue for its first servicing. Book your appointment for Lubrication (Service A) now!';
                        cAlert.Contact__c           = rvcOverDue.Contact__c;         
                        cAlert.Account__c           = rvcOverDue.Account__c;	 
                        cAlert.Date__c              = today;
                        cAlert.Datetime__c          = todaytime;
                        cAlert.Status__c            = 'unread';
                        cAlert.Registered_Vehicle__c = rvcOverDue.Id;
                        cAlert.isAlert__c           = true;
                        cAlert.isPush__c            = false;
                        cAlert.isSMS__c             = true;
                        cAlert.isEmail__c           = false;
                        cAlert.Type__c              = 'First Service';
                        cAlert.SubType__c           = 'Overdue 2nd Reminder';
                        
                        customerAlerts.add(cAlert);
                    }
                    //if the service is overdue by 60 days for Citroen - 2nd reminder 
                    else if (rvcOverDue.Next_Service_Booking_Date__c==before60days && rvcOverDue.Branch__c =='CCF'){
                        CustomerAlerts__c cAlert = new CustomerAlerts__c();
                        cAlert.Name                 = '1st Service Overdue 2nd Reminder after 60days';
                        cAlert.Alert_Description__c = 'Your car '+ rvcOverDue.Registration_Number__c+'is 1 month overdue for its first servicing. Book your appointment for Lubrication (Service A) now!';
                        cAlert.Contact__c           = rvcOverDue.Contact__c;         
                        cAlert.Account__c           = rvcOverDue.Account__c;	 
                        cAlert.Date__c              = today;
                        cAlert.Datetime__c          = todaytime;
                        cAlert.Status__c            = 'unread';
                        cAlert.Registered_Vehicle__c = rvcOverDue.Id;
                        cAlert.isAlert__c           = true ;
                        cAlert.isPush__c            = false;
                        cAlert.isSMS__c             = true;
                        cAlert.isEmail__c           = false;
                        cAlert.Type__c              = 'First Service';
                        cAlert.SubType__c           = 'Overdue 2nd Reminder';
                        
                        customerAlerts.add(cAlert);
                    }
                }               
            }   
            
            List <Registered_Vehicle__c> RegisteredVehicle1  = new  List<Registered_Vehicle__c>(); 
            // List of RegisteredVehicle data
            RegisteredVehicle1  = [SELECT Last_Service_Booking_Date__c, Branch__c, Id, Name, Registration_Number__c , Next_Service_Booking_Date__c, 
                                        Contact__c, Account__c
                                   FROM Registered_Vehicle__c 
                                   WHERE ( Next_Service_Booking_Date__c = :next14days OR Next_Service_Booking_Date__c = :next1week ) 
                                   AND Last_Service_Booking_Date__c != Null 
                                   AND Id NOT IN : regNoList];

            if(RegisteredVehicle1.size()>0){
                for(Registered_Vehicle__c rvcDue : RegisteredVehicle1)
                {   
                    
                    //if the subsequent service is due by 14 days - 1st reminder
                    if (rvcDue.Next_Service_Booking_Date__c==next14days ){
                        CustomerAlerts__c cAlert = new CustomerAlerts__c();
                        cAlert.Name                 = 'Subsequent Service Due 1st Reminder';
                        cAlert.Alert_Description__c = 'Your car '+ rvcDue.Registration_Number__c +' is due for servicing in 14 days. Check your servicing info and book your appointment now!';
                        cAlert.Contact__c           = rvcDue.Contact__c;
                        cAlert.Account__c           = rvcDue.Account__c;	 
                        cAlert.Date__c              = today;
                        cAlert.Datetime__c          = todaytime;
                        cAlert.Status__c            = 'unread';
                        cAlert.Registered_Vehicle__c = rvcDue.Id;
                        cAlert.isAlert__c           = true;
                        cAlert.isPush__c            = true;
                        cAlert.isSMS__c             = false;
                        cAlert.isEmail__c           = true;
                        cAlert.Type__c              = 'Subsequent Service';
                        cAlert.SubType__c           = 'Due 1st Reminder';
                        
                        customerAlerts.add(cAlert);
                    }
                    //if the subsequent service is due by 7 days- 2nd reminder
                    else if (rvcDue.Next_Service_Booking_Date__c==next1week ){
                        CustomerAlerts__c cAlert = new CustomerAlerts__c();
                        cAlert.Name = 'Subsequent Service Due 2nd Reminder';
                        cAlert.Alert_Description__c = 'Your car '+ rvcDue.Registration_Number__c+' is due for servicing next week. Check your servicing info and book your appointment now!';
                        cAlert.Contact__c           = rvcDue.Contact__c;         
                        cAlert.Account__c           = rvcDue.Account__c;	 
                        cAlert.Date__c              = today;
                        cAlert.Datetime__c          = todaytime;
                        cAlert.Status__c            = 'unread';
                        cAlert.Registered_Vehicle__c = rvcDue.Id;
                        cAlert.isAlert__c           = true;
                        cAlert.isPush__c            = true;   
                        cAlert.isEmail__c           = true;
                        cAlert.Type__c              = 'Subsequent Service';
                        cAlert.SubType__c           = 'Due 2nd Reminder';
                        
                        if(rvcDue.Branch__c == 'CCI') {
                            cAlert.isSMS__c = true;
                        }
                        else {
                            cAlert.isSMS__c = false;
                        }
                        
                        customerAlerts.add(cAlert);
                    }
                }                    
            }

            //Insert Alert List in Database
            Database.UpsertResult[] results = Database.upsert(customerAlerts);         
            for(Integer index = 0, size = results.size(); index < size; index++) 
            {
                if(results[index].isSuccess()) {
                    if(results[index].isCreated()) {
                        System.debug(customerAlerts[index].id +' was created');
                    } 
                }
                else {
                    System.debug(customerAlerts[index].id +' had error');
                }
            }
        }   
        catch (Exception e)
        {
            loggerDataPool.buildLogDataPool('ServiceReminders >> serviceReminders',e);
        }
        
    }   
    
     /** KIV : Only being invoked from AlertsScheduler.cls and the code has been commented !!! */
//     public static void serviceRemindersTest(){ 
        
//         Set<String> setServiceCode = new Set<String>();           
//         for(Service_Code__mdt scode : [SELECT Service_Description__c FROM Service_Code__mdt])
//         {
//             setServiceCode.add(scode.Service_Description__c);
//         }    
        
//         try {
//             Set<String> regVehIds = new Set<String>();
            
//             for(AlertsRegisteredVehicle__mdt art : [SELECT DeveloperName FROM AlertsRegisteredVehicle__mdt]){
//                 regVehIds.add(art.DeveloperName);
//             }                   
            
            
//             //Return list of all booked Services which are before today
//             List <Service_Appointment__c> tempIdO = new  List <Service_Appointment__c>();
//             tempIdO =[SELECT Registered_Vehicle__c 
//                       FROM Service_Appointment__c 
//                       WHERE Service_Appointment_Date_Time__c >= today
//                       AND Action__c != 'Cancel'
//                       AND Service_Code__c IN: setServiceCode];
            
//             List<String> regNoList = new List<String>();
//             for(Service_Appointment__c rv:tempIdO) {
//                 if(rv.Registered_Vehicle__c!=null){
//                     regNoList.add(rv.Registered_Vehicle__c); 
//                 }        
//             }
            
            
//             List <Registered_Vehicle__c> registeredVehicle  = new  List<Registered_Vehicle__c>(); 
//             // List of registeredVehicle data
//             registeredVehicle  = [Select Last_Service_Booking_Date__c,Branch__c,Id,Name,Registration_Number__c ,
//                                   Next_Service_Booking_Date__c, Contact__c, Account__c from Registered_Vehicle__c 
//                                   where ( Next_Service_Booking_Date__c = :yesterday OR 
//                                          Next_Service_Booking_Date__c = :before10days OR 
//                                          Next_Service_Booking_Date__c = :before30days OR 
//                                          Next_Service_Booking_Date__c = :before60days)
                                  
//                                   AND Last_Service_Booking_Date__c = Null AND Id Not in : regNoList
//                                   AND Id IN: regVehIds 
//                                  ];
//             if(registeredVehicle.size()>0)
//             {
//                 for(Registered_Vehicle__c rvcOverDue : registeredVehicle)
//                 {
//                     //if the first service is overdue by 1 day for all commercials - 1st reminder
//                     if (rvcOverDue.Next_Service_Booking_Date__c==yesterday)
//                     {
//                         CustomerAlerts__c cAlert = new CustomerAlerts__c();
//                         cAlert.Name = '1st Service Overdue 1st Reminder';
//                         //cAlert.Alert_Description__c = 'The first servicing is due for your car '+ rvcOverDue.Registration_Number__c+'.';
                        
//                         if(rvcOverDue.Branch__c =='CCI'){
//                             cAlert.Alert_Description__c = 'Your car '+ rvcOverDue.Registration_Number__c + ' is overdue for its first servicing. Book your appointment for Lubrication Service now!';
//                         }else{
//                             cAlert.Alert_Description__c = 'Your car '+ rvcOverDue.Registration_Number__c + ' is overdue for its first servicing. Book your appointment for Lubrication (Service A) now!';
                            
//                         }
//                         cAlert.Contact__c = rvcOverDue.Contact__c;
//                         cAlert.Date__c = today;
//                         cAlert.Datetime__c = todaytime;
//                         cAlert.Status__c = 'unread';
//                         cAlert.Registered_Vehicle__c = rvcOverDue.Id;
//                         cAlert.isAlert__c = True;
//                         cAlert.isPush__c = False;
//                         cAlert.isSMS__c = True;
//                         cAlert.isEmail__c = False;
//                         cAlert.Type__c = 'First Service';
//                         cAlert.SubType__c = 'Overdue 1st Reminder';
//                         cAlert.Account__c = rvcOverDue.Account__c;	 
                        
//                         customerAlerts.add(cAlert);
//                     }
//                     //commented the below portion as this is added in 30days message - 11/6/2019
//                     //if the first service is overdue by 10 days for MB - 2nd reminder
//                     else if (rvcOverDue.Next_Service_Booking_Date__c==before10days && rvcOverDue.Branch__c =='CCI'){
//                         CustomerAlerts__c cAlert = new CustomerAlerts__c();
//                         cAlert.Name = '1st Service Overdue 2nd Reminder after 10days';
//                         //cAlert.Alert_Description__c = 'The recommended servicing date is overdue for your car '+ rvcOverDue.Registration_Number__c+'.';
//                         cAlert.Alert_Description__c = 'Your car '+ rvcOverDue.Registration_Number__c + ' is 10 days overdue for its first servicing. Book your appointment for Lubrication Service now!';
//                         cAlert.Contact__c = rvcOverDue.Contact__c;
//                         cAlert.Date__c = today;
//                         cAlert.Datetime__c = todaytime;
//                         cAlert.Status__c = 'unread';
//                         cAlert.Registered_Vehicle__c = rvcOverDue.Id;
//                         cAlert.isAlert__c = True;
//                         cAlert.isPush__c = False;
//                         cAlert.isSMS__c = True;
//                         cAlert.isEmail__c = False;
//                         cAlert.Type__c = 'First Service';
//                         cAlert.SubType__c = 'Overdue 2nd Reminder';
//                         cAlert.Account__c = rvcOverDue.Account__c;	 
                        
//                         customerAlerts.add(cAlert);
//                     }
//                     //if the first service is overdue by 30 days for Mitsubishi and Kia - 2nd reminder  
//                     //added citreon with KIA and MIT as a 30 days 2nd reminder - 11/6/2019
//                     else if (rvcOverDue.Next_Service_Booking_Date__c==before30days && (rvcOverDue.Branch__c =='CCA' || rvcOverDue.Branch__c =='CCK' || rvcOverDue.Branch__c =='CCI')){
//                         CustomerAlerts__c cAlert = new CustomerAlerts__c();
//                         cAlert.Name = '1st Service Overdue 2nd Reminder after 30days';
//                         //cAlert.Alert_Description__c = 'The recommended servicing date is overdue for your car '+ rvcOverDue.Registration_Number__c+'.';
//                         cAlert.Alert_Description__c = 'Your car '+ rvcOverDue.Registration_Number__c + ' is 1 month overdue for its first servicing. Book your appointment for Lubrication (Service A) now!';
//                         cAlert.Contact__c = rvcOverDue.Contact__c;
//                         cAlert.Date__c = today;
//                         cAlert.Datetime__c = todaytime;
//                         cAlert.Status__c = 'unread';
//                         cAlert.Registered_Vehicle__c = rvcOverDue.Id;
//                         cAlert.isAlert__c = True;
//                         cAlert.isPush__c = False;
//                         cAlert.isSMS__c = True;
//                         cAlert.isEmail__c = False;
//                         cAlert.Type__c = 'First Service';
//                         cAlert.SubType__c = 'Overdue 2nd Reminder';
//                         cAlert.Account__c = rvcOverDue.Account__c;	 
                        
//                         customerAlerts.add(cAlert);
//                     }
//                     //if the service is overdue by 60 days for Citroen - 2nd reminder 
//                     else if (rvcOverDue.Next_Service_Booking_Date__c==before60days && rvcOverDue.Branch__c =='CCF'){
//                         CustomerAlerts__c cAlert = new CustomerAlerts__c();
//                         cAlert.Name = '1st Service Overdue 2nd Reminder after 60days';
//                         //cAlert.Alert_Description__c = 'The recommended servicing date is overdue for your car '+ rvcOverDue.Registration_Number__c+'.';
//                         cAlert.Alert_Description__c = 'Your car '+ rvcOverDue.Registration_Number__c+'is 1 month overdue for its first servicing. Book your appointment for Lubrication (Service A) now!';
//                         cAlert.Contact__c = rvcOverDue.Contact__c;
//                         cAlert.Date__c = today;
//                         cAlert.Datetime__c = todaytime;
//                         cAlert.Status__c = 'unread';
//                         cAlert.Registered_Vehicle__c = rvcOverDue.Id;
//                         cAlert.isAlert__c = True ;
//                         cAlert.isPush__c = False;
//                         cAlert.isSMS__c = True;
//                         cAlert.isEmail__c = False;
//                         cAlert.Type__c = 'First Service';
//                         cAlert.SubType__c = 'Overdue 2nd Reminder';
//                         cAlert.Account__c = rvcOverDue.Account__c;	 

//                         customerAlerts.add(cAlert);
//                     }
                    
//                 }               
//             }   
            
//             List <Registered_Vehicle__c> RegisteredVehicle1  = new  List<Registered_Vehicle__c>(); 
//             // List of RegisteredVehicle data
//             RegisteredVehicle1  = [Select Last_Service_Booking_Date__c,Branch__c,Id,Name,Registration_Number__c ,
//                                    Next_Service_Booking_Date__c, Contact__c, Account__c from Registered_Vehicle__c 
//                                    where ( 
//                                        Next_Service_Booking_Date__c = :next14days OR 
//                                        Next_Service_Booking_Date__c = :next1week ) AND
//                                    Last_Service_Booking_Date__c != Null AND Id Not in : regNoList
//                                    AND Id IN: regVehIds  ];
//             if(RegisteredVehicle1.size()>0){
//                 for(Registered_Vehicle__c rvcDue : RegisteredVehicle1)
//                 {   
                    
//                     //if the subsequent service is due by 14 days - 1st reminder
//                     if (rvcDue.Next_Service_Booking_Date__c==next14days ){
//                         CustomerAlerts__c cAlert = new CustomerAlerts__c();
//                         cAlert.Name = 'Subsequent Service Due 1st Reminder';
//                         //cAlert.Alert_Description__c ='The next servicing is due in 14 days for your car '+ rvcDue.Registration_Number__c+'.';
//                         cAlert.Alert_Description__c ='Your car '+ rvcDue.Registration_Number__c +' is due for servicing in 14 days. Check your servicing info and book your appointment now!';
//                         cAlert.Contact__c = rvcDue.Contact__c;
//                         cAlert.Date__c = today;
//                         cAlert.Datetime__c = todaytime;
//                         cAlert.Status__c = 'unread';
//                         cAlert.Registered_Vehicle__c = rvcDue.Id;
//                         cAlert.isAlert__c = True;
//                         cAlert.isPush__c = True;
//                         cAlert.isSMS__c = False;
//                         cAlert.isEmail__c = True;
//                         cAlert.Type__c = 'Subsequent Service';
//                         cAlert.SubType__c = 'Due 1st Reminder';
//                         cAlert.Account__c = rvcDue.Account__c;	 

//                         customerAlerts.add(cAlert);
//                     }
//                     //if the subsequent service is due by 7 days- 2nd reminder
//                     else if (rvcDue.Next_Service_Booking_Date__c==next1week ){
//                         CustomerAlerts__c cAlert = new CustomerAlerts__c();
//                         cAlert.Name = 'Subsequent Service Due 2nd Reminder';
//                         //cAlert.Alert_Description__c = 'The next servicing is due next week for your car '+ rvcDue.Registration_Number__c+'.';
//                         cAlert.Alert_Description__c = 'Your car '+ rvcDue.Registration_Number__c+' is due for servicing next week. Check your servicing info and book your appointment now!';
//                         cAlert.Contact__c = rvcDue.Contact__c;
//                         cAlert.Date__c = today;
//                         cAlert.Datetime__c = todaytime;
//                         cAlert.Status__c = 'unread';
//                         cAlert.Registered_Vehicle__c = rvcDue.Id;
//                         cAlert.isAlert__c = True;
//                         cAlert.isPush__c = True;                           
//                         if(rvcDue.Branch__c == 'CCI')
//                         {
//                             cAlert.isSMS__c = True;
//                         }
//                         else
//                         {
//                             cAlert.isSMS__c = False;
//                         }
//                         cAlert.isEmail__c = True;
//                         cAlert.Type__c = 'Subsequent Service';
//                         cAlert.SubType__c = 'Due 2nd Reminder';
//                         cAlert.Account__c = rvcDue.Account__c;	 

//                         customerAlerts.add(cAlert);
//                     }
//                 }                
                
//             }
//             //Insert Alert List in Database
//             Database.UpsertResult[] results = Database.upsert(customerAlerts);         
//             for(Integer index = 0, size = results.size(); index < size; index++) 
//             {
//                 if(results[index].isSuccess()) 
//                 {
//                     if(results[index].isCreated()) {
//                         System.debug(customerAlerts[index].id +' was created');
//                     } 
//                 }
//                 else
//                 {
//                     system.debug(customerAlerts[index].id +' had error');
//                 }
//             }
//         }   
//         catch (Exception e)
//         {
//             loggerDataPool.buildLogDataPool('ServiceReminders >> serviceRemindersTest',e);
//         }
        
//     }   
    
    
}