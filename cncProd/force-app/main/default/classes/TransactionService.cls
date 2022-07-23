/** *****
 * Description : Service Class for Transaction Object
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200623            HS@aodigy            Created Initial Version 
 * 
** *****/
public with sharing class TransactionService {

    private static TransactionSelector trxn_selector = new TransactionSelector();
    
    private static RegisteredVehicleSelector regveh_selector = new RegisteredVehicleSelector();
    
    private static RewardProfileSelector rwdprofile_selector = new RewardProfileSelector();


    public static Id getTransactionRecordTypeId( String recordTypeName ) 
    {
        if( Schema.SObjectType.Transaction__c.getRecordTypeInfosByDeveloperName().containsKey( recordTypeName ) ) {
            return Schema.SObjectType.Transaction__c.getRecordTypeInfosByDeveloperName().get( recordTypeName ).getRecordTypeId(); 
        }
        return null;
    }


    public static Map<String,Registered_Vehicle__c> getRegisteredVehicleByChassisID( Set<String> setChassicNumber ) 
    {
        Map<String,Registered_Vehicle__c> mapRegisteredVehicle = new Map<String,Registered_Vehicle__c>();

        if( setChassicNumber <> null & !setChassicNumber.isEmpty() ) {
            for( Registered_Vehicle__c rv : regveh_selector.selectByChassisNumber( setChassicNumber ) ){
                mapRegisteredVehicle.put( rv.Chasis_Number__c , rv );
            }
        }
        return mapRegisteredVehicle;
    }


    public static List<Transaction__c> linkACTrxnToRegVehAndContact( List<Transaction__c> lstVehicleCredits ) 
    {
        Set<String> setContactNRICs = new Set<String>();
        Map<String,Transaction__c> mapNewTrxnToInsert = new Map<String,Transaction__c>();
        for( Transaction__c vTx : lstVehicleCredits )
        {
            //Prepopulate Credit Amount
            vTx.Amount__c = vTx.CR_AMT__c;
            
            if( vTx.CHASSIS__c <> null ){
                mapNewTrxnToInsert.put( vTx.CHASSIS__c, vTx );
            }
        }

        Map<String,Registered_Vehicle__c>  mapRegisteredVehicle = TransactionService.getRegisteredVehicleByChassisID( mapNewTrxnToInsert.KeySet() );
        Map<String,Account_Mapping__c> mapAcctMapping = AccountMappingService.getAllAcctMapping();
        System.debug('@@@@DEBUG linkACTrxnToRegVehAndContact :: mapRegisteredVehicle = ' + mapRegisteredVehicle.size() + ' --- ' + mapRegisteredVehicle);
        System.debug('@@@@DEBUG linkACTrxnToRegVehAndContact :: mapAcctMapping = ' + mapAcctMapping.size() + ' --- ' + mapAcctMapping);

        List<Transaction__c> lstVehicleCreditsFiltered = new List<Transaction__c>();
        for( Transaction__c vTx : lstVehicleCredits )
        {
            Registered_Vehicle__c thisRV = null;
            if( mapRegisteredVehicle <> null && mapRegisteredVehicle.containsKey( vTx.CHASSIS__c ) )
            {
                thisRV = mapRegisteredVehicle.get( vTx.CHASSIS__c );

                vTx.Registered_Vehicle__c = thisRV.Id;
                vTx.Account__c  = thisRV.Account__c;
                vTx.Contact__c  = thisRV.Account__r.IsPersonAccount ? thisRV.Account__r.PersonContactId : thisRV.Contact__c;
                vTx.Branch__c   = thisRV.Branch__c;
                vTx.Brand__c    = thisRV.Brand__c;//TransactionService.getBrand( thisRV );
                
                lstVehicleCreditsFiltered.add( vTx );

                String cKey = vTx.SRC__c + '_' + vTx.FRAN__c;//+ '_Accessories Credit';
                if( mapAcctMapping <> null && mapAcctMapping.containsKey( cKey ) ){
                    vTx.Source__c = mapAcctMapping.get( cKey ).Source__c;
                    vTx.Type__c = mapAcctMapping.get( cKey ).Reward_Type__c;
                }
            }
            validateTransaction( thisRV, vTx );
        }

        System.debug('@@@@DEBUG linkACTrxnToRegVehAndContact :: lstVehicleCredits = ' + lstVehicleCredits.size() );
        System.debug('@@@@DEBUG linkACTrxnToRegVehAndContact :: lstVehicleCreditsFiltered = ' + lstVehicleCreditsFiltered.size() );
        return lstVehicleCreditsFiltered;
    }


    public static void processTransactionCheck( List<Transaction__c> lstUpdatedTrxns )
    {
        System.debug('@@@@DEBUG processTransactionCheck :: lstUpdatedTrxns = ' + lstUpdatedTrxns.size() + ' --- ' + lstUpdatedTrxns);
        Set<Id> setRvIds = new Set<Id>();
        for(Transaction__c trxn : lstUpdatedTrxns){
            if(trxn.RecordTypeId == getTransactionRecordTypeId('External_SRC_Transaction_RT') && trxn.Reward__c == null && trxn.Registered_Vehicle__c <> null ){
                setRvIds.add( trxn.Registered_Vehicle__c );
            }
        }

        Map<Id,Registered_Vehicle__c> mapRegisteredVehicles = new Map<Id,Registered_Vehicle__c>( regveh_selector.selectByIds( setRvIds ) );
        for(Transaction__c trxn : lstUpdatedTrxns){
            Registered_Vehicle__c tempRV = mapRegisteredVehicles.containsKey( trxn.Registered_Vehicle__c ) ? mapRegisteredVehicles.get(trxn.Registered_Vehicle__c) : null;
            validateTransaction( tempRV, trxn );
        }
    }


    public static void processTransactionToReward( List<Transaction__c> lstNewTrxns )
    {
        System.debug('@@@@DEBUG processTransactionToReward :: lstNewTrxns = ' + lstNewTrxns.size() + ' --- ' + lstNewTrxns);
        List<Transaction__c> lstDWHTrxns = new List<Transaction__c>();
        for( Transaction__c trxn : lstNewTrxns ){
            if( trxn.RecordTypeId == getTransactionRecordTypeId('External_SRC_Transaction_RT') 
                && trxn.Is_Error__c == false 
                    && trxn.Reward__c == null 
                        && trxn.Account__c <> null 
                            && trxn.Contact__c <> null 
                                && trxn.Registered_Vehicle__c <> null 
                                    && trxn.Brand__c <> null 
                                        && trxn.Branch__c <> null 
                                            && trxn.Type__c <> null 
                                                && trxn.Source__c <> null 
                                                    && trxn.NLCODE__c <> null
                                                        && trxn.COST__c <> null)
            {
                lstDWHTrxns.add( trxn );
            }
            else if( trxn.Reward__c <> null ){
                trxn.addError('UPDATE IS NOT ALLOWED. Transaction has been processed successfully.');
            }
        }
        System.debug('@@@@DEBUG processTransactionToReward :: lstDWHTrxns = ' + lstDWHTrxns.size() + ' --- ' + lstDWHTrxns);
        if( lstDWHTrxns <> null && !lstDWHTrxns.isEmpty() ){
            createRewardsWithTransactions( lstDWHTrxns );
        }
    }


    public static void validateTransaction( Registered_Vehicle__c thisRV, Transaction__c vTrnx )
    {
        System.debug('@@@@DEBUG validateTransaction :: thisRV = ' + thisRV + ' --- vTrnx = ' + vTrnx);
        vTrnx.Is_Error__c = false;
        vTrnx.Error_Message__c = '';

        if( vTrnx.Registered_Vehicle__c == null ){
            vTrnx.Is_Error__c = true;
            vTrnx.Error_Message__c = 'Registered Vehicle not found.';
        }
        else if ( vTrnx.Registered_Vehicle__c <> null && thisRV <> null && thisRV.Registration_Number__c <> vTrnx.REGN__c ){
            vTrnx.Is_Error__c = true;
            vTrnx.Error_Message__c = 'Registration Number not match.';
        }
        else if( vTrnx.Contact__c == null ){
            vTrnx.Is_Error__c = true;
            vTrnx.Error_Message__c = 'Contact not found.';
        }
        else if( vTrnx.Contact__c <> null && thisRV <> null && thisRV.Contact__r.NRIC_Passport_No__c <> vTrnx.NRIC__c  ){
            vTrnx.Is_Error__c = true;
            vTrnx.Error_Message__c = 'Contact NRIC not match.';
        }
        else if( vTrnx.Account__c == null ){
            vTrnx.Is_Error__c = true;
            vTrnx.Error_Message__c = 'Account not found.';
        }
        else if ( vTrnx.Branch__c <> null && thisRV <> null && thisRV.Branch__c <> vTrnx.Branch__c ){
            vTrnx.Is_Error__c = true;
            vTrnx.Error_Message__c = 'Branch not match.';
        }
        else if ( vTrnx.Brand__c <> null && thisRV <> null && thisRV.Brand__c <> vTrnx.Brand__c ){
            vTrnx.Is_Error__c = true;
            vTrnx.Error_Message__c = 'Brand not match.';
        }
        else if ( vTrnx.Source__c == null ){
            vTrnx.Is_Error__c = true;
            vTrnx.Error_Message__c = 'Source not found.';
        }
        else if ( vTrnx.Type__c == null ){
            vTrnx.Is_Error__c = true;
            vTrnx.Error_Message__c = 'Type not found.';
        }
        else if ( vTrnx.COST__c == null ){
            vTrnx.Is_Error__c = true;
            vTrnx.Error_Message__c = 'COST is empty.';
        }
        else if ( vTrnx.NLCODE__c == null ){
            vTrnx.Is_Error__c = true;
            vTrnx.Error_Message__c = 'NLCODE is empty.';
        }
    }


    public static void createRewardsWithTransactions(List<Transaction__c> lstTrxns)
    {
        System.debug('@@@@DEBUG createRewardsWithTransactions :: lstTrxns = ' + lstTrxns.size() + ' --- ' + lstTrxns);
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Reward_Profile__c.SObjectType, Reward__c.SObjectType, Transaction__c.SObjectType } );
        
        Map<Id,Transaction__c> mapTransactions = new Map<Id,Transaction__c>();          
        mapTransactions.putAll( lstTrxns );     
        System.debug('@@@@DEBUG createRewardsWithTransactions :: mapTransactions = ' + mapTransactions.size());                                                                                 
        
        List<Reward_Profile__c> lstRewardProfileToInsert = new List<Reward_Profile__c>();
        List<Reward__c> lstRewardsToInsert = new List<Reward__c>();
        Map<String,List<Transaction__c>> mapUniqueKeyToTrxns = new Map<String,List<Transaction__c>>();
        try{
            for( Transaction__c newTrxn : trxn_selector.selectTransactionsByIds( mapTransactions.KeySet() ) )
            {
                String uniqueKey = '';
                if( newTrxn.FLEET__c == 'Y' ){
                    uniqueKey = rwdprofile_selector.getRecordTypeId('Fleet') + '_' + newTrxn.Registered_Vehicle__c + '_' + newTrxn.Brand__c + '_' + newTrxn.Type__c;
                }
                else{
                    uniqueKey = rwdprofile_selector.getRecordTypeId('Individual') + '_' + newTrxn.Contact__c + '_' + newTrxn.Brand__c + '_' + newTrxn.Type__c;
                }

                if( mapUniqueKeyToTrxns.containsKey( uniqueKey ) ){
                    mapUniqueKeyToTrxns.get( uniqueKey ).add( newTrxn );
                }
                else{
                    mapUniqueKeyToTrxns.put( uniqueKey, new List<Transaction__c>{ newTrxn });
                }
                
            }
            
            Map<String,Reward_Profile__c> mapExistingRewardProfiles = new Map<String,Reward_Profile__c>();
            for(Reward_Profile__c rwProfile : rwdprofile_selector.selectByUniqueKeys( mapUniqueKeyToTrxns.KeySet() ) ){
                mapExistingRewardProfiles.put( rwProfile.Unique_Key__c , rwProfile );
            }
            System.debug('@@@@DEBUG createRewardsWithTransactions :: mapExistingRewardProfiles = ' + mapExistingRewardProfiles.size() + ' --- ' + mapExistingRewardProfiles);
            System.debug('@@@@DEBUG createRewardsWithTransactions :: mapUniqueKeyToTrxns = ' + mapUniqueKeyToTrxns.size() + ' --- ' + mapUniqueKeyToTrxns);

            for( String key : mapUniqueKeyToTrxns.KeySet() )
            {    
                List<Transaction__c> lstNewTransactions = mapUniqueKeyToTrxns.get( key );

                Reward_Profile__c rwdProfile = mapExistingRewardProfiles.containsKey( key ) ? mapExistingRewardProfiles.get( key ) : initRewardProfileByTransaction( lstNewTransactions.get(0) );
                if( rwdProfile.Id == null ){
                    // uow.registerNew( rwdProfile );
                    lstRewardProfileToInsert.add( rwdProfile );
                }

                for( Transaction__c trxn : lstNewTransactions ) 
                {
                    Reward__c rw = new Reward__c();
                    rw.Contact__c            = trxn.Contact__c;
                    rw.Registered_Vehicle__c = trxn.Registered_Vehicle__c;
                    rw.Branch__c             = trxn.Branch__c;
                    rw.Type__c               = trxn.Type__c;
                    rw.Brand__c              = trxn.Brand__c;
                    rw.Expiry__c             = trxn.EXPIRY__c;
                    rw.Credit__c             = trxn.Amount__c;
                    rw.Status__c             = 'Valid';
                    rw.COST__c               = trxn.COST__c;
                    rw.Source__c             = trxn.Source__c;
                    rw.Document__c           = trxn.DOCNUMBER__c;
                    rw.Posting_Date__c       = trxn.POSTING_DATE__c;
                    rw.NL_Account__c         = trxn.NL_Account__c;
                    rw.NLCODE__c             = trxn.NLCODE__c;
                    
                    uow.registerRelationship( rw, Reward__c.Reward_Profile__c, rwdProfile );
                    uow.registerDirty(trxn, Transaction__c.Reward__c, rw);
                    lstRewardsToInsert.add( rw );
                }
            }
            
            System.debug('@@@@DEBUG createRewardsWithTransactions :: lstRewardProfileToInsert = ' + lstRewardProfileToInsert.size() );
            System.debug('@@@@DEBUG createRewardsWithTransactions :: lstRewardsToInsert = ' + lstRewardsToInsert.size() + ' --- ' + lstRewardsToInsert);
            if( lstRewardsToInsert <> null && !lstRewardsToInsert.isEmpty() ){
                if( lstRewardProfileToInsert <> null && !lstRewardProfileToInsert.isEmpty() ){
                    uow.registerNew( lstRewardProfileToInsert );    
                }
                uow.registerNew( lstRewardsToInsert );
                uow.commitWork();
            }
        }
        catch(Exception ex){
            System.debug('@@@@DEBUG createRewardsWithTransactions :: ERROR - err.msg = ' + ex.getMessage() + ' --- err.cause = ' + ex.getCause() + ' --- err.line = ' + ex.getLineNumber() );
            loggerDataPool.buildLogDataPool('TransactionService.createRewardsWithTransactions', ex);
        }

    }


    public static Reward_Profile__c initRewardProfileByTransaction( Transaction__c trxn )
    {
        Id profileRecTypeID = null;
        String uniqueKey = '';
        if( trxn.FLEET__c == 'Y' ){
            profileRecTypeID = rwdprofile_selector.getRecordTypeId('Fleet');
            uniqueKey = String.valueOf(profileRecTypeID) + '_' + trxn.Registered_Vehicle__c + '_' + trxn.Brand__c + '_' + trxn.Type__c;
        }
        else{
            profileRecTypeID = rwdprofile_selector.getRecordTypeId('Individual');
            uniqueKey = String.valueOf(profileRecTypeID) + '_' + trxn.Contact__c + '_' + trxn.Brand__c + '_' + trxn.Type__c;
        }

        Reward_Profile__c newProfile = new Reward_Profile__c();
        newProfile.RecordTypeId          = profileRecTypeID;
        newProfile.Contact__c            = trxn.FLEET__c <> 'Y' ? trxn.Contact__c : null;
        newProfile.Account__c            = trxn.Account__c;
        newProfile.Registered_Vehicle__c = trxn.FLEET__c == 'Y' ? trxn.Registered_Vehicle__c : null;
        newProfile.Branch__c             = trxn.Branch__c;
        newProfile.Brand__c              = trxn.Brand__c;
        newProfile.Type__c               = trxn.Type__c;
        newProfile.Unique_Key__c         = uniqueKey;

        System.debug('@@@@DEBUG initRewardProfileByTransaction :: newProfile = ' + newProfile);
        return newProfile;
    }

}