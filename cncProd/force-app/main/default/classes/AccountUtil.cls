/** ******
 * Description : Service / Util class for PersonAccount
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name       Description
 * 20200306            HS         Created Initial Version
 *                     Hung       Added createListProspects method
 * 20210623            Khanh      Removed Person Account RecordType "E-shop customer"
 * 
** ******/
public without sharing class AccountUtil {

    private final static String CONST_CUSTOMER = 'Customer';
    private final static String CONST_PROSPECT = 'Prospect';
    private final static String CONST_PA_PROFILING_RA = 'RA_Person_Account_Profiling_RT';
    private static RA_Global_Variable__c RA_GlobalVar = RA_Global_Variable__c.getOrgDefaults();

    /** Business Account Record Type DeveloperName */
    private final static String CONST_BUSINESS_ACCOUNT = 'Business_Account';

    private static AccountSelector paSelector = new AccountSelector();

    
    public static Boolean isCustomer ( Id recordTypeId, String recordTypeAPIName ) {
        return ( ( Schema.SObjectType.Account.getRecordTypeInfosById().containsKey( recordTypeId ) &&
                        Schema.SObjectType.Account.getRecordTypeInfosById().get( recordTypeId ).getDeveloperName() == CONST_CUSTOMER ) || recordTypeAPIName == CONST_CUSTOMER );
    }

    public static Boolean isProspect ( Id recordTypeId, String recordTypeAPIName ) {
	    return ( ( Schema.SObjectType.Account.getRecordTypeInfosById().containsKey( recordTypeId ) &&
                        Schema.SObjectType.Account.getRecordTypeInfosById().get( recordTypeId ).getDeveloperName() == CONST_PROSPECT ) || recordTypeAPIName == CONST_PROSPECT );
    }

    public static Id getBusinessAccountRecordTypeId() {
        if( Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().containsKey( CONST_BUSINESS_ACCOUNT ) ) {
            return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( CONST_BUSINESS_ACCOUNT ).getRecordTypeId(); 
        }
        return null;
    }

    public static Id getCustomerRecordTypeId() {
        System.debug(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().containsKey( CONST_CUSTOMER ));
        System.debug(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( CONST_CUSTOMER ).getRecordTypeId());


        if( Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().containsKey( CONST_CUSTOMER ) ) {
            return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( CONST_CUSTOMER ).getRecordTypeId(); 
        }
        return null;
    }

    public static Id getProspectRecordTypeId() {
        if( Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().containsKey( CONST_PROSPECT ) ) {
            return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( CONST_PROSPECT ).getRecordTypeId(); 
        }
        return null;
    }

    public static Account getSinglePersonAccountById( String param_paId ) {
        List<Account> lstPAs = ( paSelector.getPersonAccountListByIds( new Set<String>{ param_paId }, null, null ) );
        return ( (lstPAs <> null && !lstPAs.isEmpty()) ? lstPAs.get(0) : null );
    }

    public static Account getSinglePersonAccountByContactId( String param_paContactId ) {
        List<Account> lstPAs = ( paSelector.getPersonAccountListByIds( null, new Set<String>{ param_paContactId }, null ) );
        return ( (lstPAs <> null && !lstPAs.isEmpty()) ? lstPAs.get(0) : null );
    }

    public static List<Account> getPersonAccountsRecordByIds( Set<String> param_SetPAIds ) {
        return paSelector.getPersonAccountListByIds( param_SetPAIds, null, null );
    }

    public static Account getCustomerRecordById( String param_customerId ) {
        List<Account> lstPA_Customer = ( paSelector.getPersonAccountListByIds( new Set<String>{ param_customerId }, null, CONST_CUSTOMER ) );
        return ( (lstPA_Customer <> null && !lstPA_Customer.isEmpty()) ? lstPA_Customer.get(0) : null ); 
    }

    public static Account getProspectRecordById( String param_prospectId ) {
        List<Account> lstPA_Prospect = paSelector.getPersonAccountListByIds( new Set<String>{ param_prospectId }, null, CONST_PROSPECT );
        return ( (lstPA_Prospect <> null && !lstPA_Prospect.isEmpty()) ? lstPA_Prospect.get(0) : null );
    }

    public static List<Account> getCustomerListByEmails( Set<String> param_customerEmails ) {
        return paSelector.getPersonAccountListByIdsOrEmails( null, null, param_customerEmails, CONST_CUSTOMER );
    }

    public static List<Account> getProspectListByEmails( Set<String> param_prospectEmails ) {
        return paSelector.getPersonAccountListByIdsOrEmails( null, null, param_prospectEmails, CONST_PROSPECT );
    }

    public static Account getPersonAccountByEmail( String email ) {
        List<Account> personAccList = getPersonAccountsByEmails( new Set<String>{ email });
        return ( (personAccList <> null && !personAccList.isEmpty()) ? personAccList.get(0) : null );
    }
    

    public static List<Account> getPersonAccountsByEmails( Set<String> emails ) {
        return paSelector.getPersonAccountListByIdsOrEmails( null, null, emails, null );
    }

    public static Account createProspect( Account prospect_Object ){
        Account newProspect = new Account();
        try{
            ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Account.SObjectType} );
            Id defaultAcctID = getDefaultAccountOwnerId();

            newProspect              = prospect_Object;
            newProspect.RecordTypeId = AccountUtil.getProspectRecordTypeId();
            if( defaultAcctID <> null ){
                newProspect.OwnerId = defaultAcctID;
            }
            uow.registerNew(newProspect);
            uow.commitWork();
        }
        catch( Exception ex ){
            System.debug('@@@@DEBUG createProspect ERROR :: err.msg = ' + ex.getMessage() );
        }
        
        return newProspect;
    }

    public static List<Account> createListProspects(List<Account> prospect_list ){
        List<Account> newProspectList = new List<Account>();
        Set<String> setOfPAEmails = new Set<String>();
        try{
            ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Account.SObjectType} );
            Id defaultAcctID = getDefaultAccountOwnerId();
            Id prospectRecordTypeID = AccountUtil.getProspectRecordTypeId();
            for(Account acc : prospect_list){
                acc.RecordTypeId = prospectRecordTypeID;
                setOfPAEmails.add(acc.PersonEmail);
                if( defaultAcctID <> null ){
                    acc.OwnerId = defaultAcctID;
                }
            }

            uow.registerUpsert(prospect_list);
            uow.commitWork();
 
            Set<Id> setProspectIds = new Map<Id,Account>( prospect_list ).keySet();
            Set<String> setStrProspectIds = (Set<String>)JSON.deserialize(JSON.serialize(setProspectIds), Set<String>.class);
            prospect_list = getPersonAccountsRecordByIds( setStrProspectIds );

        }
        catch( Exception ex ){
            System.debug('@@@@DEBUG createListProspects ERROR :: err.msg = ' + ex.getMessage() );
        }
        
        return prospect_list;
    }


    public static Id getDefaultAccountOwnerId(){
        global_var__c jccCusSetting = global_var__c.getOrgDefaults();
        if(  String.isNotBlank( jccCusSetting.Default_Owner_C_C__c )  ){
            return (Id)jccCusSetting.Default_Owner_C_C__c;
        }
        return null;
    }


    public static String createUniqueString(){
        Integer randomNumber = Integer.valueOf((Math.random()*100000));
        String hashString = randomNumber + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        system.debug('########## random string' + hexDigest );

        return hexDigest;

    }   

    /** ADDED BY TPHAN ON 23/07/2021 - PA MERGING*/
    public static void updatePA (PAWrapper record, String pAId)
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Account.SObjectType});
        List<Account> pAs = AccountUtil.getPersonAccountsRecordByIds(new Set<String> {pAId});
        System.debug('@@@@DEBUG updatePA :: pAs --- ' + pAs );
        if (pAs.size() > 0)
        {
            Account pA            = new Account (Id = pAs.get(0).Id);
            pA.Salutation         = String.isNotBlank(record.salutation)? record.salutation: pA.Salutation;
            pA.FirstName          = String.isNotBlank(record.firstName) ? record.firstName : pA.FirstName;
            pA.LastName           = String.isNotBlank(record.lastName)  ? record.lastName  : pA.LastName;
            pA.Full_Name__pc      = String.isNotBlank(record.fullName)  ? record.fullName  : pA.Full_Name__pc;
            pA.PersonMobilePhone  = String.isNotBlank(record.mobile)    ? record.mobile    : pA.PersonMobilePhone;
            pA.PersonBirthdate    = record.dateOfBirth <> null          ? record.dateOfBirth : pA.PersonBirthdate;
            pA.Address_Line_1__pc = String.isNotBlank(record.addressLine1) ? record.addressLine1 : pA.Address_Line_1__pc;
            pA.Address_Line_2__pc = String.isNotBlank(record.addressLine2) ? record.addressLine2 : pA.Address_Line_2__pc;
            pA.Address_Line_3__pc = String.isNotBlank(record.addressLine3) ? record.addressLine3 : pA.Address_Line_3__pc;
            pA.Address_Line_4__pc = String.isNotBlank(record.addressLine4) ? record.addressLine4 : pA.Address_Line_4__pc;
            pA.Address_Line_5__pc = String.isNotBlank(record.addressLine5) ? record.addressLine5 : pA.Address_Line_5__pc;
            pA.Country__pc        = String.isNotBlank(record.country)      ? record.country      : pA.Country__pc;
            pA.PDPA__pc           = record.pdpa ? 'SMS; Call; Email' : '';
            pA.SMS__pc            = record.pdpa ? true : false;
            pA.Call__pc           = record.pdpa ? true : false;
            pA.Fax__pc            = record.pdpa ? true : false;
            pA.Email__pc          = record.pdpa ? true : false;
            pA.Type__pc           = String.isNotBlank(record.type)         ? record.type         : pA.Type__pc;
            pA.CustomerType__pc   = String.isNotBlank(record.customerType) ? record.customerType : pA.CustomerType__pc;
            pA.Source__pc         = String.isNotBlank(record.source)       ? record.source       : pA.Source__pc;
            pA.CustomerDataSource__pc        = String.isNotBlank(record.customerDataSource)   ? record.customerDataSource   : pA.CustomerDataSource__pc;
            pA.Preferred_Mode_of_contact__pc = String.isNotBlank(record.preferredContactMode) ? record.preferredContactMode : pA.Preferred_Mode_of_contact__pc;

            if (String.isNotBlank(record.NRIC) && record.dateOfBirth <> null)
            {
                String temp = record.NRIC.right(4) + String.valueOf(record.dateOfBirth.day()).leftPad(2, '0') + String.valueOf(record.dateOfBirth.month()).leftPad(2, '0') + String.valueOf(record.dateOfBirth.year()); 
                pA.NRIC__pc = temp;
                pA.NRIC_Passport_No__pc = temp; 
            }
            System.debug('@@@@DEBUG updatePA :: pA --- ' + pA );
            uow.registerDirty(pA);
            uow.commitWork();
        }
    }

    public class PAWrapper
    {
        public String salutation;
        public String firstName;
        public String lastName;
        public String fullName;
        public String NRIC;
        public String mobile;
        public Date   dateOfBirth;
        public String addressLine1;
        public String addressLine2;
        public String addressLine3;
        public String addressLine4;
        public String addressLine5;
        public String country;
        public Boolean pdpa;
        public String preferredContactMode;
        public String type;
        public String customerType;
        public String customerDataSource;
        public String source;

        public PAWrapper(String salutation, String firstName, String lastName, String fullName, String NRIC, String mobile, Date dateOfBirth, 
                        String addressLine1, String addressLine2, String addressLine3, String addressLine4, String addressLine5, String country,
                        Boolean pdpa, String preferredContactMode, String type, String customerType, String customerDataSource, String source)
        {
            this.salutation   = salutation;
            this.firstName    = firstName;
            this.lastName     = lastName;
            this.fullName     = fullName;
            this.NRIC         = NRIC;
            this.mobile       = String.isNotBlank(mobile) ? (mobile.startsWith('65') ? mobile : '65' + mobile) : '';
            this.dateOfBirth  = dateOfBirth;
            this.addressLine1 = addressLine1;
            this.addressLine2 = addressLine2;
            this.addressLine3 = addressLine3;
            this.addressLine4 = addressLine4;
            this.addressLine5 = addressLine5;
            this.country      = country;
            this.pdpa         = pdpa;
            this.type         = type;
            this.source       = source;
            this.customerType = customerType;
            this.preferredContactMode = preferredContactMode;
            this.customerDataSource   = customerDataSource;
        }
    }
    /** END */

    /* ================ ***************** ==================== */
    public static Person_Account_Profiling__c createProfiling( String typeApiName, Account personAcc) {    
        System.debug('AccountUtil.createProfiling():: personAcc = ' + personAcc);    
        List<Person_Account_Profiling__c> results = createProfilings(typeApiName, new List<Account>{personAcc});
        return results != null && results.size() > 0 ? results[0] : null;
    }


    public static List<Person_Account_Profiling__c> createProfilings(String typeApiName, List<Account> accList) {
        List<Person_Account_Profiling__c> profilingList = new List<Person_Account_Profiling__c>();
        try{
            
            String profilingTypeId = PersonAccountProfilingService.getRecordTypeId(typeApiName);
            List<Account> accToCreateProfile = checkExistProfilings(profilingTypeId, accList);
            
            for(Account acc: accToCreateProfile) {

                Person_Account_Profiling__c profiling = new Person_Account_Profiling__c();
                profiling.Account__c   = acc.Id;
                profiling.RecordTypeId = profilingTypeId;
                profilingList.add( profiling );
            
            }
            insert profilingList;
        } catch (Exception ex) {
            LoggerDataPool.buildLogDataPool('AccountUtil.createProfilings()', ex);
        }
        return profilingList;
    }

    private static List<Account> checkExistProfilings(Id recordTypeId, List<Account> accList) {
        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        for(Account acc: accList) {
            mapAccounts.put(acc.Id, acc);           
        }

        List<Person_Account_Profiling__c> profilingList = [ SELECT Id, Account__c, RecordTypeId, RecordType.DeveloperName 
                                                            FROM Person_Account_Profiling__c
                                                            WHERE Account__c IN :mapAccounts.keySet()
                                                            AND RecordTypeId = :recordTypeId
                                                            ORDER BY Account__c
                                                        ];

        for(Person_Account_Profiling__c profile: profilingList) {
            if( mapAccounts.containsKey(profile.Account__c) ) {
                mapAccounts.remove(profile.Account__c);
            }
        }
        
        return mapAccounts.values();

    }

    public static Id getRecordTypeIdByName(String recordTypeName) {
        if( Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().containsKey( recordTypeName ) ) {
            return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( recordTypeName ).getRecordTypeId(); 
        }
        return null;
    }

    public static Account upsertRACustomer( RACustomerWrapper customerWrapper, String accRecType) {
        Account customer;
        String email = customerWrapper.email;
        if(String.isNotBlank(email)) {
            customer = AccountUtil.getPersonAccountByEmail( email );
            if(customer != null) { //Account exists
                if( customer.RA_Owner__c == null )
                {
                    customer.RA_Owner__c = (Id)RA_GlobalVar.Default_RA_OwnerId__c;
                }
                //Update account type from Prospect to Customer
                if(accRecType == 'Customer') {
                    customer.RecordTypeId = getCustomerRecordTypeId();
                    customer.Type__pc     = 'Customer';
                }
                updateCustomerInfo(customer, customerWrapper);
                update customer;
            } else {
                customer              = new Account();
                customer.RecordTypeId = getRecordTypeIdByName(accRecType);
                customer.Type__pc     = accRecType;
                updateCustomerInfo(customer, customerWrapper);
                insert customer;
                createProfiling(CONST_PA_PROFILING_RA, customer);
            }
        }
        customer = getSinglePersonAccountById(customer.Id);
        return customer;
    }

    public class RACustomerWrapper {
        public String firstName;
        public String lastName;
        public String fullName;
        public String email;
        public String mobile;
        public Boolean consent;

        public RACustomerWrapper(String firstName, String lastName, String email, String mobile, Boolean consent){
            this.firstName = firstName;
            this.lastName  = lastName;
            this.fullName  = firstName + ' ' + lastName;
            this.email     = email;
            this.mobile    = mobile;
            this.consent = consent;
        }
    }


    private static void updateCustomerInfo(Account customer, RACustomerWrapper wrapper ) {
        customer.FirstName         = String.isNotBlank(wrapper.firstName) ? wrapper.firstName : customer.FirstName;
        customer.LastName          = String.isNotBlank(wrapper.lastName) ? wrapper.lastName : customer.LastName;   
        customer.Full_Name__pc     = String.isNotBlank(wrapper.fullName) ? wrapper.fullName : customer.Full_Name__pc;
        customer.PersonMobilePhone = String.isNotBlank(wrapper.mobile) ? wrapper.mobile : customer.PersonMobilePhone;
        customer.PersonEmail       = String.isNotBlank(wrapper.email) ? wrapper.email : customer.PersonEmail;
        if(wrapper.consent) {
            customer.PDPA__pc  = 'SMS;Call;Email';
            customer.Email__pc = true;
            customer.Call__pc  = true;
            customer.Fax__pc   = true;
            customer.SMS__pc   = true;
        } else {
            customer.Email__pc = false;
            customer.Call__pc  = false;
            customer.Fax__pc   = false;
            customer.SMS__pc   = false;
        }
    }
    

}