/** *******
 * Class Name: ShareLeadContact
 * Description: Opportunity Detail page button 			   
 *              controller for sharing Contact and Lead view access.
 * 			
 * Note: without sharing is used so that this class will run on System mode.
 * 
 * Revision History:
 * Date(DD-MMM-YYYY)        Developer Name		            Description
 * 19-Mar-2019              Christian Gaylan		    	Created.
 * 09-Sep-2020              HS@aodigy.com                   Added manual sharing for Account (p/s: Please take note for Associated record owner or sharing)
 * 
 ******* **/ 
public without sharing class ShareLeadContact {
    
    //public String conId {get; set;}         //Contact related to the Opportunity
    //public String leadId {get; set;}        //Lead related to the Opportunity
    public String personAccId {get; set;}   //PA MIGRATION: added the Person Account related to Opportunity
    public Opportunity oppty { get; set; }
    
    public ShareLeadContact(ApexPages.StandardController ctrl) 
    {
        oppty = (Opportunity) ctrl.getRecord();
        if( oppty != null ){
            Opportunity opCopy = [SELECT Contact_Person__c, Lead__c, Account__c
                                  FROM Opportunity 
                                  WHERE Id=: oppty.Id 
                                  LIMIT 1];

            //conId       = opCopy.Contact_Person__c;
            //leadId      = opCopy.Lead__c;
            personAccId = opCopy.Account__c;
        }
    }
    

    public void shareDetails()
    {
        List<sharingHelper.generateShare> lstShares = new List<sharingHelper.generateShare>();
        
        //these Sets are used to avoid duplication
        //Set<Id> conOwnerId = new Set<Id>();
        //Set<Id> leadOwnerId = new Set<Id>();
        Set<Id> personAccIds = new Set<Id>(); 
        
        /** PA MIGRATION : To Remove Part-1 Start 
        if( String.isNotBlank(conId) ){
            //get all Opportunity Owners under the same contact.
            for(Opportunity opp : [SELECT Id, OwnerId, Contact_Person__c 
                                   FROM Opportunity 
                                   WHERE Contact_Person__c=: conId] )
            {
                //prevent duplication
                if( !conOwnerId.contains(opp.OwnerId) ){
                    conOwnerId.add( opp.OwnerId );
                    lstShares.add(
                        new sharingHelper.generateShare('Read', 
                                                        'Contact', 
                                                        opp.Contact_Person__c, 
                                                        opp.OwnerId)
                    ); 
                }
            }
        }

        if( String.isNotBlank(leadId) ){
            //get all Opportunity Owners under the same contact.
            for(Opportunity opp : [SELECT Id, OwnerId, Lead__c 
                                   FROM Opportunity 
                                   WHERE Lead__c=: leadId] )
            {
                //prevent duplication
                if( !leadOwnerId.contains(opp.OwnerId) ){
                    leadOwnerId.add( opp.OwnerId );
                    lstShares.add(
                        new sharingHelper.generateShare('Read', 
                                                        'Lead', 
                                                        opp.Lead__c, 
                                                        opp.OwnerId)
                    ); 
                }
            }
        }
        PA MIGRATION : To Remove Part-2 End */

        if( String.isNotBlank(personAccId) ){
            //get all Opportunity Owners under the same Account (i.e. Person Account/Business Account)
            for(Opportunity opp : [SELECT Id, OwnerId, Account__c , Contact_Person__c
                                   FROM Opportunity 
                                   WHERE Account__c =: personAccId] )
            {
                if( !personAccIds.contains(opp.OwnerId) ){
                    personAccIds.add( opp.OwnerId );
                    lstShares.add( 
                        new sharingHelper.generateShare('Read', 'Contact', opp.Contact_Person__c, opp.OwnerId)
                    ); 
                }
            }
        }
        
        if( !lstShares.isEmpty() ) {
            sharingHelper.creatShare(lstShares); // Call method to Update Sharing
        } 
    }

}