/****************************************************
* Class Name: BatchDeleteLeadShareRecord 
* Description: Deletes share record for converted leads
*
* Developer Name    Date      Description
* Savita          19-July-2019    Created.
****************************************************/ 

global class InsertContactShareRecord implements Database.Batchable<sObject>
{
    public String queryString = '';
    
      
    public InsertContactShareRecord(){        
        queryString = 'select Id,name,createddate from contact where Id not In (SELECT contact__c FROM share__c where object__c = \'Contact\')';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return database.getQueryLocator(queryString);
    }
    
    global void Execute(Database.BatchableContext bc, list<Contact> Contactlist){
        list<sharingHelper.generateShare> lstToCreateShare = new list<sharingHelper.generateShare>();    
        Group CCKGroupId = [select id,name from Group where name = 'KIAPC Sales Manager'];
        Group CCFGroupId = [select id,name from Group where name = 'CITPC Sales Managers'];
        Group CCAGroupId = [select id,name from Group where name = 'MITPC Sales Managers'];
         /** PA Migration : Newly Added */
        for(Registered_Vehicle__c rv: [select id,contact__c,branch__c, Account__c from Registered_Vehicle__c where contact__c in : Contactlist and branch__c !=null AND contact__c!=NULL])
        {
            if(rv.branch__c == 'CCK' && CCKGroupId.ID!=null){
                  lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Contact', rv.contact__c, CCKGroupId.id));   
            }
            if(rv.branch__c == 'CCF' && CCFGroupId.ID!=null){
                  lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Contact', rv.contact__c, CCFGroupId.id));   
            }
            if(rv.branch__c == 'CCA' && CCAGroupId.ID!=null){
                  lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Contact', rv.contact__c, CCAGroupId.id));   
                
            }
        } 
         if(!lstToCreateShare.isEmpty()){
              System.debug('@@@@@  lstToCreateShare'+lstToCreateShare);
              sharingHelper.creatShare(lstToCreateShare);
         } 
    
    }
    
    global void finish(Database.BatchableContext bc){
    }
       
}