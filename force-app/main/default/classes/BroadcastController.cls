/** ******
 * Description : Controller class that used from Broadcast.lwc
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name       Description
 * 20200220            HS         Created Initial Version
 * 20200901            TPhan      Made changes to cater for RA and NonC&C Cars - IDP Revamp Phase 2
** ******/
public with sharing class BroadcastController 
{
    
    public BroadcastController() {}

    static Integer PAGE_SIZE = 150;

    @AuraEnabled(Cacheable=true)
    public static PagedResult getFilteredRegVehicles( BroadcastFilterWrapper filters, Integer pageNumber ) 
    {

        System.debug('@@@@DEBUG getFilteredRegVehicles :: filters = ' + filters );

        PagedResult result                                = new PagedResult();
        Broadcast_Configuration__mdt customMtd            = new Broadcast_Configuration__mdt();
        String[] branches, models, variants, criteria     = new List<String>{};
        List<PagedResult.DataTableColumns> lstDataColumns = new List<PagedResult.DataTableColumns>();
        List<SObject> lstDataTableData                    = new List<SObject>();
        List<String> columnList, fieldAPINameList         = new List<String>();
        String whereClause                                = ' WHERE Contact__r.Device__c != null';
        
        try
        {
            customMtd = getCustomMtd(filters.vehicleType);

            if (filters != null) 
            {   
                if(String.isNotBlank(customMtd.Header_Value__c))
                {
                    columnList = customMtd.Header_Value__c.split(',');
                } 
                
                if(String.isNotBlank(customMtd.Field_Value__c))
                {
                    fieldAPINameList = customMtd.Field_Value__c.split(',');
                }   
                
                for(Integer i = 0; i < columnList.size(); i++)
                {        
                    PagedResult.DataTableColumns datacolumns = new PagedResult.DataTableColumns( columnList[i].trim() , 
                                                                                                 fieldAPINameList[i].substringBefore(':').trim(), 
                                                                                                 fieldAPINameList[i].substringAfter(':').trim());
        
                    lstDataColumns.add(datacolumns);
                }

                result.lstDataTableColumns = lstDataColumns;

                if ( filters.branches != null && !filters.branches.isEmpty() ) 
                {
                    branches = filters.branches;
                    criteria.add(' Branch__c IN :branches ');
                }
                
                if ( filters.models != null && !filters.models.isEmpty() ) 
                {
                    models = filters.models;
                    criteria.add(' Variant__r.Model_ID__c IN :models ');
                }

                if ( filters.variants != null && !filters.variants.isEmpty() ) 
                {
                    variants = filters.variants;
                    criteria.add(' Variant__c IN :variants ');
                }

                if ( !String.isEmpty( filters.bdayMonthFrom ) ) 
                { 
                    Integer intBdayMthFrom = Integer.valueOf( filters.bdayMonthFrom );
                    criteria.add(' CALENDAR_MONTH( Contact__r.BirthDate ) >= :intBdayMthFrom ' );
                }

                if ( !String.isEmpty( filters.bdayMonthTo ) ) 
                { 
                    Integer intBdayMthTo   = Integer.valueOf( filters.bdayMonthTo );
                    criteria.add('  CALENDAR_MONTH( Contact__r.BirthDate ) <= :intBdayMthTo ' );
                }

                if ( !String.isEmpty( filters.carAgeFrom ) ) 
                { 
                    Integer intCarAgeFrom = Integer.valueOf( filters.carAgeFrom );
                    if (filters.vehicleType == 'Registered_Vehicle__c')
                    {
                        criteria.add(' Vehicle_Age__c >= :intCarAgeFrom ' );
                    }
                    else if (filters.vehicleType == 'Used_Car_Vehicle_Stock__c')
                    {
                        criteria.add(' Age_of_Vehicle__c >= :intCarAgeFrom ' );
                    }
                }

                if ( !String.isEmpty( filters.carAgeTo ) ) 
                { 
                    Integer intCarAgeTo   = Integer.valueOf( filters.carAgeTo );
                    if (filters.vehicleType == 'Registered_Vehicle__c')
                    {
                        criteria.add('  Vehicle_Age__c <= :intCarAgeTo ' );
                    }
                    else if (filters.vehicleType == 'Used_Car_Vehicle_Stock__c')
                    {
                        criteria.add(' Age_of_Vehicle__c <= :intCarAgeTo ' );
                    }
                }

                if(!String.isEmpty( filters.lastServiceDateFrom ) )
                {
                    Date lastServDateFrom = Date.valueOf( filters.lastServiceDateFrom );
                    if (filters.vehicleType == 'Registered_Vehicle__c')
                    {
                        criteria.add(' Last_Service_Booking_Date__c >= :lastServDateFrom ' );
                    }
                    else if (filters.vehicleType == 'Non_C_C_Vehicle__c')
                    {
                        criteria.add(' Last_Service_Date__c >= :lastServDateFrom ' );
                    }
                }

                if( !String.isEmpty( filters.lastServiceDateTo ))
                {
                    Date lastServDateTo = Date.valueOf( filters.lastServiceDateTo );
                    if (filters.vehicleType == 'Registered_Vehicle__c')
                    {
                        criteria.add(' Last_Service_Booking_Date__c <= :lastServDateTo ' );
                    }
                    else if (filters.vehicleType == 'Non_C_C_Vehicle__c')
                    {
                        criteria.add(' Last_Service_Date__c <= :lastServDateTo ' );
                    }                                
                }

                if( !String.isEmpty( filters.upcomingServiceDateFrom ) )
                {
                    Date upcomingServDateFrom = Date.valueOf( filters.upcomingServiceDateFrom );
                    criteria.add(' Next_Service_Booking_Date__c >= :upcomingServDateFrom ' );
                }

                if( !String.isEmpty( filters.upcomingServiceDateTo ) )
                {
                    Date upcomingServDateTo = Date.valueOf( filters.upcomingServiceDateTo );
                    criteria.add(' Next_Service_Booking_Date__c <= :upcomingServDateTo ' );
                }

                if (String.isNotEmpty(filters.registrationDateFrom))
                {
                    Date registrationDateFrom = Date.valueOf(filters.registrationDateFrom);
                    if (filters.vehicleType == 'Used_Car_Vehicle_Stock__c')
                    {
                        criteria.add('Registration_Date__c >= :registrationDateFrom');
                    }
                    else if (filters.vehicleType == 'Non_C_C_Vehicle__c') 
                    {
                        criteria.add('Registered_Date__c >= :registrationDateFrom');
                    }
                }

                if (String.isNotEmpty(filters.registrationDateTo))
                {
                    Date registrationDateTo = Date.valueOf(filters.registrationDateTo);
                    if (filters.vehicleType == 'Used_Car_Vehicle_Stock__c')
                    {
                        criteria.add('Registration_Date__c <= :registrationDateTo');
                    }
                    else if (filters.vehicleType == 'Non_C_C_Vehicle__c') 
                    {
                        criteria.add('Registered_Date__c <= :registrationDateTo');
                    }
                }

                if (String.isNotBlank(filters.MileageFrom))
                {
                    Integer mileageFrom = Integer.valueOf(filters.MileageFrom);
                    if (filters.vehicleType == 'Used_Car_Vehicle_Stock__c')
                    {
                        criteria.add('Mileage__c >= :mileageFrom');
                    }
                    else if (filters.vehicleType == 'Non_C_C_Vehicle__c') 
                    {
                        criteria.add('Current_Mileage__c >= :mileageFrom');
                    }
                }

                if (String.isNotBlank(filters.MileageTo))
                {
                    Integer mileageTo = Integer.valueOf(filters.MileageTo);
                    if (filters.vehicleType == 'Used_Car_Vehicle_Stock__c')
                    {
                        criteria.add('Mileage__c <= :mileageTo');
                    }
                    else if (filters.vehicleType == 'Non_C_C_Vehicle__c') 
                    {
                        criteria.add('Current_Mileage__c <= :mileageTo');
                    }
                }

                if ( criteria.size() > 0 ) 
                {
                    whereClause += ' AND ' + String.join(criteria, ' AND ');
                }
            }

            Integer pageSize = BroadcastController.PAGE_SIZE;
            Integer offset   = (pageNumber - 1) * pageSize;

            result.dataTableTitle = customMtd.Label;
            result.pageSize       = pageSize;
            result.pageNumber     = pageNumber;

            if ( criteria.size() > 0 ) 
            {
                result.totalItemCount = Database.countQuery( 'SELECT count() FROM ' +  filters.vehicleType  + whereClause  );

                String strSOQL = 'SELECT ' + customMtd.Query__c + ' FROM ' +  filters.vehicleType + whereClause;

                strSOQL += pageNumber > 0 ? ' ORDER BY Name LIMIT :pageSize OFFSET :offset ' : ' ORDER BY Name '; 
                
                for(SObject item : Database.query(strSOQL))
                {
                    lstDataTableData.add(item);
                }
                
                result.records = lstDataTableData;          
                System.debug('@@@@DEBUG getFilteredRegVehicles ::  strSOQL = ' + strSOQL );
            }
            else
            {
                result.totalItemCount = 0;
                result.records = new List<SObject>();
            }
            
            System.debug('@@@@DEBUG getFilteredRegVehicles :: totalItemCount = ' + result.totalItemCount + ' record size  = ' + result.records.size() );
        }
        catch( Exception ex )
        {
            System.debug('@@@@DEBUG getFilteredRegVehicles ERROR :: err msg = ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
        }
        
        return result;
    }

    @AuraEnabled(Cacheable=true)
    public static string createBroadcastAlert( BroadcastFilterWrapper filters, String alertMessage, String subType, String campaignRefId, String deepLinkingURL, String alertName)
    {
        
        System.debug('@@@@DEBUG createBroadcastAlert :: filters =  ' + filters);
        System.debug('@@@@DEBUG createBroadcastAlert :: alertMessage =  ' + alertMessage);
        
        Map<String,String> mapStatusMsg = new Map<String,String>();
        try
        {
            PagedResult pgResult = BroadcastController.getFilteredRegVehicles( filters, 0 );
            System.debug('@@@@DEBUG createBroadcastAlert :: pgResult =  ' + pgResult);

            BroadcastCreationBatch bJob = new BroadcastCreationBatch( filters, alertMessage, subType, campaignRefId, deepLinkingURL, alertName);
            Database.executeBatch( bJob , 200 );
            mapStatusMsg.put('status', 'success');
            mapStatusMsg.put('totalitem', String.valueOf( pgResult.totalItemCount ) );
        }
        catch( Exception ex )
        {
            System.debug('@@@@DEBUG createBroadcastAlert :: err cause = ' + ex.getCause() + ' --- err msg = ' + ex.getMessage() );
            mapStatusMsg.put('status', 'error');
            mapStatusMsg.put('message', ex.getMessage() );
        }

        return JSON.serialize( mapStatusMsg );
    }

    public static void createBroadcastRecords( List<SObject> lstVehicles , String strAlertMsg, String subType, String strCampaignId, String strDeepLinkingURL, String alertName )
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {  CustomerAlerts__c.SObjectType });
        
        List<CustomerAlerts__c> lstCustAlert = new List<CustomerAlerts__c>();

        try
        {   
            String vehicleType = lstVehicles[0].Id.getSObjectType().getDescribe().getName();
            for( SObject vehicle : lstVehicles )
            {
                CustomerAlerts__c newAlert      = BroadcastController.initBroadcastRecord(null, vehicle);
                newAlert.Campaign__c            = String.isNotBlank( strCampaignId ) ? (Id) strCampaignId : null;
                newAlert.Description__c         = strAlertMsg;
                newAlert.Alert_Description__c   = strAlertMsg.left(254);
                newAlert.SubType__c             = String.isNotBlank( subType ) ? subType : newAlert.SubType__c;
                newAlert.Deep_Linking_URL__c    = strDeepLinkingURL;
                newAlert.Name                   = alertName;
                newAlert.put(vehicleType, (String)vehicle.get('Id'));
                
                lstCustAlert.add( newAlert );
            }
            System.debug('@@@@DEBUG createBroadcastRecords :: lstCustAlert = ' + lstCustAlert.size() );
            uow.registerNew( lstCustAlert );
            uow.commitWork();
        }
        catch( Exception ex )
        {
            loggerDataPool.buildLogDataPool('BroadcastController >> createBroadcastRecords', ex);
            throw ex;
        }
    }


    public static void pushCustomerBroadcast( Set<Id> setCustAlertBroacastId )
    {     
        String strMessage = '';
        String strDeviceTokens = '';
		String strDeepLink = '';
		String strBranchCode = '';

        try
        {
            if( setCustAlertBroacastId <> null && setCustAlertBroacastId.size() > 0 )
            {
                for( CustomerAlerts__c cAlert : [SELECT Id, Description__c, Contact__c, Contact_Device_Token__c , 
												Deep_Linking_URL__c, Branch_Code_Vehicle__c
                                                FROM CustomerAlerts__c 
                                                WHERE RecordType.DeveloperName = 'Broadcast'
                                                AND ID IN :setCustAlertBroacastId ]) 
                {
                    strDeviceTokens += '"'+ cAlert.Contact_Device_Token__c + '"' + ',';
                    strMessage = cAlert.Description__c;
					strDeepLink = cAlert.Deep_Linking_URL__c;
					strBranchCode = cAlert.Branch_Code_Vehicle__c;
                }

                strDeviceTokens += appendTestToken(); //To Remove
                strDeviceTokens = strDeviceTokens.trim().removeEnd(',');


                System.debug('@@@@DEBUG BroadcastPushAlertQueueable <<execute>> :: strMessage = ' + strMessage );
                System.debug('@@@@DEBUG BroadcastPushAlertQueueable <<execute>> :: strDeviceTokens = ' + strDeviceTokens );
                System.debug('@@@@DEBUG BroadcastPushAlertQueueable <<execute>> :: System.IsBatch() = ' + System.IsBatch() );
                System.debug('@@@@DEBUG BroadcastPushAlertQueueable <<execute>> :: System.isFuture() = ' + System.isFuture() );
				System.debug('@@@@DEBUG BroadcastPushAlertQueueable <<execute>> :: BranchCode = ' + strBranchCode );

                if( String.isNotBlank( strMessage ) && String.isNotBlank( strDeviceTokens ) ) 
                {
                    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults(); 
                    String strkeyword = (String)JCC_GlobalVar.TriggeredPush__c;
                    // send_PushMessage.SENDAPPPUSH_MultipleTokens( strMessage, strDeepLink, strDeviceTokens );
                    if(strBranchCode != 'CCI' || String.isBlank(strBranchCode))
					{
                        send_PushMessage.SENDAPPPUSH_MultipleTokens( strMessage, strDeepLink, strDeviceTokens );
						System.debug('@@@@DEBUG BroadcastPushAlertQueueable <<execute>> :: MF call push' + strBranchCode);
                    }
					if(strBranchCode == 'CCI') //MB car only
					{
						send_PushMessage.SENDAPPPUSH_MultipleTokensForMB( strMessage, strDeepLink, strDeviceTokens );
						System.debug('@@@@DEBUG BroadcastPushAlertQueueable <<execute>> :: CCI call push' + strBranchCode );
                    }
					// BroadcastController.SENDAPPPUSH( strMessage, strDeviceTokens );
                }
            }
        }
        catch( Exception ex ){
            loggerDataPool.buildLogDataPool('BroadcastController >> pushCustomerBroadcast', ex);
        }
    }


    public static CustomerAlerts__c initBroadcastRecord(CustomerAlerts__c thisCustAlert, SObject vehicleRecord)
    {
        Map<String,Schema.RecordTypeInfo> recType = BroadcastController.getCustomerAlertRtByDeveloperName();
        CustomerAlerts__c custAlert = (thisCustAlert<>null && thisCustAlert.Id==null) ? thisCustAlert : new CustomerAlerts__c();
        custAlert.Name        = 'Notification';
        custAlert.Date__c     = System.today();
        custAlert.DateTime__c = System.now();
        custAlert.Status__c   = 'unread';
        custAlert.isAlert__c  = true;
        custAlert.isPush__c   = true;
        custAlert.isSMS__c    = false;
        custAlert.isEmail__c  = false;
        custAlert.Type__c     = 'Broadcast';
        custAlert.Account__c  = vehicleRecord <> null ? (String)vehicleRecord.get('Account__c') : custAlert.Account__c;
        custAlert.Contact__c  = vehicleRecord <> null ? (String)vehicleRecord.get('Contact__c') : custAlert.Contact__c;
        custAlert.Alert_Description__c = custAlert.Description__c <> null ? custAlert.Description__c.left(254) : custAlert.Alert_Description__c;
        custAlert.SubType__c  = String.isBlank( custAlert.SubType__c ) ? 'E-shop' : custAlert.SubType__c;
        custAlert.RecordTypeId = recType.containsKey('Broadcast') ? recType.get('Broadcast').getRecordTypeId() : custAlert.RecordTypeId;
        
        return custAlert;
    }
    

    public static Map<String,Schema.RecordTypeInfo> getCustomerAlertRtByDeveloperName()
    {
        Schema.DescribeSObjectResult orderSObj = Schema.SObjectType.CustomerAlerts__c; 
        Map<String,Schema.RecordTypeInfo> rtMapByDeveloperName = orderSObj.getRecordTypeInfosByDeveloperName();
        return rtMapByDeveloperName;
    }


    @AuraEnabled(Cacheable=true)
    public static List<Model__c> getModelAsSelectOptions( String[] lstBranches )
    {     
        List<Model__c> lstModels = new List<Model__c>();
        if( lstBranches<>null && !lstBranches.isEmpty() ){
            lstModels=  [SELECT Id, Name FROM Model__c WHERE Active__c = true AND Branch_Code__c IN: lstBranches ORDER BY Name LIMIT 9999];
        }
        System.debug('@@@@DEBUG getModelAsSelectOptions :: lstBranches = ' + lstBranches);
        System.debug('@@@@DEBUG getModelAsSelectOptions :: lstModels = ' + lstModels.size() + ' --- ' + lstModels );
        return lstModels;
    }


    @AuraEnabled(Cacheable=true)
    public static List<Variant__c> getVariantAsSelectOptions( String[] lstBranches, String[] lstModels )
    {
        List<Variant__c> lstVariants = new List<Variant__c>();
        if( lstBranches<>null && !lstBranches.isEmpty() && lstModels<>null && !lstModels.isEmpty() )
        {
            lstVariants=  [SELECT Id, Name FROM Variant__c WHERE Active__c = true AND Branch__c IN :lstBranches AND Model_ID__c IN :lstModels ORDER BY Name LIMIT 9999];
        }
        return lstVariants;
    }

    //TO Remove
    public static String appendTestToken()
    {
        String param_tokens = '';
        Set<String> setDeviceTokens = new Set<String>();
        //setDeviceTokens.add('f1f90e0d79f4989affe4bf7459847c29b0a95dd2da080baaa890d7d687e438dd');
        //setDeviceTokens.add('940506a61e78459b01b86aae704683c2206e7d2bdb55e15eeda39c708547e729');

        if( !setDeviceTokens.isEmpty() ){
            for( String tk : setDeviceTokens ){
                param_tokens += '"'+ tk + '"' + ',';
            }
        }
        return param_tokens;
    }

    @AuraEnabled(Cacheable=true)
    public static Broadcast_Configuration__mdt getCustomMtd(String objName)
    {
        try 
        {
            Broadcast_Configuration__mdt mtd = [SELECT Label, Query__c, Object_API_Name__c, Header_Value__c, Field_Value__c FROM Broadcast_Configuration__mdt WHERE Object_API_Name__c =: objName];

            return mtd;
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }
}