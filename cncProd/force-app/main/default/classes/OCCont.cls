/** *****
 * Description : Controller class of QuickContact.Page & ModelLookp.page
 * 
 * Change History
 * Date(YYYYMMDD)       Name                    Description
 * 20160310             NAIT Admin              Created Initial Version. 
 * 20200326             khanh.do@aodigy.com     Added Changes for PA Migration - Phase 1
 * 20200901             khanh.do@aodigy.com     Added Changes for PA Migration - Phase 2
 * 20210521             khanh.do@aodigy.com     Excluded Opportunity from Round Robin
 * 20210622             khanh.do@aodigy.com     Add Person Account Profiling creation
 * 
** *****/
public class OCCont {
    public String fName{get;set;}
    public String lName{get;set;}
    public String ModName{get;set;}
    public String ModId{get;set;}
    public List<Model__c> ModList{get;set;}
    
    public Opportunity opp {get;set;}
    public Contact cont {get;set;}
    public Account acc {get;set;} 
    
    public String CustFirstName {get;set;} //First Name - Last Name changes
    public String CustlastName {get;set;}
    public String CustEmail {get;set;}
    public String CustMobile {get;set;}
    public String CustPhone {get;set;}
    
    public String branchCode{get;set;}
    public String franchiseCode{get;set;}
    public Boolean errMobile {get;set;}
    public Boolean errEmail {get;set;}
    public Boolean errFirstName {get;set;}  //For First Name
    public Boolean errName {get;set;}       //For Last Name
    public Boolean errModel {get;set;}
    public Boolean errNumberMobile {get;set;}
    public Boolean errNumberMobile2 {get;set;}
    public Boolean errNumberMobile3 {get;set;}
    public Boolean errInvalidemail {get;set;}
    public Boolean okMsg {get;set;}
    public String theGotError{get;set;}
    
    public ID ownId {get;set;}
    
    public String logo1{get;set;}
    public String logo2{get;set;}
    public String email;
    public ID rtid{get;set;}

	public String selectedSrc {get;set;}

	public Boolean isSMS {get;set;}
	public Boolean isEmail {get;set;}
    public Boolean isCall {get;set;}
    public Boolean isFax {get;set;}

	public string strChannel = 'Offline';
    
    List<sharingHelper.generateShare> lstToCreateShare = new List<sharingHelper.generateShare>();
    public PageReference callLookup(){
        ModList = [SELECT Id, Name FROM Model__c WHERE Franchise_Code__c =: franchiseCode AND Active__c = true];
        PageReference pr = new PageReference('/apex/ModelLookp');
        pr.setRedirect(false);
        return pr;
    }
    
    public PageReference goBack(){
        ModName = ApexPages.currentPage().getParameters().get('ModName');
        ModId = ApexPages.currentPage().getParameters().get('ModId');
        PageReference pr = new PageReference('/apex/QuickContact');
        pr.setRedirect(false);
        return pr;
    }
    
    public OCCont(){
        errMobile    = false;
        errName      = false;
        errFirstName = false;
        errModel     = false;
        okMsg        = false;
        ownId        = UserInfo.getUserId();

        User usr = [SELECT Branch_Code__c, Franchise_Code__c FROM User WHERE Id=: ownId];
        branchCode    = usr.Branch_Code__c;
        franchiseCode = usr.Franchise_Code__c;
        
        logo1 = [SELECT FileName__c FROM Logo__c WHERE Branch_Code__c = '' AND Franchise_Code__c = '' LIMIT 1].FileName__c;
        logo2 = [SELECT FileName__c FROM Logo__c WHERE Branch_Code__c = :branchCode LIMIT 1].FileName__c;
        
        opp     = new Opportunity();
        cont    = new Contact(); 
        acc     = new Account();

		//Code was modified for Oppty standardisation --> NSJ
		rtid = OpportunityService.getStrRecordTypeAssignment(branchCode);

        opp.RecordTypeId = rtid;
    }
    
    public List<SelectOption> getSourceOptions() {
        List<SelectOption> srcOptions = new List<SelectOption>();
        srcOptions.add(new SelectOption('','-None-'));
        srcOptions.add(new SelectOption('Chat','Chat'));
        return srcOptions;
    }

