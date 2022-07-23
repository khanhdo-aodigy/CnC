/** ******
 * Description : Schedulable job to create CustomerAlerts__c
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                              Description
 * YYYYMMDD             C&C                               Created Initial Version.
 * 20220325             tan.nguyen@aodigy.com             Added 'Third Subsequent Service Reminder' creation.
***** **/
global class subsequentServiceOverdueReminder implements Schedulable {

    // All static collections and variables for execution through scheduler
    public static List <Registered_Vehicle__c> theVehicle {get;set;}
    public static Date today         = date.today();
    static Datetime todaytime        = datetime.now();
    public static Date lastDay       = today.addDays(-1);
    public static Date lastTenDay    = today.addDays(-10);
    public static Date lastThirtyDay = today.addDays(-30);
    public static Date lastSixtyDay  = today.addDays(-60);
    public static Date last120Days = today.addDays(-120);
    public static List <CustomerAlerts__c> LsttheAlert = new List <CustomerAlerts__c>();
    
    //global execute method
    global void execute (SchedulableContext ctx){
        subsequentServiceOverdueReminder();
    }
    
    public static void subsequentServiceOverdueReminder()
    { 
        Set<String> setServiceCode = new Set<String>();           
        for(Service_Code__mdt scode : [SELECT Service_Description__c FROM Service_Code__mdt]) {
            setServiceCode.add(scode.Service_Description__c);
        }    

        try
        {
            List<Service_Appointment__c> tempId = new List<Service_Appointment__c>();
            tempId = [SELECT Registered_Vehicle__c 
                      FROM Service_Appointment__c 
                      WHERE Service_Appointment_Date_Time__c >= today
					  AND Action__c != 'Cancel'
					  AND Service_Code__c IN: setServiceCode];		
            
            List<String> regNoList = new List<String>();
            for(Service_Appointment__c rvc:tempId) {
                if(rvc.Registered_Vehicle__c != null){
                    regNoList.add(rvc.Registered_Vehicle__c);  
                }        
            }
            System.debug('@@@@ regNoList = ' + regNoList);

            theVehicle = [SELECT Id, Name, Branch__c, Contact__c, Account__c, Last_Service_Booking_Date__c, Next_Service_Booking_Date__c, Registered_Date__c, Registration_Number__c, 
                            (SELECT Id, Car_Registration_No__c,Service_Appointment_Date_Time__c FROM Service_Appointments__r)
                          FROM Registered_Vehicle__c 
                          WHERE Last_Service_Booking_Date__c != null 
                          AND (Next_Service_Booking_Date__c =: lastDay OR 
                                Next_Service_Booking_Date__c =: lastTenDay OR 
                                Next_Service_Booking_Date__c =: lastThirtyDay OR 
                                Next_Service_Booking_Date__c =: lastSixtyDay OR
                                Next_Service_Booking_Date__c =: last120Days) 
                          AND Id NOT IN : regNoList];

            System.debug('@@@@ theVehicle = ' + theVehicle);
            
            if (theVehicle.size()>0){
            
                for ( Registered_Vehicle__c rv:theVehicle)
                { 
                    //If Service Due Daye is 1 Day before from today
                    if (rv.Next_Service_Booking_Date__c == lastDay)
                    {
                        CustomerAlerts__c theAlert = new CustomerAlerts__c();
                        theAlert.Name                 = 'First Subsequent Service Reminder';
                        theAlert.Alert_Description__c = 'Your car ' + rv.Registration_Number__c + ' is overdue for servicing. Check your servicing info and book your appointment now!';
                        theAlert.Contact__c           = rv.Contact__c;          
                        theAlert.Account__c           = rv.Account__c;   
                        theAlert.Date__c              = today;
                        theAlert.Datetime__c          = todaytime;
                        theAlert.Status__c            = 'unread';
                        theAlert.Registered_Vehicle__c = rv.id;
                        theAlert.isAlert__c           = true;
                        theAlert.isPush__c            = false;
                        theAlert.isSMS__c             = true;
                        theAlert.isEmail__c           = false;
                        theAlert.Type__c              = 'Subsequent Service';
                        theAlert.SubType__c           = 'Overdue 1st Reminder';
                        LsttheAlert.add(theAlert);
                    }
                    // commented above condition and addded CCF with CCA and CCK - 11/6/2019
                    else if (rv.Next_Service_Booking_Date__c == lastThirtyDay && (rv.Branch__c == 'CCK' || rv.Branch__c == 'CCA' || rv.Branch__c == 'CCF') )
                    {
                        
                        CustomerAlerts__c theAlert = new CustomerAlerts__c();
                        theAlert.Name                 = 'Second Subsequent Service Reminder';
                        theAlert.Alert_Description__c = 'Your car ' + rv.Registration_Number__c + ' is 1 month overdue for servicing. Check your servicing info and book your appointment now!';
                        theAlert.Contact__c           = rv.Contact__c;          
                        theAlert.Account__c           = rv.Account__c;   
                        theAlert.Date__c              = today;
                        theAlert.Datetime__c          = todaytime;
                        theAlert.Status__c            = 'unread';
                        theAlert.Registered_Vehicle__c = rv.id;
                        theAlert.isAlert__c           = true;
                        theAlert.isPush__c            = false;
                        theAlert.isSMS__c             = true;
                        theAlert.isEmail__c           = false;
                        theAlert.Type__c              = 'Subsequent Service';
                        theAlert.SubType__c           = 'Overdue 2nd Reminder';
                        LsttheAlert.add(theAlert);
                        
                    } 
                    else if (rv.Next_Service_Booking_Date__c == lastTenDay && rv.Branch__c == 'CCI' )
                    {
                        CustomerAlerts__c theAlert = new CustomerAlerts__c();
                        theAlert.Name                 = 'Second Subsequent Service Reminder';
                        theAlert.Alert_Description__c = 'Your car ' + rv.Registration_Number__c + ' is 10 days overdue for servicing. Check your servicing info and book your appointment now!';
                        theAlert.Contact__c           = rv.Contact__c;          
                        theAlert.Account__c           = rv.Account__c;   
                        theAlert.Date__c              = today;
                        theAlert.Datetime__c          = todaytime;
                        theAlert.Status__c            = 'unread';
                        theAlert.Registered_Vehicle__c = rv.id;
                        theAlert.isAlert__c           = True;
                        theAlert.isPush__c            = False;
                        theAlert.isSMS__c             = True;
                        theAlert.isEmail__c           = False;
                        theAlert.Type__c              = 'Subsequent Service';
                        theAlert.SubType__c           = 'Overdue 2nd Reminder';
                        LsttheAlert.add(theAlert);
                    }
                    //if the subsequent service is overdue by 120 days for MF - added 25/03/2022
                    else if (rv.Next_Service_Booking_Date__c == last120Days && (rv.Branch__c == 'CCK' || rv.Branch__c == 'CCA' || rv.Branch__c == 'CCF')) {
                        System.debug('@@@@ Third Subsequent Service Reminder' );
                        CustomerAlerts__c theAlert = new CustomerAlerts__c();
                        theAlert.Name                 = 'Third Subsequent Service Reminder';
                        theAlert.Alert_Description__c = 'Your car '+ rv.Registration_Number__c+' is 4 months overdue for servicing. Check your servicing info and book your appointment now!';
                        theAlert.Contact__c           = rv.Contact__c;          
                        theAlert.Account__c           = rv.Account__c;   
                        theAlert.Date__c              = today;
                        theAlert.Datetime__c          = todaytime;
                        theAlert.Status__c            = 'unread';
                        theAlert.Registered_Vehicle__c = rv.id;
                        theAlert.isAlert__c           = True;
                        theAlert.isPush__c            = False;
                        theAlert.isSMS__c             = True;
                        theAlert.isEmail__c           = False;
                        theAlert.Type__c              = 'Subsequent Service';
                        theAlert.SubType__c           = 'Overdue 3rd Reminder';
                        
                        LsttheAlert.add(theAlert);
                    }
                    
                }
                //Insert Alert List in Database
                Database.UpsertResult[] results = Database.upsert(LsttheAlert, CustomerAlerts__c.Fields.Registered_Vehicle__r.Id, False);
                for(Integer index = 0, size = results.size(); index < size; index++) 
                {
                    if(results[index].isSuccess()) {
                        if(results[index].isCreated()) {
                            System.debug(LsttheAlert[index].id +' was created');
                        } 
                    }
                    else {
                        System.debug(LsttheAlert[index].id +' had error');
                    }
                }
                
            }
        } 
        catch (Exception e){
            loggerDataPool.buildLogDataPool('subsequentServiceOverdueReminder',e);
        }
    }
    
    
    /** KIV : Only being invoked from AlertsScheduler.cls and the code has been commented !!! */
    /*
    public static void subsequentServiceOverdueReminderTest()
    { 

        Set<String> setServiceCode = new Set<String>();           
        for(Service_Code__mdt scode : [SELECT Service_Description__c FROM Service_Code__mdt])
		{
            setServiceCode.add(scode.Service_Description__c);
        }    

        try{
            Set<String> regVehIds = new Set<String>();
           
            for(AlertsRegisteredVehicle__mdt art : [SELECT DeveloperName FROM AlertsRegisteredVehicle__mdt]){
                regVehIds.add(art.DeveloperName);
            }

            List <Service_Appointment__c> tempId = new  List <Service_Appointment__c>();
            tempId=[Select Registered_Vehicle__c from Service_Appointment__c where 
                    Service_Appointment_Date_Time__c >= today
					and Action__c != 'Cancel'
					and Service_Code__c in: setServiceCode];
            
            List<String> regNoList = new List<String>();
            for(Service_Appointment__c rvc:tempId) {
                if(rvc.Registered_Vehicle__c!=null){
                    regNoList.add(rvc.Registered_Vehicle__c);  }        
                
            }
            
            theVehicle = [SELECT Id, Name, Branch__c, Contact__c, Account__c, Last_Service_Booking_Date__c, Next_Service_Booking_Date__c, Registered_Date__c, Registration_Number__c, 
                            (SELECT Id, Car_Registration_No__c, Service_Appointment_Date_Time__c FROM Service_Appointments__r)
                          FROM Registered_Vehicle__c 
                          WHERE  Last_Service_Booking_Date__c !=: null 
                          AND (Next_Service_Booking_Date__c =: lastDay OR 
                                Next_Service_Booking_Date__c =: lastTenDay OR 
                                Next_Service_Booking_Date__c =: lastThirtyDay OR 
                                Next_Service_Booking_Date__c =: lastSixtyDay) 
                          AND Id NOT in : regNoList 
                          AND Id IN: regVehIds ];
            
            if (theVehicle.size()>0){
                
                for ( Registered_Vehicle__c rv:theVehicle)
                { 
                    //If Service Due Daye is 1 Day before from today
                    if (rv.Next_Service_Booking_Date__c == lastDay)
                    {
                        
                        CustomerAlerts__c theAlert = new CustomerAlerts__c();
                        
                        theAlert.Name = 'First Subsequent Service Reminder';
                        //theAlert.Alert_Description__c = 'The next servicing is due for your car ' + rv.Registration_Number__c;
                        theAlert.Alert_Description__c = 'Your car ' + rv.Registration_Number__c + ' is overdue for servicing. Check your servicing info and book your appointment now!';
                        theAlert.Contact__c = rv.Contact__c;
                        theAlert.Account__c = rv.Account__c; //PA MIGRATION: Newly Added
                        theAlert.Date__c = today;
                        theAlert.Datetime__c = todaytime;
                        theAlert.Status__c = 'unread';
                        theAlert.Registered_Vehicle__c = rv.id;
                        theAlert.isAlert__c = True;
                        theAlert.isPush__c = False;
                        theAlert.isSMS__c = True;
                        theAlert.isEmail__c = False;
                        theAlert.Type__c = 'Subsequent Service';
                        theAlert.SubType__c = 'Overdue 1st Reminder';
                        LsttheAlert.add(theAlert);
                        
                    }
                    // commented above condition and addded CCF with CCA and CCK - 11/6/2019
                    else if (rv.Next_Service_Booking_Date__c == lastThirtyDay && (rv.Branch__c == 'CCK' || rv.Branch__c == 'CCA' || rv.Branch__c == 'CCF') )
                    {
                        
                        CustomerAlerts__c theAlert = new CustomerAlerts__c();
                        
                        theAlert.Name = 'Second Subsequent Service Reminder';
                        //theAlert.Alert_Description__c = 'The recommended servicing date is overdue for your car ' + rv.Registration_Number__c;
                        theAlert.Alert_Description__c = 'Your car ' + rv.Registration_Number__c + ' is 1 month overdue for servicing. Check your servicing info and book your appointment now!';
                        theAlert.Contact__c = rv.Contact__c;
                        theAlert.Account__c = rv.Account__c; //PA MIGRATION: Newly Added
                        theAlert.Date__c = today;
                        theAlert.Datetime__c = todaytime;
                        theAlert.Status__c = 'unread';
                        theAlert.Registered_Vehicle__c = rv.id;
                        theAlert.isAlert__c = True;
                        theAlert.isPush__c = False;
                        theAlert.isSMS__c = True;
                        theAlert.isEmail__c = False;
                        theAlert.Type__c = 'Subsequent Service';
                        theAlert.SubType__c = 'Overdue 2nd Reminder';
                        LsttheAlert.add(theAlert);
                        
                        
                    } 
                    else if (rv.Next_Service_Booking_Date__c == lastTenDay && rv.Branch__c == 'CCI' )
                    {
                        CustomerAlerts__c theAlert = new CustomerAlerts__c();
                        
                        theAlert.Name = 'Second Subsequent Service Reminder';
                        //theAlert.Alert_Description__c = 'The recommended servicing date is overdue for your car ' + rv.Registration_Number__c;
                        theAlert.Alert_Description__c = 'Your car ' + rv.Registration_Number__c + ' is 10 days overdue for servicing. Check your servicing info and book your appointment now!';
                        
                        theAlert.Contact__c = rv.Contact__c;
                        theAlert.Account__c = rv.Account__c; //PA MIGRATION: Newly Added
                        theAlert.Date__c = today;
                        theAlert.Datetime__c = todaytime;
                        theAlert.Status__c = 'unread';
                        theAlert.Registered_Vehicle__c = rv.id;
                        theAlert.isAlert__c = True;
                        theAlert.isPush__c = False;
                        theAlert.isSMS__c = True;
                        theAlert.isEmail__c = False;
                        theAlert.Type__c = 'Subsequent Service';
                        theAlert.SubType__c = 'Overdue 2nd Reminder';
                        LsttheAlert.add(theAlert);
                    }
                    
                }
                //Insert Alert List in Database
                Database.UpsertResult[] results = Database.upsert(LsttheAlert, CustomerAlerts__c.Fields.Registered_Vehicle__r.Id, False);
                for(Integer index = 0, size = results.size(); index < size; index++) 
                {
                    if(results[index].isSuccess()) 
                    {
                        if(results[index].isCreated()) {
                            System.debug(LsttheAlert[index].id +' was created');
                        } 
                    }
                    else
                    {
                        system.debug(LsttheAlert[index].id +' had error');
                    }
                }
                
            }
        } 
        catch (Exception e){
            loggerDataPool.buildLogDataPool('subsequentServiceOverdueReminder',e);
        }
    }    
    */

}