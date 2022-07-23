global class ServiceAppointmentReminders implements Schedulable
{
	
    global void execute(SchedulableContext ctx){ServiceAppointmentReminder();}
    //Variable declaration 
    public static list <Service_Appointment__c> ServiceAppointmentObj {get;set;}
    public static Date today 		 = date.today();
    public static DateTime todaytime = datetime.now();
    public static Date nextThreeDays = today.addDays(3);
    public static List <CustomerAlerts__c> customerAlertList  = new List<CustomerAlerts__c>(); 
    
	//Need to enhance this after testing in clear   
    public static void ServiceAppointmentReminder()
    {         
        try
        {
            Set<String> regVehIds = new Set<String>();
           
            for(AlertsRegisteredVehicle__mdt art : [SELECT DeveloperName FROM AlertsRegisteredVehicle__mdt])
			{
                regVehIds.add(art.DeveloperName);
            }                   
            
            List <Service_Appointment__c> tempId = new  List <Service_Appointment__c>();
            
            //fetching list of all registered vehicle with today or future service appointments             
            ServiceAppointmentObj  = [SELECT Registered_Vehicle__r.Id,Is_Non_Owner__c,
                                              Registered_Vehicle__r.Registration_Number__c,
                                              Service_Appointment_Date_Time__c, 
                                              Service_Centre_Location__c,
											  Car_Registration_No__c,
											  Non_Owner_Email__c,	
											  Contact__r.Email,											  										   
                                              Contact__r.Id,
											  Account__c 			 //PA MIGRATION
									  FROM Service_Appointment__c
									  WHERE Action__c != 'Cancel' 
									  AND Service_Appointment_Date__c = :nextThreeDays ];

            
            if(ServiceAppointmentObj.size()>0) 
            {
                for(Service_Appointment__c rvc : ServiceAppointmentObj)
                {
					
					if( rvc.Is_Non_Owner__c == false || rvc.Is_Non_Owner__c == true 
							&& ( rvc.Non_Owner_Email__c == rvc.Contact__r.Email ) )
					{						
						Datetime servDateTime  	  = rvc.Service_Appointment_Date_Time__c; 
						String dateVal 			  = servDateTime.format('dd MMMMM yyyy,EEEEE');
						String hourMinutes 		  = servDateTime.format('hh:mm a');  
						String formatedDate 	  = String.valueof(servDateTime.format('dd/MM/YY'));
						formatedDate 			  = formatedDate+' '+servDateTime.format('hh:mm aaa');
                    
						String servCentre 		  = rvc.Service_Centre_Location__c; 
						String registrationnumber = rvc.Registered_Vehicle__r.Registration_Number__c ;
						String message 			  = 'Don’t forget your service appt on ' + formatedDate  + ' at '+ servCentre +'.';       

						CustomerAlerts__c cAlert  	= new CustomerAlerts__c();
						cAlert.Name 			    = 'Reminder for Booked Service 1st Alert';
						cAlert.Alert_Description__c = message ;
						cAlert.Contact__c 			= rvc.Contact__r.Id;
						cAlert.Account__c			= rvc.Account__c;
						cAlert.Date__c 				= today;
						cAlert.Datetime__c 			= todaytime;
						cAlert.isAlert__c 			= true;
						cAlert.isPush__c 			= true;
						cAlert.isSMS__c 			= false;
						cAlert.isEmail__c 			= true;
						cAlert.Type__c 				= 'Service Appointment';
						cAlert.SubType__c 			= 'Due 1st Reminder';
						cAlert.Status__c 			= 'unread';
						cAlert.Registered_Vehicle__c  = rvc.Registered_Vehicle__r.Id ;
						cAlert.Service_Appointment__c = rvc.Id ;
						customerAlertList.add( cAlert );
                   }
				   else if( rvc.Is_Non_Owner__c == true 
								&& (rvc.Non_Owner_Email__c != rvc.Contact__r.Email ) )
				   {
						Datetime servDateTime  	  = rvc.Service_Appointment_Date_Time__c; 
						String dateVal 			  = servDateTime.format('dd MMMMM yyyy,EEEEE');
						String hourMinutes 		  = servDateTime.format('hh:mm a');  
						String formatedDate 	  = String.valueof(servDateTime.format('dd/MM/YY'));
						formatedDate 			  = formatedDate+' '+servDateTime.format('hh:mm aaa');
                    
						String servCentre 		  = rvc.Service_Centre_Location__c; 
						String registrationnumber = rvc.Car_Registration_No__c ;
						String message 			  = 'Don’t forget your service appt on ' + formatedDate  + ' at '+ servCentre +'.';       
						
						CustomerAlerts__c cAlert  = new CustomerAlerts__c();
						cAlert.Name 			  = 'Reminder for Booked Service 1st Alert';
						cAlert.Alert_Description__c = message ;
						cAlert.Date__c 				= today;
						cAlert.Datetime__c 			= todaytime;
						cAlert.isAlert__c 			= true;
						cAlert.isPush__c 			= true;
						cAlert.isSMS__c 			= false;
						cAlert.isEmail__c 			= true;
						cAlert.Type__c 				= 'Service Appointment Guest'; //New Changes for DE filter in MC
						cAlert.SubType__c 			= 'Due 1st Reminder';
						cAlert.Status__c 			= 'unread';
						cAlert.Registered_Vehicle__c  = rvc.Registered_Vehicle__r.Id ;
						cAlert.Service_Appointment__c = rvc.Id ;
						customerAlertList.add(cAlert);				   
				   }  
                }
            }
            
            //pass customer list to upsert function  create customer alert 
            insertCreateCustomerAlert( customerAlertList ) ; 
        }
        catch(Exception e)
        {
			System.debug('+ ' + e.getMessage());
            loggerDataPool.buildLogDataPool('ServiceAppointmentReminders',e);
        }
	}
    

    public static void ServiceAppointmentReminderTEST()
    {         
        try
        {
            Set<String> regVehIds = new Set<String>();
           
            for(AlertsRegisteredVehicle__mdt art : [SELECT DeveloperName FROM AlertsRegisteredVehicle__mdt])
			{
                regVehIds.add(art.DeveloperName);
            }                   
            
            List <Service_Appointment__c> tempId = new  List <Service_Appointment__c>();

			if(Test.isRunningTest())
			{
				 regVehIds.add('ABC');
				 regVehIds.add('ABCDF');
			}
            
            //fetching list of all registered vehicle with today or future service appointments             

            ServiceAppointmentObj  = [Select Registered_Vehicle__r.Id,Is_Non_Owner__c,
                                              Registered_Vehicle__r.Registration_Number__c,
                                              Service_Appointment_Date_Time__c, 
                                              Service_Centre_Location__c, 
											  Car_Registration_No__c,
											  Non_Owner_Email__c,
											  Contact__r.email,
                                              Contact__r.Id,
											  Account__c//PA MIGRATION									   
                                      from Service_Appointment__c
                                      where Action__c != 'Cancel' 
                                      and Service_Appointment_Date__c = :nextThreeDays AND Car_Registration_No__c in : regVehIds];

            
            if(ServiceAppointmentObj.size()>0) 
            {
				for(Service_Appointment__c rvc : ServiceAppointmentObj)
				{
					if(rvc.Is_Non_Owner__c == false || 
						rvc.Is_Non_Owner__c == true 
						&& (rvc.Non_Owner_Email__c == rvc.Contact__r.email ) )
					{						
						Datetime servDateTime  = rvc.Service_Appointment_Date_Time__c; 
						String dateVal = servDateTime.format('dd MMMMM yyyy,EEEEE');
						String hourMinutes = servDateTime.format('hh:mm a');  
						String formatedDate = String.valueof(servDateTime.format('dd/MM/YY'));
						formatedDate = formatedDate+' '+servDateTime.format('hh:mm aaa');
                    
						String servCentre = rvc.Service_Centre_Location__c; 
						String registrationnumber =  rvc.Registered_Vehicle__r.Registration_Number__c ;
						String message = 'Don’t forget your service appt on ' + formatedDate  + ' at '+ servCentre +'.';       
						CustomerAlerts__c cAlert = new CustomerAlerts__c();
						cAlert.Name = 'Reminder for Booked Service 1st Alert';
						cAlert.Alert_Description__c = message ;
						cAlert.Contact__c = rvc.Contact__r.Id;
						if(rvc.Account__c != null)
						{ 
							cAlert.Account__c = rvc.Account__r.Id;
						}
						cAlert.Date__c = today;
						cAlert.Datetime__c = todaytime;
						cAlert.isAlert__c = True;
						cAlert.isPush__c = True;
						cAlert.isSMS__c = False;
						cAlert.isEmail__c = True;
						cAlert.Type__c = 'Service Appointment';
						cAlert.SubType__c = 'Due 1st Reminder';
						cAlert.Status__c = 'unread';
						cAlert.Registered_Vehicle__c = rvc.Registered_Vehicle__r.Id ;
						cAlert.Service_Appointment__c = rvc.Id ;
						customerAlertList.add(cAlert);
                   }
				   else if(rvc.Is_Non_Owner__c == true 
							&& (rvc.Non_Owner_Email__c != rvc.Contact__r.email ) )
				   {
						Datetime servDateTime  = rvc.Service_Appointment_Date_Time__c; 
						String dateVal = servDateTime.format('dd MMMMM yyyy,EEEEE');
						String hourMinutes = servDateTime.format('hh:mm a');  
						String formatedDate = String.valueof(servDateTime.format('dd/MM/YY'));
						formatedDate = formatedDate+' '+servDateTime.format('hh:mm aaa');
                    
						String servCentre = rvc.Service_Centre_Location__c; 
						String registrationnumber =  rvc.Car_Registration_No__c ;
						String message = 'Don’t forget your service appt on ' + formatedDate  + ' at '+ servCentre +'.';       
						CustomerAlerts__c cAlert = new CustomerAlerts__c();
						cAlert.Name = 'Reminder for Booked Service 1st Alert';
						cAlert.Alert_Description__c = message ;
						cAlert.Date__c = today;
						cAlert.Datetime__c = todaytime;
						cAlert.isAlert__c = True;
						cAlert.isPush__c = True;
						cAlert.isSMS__c = False;
						cAlert.isEmail__c = True;
						cAlert.Type__c = 'Service Appointment Guest'; //New Changes for DE filter in MC
						cAlert.SubType__c = 'Due 1st Reminder';
						cAlert.Status__c = 'unread';
						cAlert.Registered_Vehicle__c = rvc.Registered_Vehicle__r.Id ;
						cAlert.Service_Appointment__c = rvc.Id ;
						customerAlertList.add(cAlert);				   
				   }  
                }
            }
            
            //pass customer list to upsert function  create customer alert 
            insertCreateCustomerAlert(customerAlertList) ; 
        }
        catch(Exception e)
        {
            loggerDataPool.buildLogDataPool('ServiceAppointmentReminders',e);
        }
   }

    
    //function for upsert and create customer alert 
    public static void insertCreateCustomerAlert( List<CustomerAlerts__c> newCustomerAlerts )
    {
        //insert newCustomerAlerts;
        if(newCustomerAlerts.size()>0)
        {        
            Database.UpsertResult[] results = Database.upsert(newCustomerAlerts);  
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
}