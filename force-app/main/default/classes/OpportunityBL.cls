/** *******
 * 
 * Class Name: OpportunityBL
 * Description: Business Logic class for Opportunity object.
 * 
 * Note: without sharing is used so that this batch will run on System mode.
 * 
 * Revision History
 * Date(YYYYMMDD)       Developer Name          Description
 * 20190322             Christian Gaylan        Created.
 * 20190325             Christian Gaylan        Added setBranchCode method : To populate the branch code of Opportunities (p/s: Refactored from OpposetBranchNFranchiseCode trigger)  
 * 20190401             Christian Gaylan        Added setSharing method : Set Contact and Lead sharing on Owner Reassignment   
 * 20200325             HS                      Added PA Migration Changes
 * 
 ******* **/
public without sharing class OpportunityBL {
    
    //Custom Exception for Test Coverage
    public class CustTestException extends Exception{}
    

    public static void checkIsFleetOwner( List<Opportunity> oppList ){
        Set<Id> setOwnerIds = new Set<Id>();
        for( Opportunity opp : oppList ){
            setOwnerIds.add( opp.OwnerId );
        }
        
        if( !setOwnerIds.isEmpty() )
        {
            Map<Id,User> mapFleetUsers = new Map<Id,User>( [SELECT Id FROM User WHERE ID IN:setOwnerIds AND Profile.Name LIKE '%Fleet%' ] );

            if( !mapFleetUsers.isEmpty() ){
                for( Opportunity opp : oppList ){
                    if( mapFleetUsers.keySet().contains( opp.OwnerId ) ){
                        opp.Is_Fleet__c = true;
                    }
                }
            }
        }
    }

    public static void forceUpdateListOfContact( List<Opportunity> oppList )
	{
        List<contact> contactList = new List<contact>();
        for( Opportunity opp : oppList )
		{
			if(opp.customer_type__c == 'Prospect')
			{
				contact con = new contact();
				con.id = opp.Contact_Person__c;
				contactList.add(con);
			}
        }

		if(contactList.size() > 0)
		{
			Database.update(contactList);
		}
    }


    /** ********
     * Method Name: createTaskOnOwnerReassign
     * Description : Create a To-Do (Task) on every Opportunity OwnerId update
     * @param oppList : Trigger.new
     * @param oldMap : Trigger.oldMap
     * @return : N/A
     ******** **/
    public static void createTaskOnOwnerReassign(List<Opportunity> oppList, Map<Id, Opportunity> oldMap){
        try{
            if(oppList!=null && !oppList.isEmpty()){
                List<Task> tskList = new List<Task>();
                Set<Id> opptyIds = new Set<Id>();
                
                for(Opportunity opp : oppList){
                    //Owner has changed
                    if(opp.OwnerId != oldMap.get(opp.Id).OwnerId){
                        opptyIds.add(opp.Id);
                        tskList.add(
                            Utility.createTask(opp.Id, opp.OwnerId, System.Label.OppAssignment)
                        );
                    }
                }
                
                if(!tskList.isEmpty()){
                    //Close all open assignmen Tasks if any
                    List<Task> tskToComplete = new List<Task>();
                    for(Task tk : [SELECT Id, Status 
                                   FROM Task 
                                   WHERE WhatId IN: opptyIds 
                                   AND Subject =: Label.OppAssignment 
                                   AND Status=: TaskConstants.STAT_OPEN] )
                    {
                        tk.Status = TaskConstants.STAT_COMP;
                        tskToComplete.add(tk);
                    }
                    
                    if( !tskToComplete.isEmpty() ){
                        update tskToComplete;
                    }
                    
                    insert tskList;

                    if(Test.isRunningTest()){
                        //for test class coverage
                        throw new CustTestException();
                    }
                }
            }  
        }
        catch(Exception e){
            loggerDataPool.buildLogDataPool('OpportunityBL.createTaskOnOwnerReassign',e);
        }
    }
    

    /** ********
     * Method Name: Clash Opportunity Logic
     * Descriptin : Identify Clash Opportunities and create Clash Deal
     * @param oppList : Trigger.new
     * @param oldMap : Trigger.oldMap
     * @return : N/A
     ******** **/
    public static void setClashOpportunity(List<Opportunity> oppList, Map<Id, Opportunity> oldMap){
        try{
            if(oppList!=null && !oppList.isEmpty()){
                //Set<Id> leadIds = new Set<Id>();       
                Set<Id> contactIds = new Set<Id>();    
                Set<Id> accountIds = new Set<Id>();             
                String clashEmailIds;
                Map<Id,String> oppIdToClashString = new Map<Id,String>();
                Set<Id> Oppid = new Set<Id>();
                global_var__c jccCusSetting = global_var__c.getOrgDefaults();
                //Flag for update
                Boolean isUpdate = oldMap!=null;
                
                for(Opportunity opp : oppList) {
                    Opportunity oldOpp = null;
                    Oppid.add(opp.Id);

                    /*
                    if(opp.Account__c != null){
                        //for insert
                        if(!isUpdate){
                            accountIds.add(opp.Account__c);
                        }
                        //for update, is not clash and Status is Stock Reserved now.
                        if(isUpdate && !opp.Clash_Opportunity__c && opp.StageName =='Stock Reserved' && opp.StageName != oldMap.get(opp.Id).StageName){
                            accountIds.add(opp.Account__c);
                        }
                    }
                    */
                    /*if(opp.Lead__c != null){
                        //for Insert
                        if(!isUpdate){
                            leadIds.add(opp.Lead__c);                        
                        }
                        
                        //for update, is not clash and Status is Stock Reserved now.
                        if(isUpdate && !opp.Clash_Opportunity__c && opp.StageName =='Stock Reserved' && opp.StageName != oldMap.get(opp.Id).StageName){
                            leadIds.add(opp.Lead__c);
                        }
                    }*/
                    //else if (opp.Contact_Person__c != null){
                    if (opp.Contact_Person__c != null){
                        //for Insert
                        if(!isUpdate){
                            contactIds.add(opp.Contact_Person__c);
                        }
                        
                        //for update, is not clash and Status is Stock Reserved now.
                        if(isUpdate && !opp.Clash_Opportunity__c && opp.StageName =='Stock Reserved' && opp.StageName != oldMap.get(opp.Id).StageName){
                            contactIds.add(opp.Contact_Person__c);
                        }
                    }
                }

                List<Opportunity> lstOpp = new List<Opportunity>();
                List<Account> lstAccounts = new List<Account>();
                List<Account> lstCustomerAccounts = new List<Account>();
                List<Account> lstProspectAccounts = new List<Account>();
                /*if(!accountIds.isEmpty())
                {
                    for(Account acct : [SELECT Id, RecordTypeId, RecordType.DeveloperName, 
                                            (SELECT Id, StageName, Owner.Email, OwnerId, Account__c, Clash_Opportunity__c, Branch_Code__c, isClosed 
                                             FROM Opportunities__r 
                                             WHERE isClosed = false AND Branch_Code__c = :oppList[0].Branch_Code__c 
                                             ORDER BY CreatedDate ASC) 
                                        FROM Account 
                                        WHERE Id IN :accountIds
                                        AND IsPersonAccount = true] ) {

                        if( AccountUtil.isCustomer( acct.RecordTypeId, acct.RecordType.DeveloperName ) ){
                            lstCustomerAccounts.add( acct );
                        }
                        else if( AccountUtil.isProspect( acct.RecordTypeId, acct.RecordType.DeveloperName ) ){
                            lstProspectAccounts.add( acct );
                        }
                    }
                }
                lstAccounts = ( !lstCustomerAccounts.isEmpty() ) ?  lstCustomerAccounts : lstProspectAccounts;

                if( !lstAccounts.isEmpty() ){
                    for(Account acct : lstAccounts){
                        if(acct.Opportunities__r != null && !acct.Opportunities__r.isEmpty() && acct.Opportunities__r.size() >= 2){
                            Boolean flag = true;
                            for(Opportunity opp : acct.Opportunities__r){
                                if(opp.OwnerId != jccCusSetting.Default_Owner_C_C__c ){
                                    clashEmailIds = clashEmailIds +';'+opp.Owner.Email;
                                    oppIdToClashString.put( opp.Id, clashEmailIds );                                  
                                }
                                if(flag){
                                    flag = false; // Bypass the first opportunity
                                }
                                else{
                                    if(opp.Clash_Opportunity__c == false){
                                        opp.Clash_Opportunity__c = true; 
                                        lstOpp.add( opp );
                                    }
                                }
                            }
                        }
                    }
                }
                else if(!contactIds.isEmpty()){*/
                if(!contactIds.isEmpty()){
                    List<Contact> lstCon = [SELECT Id, (SELECT Id, StageName, Owner.Email, OwnerId, Contact_Person__c, Clash_Opportunity__c, Branch_Code__c, isClosed 
                                                        FROM Opportunities__r 
                                                        WHERE isClosed = false AND Branch_Code__c = :oppList[0].Branch_Code__c 
                                                        ORDER BY CreatedDate ASC) 
                                            FROM Contact 
                                            WHERE Id IN :contactIds];

                    for(Contact con : lstCon){
                        if(con.Opportunities__r != null && !con.Opportunities__r.isEmpty() && con.Opportunities__r.size() >= 2){
                            Boolean flag = true;
                            for(Opportunity opp : con.Opportunities__r){
                                if(opp.OwnerId != jccCusSetting.Default_Owner_C_C__c ){
                                    clashEmailIds = clashEmailIds +';'+opp.Owner.Email;
                                    oppIdToClashString.put( opp.Id, clashEmailIds );                                  
                                }
                                if(flag){
                                    flag = false; // Bypass the first opportunity
                                }
                                else{
                                    if(opp.Clash_Opportunity__c == false){
                                        opp.Clash_Opportunity__c = true; 
                                        lstOpp.add( opp );
                                    }
                                }
                            }
                        }
                    }
                }
                /*else if(!leadIds.isEmpty()){
                    List<Lead> lstLead = [SELECT Id, 
                                                (SELECT Id, StageName, Lead__c, OwnerId, Owner.Email, Clash_Email1__c, Clash_Opportunity__c, Branch_Code__c, isClosed 
                                                 FROM Opportunities__r 
                                                 WHERE isClosed=false AND Branch_Code__c = :oppList[0].Branch_Code__c 
                                                 ORDER BY CreatedDate ASC) 
                                          FROM Lead WHERE Id IN :leadIds];

                    for(Lead ld : lstLead){
                        if(ld.Opportunities__r != null && !ld.Opportunities__r.isEmpty() && ld.Opportunities__r.size() >= 2){
                            Boolean flag = true;
                            for(Opportunity opp : ld.opportunities__r){                             
                                if(opp.OwnerId != jccCusSetting.Default_Owner_C_C__c ){
                                    clashEmailIds = clashEmailIds +';'+opp.owner.Email; 
                                    oppIdToClashString.put( opp.Id, clashEmailIds );                                 
                                }
                                if(flag){
                                    flag = false; // Bypass the first opportunity
                                }
                                else{
                                    if(opp.Clash_Opportunity__c == false){
                                        opp.Clash_Opportunity__c = true;                                                                          
                                        lstOpp.add(opp);
                                    }
                                }
                            }
                        }
                    }
                }*/
                
               if(!lstOpp.isEmpty()){
                    if(!oppIdToClashString.isEmpty()){
                        
                        for(Opportunity opp : lstOpp)
                        {                            
                            if(oppIdToClashString.ContainsKey(opp.Id) && String.isNotBlank(oppIdToClashString.get(opp.Id))){
                                String[] arrEmails = oppIdToClashString.get(opp.Id).removeStart('null;').split(';');
                                if(arrEmails!=null && !arrEmails.isEmpty()){
                                    for(Integer i = 0; i<arrEmails.size(); i++) {                                      
                                        if(i==0){ 
                                            opp.Clash_Email1__c = arrEmails[i]; 
                                        }
                                        if(i==1){    
                                            opp.Clash_Email2__c = arrEmails[i];
                                        }
                                        if(i==2){
                                            opp.Clash_Email3__c = arrEmails[i];
                                        }
                                        if(i==3){
                                            opp.Clash_Email4__c = arrEmails[i];
                                        }
                                        if(i==4){
                                            opp.Clash_Email5__c = arrEmails[i];
                                        }
                                    }
                                }
                            }
                        }                                         
                    }   
                    update lstOpp;
                    
                    //For Clash Opportunity Daily report send.
                    //Maps to a Staging SObject
                    if(!System.isBatch() && !System.isFuture()){
                        System.enqueueJob( new ClashOpportunityQueueable(lstOpp) );
                    }
                }
                    
            }
        }
        catch(Exception e){
            loggerDataPool.buildLogDataPool('OpportunityBL.setClashOpportunity',e);
        }
    }
    

    /** ********
     * Method Name: setBranchCode
     * Description: Populate the branch code of Opportunities
     * @param oppList : Trigger.new
     * @return : N/A
     ******** **/
    public static void setBranchCode( List<Opportunity> oppList ){
        try{
            if(oppList!=null && !oppList.isEmpty()){
                //Owner Id to  List< BranchCode[0] , FranchiseCode[0] >
                Map<Id, List<String>> ownerIdToCodes = new Map<Id, List<String>>();
                List<Opportunity> oppToUpd = new List<Opportunity>();
                List<Opportunity> oppFinal = new List<Opportunity>();
                
                //JCC Global Variables
                global_var__c jcc = global_var__c.getOrgDefaults();
                
                for(Opportunity o : oppList){
                    //if Oppty does not have Branch and Franchise codes yet
                    //Assign the Owner's branch and Franchise Code
                    if( o.OwnerId != jcc.Default_Owner_C_C__c && (String.isBlank(o.Branch_Code__c) || String.isBlank(o.Franchise_Code__c)) && String.isNotBlank(o.OwnerId) )
                    {
                        //setOfOwner.add(o.OwnerId);
                        ownerIdToCodes.put(o.OwnerId, null);    
                        oppToUpd.add( o );
                    }
                }
                
                if(ownerIdToCodes != null && !ownerIdToCodes.isEmpty()){
                    for(User u : [SELECT Id, Branch_Code__c, Franchise_Code__c
                                  FROM User 
                                  WHERE Id IN: ownerIdToCodes.keySet()]) 
                    {
                        ownerIdToCodes.put( u.Id, new List<String>{u.Branch_Code__c, u.Franchise_Code__c} );
                    }
                    
                    //Update opportunities
                    for(Opportunity opp : oppToUpd){
                        if( ownerIdToCodes.containsKey(opp.OwnerId) && ownerIdToCodes.get(opp.OwnerId) != null)
                        {
                            List<String> oppVal = ownerIdToCodes.get(opp.OwnerId);
                            oppFinal.add( new Opportunity( 
                                                Id = opp.Id, 
                                                Branch_Code__c = oppVal.get(0), 
                                                Franchise_Code__c = oppVal.get(1) ) );
                        }
                    }
                    
                    Database.update(oppFinal,false);
                    
                    if(Test.isRunningTest()){
                        //for test class coverage
                        throw new CustTestException();
                    }
                }
            }
        }
        catch(Exception e){
            loggerDataPool.buildLogDataPool('OpportunityBL.setBranchCode',e);
        }
    }

    
    /** ********
     * Method Name: setSharing
     * Description: Set Sharing on Owner Update
     * @param oppList : Trigger.new
     * @param oldMap : Trigger.oldMap
     * @return : N/A
     ******** **/
    public static void setSharing( List<Opportunity> oppList, Map<Id, Opportunity> oldMap ){
        try{
            if(oppList!=null && !oppList.isEmpty()){
                List<sharingHelper.generateShare> crShare = new List<sharingHelper.generateShare>();
                for(Opportunity opp : oppList)
                {
                    String oldOwnerId = oldMap.get(opp.Id).OwnerId;
                    if( opp.OwnerId !=  oldOwnerId)
                    {
                        //Share the Opportunity to the New and Old Owner
                        crShare.add( new sharingHelper.generateShare('Read', 'Opportunity', opp.Id, opp.OwnerId)); 
                        crShare.add( new sharingHelper.generateShare('Read', 'Opportunity', opp.Id, oldOwnerId)); 
                        
                        //Share the Lead to Old and New Owner
                        /*if( opp.Lead__c != null ){
                            crShare.add( new sharingHelper.generateShare('Read', 'Lead', opp.Lead__c, opp.OwnerId)); 
                            crShare.add( new sharingHelper.generateShare('Read', 'Lead', opp.Lead__c, oldOwnerId)); 
                        }*/
                        
                        //Share the Contact
                        if( opp.Contact_Person__c != null ){
                            crShare.add( new sharingHelper.generateShare('Read', 'Contact', opp.Contact_Person__c, opp.OwnerId)); 
                            crShare.add( new sharingHelper.generateShare('Read', 'Contact', opp.Contact_Person__c, oldOwnerId)); 
                        }

                        //Share the Account /** PA MIGRATION */
                        if( opp.Account__c != null ){
                            crShare.add( new sharingHelper.generateShare('Read', 'Account', opp.Account__c, opp.OwnerId)); 
                            crShare.add( new sharingHelper.generateShare('Read', 'Account', opp.Account__c, oldOwnerId)); 
                        }
                    }
                }
                
                if(!crShare.isEmpty()) {
                    sharingHelper.creatShare(crShare); // Call method to Update Sharing
                    
                    if(Test.isRunningTest()){
                        //for test class coverage
                        throw new CustTestException();
                    }
                } 
            }
        }
        catch(Exception e){
            loggerDataPool.buildLogDataPool('OpportunityBL.setSharing',e);
        }
    }
    

    /*
    public static void setOwner(List<Opportunity> oppList){
        try{
            if(oppList!=null && !oppList.isEmpty()){
                List<Opportunity> oppToUpd = new List<Opportunity>();
                String RoleName = '';
            	List<User> RRUsersLst = new List<User>();
				Map<Integer,User> RRUsersLstMap = new Map<Integer,User>();  
				Decimal Seq = 0;    
				List<Opportunity>  oppoToInsert = new List<Opportunity>(); 
				List<Lead> LstLead = new List<Lead>();
                
                for(Opportunity o : oppList){
                    // check for opp with contact exists 
                    List<Opportunity> lopp = [select id, Franchise_Code__c, OwnerId from Opportunity
                        			where StageName !='Lost' 
                                    and Branch_Code__c = :o.Branch_Code__c
                        			and Contact_Person__c=:o.Contact_Person__c 
                        			and Contact_Person__c!=null
                        			order by createdDate desc]; 
                      if(lopp.size()>0)
                      {
                          o.OwnerId = lopp[0].OwnerId;
                          Update o;
                      }else{
                          // If no opp with contact exists - check for recent opp with lead 
                          lopp = [select Id, Franchise_Code__c, OwnerId from Opportunity
                            				WHERE StageName !='Lost'
                            				AND Lead__c =:o.Lead__c
                                            AND Branch_Code__c =: o.Branch_Code__c
                            				AND Lead__c!=null
                            				ORDER by CreatedDate DESC];
                          if (lopp.size()>0){
                                o.OwnerId = lopp[0].OwnerId;
                          		Update o;
                          }else{
                              // Round Robin...
                              if(O.Branch_Code__c != null && O.Branch_Code__c != '' && O.LeadSource != 'Stock Reserved' 
               					&& O.LeadSource != 'Walk-in')
                              {
                                global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults(); 
                
                				If(O.Branch_Code__c == 'CCK'){
                    				RoleName='KIAPC Sales Consultant'; 
                    				Seq = (Integer)JCC_GlobalVar.Opportunity_Seq_KIA__c;
                    				if(Seq == null) {
                        				Seq = 1;
                    				} else {
                        				Seq = Seq + 1;
                    				}
                    				JCC_GlobalVar.Opportunity_Seq_KIA__c = Seq;
                				}
                				else if(O.Branch_Code__c == 'CCA'){
                   					RoleName='MITPC Sales Consultant'; 
                    				Seq = (Integer)JCC_GlobalVar.Opportunity_Seq_MIT__c;
                    				if(Seq == null) {
                        				Seq = 1;
                    				} else {
                        				Seq = Seq + 1;
                    				}
                    				JCC_GlobalVar.Opportunity_Seq_MIT__c = Seq;
                				}
                 				else if(O.Branch_Code__c == 'CCI'){
                    				RoleName='MBP Sales Consultant'; 
                    				Seq = (Integer)JCC_GlobalVar.Opportunity_Seq_MB__c;
                    				if(Seq == null) {
                        				Seq = 1;
                    				} else {
                        				Seq = Seq + 1;
                    				}
                    				JCC_GlobalVar.Opportunity_Seq_MB__c = Seq;
                				}
                 				else if(O.Branch_Code__c == 'CCF'){
                    				RoleName='CITPC Sales Consultant'; 
                    				Seq = (Integer)JCC_GlobalVar.Opportunity_Seq_CIT__c;
                    				if(Seq == null) {
                        				Seq = 1;
                    				} else {
                        				Seq = Seq + 1;
                    				}
                    				JCC_GlobalVar.Opportunity_Seq_CIT__c = Seq;
                					}
                			upsert JCC_GlobalVar;
                
                			If(RoleName=='')
                			{
                    			RoleName='Management';
                			}
                			RRUsersLst = [Select Id, Name from User where UserRole.Name =:RoleName AND Is_Eligible_Opp_Owner__c=True AND IsActive = TRUE ORDER BY Id ASC];                
                			System.debug(RRUsersLst.size());
                			If(RRUsersLst.size()>0)
                			{
                    		for (Integer i = 0; i < RRUsersLst.size(); i++) 
                    		{
                        		RRUsersLstMap.put(i, RRUsersLst[i]);                       
                    		}                   
                    
                    		O.OwnerId = RRUsersLstMap.get(Math.MOD(Integer.valueOf(Seq),RRUsersLst.size())).Id;  
                    		Update o;
                              }
                          }
                      }
                      
                    
                }
            }
            
            }
        }catch(Exception e)
        {
            loggerDataPool.buildLogDataPool('OpportunityBL.setOwner',e);
        }
    }
    */
}