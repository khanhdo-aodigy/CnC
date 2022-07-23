/** ******
 * Description : Service Class for PAMigration related services
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        Description
 * 20200219            AT          Created Initial Version.
 * 20201016            KD          Modified method selectRecordTypeId() to avoid big child list data limitation
 * 20210623            KD          Removed Person Account RecordType "E-shop customer"
 * 
** ******/
public with sharing class PAMigrationService {


    private static global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();
    private static AccountSelector accountSelector = new AccountSelector();
    private static List<String> accountFields = accountSelector.getEditableAccountFields();

    private static void initTriggerExlusion(){
		//removed ContactHobby__c in listSObject cuz ContactHobby__c is deleted [Thang - 04/08/21]
        List<String> listSObject = new List<String>{'Account','Contact','Lead','Registered_Vehicle__c', 'Campaign_Member_Vehicle__c',
                                                    'CustomerAlerts__c', 'Sales_Agreement__c', 'Case', 'Feedback__c', 'SMS_Reply__c',
                                                    'Service_Appointment__c', 'Event_Registration__c', 'Share__c', 'ClashDeal__c',
                                                    'Opportunity', 'Invoice__c', 'Custom_Quote__c', 'Customer_Detail__c',
                                                    'Test_Drive__c', 'Order__c'};

        for( String strObject : listSObject ) 
        {
            TriggerExclusion.excludeTrigger( strObject , true );
        }
    }

    public static void processConversion(List<Contact> contacts, 
                                            Map<String,String> contAccountMap,
                                                List<Map<String, List<SObject>>> childListMaps){
        System.debug('PAMigrationService >> processConversion: contacts =' + contacts);
        System.debug('PAMigrationService >> processConversion: contAccountMap =' + contAccountMap);
        System.debug('PAMigrationService >> processConversion: childListMaps =' + childListMaps);
        
        if(contacts.isEmpty()){
            throw new AccountServiceException('Contacts not specified');
        }

        initTriggerExlusion();
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(
            new Schema.SObjectType[]{   Account.SObjectType,
                                        Registered_Vehicle__c.SObjectType,
                                        Campaign_Member_Vehicle__c.SObjectType,
                                    //    ContactHobby__c.SObjectType, cuz ContactHobby__c is deleted [Thang - 04/08/21]
                                        CustomerAlerts__c.SObjectType,
                                        Sales_Agreement__c.SObjectType,
                                        Case.SObjectType,
                                        Feedback__c.SObjectType,
                                        SMS_Reply__c.SObjectType,
                                        Service_Appointment__c.SObjectType,
                                        Event_Registration__c.SObjectType,
                                        Share__c.SObjectType,
                                        ClashDeal__c.SObjectType,
                                        Opportunity.SObjectType,
                                        Invoice__c.SObjectType,
                                        Custom_Quote__c.SObjectType,
                                        Customer_Detail__c.SObjectType,
                                        Test_Drive__c.SObjectType,
                                        Contact.SObjectType,
                                        Order__c.SObjectType,
                                        CampaignMember.SObjectType
                                    }
        );
        
        ContactSelector conSelector = new ContactSelector();
        List<String> lstCntFields = conSelector.getEditableContactFields();

        Map<Id, Account> mapConIdToPA= new Map<Id, Account>();
        Map<Id, Account> mapConIdToPAToInsert = new Map<Id, Account>();
        
        for(Contact con : contacts)
        {
            Account personAcc;
            if(contAccountMap != null && contAccountMap.containsKey(con.Id)){
                if( Contact.Account__c <> null ){
                    System.debug('@@@@DEBUG PAMigrationService :: EXISTING PA !!!');

                    personAcc = updateAccountRecordType(con, contAccountMap.get(con.Id) , accountFields, lstCntFields );
                    uow.registerDirty(con, Contact.Account__c, personAcc);
                    uow.registerDirty(personAcc, new List<SObjectField>{Account.RecordTypeId});
                }
            }
            else{
                System.debug('@@@@DEBUG PAMigrationService :: NEW PA !!!');
                personAcc = createAccountFromContact(con);
                uow.registerNew(personAcc);

                //Work around to update Contact of Person Account
                Contact tempCon = new Contact(Id = con.Id);
                uow.registerDirty(tempCon, Contact.Account__c, personAcc);
            }

            List<List<SObject>> childLists = new List<List<SObject>>();
            for(Map<String, List<SObject>> childListMap : childListMaps){
                if(childListMap.containsKey(con.Id)){
                    linkToPersonAccount(childListMap.get(con.Id), uow, personAcc);
                }
            }

        }

        initTriggerExlusion();
        uow.commitWork();
        system.debug('@@@ Done');


    }

    public static void processConversion(List<Lead> leads, List<Map<String, List<SObject>>> childListMaps){
        if(leads.isEmpty()){
            throw new AccountServiceException('Leads not specified');
        }

        Map<String, String> leadFieldMap = new Map<String, String>{
                                                                    'Street'            => 'PersonMailingStreet',
                                                                    'City'              => 'PersonMailingCity',
                                                                    'State'             => 'PersonMailingState',
                                                                    'PostalCode'        => 'PersonMailingPostalCode',
                                                                    'Country'           => 'PersonMailingCountry',
                                                                    'Latitude'          => 'PersonMailingLatitude',
                                                                    'Longitude'         => 'PersonMailingLongitude',
                                                                    'GeocodeAccuracy'   => 'PersonMailingGeocodeAccuracy',
                                                                    'Description'       => 'Description',
                                                                    'DoNotCall'         => 'PersonDoNotCall',
                                                                    'Email'             => 'PersonEmail',
                                                                    'HasOptedOutOfEmail'=> 'PersonHasOptedOutOfEmail',
                                                                    'IndividualId'      => 'PersonIndividualId',
                                                                    'Industry'          => 'Industry',
                                                                    'OwnerId'           => 'OwnerId',
                                                                    'LeadSource'        => 'PersonLeadSource',
                                                                    'MobilePhone'       => 'PersonMobilePhone',
                                                                    'LastName'          => 'LastName',
                                                                    'FirstName'         => 'FirstName',
                                                                    'NumberOfEmployees' => 'NumberOfEmployees',
                                                                    'Address_Line_1__c' => 'Address_Line_1__pc',
                                                                    'Address_Line_2__c' => 'Address_Line_2__pc',
                                                                    'Address_Line_3__c' => 'Address_Line_3__pc',
                                                                    'Address_Line_4__c' => 'Address_Line_4__pc',
                                                                    'Address_Line_5__c' => 'Address_Line_5__pc',
                                                                    'Birthdate__c'      => 'PersonBirthdate',
                                                                    'Branch_Code__c'    => 'Branch_Code__pc',
                                                                    'Full_Name__c'      => 'Full_Name__pc',
                                                                    'Gender__c'         => 'Gender__pc',
                                                                    'et4ae5__Mobile_Country_Code__c' => 'et4ae5__Mobile_Country_Code__pc',
                                                                    'et4ae5__HasOptedOutOfMobile__c' => 'et4ae5__HasOptedOutOfMobile__pc',
                                                                    'NRIC__c'           => 'NRIC__pc',
                                                                    'PDPA__c'           => 'PDPA__pc',
                                                                    'Source__c'         => 'Source__pc'
                                                                };


        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(
            new Schema.SObjectType[]{   Account.SObjectType,
                                        Lead.SObjectType,
                                        Event_Registration__c.SObjectType,
                                        Share__c.SObjectType,
                                        ClashDeal__c.SObjectType,
                                        Opportunity.SObjectType,
                                        Invoice__c.SObjectType,
                                        Custom_Quote__c.SObjectType,
                                        Customer_Detail__c.SObjectType,
                                        Test_Drive__c.SObjectType,
                                        Feedback__c.SObjectType
                                    }
        );

        /*
        AccountSelector selector = new AccountSelector();
        Map<String, RecordType> accountRecordTypeMap = selector.getAccountRecordTypeMap();

        for(Lead ld : leads){
            Account personAcc = new Account();
            personAcc.RecordTypeId = accountRecordTypeMap.get('Prospect').Id;

            for(String leadField : leadFieldMap.keySet()){
                personAcc.put(leadFieldMap.get(leadField), ld.get(leadField));
            }

            uow.registerNew(personAcc);
            uow.registerDirty(ld, Lead.Account__c, personAcc);

            for(Map<String,List<SObject>> childListMap : childListMaps){
                if(childListMap.containsKey(ld.Id)){
                    linkToPersonAccount(childListMap.get(ld.Id), uow, personAcc);
                }
            }
        }
        */

        Id prospectRecTypeID = AccountUtil.getProspectRecordTypeId();
        List<SObject> sObjectListToUpdate = new List<SObject>();
        for(Lead ld : leads){
            Account personAcc = new Account();
            personAcc.RecordTypeId = prospectRecTypeID;
            for(String leadField : leadFieldMap.keySet()){
                personAcc.put(leadFieldMap.get(leadField), ld.get(leadField));
            }

            uow.registerNew(personAcc);
            uow.registerDirty(ld, Lead.Account__c, personAcc);

            for(Map<String,List<SObject>> childListMap : childListMaps){
                if(childListMap.containsKey(ld.Id)){
                    linkToPersonAccount(childListMap.get(ld.Id), uow, personAcc);
                }
            }
        }

        initTriggerExlusion();
        uow.commitWork();
        system.debug('@@@ Done');

    }

    // public static void linkToPersonAccount (SObject[] sObjectList, ADGLIB_SObjectUnitOfWork uow, String strFkey, sObject parentSObj ){
        private static void linkToPersonAccount (SObject[] sObjectList, ADGLIB_SObjectUnitOfWork uow, Account personAcc ){
            if( !sObjectList.isEmpty() ){
                for( SObject sObj : sObjectList ){
                    if( sObj.getSObjectType().getDescribe().fields.getMap().containsKey('Account__c') ){
                        uow.registerDirty( sobj, sObj.getSObjectType().getDescribe().fields.getMap().get('Account__c'), personAcc);
                    }
                }
            }
        }

    private static Account createAccountFromContact (Contact con){
        //AccountSelector selector = new AccountSelector();
        
        system.debug('@@@ conId: '+con.Id);
        Account acc = new Account();

        acc.RecordTypeId = selectRecordTypeId(con);
        acc.FirstName    = con.FirstName;
        acc.LastName     = con.LastName;
        acc.Salutation   = con.Salutation != null ? con.Salutation : '';
        acc.Phone        = con.Phone;
        acc.OwnerId      = ( con.Owner.IsActive ) ? con.OwnerId : (String.isNotBlank( global_var__c.getOrgDefaults().Default_Owner_C_C__c ) ? (Id) global_var__c.getOrgDefaults().Default_Owner_C_C__c : acc.OwnerId);
        //acc.OwnerId = con.OwnerId; KIV: WHO WILL BE THE OWNER OF PA
        acc.Jigsaw       = con.Jigsaw;
        acc.DWH_Contact_ID__c = con.DWH_Contact_ID__c;
        for( String field : accountFields )
        {
            if( field.endsWith('__pc') ){
                String contactField = field.replace('__pc', '__c');
                acc.put( field, con.get(contactField) );
            }
            else if( field.startsWith('Person') ){
                String contactField = field.remove('Person');
                acc.put( field, con.get(contactField) );
                
            }
        }

        return acc;
    }

    private static Account updateAccountRecordType(Contact con, String accId, List<String> lstAcctFields, List<String> lstContFields ){
        system.debug('@@@ conId: '+con.Id);
        system.debug('@@@ accId: '+ accId);
        Account acc = new Account();
        acc.Id = accId;
        acc.RecordTypeId = selectRecordTypeId(con);

        for(String field : lstAcctFields)
        {
            String strCntField;
            if(field == 'Account__pc' || field == 'Identifier__c' || field == 'Identifier__pc' ){
                continue;
            }
            if(field.endsWith('__pc')){
                strCntField = field.replace('__pc', '__c');
            }
            else if(field.startsWith('Person') ){
                strCntField = field.remove('Person');
            }
            else{
                strCntField = field;
            }
            
            if( lstContFields.contains(strCntField) ){
                acc.put(field, con.get(strCntField));
            }
        }

        System.debug('@@@@DEBUG updateAccountRecordType = acc =' + acc );
        return acc;
    }

    public static String selectRecordTypeId( Contact con ) {

        Boolean isCustomer = false;
        Boolean isEShop = false;

        for (Registered_Vehicle__c tmp : con.Registered_Vehicles__r) {
            isCustomer = true;
            break;
        }

        for (Order__c tmp : con.Orders__r) {
            isEShop = true;
            break;
        }

        if(isCustomer || isEShop) {
            system.debug('------------------1');
            return AccountUtil.getCustomerRecordTypeId();
        }
        // else if(isEShop){
        //     system.debug('------------------2');
        //     return AccountUtil.getEShopCustomerRecordTypeId();
        // }
        else{
            system.debug('------------------3');
            return AccountUtil.getProspectRecordTypeId();
        }

    }



    public class AccountServiceException extends Exception{

    }
}