/** *****
 * Description : Class to create new Customer Alerts for Accessories Credits Expiration
 * 
 * Change History:
 * Date(YYYYMMDD)       Developer               Details
 * 20210512            tphan@aodigy.com      Created initial version
 * 20211001            tphan@aodigy.com      Enhanced to cater more scenarios
 ** *****/

global class accessoriesCreditExpirationReminder implements Schedulable, Database.Batchable<sObject>, Database.Stateful
{
    private static List<CustomerAlerts__c> newAlerts = new List<CustomerAlerts__c>();
    private static Date today = date.today();  /*Date.newInstance(2021, 2, 28);*/
    private static Datetime todaytime  = datetime.now();
    private static Date nextMonth      = today.addMonths(1);
    private static Date nextThreeMonth = today.addMonths(3);
    private static Date nextSixMonth   = today.addMonths(6);

    private static Date lastDateOfNextMonth      = today.day() == 30 && isLastDayOfMonth(today) ? nextMonth.addDays(1) : null;
    private static Date lastDateOfNextThreeMonth = today.day() == 30 && isLastDayOfMonth(today) ? nextThreeMonth.addDays(1) : null;
    private static Date lastDateOfNextSixMonth   = today.day() == 30 && isLastDayOfMonth(today) ? nextSixMonth.addDays(1) : null;

    private static Date nextMonthTo      = today.month() == 2 ? (today.day() == 28 ? nextMonth.addDays(3)      : (today.day() == 29 ? nextMonth.addDays(2)      : null)) : null;
    private static Date nextThreeMonthTo = today.month() == 2 ? (today.day() == 28 ? nextThreeMonth.addDays(3) : (today.day() == 29 ? nextThreeMonth.addDays(2) : null)) : null;
    private static Date nextSixMonthTo   = today.month() == 2 ? (today.day() == 28 ? nextSixMonth.addDays(3)   : (today.day() == 29 ? nextSixMonth.addDays(2)   : null)) : null;

    public Set<Id> setIdsOfVehCredit = new Set<Id>();
    public String  expiryDate        = '';
    public Boolean isFeb             = false;
    
    global accessoriesCreditExpirationReminder(){}
    
    global accessoriesCreditExpirationReminder( Set<Id> setIdsOfVehicleCredit, String checkedDate )
    {
        setIdsOfVehCredit = setIdsOfVehicleCredit;
        expiryDate        = checkedDate;
        System.debug('@@@@DEBUG accessoriesCreditExpirationReminder :: setIdsOfVehCredit ' + setIdsOfVehCredit);
    }

    global void execute (SchedulableContext ctx)
    {
        System.debug('@@@@DEBUG schc.exe :: setIdsOfVehCredit ' + setIdsOfVehCredit);
        
        //invoke schc itself
        // accessoriesCreditExpirationReminder();

        //invoke batch
        Database.executebatch(new accessoriesCreditExpirationReminder( setIdsOfVehCredit, expiryDate ),200);
    }    

    //Batch Start
    public Iterable<sObject> start(Database.Batchablecontext BC)
    {
        ID vrecordTypeID = Schema.SObjectType.Vehicle_Credit__c.getRecordTypeInfosByDeveloperName().get('Accessories_Credit').getRecordTypeId();
        String strSOQL = 'SELECT Id, Expiry_Date__c, Credit_Balance__c, Registered_Vehicle__c, Registered_Vehicle__r.Registration_Number__c, Registered_Vehicle__r.Account__c, Registered_Vehicle__r.Contact__c, Registered_Vehicle__r.Contact__r.Email FROM Vehicle_Credit__c  WHERE Status__c = \'Active\' AND Type__c = \'Accessories\' AND RecordTypeId =: vrecordTypeID AND Credit_Balance__c > 0 AND Expiry_Date__c != null ';
        if( setIdsOfVehCredit <> null && !setIdsOfVehCredit.isEmpty() )
        {
            strSOQL += ' AND ID IN : setIdsOfVehCredit ';
        }
        else if (String.isNotBlank(expiryDate))
        {
            Date expiryDate = Date.valueOf(expiryDate);
            strSOQL += ' AND Expiry_Date__c =: expiryDate ';
        }
        else
        {        
            if (nextMonthTo <> null || nextThreeMonthTo <> null || nextSixMonthTo <> null)
            {
                isFeb = true;
                strSOQL += ' AND ((Expiry_Date__c >= :nextMonth AND Expiry_Date__c <= :nextMonthTo) OR (Expiry_Date__c >= :nextThreeMonth AND Expiry_Date__c <= :nextThreeMonthTo) OR (Expiry_Date__c >= :nextSixMonth AND Expiry_Date__c <= :nextSixMonthTo)) ';
            }
            else if (lastDateOfNextMonth <> null || lastDateOfNextThreeMonth <> null || lastDateOfNextSixMonth <> null)
            {
                strSOQL += ' AND (Expiry_Date__c =: nextMonth OR Expiry_Date__c =: nextThreeMonth OR Expiry_Date__c =: nextSixMonth OR Expiry_Date__c =: lastDateOfNextMonth OR Expiry_Date__c =: lastDateOfNextThreeMonth OR Expiry_Date__c =: lastDateOfNextSixMonth)';   
            }
            else 
            {
                strSOQL += ' AND (Expiry_Date__c =: nextMonth OR Expiry_Date__c =: nextThreeMonth OR Expiry_Date__c =: nextSixMonth)';
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
                for (Vehicle_Credit__c credit : (List<Vehicle_Credit__c>) scope)
                {
                    if (isFeb)
                    {
                        if (credit.Expiry_Date__c >= nextSixMonth && credit.Expiry_Date__c <= nextSixMonthTo)
                        {                          
                            newAlerts.add(createCustomerAlert('first', credit));
                        }
                        else if (credit.Expiry_Date__c >= nextThreeMonth && credit.Expiry_Date__c <= nextThreeMonthTo)
                        {
                            newAlerts.add(createCustomerAlert('second', credit));
                        }
                        else if (credit.Expiry_Date__c >= nextMonth && credit.Expiry_Date__c <= nextMonthTo) 
                        {
                            newAlerts.add(createCustomerAlert('third', credit));
                        }
                    }
                    else 
                    {
                        if ((credit.Expiry_Date__c == nextSixMonth) || (lastDateOfNextSixMonth <> null && credit.Expiry_Date__c == lastDateOfNextSixMonth))
                        {
                            newAlerts.add(createCustomerAlert('first', credit));
                        }
                        else if ((credit.Expiry_Date__c == nextThreeMonth) || (lastDateOfNextThreeMonth <> null && credit.Expiry_Date__c == lastDateOfNextThreeMonth))
                        {
                            newAlerts.add(createCustomerAlert('second', credit));
                        }
                        else if ((credit.Expiry_Date__c == nextMonth) || (lastDateOfNextMonth <> null && credit.Expiry_Date__c == lastDateOfNextMonth))
                        {
                            newAlerts.add(createCustomerAlert('third', credit));
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
            loggerDataPool.buildLogDataPool('accessoriesCreditExpirationReminder', e);
        }       
    }

    //Batch End
    public void finish(Database.BatchableContext info){}

    public static void accessoriesCreditExpirationReminder()
    {   
        Database.executebatch(new accessoriesCreditExpirationReminder( null, null ),200);
    }

    private static CustomerAlerts__c createCustomerAlert (String alertName, Vehicle_Credit__c credit)
    {
        CustomerAlerts__c newAlert = new CustomerAlerts__c();
        String rem =  'Use them at myC&C mobile app eShop now!';

        switch on alertName {
            when 'first' 
            {
                newAlert.Name                 = 'Accessories Credit Expiration 1st Reminder';
                newAlert.Alert_Description__c = 'Your Accessories Credits for ' + credit.Registered_Vehicle__r.Registration_Number__c  + ' are expiring in 6 months. ' + rem;
                newAlert.SubType__c           = 'Due 1st Reminder';

                if ( newAlert.Registered_Vehicle__r.Contact__r.Email == null || newAlert.Registered_Vehicle__r.Contact__r.Email == '' ) 
                {
                    newAlert.isSMS__c = false;   
                }
            }
            when 'second' 
            {
                newAlert.Name                 = 'Accessories Credit Expiration 2nd Reminder';
                newAlert.Alert_Description__c = 'Your Accessories Credits for ' + credit.Registered_Vehicle__r.Registration_Number__c  + ' are expiring in 3 months. ' + rem;
                newAlert.SubType__c           = 'Due 2nd Reminder';

                if ( newAlert.Registered_Vehicle__r.Contact__r.Email == null || newAlert.Registered_Vehicle__r.Contact__r.Email == '' ) 
                {
                    newAlert.isSMS__c = true;   
                }
            }
            when 'third'
            {
                newAlert.Name                 = 'Accessories Credit Expiration 3rd Reminder';
                newAlert.Alert_Description__c = 'Your Accessories Credits for ' + credit.Registered_Vehicle__r.Registration_Number__c  + ' are expiring next month. ' + rem;
                newAlert.SubType__c           = 'Due 3rd Reminder';

                if ( newAlert.Registered_Vehicle__r.Contact__r.Email == null || newAlert.Registered_Vehicle__r.Contact__r.Email == '' ) 
                {
                    newAlert.isSMS__c = true;   
                }
            }
        }
       
        newAlert.Contact__c           = credit.Registered_Vehicle__r.Contact__c; 
        newAlert.Account__c           = credit.Registered_Vehicle__r.Account__c; 
        newAlert.Date__c              = today;
        newAlert.Datetime__c          = todaytime;
        newAlert.Status__c            = 'unread';
        newAlert.isAlert__c           = true;
        newAlert.isPush__c            = true;
        newAlert.isEmail__c           = true;
        newAlert.Type__c              = 'Accessories Credits';     
        newAlert.Registered_Vehicle__c = credit.Registered_Vehicle__c;
        newAlert.Vehicle_Credit__c    = credit.Id;

        return newAlert;
    }

    private static Boolean isLastDayOfMonth (Date checkedDate)
    {
        return checkedDate == checkedDate.addMonths(1).toStartofMonth().addDays(-1);
    }
}