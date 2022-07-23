/****************************************************
* Class Name: BatchLeadToContactConverter
* Description: 1.Converts leads on opportunities to Contacts based on Chassis Number and back populates contact on Opportunity
*              2.updates opportunity stage and models interested stage to Booked/Lost
*
* Developer Name    Date      DescriptionBatchManager
* Savita          13-May-2019    Created.
****************************************************/

public class BatchLeadToContactConverter implements Database.Batchable<sObject>, Schedulable, Database.Stateful{

    public String queryString = '';
    public String batchForDataPool = '';
    public Set<String> setRegisteredVehicleIds = new Set<String>();

    public BatchLeadToContactConverter( Set<String> setRVIds ){
        setRegisteredVehicleIds = setRVIds;
        queryString = Queries.RegisteredVehicleQuery;
        queryString = queryString.subStringbefore('CreatedDate').trim().removeEnd('AND') + ' AND Id IN :setRegisteredVehicleIds';
    }

    public BatchLeadToContactConverter(){
        batchForDataPool = 'BatchLeadToContactConverter';
        queryString = Queries.RegisteredVehicleQuery;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('@@@@DEBUG BatchLeadToContactConverter :: queryString = ' + queryString );
        return database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext bc, List<Registered_Vehicle__c> lstRv){
        Map<String,Registered_Vehicle__c> chasisNumRvMap = new Map<String,Registered_Vehicle__c>();
        List<Account> accountToUpdate = new List<Account>();
        System.debug('@@@ Num RV records' +lstRv);

        /*
          PA MIGRATION when registerd_vehicle records created, related Person_Accounts will be converted to Customer type
          if they haven't
          Other processes must ensure that Registered_Vehicle__c.Account__c == Opp.Account__c
        */

        AccountSelector selector = new AccountSelector();
        RecordType customerType = selector.getAccountRecordTypeMap().get('Customer');
        
        for(Registered_Vehicle__c rv: lstRv){
            chasisNumRvMap.put( rv.Chasis_Number__c, rv );
            
            if(rv.Account__c != null && rv.Account__r.RecordTypeId != customerType.Id){
                accountToUpdate.add( new Account(Id=rv.Account__c, RecordTypeId=customerType.Id) );
            }
        }
        
        if( !chasisNumRvMap.IsEmpty() ){
            updateOppAccAndModel( chasisNumRvMap, accountToUpdate );
        }
    }

    
    public void finish(Database.BatchableContext bc){
        batchDataPool.buildBatchDataPool(batchForDataPool, bc.getJobId());
    }

    public void execute(SchedulableContext sc){
        new BatchManager('BatchLeadToContactConverter', null);
    }

