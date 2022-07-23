global class planPackageReminder implements Schedulable{
    // All static collections and variables for execution through scheduler
    public static List <Service_Packages__c> thePackage {get;set;} 
    static Datetime todaytime = datetime.now();
    public static Date today          = date.today(); 
    public static Date nextSixMonth   = today.addMonths(6);
    public static Date nextThreeMonth = today.addMonths(3);
    public static Date nextOneMonth   = today.addMonths(1);
    public static List <CustomerAlerts__c> LsttheAlert = new List <CustomerAlerts__c>();

    //void execute method
    global void execute (SchedulableContext ctx) 
    {
        planPackageReminder();
    }
    
    public static void planPackageReminder()
    {
        try {
            
            // List of packages whose expiry dates are at six, three or one months from today
            thePackage = [SELECT Id, Name, ITEM_EXPIRY_DATE__c, PACKAGE_DESCRIPTION__c, Registered_Vehicle__r.Registration_Number__c, Registered_Vehicle__r.Name, Registered_Vehicle__c,
                                Registered_Vehicle__r.Contact__c, Registered_Vehicle__r.Contact__r.Email, Registered_Vehicle__r.Contact__r.NRIC_Passport_No__c, 
                                Registered_Vehicle__r.Account__c, Registered_Vehicle__r.Account__r.PersonEmail, Registered_Vehicle__r.Account__r.NRIC_Passport_No__pc 
                          FROM Service_Packages__c 
                          WHERE (ITEM_EXPIRY_DATE__c =: nextSixMonth OR ITEM_EXPIRY_DATE__c=: nextThreeMonth OR ITEM_EXPIRY_DATE__c=: nextOneMonth)
                          AND Status__c = 'Active' ];
            
            if(thePackage.size()>0)
            {
                String rem = '. Remember to utilise it soon!';
                for (Service_Packages__c sp:thePackage)
                {
                    if( sp.ITEM_EXPIRY_DATE__c == nextSixMonth )
                        
                    {
                        //If Expiration date is six months from today
                        //Set Alert Values 
                        CustomerAlerts__c theAlert = new CustomerAlerts__c();
                        theAlert.Name                 = 'Plan package 6 monthly reminder';
                        theAlert.Alert_Description__c = 'The ' + sp.PACKAGE_DESCRIPTION__c + ' is expiring in 6 months for your car '+ sp.Registered_Vehicle__r.Registration_Number__c + rem;
                        theAlert.Contact__c           = sp.Registered_Vehicle__r.Contact__c;
                        theAlert.Date__c              = today;
                        theAlert.Datetime__c          = todaytime;
                        theAlert.Status__c            = 'unread';
                        theAlert.isAlert__c           = true;
                        theAlert.isPush__c            = true;

                        if (sp.Registered_Vehicle__r.Contact__r.Email == null || sp.Registered_Vehicle__r.Contact__r.Email == '') {
                            theAlert.isSMS__c = false;  
                        }

                        theAlert.isEmail__c           = true;
                        theAlert.Type__c              = 'Plan/Package';
                        theAlert.SubType__c           = 'Due 1st Reminder';
                        theAlert.Registered_Vehicle__c = sp.Registered_Vehicle__c;
                        theAlert.Service_Package__c   = sp.Id; 
                        theAlert.Account__c           = sp.Registered_Vehicle__r.Account__c;
                        LsttheAlert.add(theAlert);                
                    }
                    else if( sp.ITEM_EXPIRY_DATE__c == nextThreeMonth )
                    {
                        //If Expiration date is three months from today
                        //Set Alert Values 
                        CustomerAlerts__c theAlert = new CustomerAlerts__c();
                        theAlert.Name                 = 'Plan package 3 monthly reminder';
                        theAlert.Alert_Description__c = 'The ' + sp.PACKAGE_DESCRIPTION__c+ ' is expiring in 3 months for your car '+ sp.Registered_Vehicle__r.Registration_Number__c + rem;
                        theAlert.Contact__c           = sp.Registered_Vehicle__r.Contact__c;
                        theAlert.Date__c              = today;
                        theAlert.Datetime__c          = todaytime;
                        theAlert.Status__c            = 'unread';
                        theAlert.isAlert__c           = true;
                        theAlert.isPush__c            = true;

                        if (sp.Registered_Vehicle__r.Contact__r.Email == null || sp.Registered_Vehicle__r.Contact__r.Email == '') {
                            theAlert.isSMS__c = true;   
                        }

                        theAlert.isEmail__c           = true;
                        theAlert.Type__c              = 'Plan/Package';
                        theAlert.SubType__c           = 'Due 2nd Reminder';
                        theAlert.Registered_Vehicle__c = sp.Registered_Vehicle__c;
                        theAlert.Service_Package__c   = sp.Id;   
                        theAlert.Account__c           = sp.Registered_Vehicle__r.Account__c;
                        LsttheAlert.add(theAlert);
                        
                    }
                    else if( sp.ITEM_EXPIRY_DATE__c == nextOneMonth )
                    {
                        //If Expiration date is one month from today
                        //Set Alert Values 
                        CustomerAlerts__c theAlert = new CustomerAlerts__c();
                        theAlert.Name                 = 'Plan package 1 monthly reminder';
                        theAlert.Alert_Description__c = 'The ' + sp.PACKAGE_DESCRIPTION__c + ' is expiring next month for your car '+ sp.Registered_Vehicle__r.Registration_Number__c + rem;
                        theAlert.Contact__c           = sp.Registered_Vehicle__r.Contact__c;
                        theAlert.Date__c              = today;
                        theAlert.Datetime__c          = todaytime;
                        theAlert.Status__c            = 'unread';
                        theAlert.isAlert__c           = true;
                        theAlert.isPush__c            = false;

                        if (sp.Registered_Vehicle__r.Contact__r.Email == null || sp.Registered_Vehicle__r.Contact__r.Email == '') {
                            theAlert.isSMS__c = true;   
                        }

                        theAlert.isEmail__c           = false;
                        theAlert.Type__c              = 'Plan/Package';
                        theAlert.SubType__c           = 'Due 3rd Reminder';
                        theAlert.Registered_Vehicle__c = sp.Registered_Vehicle__c;
                        theAlert.Service_Package__c   = sp.Id;
                        theAlert.Account__c           = sp.Registered_Vehicle__r.Account__c;
                        LsttheAlert.add(theAlert);
                        
                    }         
                }
                //Insert Alert List in Database
                Database.UpsertResult[] results = Database.upsert(LsttheAlert); 
            }
        } 
        catch (Exception e)
        {
            loggerDataPool.buildLogDataPool('planPackageReminder',e);
        }    
    }    
}