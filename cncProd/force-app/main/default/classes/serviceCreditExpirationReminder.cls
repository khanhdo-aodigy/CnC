/** *****
 * Description : Class to create new Customer Alerts for Service Credits Expiration
 * 
 * Change History:
 * Date(YYYYMMDD)       Developer               Details
 * xxxxxxxx                xxxxxxx           Created initial version
 * 20211001            tphan@aodigy.com      Enhanced to cater more scenarios
 ** *****/

global class serviceCreditExpirationReminder implements Schedulable, Database.Batchable<sObject>, Database.Stateful
{
    public static list <CustomerAlerts__c> newAlerts = new list <CustomerAlerts__c>();

    public static Date today          = date.today();
    static Datetime todaytime         = datetime.now();
    public static Date nextMonth      = today.addMonths(1);
    public static Date nextThreeMonth = today.addMonths(3);
    public static Date nextSixMonth   = today.addMonths(6);

    private static Date lastDateOfNextMonth      = today.day() == 30 && isLastDayOfMonth(today) ? nextMonth.addDays(1) : null;
    private static Date lastDateOfNextThreeMonth = today.day() == 30 && isLastDayOfMonth(today) ? nextThreeMonth.addDays(1) : null;
    private static Date lastDateOfNextSixMonth   = today.day() == 30 && isLastDayOfMonth(today) ? nextSixMonth.addDays(1) : null;

    private static Date nextMonthTo      = today.month() == 2 ? (today.day() == 28 ? nextMonth.addDays(3)      : (today.day() == 29 ? nextMonth.addDays(2)      : null)) : null;
    private static Date nextThreeMonthTo = today.month() == 2 ? (today.day() == 28 ? nextThreeMonth.addDays(3) : (today.day() == 29 ? nextThreeMonth.addDays(2) : null)) : null;
    private static Date nextSixMonthTo   = today.month() == 2 ? (today.day() == 28 ? nextSixMonth.addDays(3)   : (today.day() == 29 ? nextSixMonth.addDays(2)   : null)) : null;

    public Set<Id> setIdsOfRV = new Set<Id>();
    public String  expiryDate = '';
    public Boolean isFeb      = false;

    global serviceCreditExpirationReminder() {}

    global serviceCreditExpirationReminder( Set<Id> setIdsOfRVeh, String checkedDate )
    {
        setIdsOfRV = setIdsOfRVeh;
        expiryDate = checkedDate;
        System.debug('@@@@DEBUG serviceCreditExpirationReminder :: setIdsOfRV ' + setIdsOfRV);
    }

    global void execute (SchedulableContext ctx)
    {
        System.debug('@@@@DEBUG schc.exe :: setIdsOfRV ' + setIdsOfRV);
        
        //invoke schc itself
        // accessoriesCreditExpirationReminder2();

        //invoke batch
        Database.executebatch(new serviceCreditExpirationReminder( setIdsOfRV, expiryDate ),200);
    }    

    //Batch Start
    public Iterable<sObject> start(Database.Batchablecontext BC)
    {
        String strSOQL = 'SELECT Id, Name, Registration_Number__c, Service_Credits_Expiry_Date__c, Service_Credits__c, Contact__c, Contact__r.Email, Account__c FROM Registered_Vehicle__c WHERE Service_Credits_Expiry_Date__c != null AND Service_Credits__c != \'\'';
        if( setIdsOfRV <> null && !setIdsOfRV.isEmpty() )
        {
            strSOQL += ' AND ID IN : setIdsOfRV ';
        }
        else if (String.isNotBlank(expiryDate))
        {
            Date expiryDate = Date.valueOf(expiryDate);
            strSOQL += ' AND Service_Credits_Expiry_Date__c =: expiryDate ';
        }
        else
        {        
            if (nextMonthTo <> null || nextThreeMonthTo <> null || nextSixMonthTo <> null)
            {
                isFeb = true;
                strSOQL += ' AND ((Service_Credits_Expiry_Date__c >= :nextMonth AND Service_Credits_Expiry_Date__c <= :nextMonthTo) OR (Service_Credits_Expiry_Date__c >= :nextThreeMonth AND Service_Credits_Expiry_Date__c <= :nextThreeMonthTo) OR (Service_Credits_Expiry_Date__c >= :nextSixMonth AND Service_Credits_Expiry_Date__c <= :nextSixMonthTo)) ';
            }
            else if (lastDateOfNextMonth <> null || lastDateOfNextThreeMonth <> null || lastDateOfNextSixMonth <> null)
            {
                strSOQL += ' AND (Service_Credits_Expiry_Date__c =: nextMonth OR Service_Credits_Expiry_Date__c =: nextThreeMonth OR Service_Credits_Expiry_Date__c =: nextSixMonth OR Service_Credits_Expiry_Date__c =: lastDateOfNextMonth OR Service_Credits_Expiry_Date__c =: lastDateOfNextThreeMonth OR Service_Credits_Expiry_Date__c =: lastDateOfNextSixMonth)';   
            }
            else 
            {
                strSOQL += ' AND (Service_Credits_Expiry_Date__c =: nextMonth OR Service_Credits_Expiry_Date__c =: nextThreeMonth OR Service_Credits_Expiry_Date__c =: nextSixMonth)';
            }
        }

        return Database.query( strSOQL );
    }

    //Batch Execute
    public void execute(Database.BatchableContext BC, List<sObject> scope)
    {  
        System.debug('@@@@DEBUG batch.execute :: scope.size - ' + scope.size() );
        try 
        {   
            if (scope.size() > 0 && scope <> null)
            {
                for (Registered_Vehicle__c rv : (List<Registered_Vehicle__c>) scope)
                {
                    if (isFeb)
                    {
                        if (rv.Service_Credits_Expiry_Date__c >= nextSixMonth && rv.Service_Credits_Expiry_Date__c <= nextSixMonthTo)
                        {                          
                            newAlerts.add(createCustomerAlert('first', rv));
                        }
                        else if (rv.Service_Credits_Expiry_Date__c >= nextThreeMonth && rv.Service_Credits_Expiry_Date__c <= nextThreeMonthTo)
                        {
                            newAlerts.add(createCustomerAlert('second', rv));
                        }
                        else if (rv.Service_Credits_Expiry_Date__c >= nextMonth && rv.Service_Credits_Expiry_Date__c <= nextMonthTo) 
                        {
                            newAlerts.add(createCustomerAlert('third', rv));
                        }
                    }
                    else 
                    {
                        if ((rv.Service_Credits_Expiry_Date__c == nextSixMonth) || (lastDateOfNextSixMonth <> null && rv.Service_Credits_Expiry_Date__c == lastDateOfNextSixMonth))
                        {
                            newAlerts.add(createCustomerAlert('first', rv));
                        }
                        else if ((rv.Service_Credits_Expiry_Date__c == nextThreeMonth) || (lastDateOfNextThreeMonth <> null && rv.Service_Credits_Expiry_Date__c == lastDateOfNextThreeMonth))
                        {
                            newAlerts.add(createCustomerAlert('second', rv));
                        }
                        else if ((rv.Service_Credits_Expiry_Date__c == nextMonth) || (lastDateOfNextMonth <> null && rv.Service_Credits_Expiry_Date__c == lastDateOfNextMonth))
                        {
                            newAlerts.add(createCustomerAlert('third', rv));
                        }               
                    }
                }

                Database.UpsertResult[] results = Database.upsert(newAlerts);
                for(Integer index = 0, size = results.size(); index < size; index++) 
                {
                    if(results[index].isSuccess())
                    {
                        if(results[index].isCreated()) 
                        {
                            System.debug(newAlerts[index].id +' was created');
                        } 
                    }
                    else 
                    {
                        System.debug(newAlerts[index].id +' had error');
                    }
                }
                System.debug('Customer Alerts Created: ' + newAlerts.size());
            }       
        }
        catch (Exception e)
        {
            System.debug('ERROR: ' + e.getMessage() + ' ' + e.getLineNumber());
            loggerDataPool.buildLogDataPool('serviceCreditExpirationReminder', e);
        }       
    } 
    
    //Batch End
    public void finish(Database.BatchableContext info){}

    public static void serviceCreditExpirationReminder()
    {   
        Database.executebatch(new serviceCreditExpirationReminder( null, null ),200);
    }

    private static CustomerAlerts__c createCustomerAlert (String alertName, Registered_Vehicle__c vehicle)
    {
        CustomerAlerts__c newAlert = new CustomerAlerts__c();
        String rem = '. Remember to utilise them soon!';

        switch on alertName {
            when 'first' 
            {
                newAlert.Name                 = 'Service Credit Expiration 1st Reminder';
                newAlert.Alert_Description__c = 'Your Service Credits are expiring in 6 months for ' + vehicle.Registration_Number__c + rem;
                newAlert.SubType__c           = 'Due 1st Reminder';

                if ( vehicle.Contact__r.Email == null || vehicle.Contact__r.Email == '' ) 
                {
                    newAlert.isSMS__c = false;   
                }
            }
            when 'second' 
            {
                newAlert.Name                 = 'Service Credit Expiration 2nd Reminder';
                newAlert.Alert_Description__c = 'Your Service Credits are expiring in 3 months for ' + vehicle.Registration_Number__c + rem;
                newAlert.SubType__c           = 'Due 2nd Reminder';
                if ( vehicle.Contact__r.Email == null || vehicle.Contact__r.Email == '' ) 
                {
                    newAlert.isSMS__c = true;   
                }
            }
            when 'third'
            {
                newAlert.Name                 = 'Service Credit Expiration 3rd Reminder';
                newAlert.Alert_Description__c = 'Your Service Credits are expiring next month for  ' + vehicle.Registration_Number__c + rem;
                newAlert.SubType__c           = 'Due 3rd Reminder';

                if ( vehicle.Contact__r.Email == null || vehicle.Contact__r.Email == '' ) 
                {
                    newAlert.isSMS__c = true;   
                }
            }
        }
       
        newAlert.Contact__c           = vehicle.Contact__c; 
        newAlert.Account__c           = vehicle.Account__c; 
        newAlert.Date__c              = today;
        newAlert.Datetime__c          = todaytime;
        newAlert.Status__c            = 'unread';
        newAlert.isAlert__c           = true;
        newAlert.isPush__c            = true;
        newAlert.isEmail__c           = true;
        newAlert.Type__c              = 'Service Credits';     
        newAlert.Registered_Vehicle__c = vehicle.Id;

        return newAlert;
    }

    private static Boolean isLastDayOfMonth (Date checkedDate)
    {
        return checkedDate == checkedDate.addMonths(1).toStartofMonth().addDays(-1);
    }
}