/** ******
 * Description : Wrapper Class for Referral Object
 * 
 * Change History:
 * Date(YYYYMMDD)   Name                Description
 * 20200211         HS@aodigy           Created Initial Version. 
 * 20200325         SJ@aodigy           Need var added: string brand
 * 20200908         Thu@aodigy          PA Phase 2 : Removed Lead reference & checking from the code         
 * 20210315         HS@aodigy           Check existing Prospect (i.e. Referee) in the DB before creating a new one at populateProspectRecord
 * 20211213         Thu@aodigy          Modified populateProspectRecord method
 * 20220110         Thu@aodigy          Modified populateReferralRecord method to capture Referee infor.
** ******/
public class ReferralWrapper {
    
    public String FirstName {get; set;}
    public String LastName  {get; set;}
    public String MobileNumber {get; set;}
    public String Email {get; set;}
    public String PreferredSC {get; set;}
    public String Brand {get; set;}
    public String PDPA {get; set;}
    public String UserId {get; set;}
    
    public String referrerContactId {get; set;}
    public String referrerPAId {get; set;}
    public Lead leadObj {get; set;}
    public Account prospectObj {get; set;}
    public Opportunity opportunityObj {get; set;}
    public Referral__c referralObj {get; set;}

    public static Account populateProspectRecord( ReferralWrapper reffWrap, Map<Id,User> mapUser ){

        //Find Existing Prospect based on Email
        Account existingProspect = new Account();
        if( String.isNotBlank( reffWrap.Email ))
        {
            //List<Account> lstExistingProspect = AccountUtil.getProspectListByEmails( new Set<String>{ reffWrap.Email } );
            List<Account> lstExistingProspect = AccountUtil.getPersonAccountsByEmails(new Set<String>{reffWrap.Email});
            existingProspect = !lstExistingProspect.isEmpty() ? lstExistingProspect.get(0) : null;
        }

        Account newAccount = new Account();
        if( existingProspect == null )
        {
            String strPreferredSCId = reffWrap.PreferredSC;
            // Account newAccount = new Account();
            newAccount.recordTypeId     = AccountUtil.getProspectRecordTypeId();
            newAccount.FirstName        = reffWrap.FirstName;
            newAccount.LastName         = reffWrap.LastName;
            newAccount.PersonEmail      = reffWrap.Email;
            newAccount.PersonMobilePhone  = '65' + reffWrap.MobileNumber;
            newAccount.PersonLeadSource = 'Referral';
            newAccount.Full_Name__pc    = reffWrap.FirstName + ' ' + reffWrap.LastName;
            newAccount.Branch_Code__pc  = mapUser.containsKey( strPreferredSCId ) ? mapUser.get( strPreferredSCId ).Branch_Code__c : null;
        }
        else
        {
            if (existingProspect.RecordType.DeveloperName == 'Prospect')
            {
                newAccount = existingProspect;
            }
            else if (existingProspect.RecordType.DeveloperName == 'Customer') 
            {
                return null;
            }
        }

        if(String.isNotBlank( reffWrap.PDPA ) && reffWrap.PDPA.equalsIgnoreCase('TRUE'))
        {
            UpdatePDPA.updatePDPA(newAccount, true, true, true);
        }
        
        return newAccount;
    }
    
    
    public static Opportunity populateOpportunityRecord( ReferralWrapper reffWrap, Map<Id,User> mapUser ){ 
        
        String strPreferredSCId = reffWrap.PreferredSC;
        Opportunity newOppo = new Opportunity();
        newOppo.Name              = 'Referral(app) - ' + reffWrap.FirstName + ' ' + reffWrap.LastName ;     
        newOppo.StageName         = 'Open';        
        newOppo.LeadSource        = 'Referral(app)';   
        newOppo.CloseDate         = Date.today().addMonths( 6 );
        newOppo.Account__c        = reffWrap.prospectObj <> null ? reffWrap.prospectObj.Id : null;   
        
        User thisSC = (mapUser <> null && mapUser.containsKey( strPreferredSCId )) ? mapUser.get( strPreferredSCId ) : null;
        
        newOppo.Branch_Code__c = ReferralService.call_Str_Brand_to_Branch_Convertor(reffWrap.Brand);
        
        System.debug('ThisSC ' + thisSC);
        if( thisSC <> null  ) 
        {
            newOppo.Franchise_Code__c = thisSC.Franchise_Code__c;
            
            if(thisSC.IsActive == true)
            {
                newOppo.OwnerId = strPreferredSCId;
                TriggerExclusion.skipRR = true;
            }      
        }
        
        if( mapUser <> null 
                && mapUser.containsKey( strPreferredSCId ) 
                    && Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().containsKey( mapUser.get( strPreferredSCId ).Franchise_Code__c ) ) 
        {
            newOppo.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get( mapUser.get( strPreferredSCId ).Franchise_Code__c ).getRecordTypeId(); 
        }
        
        return newOppo;
    }
    
    
    public static Referral__c populateReferralRecord( ReferralWrapper reffWrap )
    {
        Referral__c newReferral              = new Referral__c();
        newReferral.Stage__c                 = 'Opened';
        newReferral.Referral_Code__c         = REFFPostCreateReferralRecordAPI.genRefCode(reffWrap.Brand);
        newReferral.PDPA__c                  = ( String.isNotBlank( reffWrap.PDPA ) && reffWrap.PDPA.equalsIgnoreCase('TRUE') ) ? true : false;
        newReferral.brand_picklist__c        = reffWrap.Brand;
        newReferral.Preferred_SC__c          = reffWrap.PreferredSC;
        newReferral.Opportunity__c           = reffWrap.opportunityObj <> null ? reffWrap.opportunityObj.Id : null;
        newReferral.Referee_Account__c       = reffWrap.prospectObj <> null ? reffWrap.prospectObj.Id : null;                             
        newReferral.Referrer_Account__c      = String.isNotBlank( reffWrap.referrerPAId ) ? (Id)reffWrap.referrerPAId : null;             
        newReferral.Expiry_Referred_Date__c  = Date.today() + 90;
        newReferral.Referred_Date__c         = Date.today();
        newReferral.Referree__c              = reffWrap.FirstName;
        newReferral.Referee_Last_Name__c     = reffWrap.LastName;
        newReferral.Referee_Mobile_Number__c = '65' + reffWrap.MobileNumber;

        Registered_Vehicle__c tempRegVeh = ReferralService.call_Reg_veh(reffWrap.referrerContactId, reffWrap.Brand);
        if(tempRegVeh != null)
        {
            newReferral.Referrer_Registered_Vehicle_Customer__c = tempRegVeh.id;
        }
        return newReferral;
    }

    
}