    public static void updateOppAccAndModel( Map<String,Registered_Vehicle__c> chassisNumRVmap, List<Account> accountToUpdate){
        
        try
        {
            if(!chassisNumRVmap.isEmpty())
            {
                List<Stock_Reservation__c> srList = new List<Stock_Reservation__c>( Queries.getSR(chassisNumRVmap.KeySet()) );
                Map<Id,Opportunity> oppsWithLeadMap = new Map<Id,Opportunity>();
                List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
                Map<Id,Id> newConToOppMap = new Map<Id,Id>();
                Set<Id> modelIdSet = new Set<Id>();
                List<Models_Interested__c> updModelInterested = new List<Models_Interested__c>();
                List<Opportunity> finalOppUpdList = new List<Opportunity>();
                Map<Id,Id> oppIdToConIdMap = new Map<Id,Id>();
                List<sharingHelper.generateShare> lstToCreateShare = new List<sharingHelper.generateShare>();
                Map<Id,Id> oppIdToLeadIdMap = new Map<Id,Id>();
                Map<Id,Stock_Reservation__c> oppIdStockmap = new Map<Id,Stock_Reservation__c>();
                List<Opportunity> oppList= new List<Opportunity>();
                Map<String,Registered_Vehicle__c> rvToSrmap= new Map<String,Registered_Vehicle__c>();
                List<Stock_Reservation__c> srUpdList= new List<Stock_Reservation__c>();
                List<Registered_Vehicle__c> rvUpdList= new List<Registered_Vehicle__c>();
                Map<String,Id> chasisStockMap = new Map<String,Id>();

                Map<Id,Id> mapProspectToCustomer = new Map<Id,Id>();    //PA MIGRATION
                Set<Id> setProspectToRemove = new Set<Id>();            //PA MIGRATION

                System.debug('@@@@DEBUG updateOppAccAndModel :: srList = '+srList.size() +  ' --- ' + srList );
                if(!srList.isEmpty())
                {
                    for( Stock_Reservation__c sr : srList ) {
                        oppIdStockmap.put( sr.Opportunity__c, sr );
                        chasisStockMap.put( sr.Vehicle_Chassis_Number__c, sr.Id );

                        //PA MIGRATION - PA(Prospect) Id with PA(Customer) Id
                        if( sr.Opportunity__c <> null &&  sr.Opportunity__r.Account__c <> null && sr.Registered_Vehicle__r.Account__c <> null ) {
                            mapProspectToCustomer.put( sr.Opportunity__r.Account__c , sr.Registered_Vehicle__r.Account__c );
                        }
                        //2nd time initialize the map just in case the Oppotunity don't have Account lookup 
                        // if( sr.Opportunity__c <> null && sr.Opportunity__r.Lead__c <> null && sr.Opportunity__r.Lead__r.Account__c <> null ) {
                            
                        //     if( !mapProspectToCustomer.containsKey( sr.Opportunity__r.Lead__r.Account__c ) ){
                        //         mapProspectToCustomer.put( sr.Opportunity__r.Lead__r.Account__c , sr.Registered_Vehicle__r.Account__c );
                        //     }
                        // }
                    }
                    
                    if( !oppIdStockmap.isEmpty() ){
                        oppList = Queries.getOpps( oppIdStockmap.keySet() );
                    }
                }
                System.debug('@@@@DEBUG updateOppAccAndModel :: mapProspectToCustomer = '+mapProspectToCustomer);
                System.debug('@@@@DEBUG updateOppAccAndModel :: oppList = '+oppList);

                
                if(!oppList.isEmpty())
                {
                    for(Opportunity opp : oppList) {
                        modelIdSet.add(opp.Id);

                        if( opp.Lead__c != null ) {
                            oppsWithLeadMap.put( opp.Lead__c, opp );
                            oppIdToLeadIdMap.put( opp.Id, opp.Lead__c );
                        }

                    }
                }
                
                if(!oppsWithLeadMap.isEmpty())
                {
                    List<Lead> leadList= new List<Lead>( Queries.getLeads( oppsWithLeadMap.KeySet() ) );
                    if(!leadList.isEmpty()) {
                        for(Lead leadToConverted : LeadList) {
                            Database.LeadConvert lc = new database.LeadConvert();
                            if( oppsWithLeadMap.ContainsKey(leadToConverted.Id) && oppIdStockmap.ContainsKey( oppsWithLeadMap.get(leadToConverted.Id).Id ) )
                            {
                                Id contactId = chassisNumRVmap.get( oppIdStockmap.get( oppsWithLeadMap.get(leadToConverted.Id).Id).Vehicle_Chassis_Number__c ).Contact__c;
                                Id accountId = global_var__c.getOrgDefaults().JCC_Accound_ID__c;

                                //PA MIGRATION
                                // if( leadToConverted.Account__c <> null && leadToConverted.Account__r.IsPersonAccount ){
                                //     contactId = leadToConverted.Account__r.PersonContactId;
                                //     accountId = leadToConverted.Account__c;
                                //     setAcctIds.add( accountId );
                                // }
                                
                                setProspectToRemove.add( leadToConverted.Account__c );
                                
                                lc.setLeadId( leadToConverted.Id );
                                lc.ConvertedStatus = 'Qualified';
                                lc.setDoNotCreateOpportunity(true);
                                lc.setContactId( contactId );
                                lc.setAccountId( global_var__c.getOrgDefaults().JCC_Accound_ID__c );
                                lc.bypassaccountdedupecheck = false;
                                lc.bypasscontactdedupecheck = true;
                                leadConverts.add(lc);
                                newConToOppMap.put( oppsWithLeadMap.get(leadToConverted.Id).Id, contactId );
                            } 
                        }
                    }
                }

                if(!modelIdSet.isEmpty()) 
                {
                    List<Models_Interested__c> modelsInterestedList = new List<Models_Interested__c>( Queries.getModelsInterested(modelIdSet) );
                    if( !modelsInterestedList.isEmpty()) {
                        for( Models_Interested__c mi : modelsInterestedList ) {
                            if( mi.Model__c != null && oppIdStockmap.ContainsKey( mi.Opportunity__c ) && chassisNumRVmap.ContainsKey(oppIdStockmap.get(mi.Opportunity__c).Vehicle_Chassis_Number__c))
                            {
                                if( chassisNumRVmap.get(oppIdStockmap.get(mi.Opportunity__c).Vehicle_Chassis_Number__c).Variant__c!=null && chassisNumRVmap.get(oppIdStockmap.get(mi.Opportunity__c).Vehicle_Chassis_Number__c).Variant__r.Model_ID__c!=null)
                                {
                                    String modelRv = String.ValueOf(chassisNumRVmap.get(oppIdStockmap.get(mi.Opportunity__c).Vehicle_Chassis_Number__c).Variant__r.Model_ID__c);
                                    if(modelRv.Contains(mi.Model__c))
                                    {
                                        mi.status__c ='Booked';
                                        updModelInterested.add(mi);
                                    }
                                }
                             }
                        }
                        System.debug('@@@ ModelInterested'+updModelInterested);
                    }
                }

                if(!oppList.isEmpty())
                {
                    for(Opportunity opps : oppList)
                    {
                        if( oppIdStockmap.ContainsKey(opps.Id) && chassisNumRVmap.ContainsKey( oppIdStockmap.get(opps.Id).Vehicle_Chassis_Number__c ) )
                        {
                            if(chassisNumRVmap.get( oppIdStockmap.get(opps.Id).Vehicle_Chassis_Number__c).Variant__c != null 
                                && chassisNumRVmap.get( oppIdStockmap.get(opps.Id).Vehicle_Chassis_Number__c).Variant__r.Model_ID__c != null )
                            {
                                Id modelRv = String.ValueOf( chassisNumRVmap.get( oppIdStockmap.get(opps.Id).Vehicle_Chassis_Number__c ).Variant__r.Model_ID__c);
                                if(modelRv!=null)
                                {
                                    opps.Model_c__c = modelRv;
                                    opps.StageName  = 'Booked';
                                    if( oppsWithLeadMap.ContainsKey(opps.Lead__c) && newConToOppMap.containsKey(opps.Id) && newConToOppMap.get(opps.Id) != null)
                                    {
                                        opps.Lead__c = null;
                                        opps.Contact_Person__c = newConToOppMap.get(opps.Id);

                                        //PA MIGRATION : Change the PA(Prospect) to the corresponding PA(Customer) that created from DWH, before delete the PA(Prospect)
                                        if( opps.Lead__r.Account__c <> null && mapProspectToCustomer.containsKey( opps.Lead__r.Account__c )  ){
                                            opps.Account__c = mapProspectToCustomer.get( opps.Lead__r.Account__c );
                                        }
                                    }
                                    
                                    finalOppUpdList.add(opps);
                                }
                            }
                        }
                    }

                }
                System.debug('@@@@DBEUG updateOppAccAndModel :: leadConverts = ' + leadConverts.size() +' --- ' + leadConverts);
                System.debug('@@@@DBEUG updateOppAccAndModel :: finalOppUpdList = ' + finalOppUpdList.size() +' --- ' + finalOppUpdList);
                
                /** PA MIGRATION : To Remove ; No More Lead Conversion */
                if(!leadConverts.isEmpty()){
                    TriggerExclusion.excludeTrigger('Contact', true);
                    Database.LeadConvertResult[] lcrList = Database.convertLead(leadConverts);
                    TriggerExclusion.excludeTrigger('Contact', false);
                }

                if(!finalOppUpdList.isEmpty())
                {
                    TriggerExclusion.excludeTrigger('Opportunity', true);
                    System.debug('check -- finalOppUpdList = ' + finalOppUpdList );
                    update finalOppUpdList;
                    TriggerExclusion.excludeTrigger('Opportunity', false);

                    // Update newly converted contact on Test Drive,Event Regis,Custom Quote records and create new Share for that contact
                    Map<Id,Id> LeadIdToConIdMap = new Map<Id,Id>();
                    for(Opportunity opp : [SELECT Id, Contact_Person__c, Lead__c, OwnerId, Account__c FROM Opportunity WHERE Id IN :finalOppUpdList]){
                        
                        if(opp.Contact_Person__c!=null && opp.Lead__c==null)
                        {
                            oppIdToConIdMap.put( opp.Id, opp.Contact_Person__c );
                            
                            if( oppIdToLeadIdMap.ContainsKey( opp.Id ) ){
                                LeadIdToConIdMap.put( oppIdToLeadIdMap.get(opp.Id), opp.Contact_Person__c );
                            }
                            lstToCreateShare.add( new sharingHelper.generateShare('Read', 'Contact', opp.Contact_Person__c, opp.OwnerId) );
                        }

                        /** PA MIGRATION : Newly Added */
                        if( opp.Account__c != null )
                        {   
                            lstToCreateShare.add( new sharingHelper.generateShare('Read', 'Account', opp.Account__c, opp.OwnerId) );
                        }
                    }
                        
                    if(!lstToCreateShare.isEmpty())
                    {
                        sharingHelper.creatShare( lstToCreateShare );
                    }


                    System.debug('@@@@DEBUG updateOppAccAndModel :: oppIdToConIdMap = ' + oppIdToConIdMap);
                    if( !oppIdToConIdMap.isEmpty() )
                    {   
                        // List<Test_Drive__c> updTDlist = new List<Test_Drive__c>( Queries.getTestDrives ( oppIdToLeadIdMap ) );
                        List<Test_Drive__c> updTDlist = new List<Test_Drive__c>( Queries.getTestDrives( oppIdToLeadIdMap.keyset() ) );
                        for(Test_Drive__c td : updTDlist)
                        {
                            if(oppIdToConIdMap.ContainsKey(td.Opportunity__c)){
                                td.Prospect__c = oppIdToConIdMap.get(td.Opportunity__c);
                            }

                            //PA MIGRATION : Change the PA(Prospect) to the corresponding PA(Customer) that created from DWH, before delete the PA(Prospect)
                            if( td.Lead__r.Account__c <> null && mapProspectToCustomer.containsKey( td.Lead__r.Account__c ) ){
                                td.Account__c = mapProspectToCustomer.get( td.Lead__r.Account__c  );
                            }
                        }

                        if(!updTDlist.isEmpty()){
                            TriggerExclusion.excludeTrigger('TestDrive', true);
                            System.debug('check -- updTDlist = ' + updTDlist );
                            update updTDlist;
                            TriggerExclusion.excludeTrigger('TestDrive', false);
                        }
                    }

                    if(!LeadIdToConIdMap.isEmpty())
                    {
                        List<Event_Registration__c> updERlist = new List<Event_Registration__c>(Queries.getEventRegistrations(LeadIdToConIdMap));
                        List<Custom_Quote__c> updCustQuotelist = new List<Custom_Quote__c>(Queries.getCustomQuotes(LeadIdToConIdMap));

                        for(Event_Registration__c er : updERlist) {
                            if( LeadIdToConIdMap.containsKey( er.LeadId__c ) ){
                                er.ContactId__c = LeadIdToConIdMap.get(er.LeadId__c);
                            }

                            //PA MIGRATION : Change the PA(Prospect) to the corresponding PA(Customer) that created from DWH, before delete the PA(Prospect)
                            if( er.LeadId__r.Account__c <> null && mapProspectToCustomer.containsKey( er.LeadId__r.Account__c ) ){
                                er.Account__c = mapProspectToCustomer.get( er.LeadId__r.Account__c );
                            }
                        }

                        for(Custom_Quote__c cs : updCustQuotelist) {
                            if( LeadIdToConIdMap.containsKey( cs.Lead__c ) ){
                                cs.Contact__c = LeadIdToConIdMap.get(cs.Lead__c);
                            }

                            //PA MIGRATION : Change the PA(Prospect) to the corresponding PA(Customer) that created from DWH, before delete the PA(Prospect)
                            if( cs.Lead__r.Account__c <> null && mapProspectToCustomer.containsKey( cs.Lead__r.Account__c ) ){
                                cs.Account__c = mapProspectToCustomer.get( cs.Lead__r.Account__c );
                            }
                        }
                        
                        if(!updERlist.isEmpty()){
                            TriggerExclusion.excludeTrigger('Event_Registration__c', true);
                            System.debug('check -- updERlist = ' + updERlist );
                            update updERlist;
                            TriggerExclusion.excludeTrigger('Event_Registration__c', false);
                        }
                        
                        if(!updCustQuotelist.isEmpty()){
                            TriggerExclusion.excludeTrigger('Custom_Quote__c ', true);
                            System.debug('check -- updCustQuotelist = ' + updCustQuotelist );
                            update updCustQuotelist;
                            TriggerExclusion.excludeTrigger('Custom_Quote__c ', false);
                        }
                    }
              
                    if(!updModelInterested.isEmpty()){
                        update updModelInterested;
                    }
                }

                if(!chassisNumRVmap.values().isEmpty())
                {
                    for(Registered_Vehicle__c rv : chassisNumRVmap.values()){
                        if(!chasisStockMap.isEmpty() && chasisStockMap.containsKey(rv.Chasis_Number__c)){
                            rv.LeadBatchProcessed__c = true;
                            rvToSrmap.put(rv.Chasis_Number__c,rv);
                            rvUpdList.add(rv);
                        }
                    }
                    
                    if( !srList.IsEmpty() ){
                        for(Stock_Reservation__c sr : srList){
                            if(rvToSrmap.containsKey(sr.Vehicle_Chassis_Number__c) && rvToSrmap.get(sr.Vehicle_Chassis_Number__c).LeadBatchProcessed__c){
                                sr.LeadBatchProcessed__c = true;
                                sr.Registered_Vehicle__c = rvToSrmap.get(sr.Vehicle_Chassis_Number__c).id;
                                srUpdList.add(sr);
                            }
                        }
                    }
              
                    if( !rvUpdList.isEmpty() ){
                        TriggerExclusion.excludeTrigger('Registered_Vehicle__c', true);
                        System.debug('check -- rvUpdList = ' + rvUpdList );
                        update rvUpdList;
                        TriggerExclusion.excludeTrigger('Registered_Vehicle__c', false);
                    }
                
                    if( !srUpdList.isEmpty() ){
                        TriggerExclusion.excludeTrigger('Stock Reservation', true);
                        System.debug('check -- srUpdList = ' + srUpdList );
                        update srUpdList;
                        TriggerExclusion.excludeTrigger('Stock Reservation', false);
                    }


                    if( !setProspectToRemove.isEmpty() ){
                        TriggerExclusion.excludeTrigger('Stock Reservation', true);
                        List<Account> lstProspectToDelete = [SELECT Id FROM Account WHERE Id IN :setProspectToRemove ];
                        System.debug('check -- lstProspectToDelete = ' + lstProspectToDelete );
                        delete lstProspectToDelete;
                        TriggerExclusion.excludeTrigger('Stock Reservation', false);
                    }
                }
            }
        }
        catch(Exception e){
            loggerDataPool.buildLogDataPool('BatchLeadToContactConverter.execute',e);

        }
    }

}