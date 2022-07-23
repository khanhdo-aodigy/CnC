/** *****
 * Class Name: IdentifyDuplicatePABatch
 * Description: Identify and remark duplicate Person Account (PA) records
 *  Key Identifier : Email 
 *  Business logic for merging: 
 *     > If person account has user record, this is primary. All the duplicated PA child records will be merged to this person account
 *     > If person account has no user record, check if DWH Contact ID is available, if yes then this is primary record. 
 *     > If Multiple DWH Contact Id found at Person Account level per email, flag it for notification. 
 *     > Else either records could be primary (PA without User account and DWH ID, system will merge all).
 *  
 *  Identifiers priority: User record > DWH Contact Id
 *  Scenarios for PA without email:
 *      > PA without email but have User: Patch PA Email from User’s email
 *      > PA without email and don't have User: If PAs have DWH Contact Id => Primary Account
 * 
 * 
 * Change History:
 * Date(YYYYMMDD)       Developer               Details
 * 20210608             khanh.do@aodigy         Created Initial Version
 * 
***** **/
global with sharing class IdentifyDuplicatePABatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    private static Map<String, Account> mapPrimaryPAByEmail = new Map<String, Account>();
    private static Map<Id, Account> duplicatedPAs = new Map<Id, Account>();
    private static Map<Id, Account> conflictPAs = new Map<Id, Account>();
    private List<String> errMsgs = new List<String>();

    /** Private variable for tracking purpose -Start **/
    
    private Integer totalPAsToProcess = 0;
    private Integer noOfPrimaryPAs = 0;
    private Integer noOfDuplicates = 0;
    private Integer noOfConflict = 0;
    private Integer noOfHaveUserButNoEmail = 0;
    private Integer noOfCustomerWithoutEmail = 0;
    //Prospect
    private Integer noOfProspects = 0;
    private Integer noOfProspectsToRetain = 0;
    private Integer noOfProspectsToBlankOff = 0;
    private Integer noOffProspectToDelete = 0;
    /** Private variable for tracking purpose - End */    
    
    private static Set<Id>  prospectIds = new Set<Id>();
    private static Map<Id, Account> expiredProspects = new Map<Id, Account>();
    private static Map<Id, Account> prospectsToUpdate = new Map<Id, Account>();

    private String personEmail;

    global IdentifyDuplicatePABatch() {}

    public void execute(SchedulableContext ctx)
    {
        Database.executebatch(new IdentifyDuplicatePABatch());
    }

    global IdentifyDuplicatePABatch(String personEmail) {
        this.personEmail = personEmail;
    }

    global Database.QueryLocator start(Database.Batchablecontext bc) {        
        
        String queryString =  ' SELECT ID, PersonEmail, IsCustomerPortal, DWH_Contact_ID__pc , RecordTypeId, ' +
                                       ' is_Duplicated__pc, Is_Primary_Account__c, Primary_Account_ID__c, ' +
                                       ' Is_DWHContactId_Conflict__c' +
                              ' FROM Account ' +
                              ' WHERE IsPersonAccount = true '
                              ;

        if(personEmail != null) {
            queryString += ' AND PersonEmail = :personEmail ';
            
        }

        queryString += ' ORDER BY PersonEmail NULLS LAST, Is_Primary_Account__c DESC, IsCustomerPortal DESC, DWH_Contact_ID__pc NULLS LAST';

        System.debug('@@@@DEBUG IdentifyDuplicatePABatch.start() queryString = ' + queryString);
        return Database.getQueryLocator( queryString );
    }

    global void execute(Database.BatchableContext jobId, List<Account> scope) {
        TriggerExclusion.excludeTrigger('Account', true);
        // System.debug('@@@@DEBUG IdentifyDuplicatePABatch scope.size = ' + scope.size());

        if(scope != null && scope.size() > 0) {            
            totalPAsToProcess += scope.size();
            try{

                Id prosRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();
                // Id custRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        
                Map<String, List<Account>> mapPAsByEmail = new Map<String, List<Account>>();        
            
                Map<Id, Account> portalCustomersWithoutEmail = new Map<Id, Account>(); //PAs dont have PersonEmail but have User record
                Set<Id> portalAccIds = new Set<Id>();

                for(Account acc: scope) {

                    if(String.isNotBlank(acc.PersonEmail)) {

                        String email = acc.PersonEmail;
                        
                        if(acc.Is_Primary_Account__c && !mapPrimaryPAByEmail.containsKey(email))
                        {
                            acc.is_Duplicated__pc = false;
                            acc.Is_DWHContactId_Conflict__c = false;
                            mapPrimaryPAByEmail.put(email, acc);
                            if(acc.IsCustomerPortal) {
                                portalAccIds.add(acc.Id);
                            }
                        }
                        else if(acc.IsCustomerPortal)
                        {
                            portalAccIds.add(acc.Id);
                        }
                        else
                        {
                            if( mapPAsByEmail.containsKey(email) ) {
                                mapPAsByEmail.get(email).add(acc);
                            } else {
                                mapPAsByEmail.put(email, new List<Account>{acc});
                            }
                            
                        }                
                        
                    } else  {

                        if( acc.IsCustomerPortal ) {
                            portalCustomersWithoutEmail.put( acc.Id, acc );
                        }
                        else if( acc.RecordTypeId == prosRecTypeId ) {
                            prospectIds.add(acc.Id);
                        } else {
                            noOfCustomerWithoutEmail++;
                        }
                    }
                    
                }
                
                Map<String, List<Account>> mapPortalAccByEmail = new Map<String, List<Account>>();

                /** Accounts without Email but have User records: Patch account's email from User's Email -- Start */
                if(portalCustomersWithoutEmail.size() > 0) {
                    Set<Id> noEmailAccIds = portalCustomersWithoutEmail.keySet();
                    Map<Id, User> mapAccIdToUser = new Map<Id, User>();
                    for(User portalUser: [ SELECT Id, AccountId, Email, UserName, IsActive
                                            FROM User
                                            WHERE AccountId IN :noEmailAccIds
                                         ]
                    ){
                        mapAccIdToUser.put(portalUser.AccountId, portalUser);
                    }

                    if(mapAccIdToUser != null && mapAccIdToUser.size() > 0) {                        
                        noOfHaveUserButNoEmail += mapAccIdToUser.size();

                        List<Account> listCustomerWithoutEmail = new List<Account>();
                        for(Account portalAcc: portalCustomersWithoutEmail.values()) {
                            if(mapAccIdToUser.containsKey(portalAcc.Id)) {
                                String email = mapAccIdToUser.get(portalAcc.Id).Email;
                                portalAcc.PersonEmail = email; //Patch account's email with User's Email

                                if( mapPortalAccByEmail.containsKey(email) ) {
                                    mapPortalAccByEmail.get(email).add(portalAcc);                    
                                } else {
                                    mapPortalAccByEmail.put(email, new List<Account>{portalAcc});
                                }
                            } else { //IsCustomerPortal = true but in fact have no User record
                                portalAcc.IsCustomerPortal = false;
                                listCustomerWithoutEmail.add(portalAcc);
                            }
                        }

                        if(listCustomerWithoutEmail.size() > 0) {
                            update listCustomerWithoutEmail;
                            noOfCustomerWithoutEmail += listCustomerWithoutEmail.size();
                        }
                                     
                    }                    
                }                        
                /** Patch account's email from User's Email -- End */

                // Update Account's email (UserEmail and AccountEmail should be the same)
                List<Account> portalPAs = new List<Account>();
                Map<String,Account> newAccByOldEmail= new Map<String,Account>();
                for(Account acc: [  SELECT Id, PersonEmail, DWH_Contact_ID__pc, Is_Primary_Account__c, RecordTypeId,
                                          Is_Duplicated__pc, Primary_Account_ID__c, Is_DWHContactId_Conflict__c,
                                          IsCustomerPortal,
                                          (SELECT Id, Username, Email, IsActive FROM Users) 
                                    FROM Account
                                    WHERE Id IN :portalAccIds
                                ]
                ){
                    if(acc.Users != null && acc.Users.size() > 0) {
                        User portalUser = acc.Users[0];
                        if(acc.PersonEmail != portalUser.Email) {
                            String oldEmail = acc.PersonEmail;
                            acc.PersonEmail = portalUser.Email;
                            if(acc.Is_Primary_Account__c) {                                
                                acc.is_Duplicated__pc = false;
                                acc.Is_DWHContactId_Conflict__c = false;
                                newAccByOldEmail.put(oldEmail, acc);
                            }
                        }
                    } else { //Actually there is case *PersonAccount which IsCustomerPortal = true but have no user record*
                        acc.IsCustomerPortal = false;                        
                    }
                    portalPAs.add(acc);
                }

                // System.debug('portalPAs = '  + portalPAs.size() + ' : ' + portalPAs);
                update portalPAs;

                //Handle primary PAs which have Account.PersonEmail != User.Email
                if(newAccByOldEmail.size() > 0) {
                    for(String oldEmail: newAccByOldEmail.keySet()) {
                        Account updatedprimaryPA = newAccByOldEmail.get(oldEmail);
                        mapPrimaryPAByEmail.remove(oldEmail);
                        mapPrimaryPAByEmail.put(updatedprimaryPA.PersonEmail, updatedprimaryPA);
                    }
                } 

                for(Account acc: portalPAs) {
                    
                    String email = acc.PersonEmail;
                    if(!acc.IsCustomerPortal) {                      
                        //Add them to the list accounts have no user
                        if( mapPAsByEmail.containsKey(email) ) {
                            mapPAsByEmail.get(email).add(acc);
                        } else {
                            mapPAsByEmail.put(email, new List<Account>{acc});
                        }
                    } else if( mapPortalAccByEmail.containsKey(email) ) {
                        mapPortalAccByEmail.get(email).add(acc);                    
                    } else {
                        mapPortalAccByEmail.put(email, new List<Account>{acc});
                    }
                }

                //Remove primaryAcc from portalAccList
                for(String email: mapPortalAccByEmail.keySet()) {
                    if( mapPrimaryPAByEmail.containsKey(email)) {        
                        Account primaryAcc = mapPrimaryPAByEmail.get(email);
                        List<Account> portalAccs = mapPortalAccByEmail.get(email);
                        for(Account portalAcc: portalAccs) {
                            if(primaryAcc.Id == portalAcc.Id) {
                                mapPortalAccByEmail.get(email).remove(portalAccs.indexOf(portalAcc));
                            }
                        }                        
                    }
                }                

                //Identify Primary Account from portal PAs list
                for(String email: mapPortalAccByEmail.keySet()){                    
                    List<Account> accList = mapPortalAccByEmail.get(email);
                    Account primaryPA;
                    if(mapPrimaryPAByEmail.containsKey(email)){
                        primaryPA = mapPrimaryPAByEmail.get(email);
                        for(Account acc: accList) {
                            if(!duplicatedPAs.containsKey(acc.Id)){
                                acc.is_Duplicated__pc = true;
                                acc.Primary_Account_ID__c = primaryPA.Id;
                                acc.Is_Primary_Account__c = false;
                                acc.Is_DWHContactId_Conflict__c = false;
                                duplicatedPAs.put(acc.Id, acc);
                            }
                        }
                    } else if(accList.size() == 1) { //Unique Email and have User record => Primary
                        primaryPA = accList[0];
                        primaryPA.Is_Primary_Account__c = true;
                        primaryPA.is_Duplicated__pc =  false;
                        primaryPA.Is_DWHContactId_Conflict__c = false;
                        if( !mapPrimaryPAByEmail.containsKey(email)){
                            mapPrimaryPAByEmail.put( email, primaryPA );
                        }
                    } else { //multiple accounts have same Email and all have User records <<PARTCOPY_ONLY: case doesnt exist in prod>>
                        indentifyByDwhConId(accList);                        
                    } 
                } 

                // Handle Accounts without user records and have same Email
                //System.debug(' mapPAsByEmail: ' + mapPAsByEmail.size() + ' = ' + mapPAsByEmail);
                for(String email: mapPAsByEmail.keySet()) {
                    List<Account> accList = mapPAsByEmail.get( email );
                    Account primaryPA;

                    if( mapPrimaryPAByEmail.containsKey(email) ) {

                        primaryPA = mapPrimaryPAByEmail.get(email);
                        for(Account acc: accList) {
                            if(!duplicatedPAs.containsKey(acc.Id)) {
                                acc.is_Duplicated__pc = true;
                                acc.Primary_Account_ID__c = primaryPA.Id;
                                acc.Is_Primary_Account__c = false;
                                acc.Is_DWHContactId_Conflict__c = false;
                                duplicatedPAs.put(acc.Id, acc);
                            }
                        }

                    } else if(!mapPortalAccByEmail.containsKey(accList[0].PersonEmail)){
                        if(accList.size() == 1) { //Unique email
                            if(String.isNotBlank(accList[0].DWH_Contact_Id__pc)) {
                                primaryPA =  accList[0];
                                primaryPA.Is_Primary_Account__c = true;
                                primaryPA.is_Duplicated__pc =  false;
                                primaryPA.Is_DWHContactId_Conflict__c = false;
                                mapPrimaryPAByEmail.put( email, primaryPA );
                            } else if( accList[0].RecordTypeId == prosRecTypeId ) {
                                prospectIds.add(accList[0].Id);
                            } else {
                                accList[0].Is_DWHContactId_Conflict__c = true;
                                conflictPAs.put(accList[0].Id, accList[0]);
                            }                            
                        
                        } else {
                            // Multiple Accounts have same Email
                            indentifyByDwhConId(accList);
                        }
                    }                              

                }
                
                handleProspects(prospectIds); //Handle prospects have no email and Prospects have Email but neither User nor DWH_Id

                if(mapPrimaryPAByEmail.size() > 0) {
                    noOfPrimaryPAs += mapPrimaryPAByEmail.size();
                    update mapPrimaryPAByEmail.values();
                }
                
                if(duplicatedPAs.size() > 0) {
                    noOfDuplicates += duplicatedPAs.size();
                    update duplicatedPAs.values();
                }
                
                if(conflictPAs.size() > 0) {
                    noOfConflict += conflictPAs.size();
                    update conflictPAs.values();
                }

                if(prospectsToUpdate.size() > 0) {
                    noOfProspectsToBlankOff += prospectsToUpdate.size();
                    update prospectsToUpdate.values();
                }

                if(expiredProspects.size() > 0) {           
                    noOffProspectToDelete +=  expiredProspects.size();
                    delete expiredProspects.values();
                }

            } catch(Exception ex){
                errMsgs.add( ex.getCause() + ' -- ' + ex.getMessage() + ' -- At line: #' + ex.getLineNumber() );
                loggerDataPool.buildLogDataPool('IdentifyDuplicatePABatch', ex);
            }
        }
        
        
    }

    global void finish(Database.BatchableContext bc){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'khanh.do@aodigy.com', 'thieudang.vu@aodigy.com'};
        mail.setToAddresses( toAddresses );
        mail.setTargetObjectId( UserInfo.getUserId() );
        mail.saveAsActivity = false;
        String body;
        mail.setSubject('IdentifyDuplicatePABatch Run Result - ' + Datetime.now());
        if(!errMsgs.isEmpty()){
            for(Integer i = 0; i < errMsgs.size(); i++){
                body = 'IdentifyDuplicatePABatch Got Exception !!!\n';
                body += (String.valueof(i+1)+' '+errMsgs[i]+ '\r\n');
            }
        } 
        else{            
            body = 'IdentifyDuplicatePABatch Processed Successfully !!!\n';
        }

        body += 'Total PAs to Process :: ' + totalPAsToProcess + '\r\n';        
        body += 'Total Primary PAs :: ' + noOfPrimaryPAs + '\r\n';
        body += 'Number PAs Have User but Not Email  :: ' + noOfHaveUserButNoEmail + '\r\n';
        body += 'Number Duplicated PAs :: ' + noOfDuplicates + '\r\n';
        body += 'Number PAs have Conflict DWH_Contact_Id__pc to check :: ' + noOfConflict + '\r\n';
        body += 'Number Customers without Email :: ' + noOfCustomerWithoutEmail + '\r\n';        
        body += 'Number Prospects :: ' + noOfProspects + '\r\n';
        body += 'Number Prospects to Retain :: ' + noOfProspectsToRetain + '\r\n';
        body += 'Number Prospects to Blank off PII :: ' + noOfProspectsToBlankOff + '\r\n';
        body += 'Number Prospects Deleted :: ' + noOffProspectToDelete + '\r\n';
        
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        TriggerExclusion.excludeTrigger('Account', false);
    }

    
    
    private void handleProspects(Set<Id> prospectIds){            
        noOfProspects += [    SELECT Id, FirstName, Full_Name__pc, PersonEmail, PersonMobilePhone,
                                NRIC__pc, NRIC_Passport_No__pc, CreatedDate, IsCustomerPortal,
                                Address_Line_1__pc, Address_Line_2__pc, Address_Line_3__pc,
                                Address_Line_4__pc, Address_Line_5__pc,                                               
                                ( SELECT Id, CreatedDate FROM Opportunities__r ORDER BY CreatedDate DESC LIMIT 1),
                                ( SELECT Id, CreatedDate FROM Test_Drives1__r ORDER BY CreatedDate DESC LIMIT 1)
                            FROM Account
                            WHERE Id IN :prospectIds                                       
                        ].size();

        for(Account prospect: [  SELECT Id, FirstName, Full_Name__pc, PersonEmail, PersonMobilePhone,
                                        NRIC__pc, NRIC_Passport_No__pc, CreatedDate, IsCustomerPortal,
                                        Address_Line_1__pc, Address_Line_2__pc, Address_Line_3__pc,
                                        Address_Line_4__pc, Address_Line_5__pc,                                               
                                    ( SELECT Id, CreatedDate FROM Opportunities__r ORDER BY CreatedDate DESC LIMIT 1),
                                    ( SELECT Id, CreatedDate FROM Test_Drives1__r ORDER BY CreatedDate DESC LIMIT 1)
                                FROM Account
                                WHERE Id IN :prospectIds                                       
                                ]
        ){
            Opportunity lastOppo;
            Test_Drive__c lastTestDrive;
            Datetime lastDateTime;
            if(prospect.Opportunities__r.size() > 0 ) {
                lastOppo = prospect.Opportunities__r[0];
            }
            if(prospect.Test_Drives1__r.size() > 0 ) {
                lastTestDrive = prospect.Test_Drives1__r[0];
            }

            if( lastOppo != null && lastTestDrive != null) {
                lastDateTime = lastOppo.CreatedDate > lastTestDrive.CreatedDate ? lastOppo.CreatedDate : lastTestDrive.CreatedDate;
            } else if (lastOppo != null) {
                lastDateTime = lastOppo.CreatedDate;
            } else if (lastTestDrive != null) {
                lastDateTime = lastTestDrive.CreatedDate;
            }

            Date lastActiveDate;
            if( lastDateTime != null ) {
                lastActiveDate = lastDateTime.Date();
                if( lastActiveDate.monthsBetween(Date.today()) > 18) {
                    prospect.FirstName            = '';
                    prospect.Full_Name__pc        = '';
                    prospect.PersonEmail          = '';
                    prospect.PersonMobilePhone    = '';
                    prospect.NRIC__pc             = '';
                    prospect.NRIC_Passport_No__pc = '';
                    prospect.Address_Line_1__pc   = '';
                    prospect.Address_Line_2__pc   = '';
                    prospect.Address_Line_3__pc   = '';
                    prospect.Address_Line_4__pc   = '';
                    prospect.Address_Line_5__pc   = '';
                    
                    prospectsToUpdate.put(prospect.Id, prospect);
                } else {
                    noOfProspectsToRetain++;
                }

            } else { //Prospect has no child
                lastActiveDate = prospect.CreatedDate.date();
                if( lastActiveDate.monthsBetween(Date.today())  > 18 && !prospect.IsCustomerPortal) { //partcopy has Prospect associated with portal user
                    expiredProspects.put(prospect.Id, prospect);
                } else {
                    noOfProspectsToRetain++;
                }
            }
        }
    }

    private Account indentifyByDwhConId(List<Account> accList) {
        Id prosRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();
        Id custRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Map<String, Account> mapAccToDwh = new Map<String, Account>();
        Account primaryAcc;

        for(Account acc: accList) {
            if( String.isNotBlank(acc.DWH_Contact_Id__pc) ){
                mapAccToDwh.put( acc.DWH_Contact_Id__pc, acc);
            }
        }

        // Handle Accounts have DWH Contact Id
        if(mapAccToDwh.keySet().size() == 1) { //Only 1 account has DWH_Contact_Id => this is the primary

            primaryAcc = mapAccToDwh.values()[0];
            primaryAcc.Is_Primary_Account__c = true;
            primaryAcc.is_Duplicated__pc = false;
            primaryAcc.Is_DWHContactId_Conflict__c = false;
            mapPrimaryPAByEmail.put( primaryAcc.PersonEmail, primaryAcc );
            
        } else { //Multiple accounts have DWH_Contact_Id OR all dont have DWH Contact Id => Flag them for notification

            for(Account acc: accList) {
                if(acc.RecordTypeId == custRecTypeId || String.isNotBlank(acc.DWH_Contact_Id__pc) ){
                    acc.Is_DWHContactId_Conflict__c = true;        
                    conflictPAs.put(acc.Id, acc);
                }                

                //Handle prospect with neither user nor dwh
                if(String.isBlank(acc.DWH_Contact_Id__pc) && acc.RecordTypeId == prosRecTypeId) {
                    prospectIds.add(acc.Id);
                }
            }

        }

        if(primaryAcc != null ){
            for(Account acc: accList) {
                if( acc.Id != primaryAcc.Id && !duplicatedPAs.containsKey(acc.Id) ) {
                    acc.is_Duplicated__pc = true;
                    acc.Primary_Account_ID__c = primaryAcc.Id;
                    acc.Is_Primary_Account__c = false;
                    acc.Is_DWHContactId_Conflict__c = false;
                    duplicatedPAs.put(acc.Id, acc);
                }
            }
        }

        // System.debug('@@@ indentifyByDwhConId primaryAcc = '  + primaryAcc);
        return primaryAcc;
    }


}