    public Pagereference doSave() {
        Set<String> oppStagesSet = new Set<String>();
        //these are the open opp's
        oppStagesSet.add('Open');
        oppStagesSet.add('Test Driven');
        oppStagesSet.add('Stock Reserved'); 
        oppStagesSet.add('Contacted'); // new added value as its comes under Open category according to new approach
        List<Opportunity> oppList = new List<Opportunity>();
        List<Contact> contact = new List<Contact>();
        errMobile        = false;
        errEmail         = false;
        errName          = false;
        errFirstName     = false;
        errModel         = false;
        errInvalidemail  = false;
        errNumberMobile  = false;
        errNumberMobile2 = false;
        errNumberMobile3 = false;
        theGotError      = '';

        try 
        {
            if ( String.isBlank(custMobile) )
            {
                errMobile = true;
            }
            else if ( custMobile.length() < 8 )
            {
                errNumberMobile = true;
            } 

            if ( String.isBlank(custEmail) && selectedSrc != 'Whatsapp')
			{
				System.debug('selectedSrc' + selectedSrc);
                errEmail = true;
            }
            else
            {
                //Updated Regex for Email Address Checking
                if(!Pattern.matches('^([0-9a-zA-Z+_.-]*[0-9a-zA-Z]+[@][0-9a-zA-Z+_.-]+\\.[0-9a-zA-Z+_.-]*)$', custEmail))
				{
					if(selectedSrc != 'Whatsapp')
					{
						errInvalidemail = true;
						return null;
					}
                }
            }
            
            if ( String.isBlank(CustFirstName) )
            {
                errFirstName = true;
            }
            
            if ( String.isBlank(CustLastName) )
            {
                errName = true;
            }
            
            if ( String.isBlank(modName) )
            {
                errModel = true;
            }

            if ( errFirstName || errName || errMobile || errModel || errNumberMobile )
            {
                theGotError = 'err';
                return null;
            }
            
            Date today = Date.today();
            if( String.isNotBlank(custMobile) )
            {
                //append 65 if do not have
                if(!custMobile.startsWith('65'))
                {
                    custMobile = '65' + custMobile;
                }
                
                //if any existing contact with input MobilePhone
                contact = [ SELECT Id, 
                                FirstName, 
                                LastName, 
                                Name, 
                                MobilePhone, 
                                Phone , 
                                AccountId
                            FROM Contact 
                            WHERE MobilePhone = :custMobile
                            AND IsPersonAccount = true
                            ORDER BY Account.RecordType.Name ASC, CreatedDate DESC 
                            LIMIT 1];

                System.debug('@@@@DEBUG doSave :: contact = ' + contact);

                if( contact.size() > 0 )
                {
                    oppList = [ SELECT Id, Opportunity_Score__c, Franchise_Code__c 
                                FROM Opportunity
                                WHERE StageName NOT IN ('Booked', 'Lost') 
                                AND OwnerId =:ownID 
                                AND Contact_Person__c = :contact[0].id
                                ORDER BY CreatedDate DESC];          
                    
                    if ( oppList.size() > 0 )
                    {
                        opp = oppList[0];
                        Decimal oppScore = oppList[0].Opportunity_Score__c; 
                        if (oppScore != null)
                        {
                            oppScore = oppScore.intValue() + 5;                
                        }
                        else 
                        {
                            oppScore = 5;
                        }
                        opp.Opportunity_Score__c = oppScore;


						opp.LeadSource = 'Walk-In';

						update opp;

						if(selectedSrc == 'Chat')
						{
							strChannel = 'Online';
							opp.LeadSource = selectedSrc;
						}
                        
                        String modInterested = createdModelInterested( opp.Id, ModId, strChannel );    
                    } 
                    else
                    {

						if(selectedSrc == 'Chat')
						{
							strChannel = 'Online';
						}
						else
						{
							selectedSrc = 'Walk-In';
						}

						//Code was modified for Oppty standardisation --> NSJ
                        Opportunity newOpp = new Opportunity();
						newOpp = OpportunityService.newOpportunityObject(contact[0].Id, contact[0].AccountId, rtid,
																		branchCode, franchiseCode, selectedSrc);


                        newOpp.Name = OpportunityService.getStrOpportunityName(CustlastName, franchiseCode);
                        newOpp.Opportunity_Score__c = 5;
                        TriggerExclusion.skipRR = true;
                        insert newOpp;
                        


                        String modInterested = createdModelInterested( newOpp.Id, modId, strChannel );
                    } 
                    
                    lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Contact', contact[0].Id, ownId));
                

                    Contact newContact = new Contact(Id = contact[0].Id); //Work around to update Person Contact
                    //Requirement: For Contact, update only First Name if blank
                    if( String.isBlank(newContact.FirstName) && String.isNotBlank(custFirstName) )
                    {
                        newContact.FirstName = custFirstName;
                    }
                    
                    if( String.isNotBlank(custLastName) )
                    {
                        newContact.LastName = custLastName;
                    }

                    if( String.isNotBlank(custMobile) )
                    {
                        newContact.MobilePhone= custMobile;
                    }  
                    
                    if( String.isNotBlank(custPhone) && !custPhone.startsWith('65') )
                    {
                        newContact.Phone = '65' + custPhone;
                    }
                    else if( String.isNotBlank(custPhone) && custPhone.startsWith('65') )
                    {
                        newContact.Phone = custPhone;
                    }
                    
                    if( String.isNotBlank(custEmail) )
                    {
                        newContact.Email = CustEmail;
                    }

                    newContact.PDPA__c = strPDPAformat();
                    UpdatePDPA.updatePDPA(newContact, isSMS, isCall, isEmail, isFax);
                    update newContact;
                    okMsg = true;            
                } 
                else 
                {
                        
                    Account newProspect = new Account();    
                    newProspect.recordTypeId  = AccountUtil.getProspectRecordTypeId();
                    newProspect.FirstName     = CustFirstName;
                    newProspect.LastName      = CustlastName;
                    newProspect.PersonEmail   = CustEmail;
                    newProspect.Source__pc    = selectedSrc;
                    newProspect.PDPA__pc      = strPDPAformat();
                    UpdatePDPA.updatePDPA(newProspect, isSMS, isCall, isEmail, isFax);

                    if( String.isNotBlank(custMobile) && !custMobile.startsWith('65') )
                    {
                        newProspect.PersonMobilePhone = '65' + custMobile;
                    } 
                    else if( String.isNotBlank(custMobile) && custMobile.startsWith('65') )
                    {
                        newProspect.PersonMobilePhone = custMobile;
                    }   
                    
                    if( String.isNotBlank(custPhone) && !custPhone.startsWith('65') )
                    {
                        newProspect.Phone = '65' + custPhone;
                    }
                    else if( String.isNotBlank(custPhone) && custPhone.startsWith('65') )
                    {
                        newProspect.Phone = custPhone;
                    }
                    System.debug('Line 311 :: ' + newProspect);
                    newProspect = AccountUtil.createProspect( newProspect ); 
                    newProspect = AccountUtil.getProspectRecordById(newProspect.Id);
                    System.debug('@@@@DEBUG doSave :: newProspect = ' + newProspect);

                    //Added by Khanh - Create Person Account Profiling
                    AccountUtil.createProfiling('CCS_Person_Account_Profiling_RT', newProspect);
                    

                    lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Account', newProspect.Id, ownId)); 
                    
					//Code was modified for Oppty standardisation --> NSJ
                    Opportunity newOpp = new Opportunity();

					if(selectedSrc == 'Chat')
					{
						strChannel = 'Online';
					}
					else
					{
						selectedSrc = 'Walk-In';
					}

					newOpp = OpportunityService.newOpportunityObject(newProspect.PersonContactId, newProspect.Id, rtid,
																	branchCode, franchiseCode, selectedSrc);

                    newOpp.Name = OpportunityService.getStrOpportunityName(CustlastName, franchiseCode);
                    newOpp.Opportunity_Score__c = 5;

                    TriggerExclusion.skipRR = true;
                    insert newopp;
                    okMsg = true;   

                    String modInterested = createdModelInterested( newOpp.Id, modId, strChannel);
                }
            }
                
            System.debug('@@@@DEBUG doSave :: lstToCreateShare = ' + lstToCreateShare.size() + ' --- ' + lstToCreateShare );
            if(!Test.isRunningTest())
            {
                sharingHelper.creatShare(lstToCreateShare);
            }   
            
            if ( okMsg )
            {
                errMobile = false;
                errName   = false;
                errModel  = false;
            }
            
            custMobile    = '';
            custFirstName = '';
            custlastName  = '';
            custEmail     = '';
            custPhone     = '';
            modName       = '';
        }
        catch(Exception ex)
        {
            System.debug('@@@@DEBUG doSave :: EXCEPTION = ' + ex);
        }

        return null;
    }
    
