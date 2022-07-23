public class BatteryChange implements Schedulable{
    
    public void execute (SchedulableContext ctx)
    {   
        customerAlert();
    }  
    
    public static void customerAlert(){
        Date dt = System.today();
        Date twentytwoMonthsAgo = dt.addMonths(-22);
        Date twentythreeMonthsAgo = dt.addMonths(-23);
        List<CustomerAlerts__c> lstcustAlert = new List<CustomerAlerts__c >();
        try{
            for(Registered_Vehicle__c reg : [SELECT id,Contact__c,Last_Battery_Change__c,OwnerId,Registration_Number__c, Account__c from Registered_Vehicle__c WHERE Last_Battery_Change__c != null AND Last_Battery_Change__c =: twentytwoMonthsAgo]){
                CustomerAlerts__c custAlert = new CustomerAlerts__c();
                custAlert.Name = 'Battery Change Reminder';
                custAlert.Contact__c = reg.Contact__c;                  /** PA Migration : To Remove */
                custAlert.Registered_Vehicle__c = reg.Id;
                custAlert.OwnerId = reg.OwnerId;
                //custAlert.Alert_Description__c = 'On average, car battery lasts less than 2 years. Your car battery for '+reg.Registration_Number__c+' is recommended for a free battery check.';
                custAlert.Alert_Description__c = 'Is your car battery healthy? Find out why it is important to check the condition of your car battery.';
                custAlert.Date__c = System.today();
                custAlert.DateTime__c = System.now();
                custAlert.Status__c = 'unread';
                custAlert.Type__c = 'Battery Change';
                custAlert.SubType__c = 'Due 1st Reminder';
                custAlert.isAlert__c = true;
                custAlert.isPush__c = true;
                custAlert.Account__c = reg.Account__c;    /** PA Migration : Newly Added */
                lstcustAlert.add(custAlert);
            }
            for(Registered_Vehicle__c reg : [SELECT id,Contact__c,Last_Battery_Change__c,OwnerId,Registration_Number__c, Account__c from Registered_Vehicle__c WHERE Last_Battery_Change__c != null AND Last_Battery_Change__c =: twentythreeMonthsAgo]){
                CustomerAlerts__c custAlert = new CustomerAlerts__c();
                custAlert.Name = 'Battery Change Reminder';
                custAlert.Contact__c = reg.Contact__c;                  /** PA Migration : To Remove */
                custAlert.Registered_Vehicle__c = reg.Id;
                custAlert.OwnerId = reg.OwnerId;
                //custAlert.Alert_Description__c = 'Do not be caught in an unpleasant situation. Visit our Drive-In Tyre Shop for a free battery check now!';
                custAlert.Alert_Description__c  = 'Is your car battery healthy? Find out why it is important to check the condition of your car battery.';
                custAlert.Date__c = System.today();
                custAlert.DateTime__c = System.now();
                custAlert.Status__c = 'unread';
                custAlert.Type__c = 'Battery Change';
                custAlert.SubType__c = 'Due 2nd Reminder';
                custAlert.isAlert__c = true;
                custAlert.isPush__c = true;
                custAlert.Account__c = reg.Account__c;    /** PA Migration : Newly Added */
                lstcustAlert.add(custAlert);
            }
            if(!lstcustAlert.isEmpty()){
                Database.SaveResult[] customerAlertResults = Database.Insert(lstcustAlert,False);
                for(Integer index = 0, size = customerAlertResults.size(); index < size; index++){
                    if(!customerAlertResults[index].isSuccess()){
                        system.debug(lstcustAlert[index] +' has error '+customerAlertResults[index].getErrors());
                    }
                }
            }
        }
        catch(Exception e){      
            loggerDataPool.buildLogDataPool('BatteryChange',e);
        }
    }
    
    public static void customerAlertTest( Set<String> setRegVehicles ){
        Date dt = System.today();
        Date twentytwoMonthsAgo = dt.addMonths(-22);
        Date twentythreeMonthsAgo = dt.addMonths(-23);
        List<CustomerAlerts__c> lstcustAlert = new List<CustomerAlerts__c >();
        try{
            Set<String> regVehIds = new Set<String>();
            
            for(AlertsRegisteredVehicle__mdt art : [SELECT DeveloperName FROM AlertsRegisteredVehicle__mdt]){
                regVehIds.add(art.DeveloperName);
            }
            
            if( !setRegVehicles.isEmpty() ){
                regVehIds.addAll( setRegVehicles );
                regVehIds.remove( null );
            }
            
            for(Registered_Vehicle__c reg : [SELECT id,Contact__c,Last_Battery_Change__c,OwnerId,Registration_Number__c, Account__c from Registered_Vehicle__c WHERE Last_Battery_Change__c != null AND Last_Battery_Change__c =: twentytwoMonthsAgo AND Id IN: regVehIds]){
                CustomerAlerts__c custAlert = new CustomerAlerts__c();
                custAlert.Name = 'Battery Change Reminder';
                custAlert.Contact__c = reg.Contact__c;                 //PA Migration : To Remove
                custAlert.Registered_Vehicle__c = reg.Id;
                custAlert.OwnerId = reg.OwnerId;
                //custAlert.Alert_Description__c = 'On average, car battery lasts less than 2 years. Your car battery for '+reg.Registration_Number__c+' is recommended for a free battery check.';
                custAlert.Alert_Description__c = 'Is your car battery healthy? Find out why it is important to check the condition of your car battery.';
                custAlert.Date__c = System.today();
                custAlert.DateTime__c = System.now();
                custAlert.Status__c = 'unread';
                custAlert.Type__c = 'Battery Change';
                custAlert.SubType__c = 'Due 1st Reminder';
                custAlert.isAlert__c = true;
                custAlert.isPush__c = true;
                custAlert.Account__c = reg.Account__c;   // PA Migration : Newly Added 
                lstcustAlert.add(custAlert);
            }
            for(Registered_Vehicle__c reg : [SELECT id,Contact__c,Last_Battery_Change__c,OwnerId,Registration_Number__c, Account__c from Registered_Vehicle__c WHERE Last_Battery_Change__c != null AND Last_Battery_Change__c =: twentythreeMonthsAgo AND Id IN: regVehIds]){
                CustomerAlerts__c custAlert = new CustomerAlerts__c();
                custAlert.Name = 'Battery Change Reminder';
                custAlert.Contact__c = reg.Contact__c;                 //PA Migration : To Remove 
                custAlert.Registered_Vehicle__c = reg.Id;
                custAlert.OwnerId = reg.OwnerId;
                //custAlert.Alert_Description__c = 'Do not be caught in an unpleasant situation. Visit our Drive-In Tyre Shop for a free battery check now!';
                custAlert.Alert_Description__c  = 'Is your car battery healthy? Find out why it is important to check the condition of your car battery.';
                custAlert.Date__c = System.today();
                custAlert.DateTime__c = System.now();
                custAlert.Status__c = 'unread';
                custAlert.Type__c = 'Battery Change';
                custAlert.SubType__c = 'Due 2nd Reminder';
                custAlert.isAlert__c = true;
                custAlert.isPush__c = true;
                custAlert.Account__c = reg.Account__c;    //PA Migration : Newly Added 
                lstcustAlert.add(custAlert);
            }
            if(!lstcustAlert.isEmpty()){
                Database.SaveResult[] customerAlertResults = Database.Insert(lstcustAlert,False);
                for(Integer index = 0, size = customerAlertResults.size(); index < size; index++){
                    if(!customerAlertResults[index].isSuccess()){
                        system.debug(lstcustAlert[index] +' has error '+customerAlertResults[index].getErrors());
                    }
                }
            }
        }
        catch(Exception e){      
            loggerDataPool.buildLogDataPool('BatteryChange',e);
        }
    }
    
    
}