    public pageReference searchCustPhone()
    {
        Set<String> SetOppStage = new Set<String>();
        //these are the open opp's
        SetOppStage.add('Open');
        SetOppStage.add('Test Driven');
        SetOppStage.add('Stock Reserved');  
        SetOppStage.add('Contacted'); // new added value as its comes under Open category according to new approach
        theGotError      = '';
        errNumberMobile  = false;
        errNumberMobile2 = false;
        errNumberMobile3 = false;
        
        okMsg = false;
        if ( String.isBlank(custMobile) ){
            errMobile = true;
            return null;
        }      
        
        if ( String.isNotBlank(custMobile) )
        {    
            //This string will automatically append  65 to the MobilePhone
            String queryMobile = '65' + custMobile;
            
            //Search for Existing Contact
            List<Contact> lstContact = [SELECT Id, Email, FirstName, LastName, Name, MobilePhone, Phone, 
                                            Branch_Code__c, Franchise_Code__c, OwnerID 
                                        FROM Contact 
                                        WHERE MobilePhone = :queryMobile 
                                        ORDER BY CreatedDate DESC 
                                        LIMIT 1];

            /**PA MIGRARION: Newly Added -- Start */
            //Search for Existing Person Account regardless of Customer or Prospect
            List<Account> lstPersonAccount = new List<Account>();
            lstPersonAccount = [SELECT Id, PersonEmail, FirstName, LastName, Full_Name__pc, Name, PersonMobilePhone, Phone, 
                                        Branch_Code__pc, Franchise_Code__pc, OwnerID, RecordTypeId, RecordType.DeveloperName
                                FROM Account 
                                WHERE PersonMobilePhone = :queryMobile
                                AND IsPersonAccount = true 
                                ORDER BY CreatedDate DESC 
                                LIMIT 1];
            /**PA MIGRARION: Newly Added -- Stop */          

            if( lstPersonAccount.size() > 0 )
            {
                acc = lstPersonAccount.get (0);
                List<Opportunity> opp = [ SELECT Id, Model_Interested_In__c, Model_c__c, Franchise_Code__c
                                          FROM Opportunity
                                          WHERE StageName NOT IN ('Booked', 'Lost')
                                          AND OwnerId = :ownID
                                          AND Account__c =: acc.Id
                                          AND Account__c != null
                                          ORDER BY createdDate DESC
                                          LIMIT 1 ];
                if (opp.size()>0)
                {
                    this.opp = opp[0];
                }

                theGotError   = 'go';
                errMobile     = false;
                errEmail      = false;
                errFirstName  = false;
                errName       = false;
                errModel      = false;  
                email         = acc.PersonEmail;
                custFirstName = acc.FirstName;
                custlastName  = acc.LastName;
                custEmail     = String.isBlank(acc.PersonEmail) ? '' : acc.PersonEmail;
				custPhone     = String.isBlank(acc.Phone) ? '' : acc.Phone;
            } 
            else if( lstContact.size() > 0 ) 
            {
                cont = lstContact.get(0);
                List<Opportunity> opp = [ SELECT Id, Model_Interested_In__c, Model_c__c, Franchise_Code__c
                                          FROM Opportunity
                                          WHERE StageName NOT IN ('Booked', 'Lost')
                                          AND OwnerId = :ownID
                                          AND Contact_Person__c = :cont.Id
                                          AND Contact_Person__c != null
                                          ORDER BY CreatedDate DESC
                                          LIMIT 1];
                if( opp.size() > 0 )
                {
                    this.opp = opp[0];
                }
                theGotError   = 'go';
                errMobile     = false;
                errEmail      = false;
                errFirstName  = false;
                errName       = false;
                errModel      = false;  
                email         = cont.Email;
                custFirstName = cont.FirstName;
                custlastName  = cont.LastName;
                custEmail     = String.isBlank(cont.Email) ? '' : cont.Email;
				custPhone     = String.isBlank(cont.Phone) ? '' : cont.Phone;
            }
            else
            {
                errMobile     = false;
                errEmail      = false;
                errName       = false;
                errModel      = false;
                okMsg         = false;
                opp           = new Opportunity();
                acc           = new Account();      //PA MIGRATION: Newly Added
                custFirstName = '';
                CustlastName  = '';   
                CustEmail     = '';
                custPhone     = '';
            }

            ModName = '';
            ModId   = '';
        }    

        return null;
    }
    
    //Clear Form Input
    public PageReference doClear() 
    {
        errMobile        = false;
        errNumberMobile  = false;
        errNumberMobile2 = false;
        errNumberMobile3 = false;
        errFirstName     = false;
        errInvalidemail  = false;
        errName          = false;
        errModel         = false;
        okMsg            = false;
        CustMobile       = '';
        CustFirstName    = '';
        CustlastName     = '';
        CustEmail        = '';
        CustPhone        = '';
        modName          = '';
        opp = new Opportunity();
        opp.RecordTypeId = rtid;
        cont = new Contact();
        
        return null;
    } 

    //Go back to SF Page
    public PageReference doCancel() 
    {
        return new pagereference('/');
    }
    

    //Create Models Interested
    public String createdModelInterested( String OppId, String ModId, String channel )
    {
        try
        {
			//Code was modified for Oppty standardisation --> NSJ
			Models_Interested__c createModInt = new Models_Interested__c();
			createModInt = ModelsInterestedService.newModelInterestedObject(OppId, ModId, channel, 'Quick Contact');
			insert createModInt;
            return 'Success';
        }
        catch(Exception e)
        {
            return 'Exception';
        }
    }

    public String strPDPAformat()
	{
		String strPDPA = '';

		if(isSMS == true)
		{
			strPDPA = 'SMS;';
		}
		if(isEmail == true)
		{
			strPDPA = strPDPA + 'Email;';
		}
		if(isCall == true)
		{
			strPDPA = strPDPA + 'Call';
		}
		
		return strPDPA;
	}
}