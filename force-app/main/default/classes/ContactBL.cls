/*******************************************
 * Class Name: ContactBL
 * Description: Business Logic class for Contact object.
 *******************************************/ 
public without sharing class ContactBL {
    public static void contactChange(List<Contact> conList, Map<Id,Contact> oldMap){
        system.debug('@@@: contactTrigger');
        List<Account> pAccList = new List<Account>();
        Map<String, String> contactAccountMap = new Map<String,String>();
        Map<String, Contact> contactMap = new Map<String, Contact>();
        
        AccountSelector accSelector = new AccountSelector();
        List<String> accFields = accSelector.getEditableAccountFields();
        
        ContactSelector conSelector = new ContactSelector();
        List<String> conFields = conSelector.getEditableContactFields();
        
        try{ 
            for(Contact con : conList){
                System.debug('@@@@DEBUG contactChange :: con = '+ con );
                if(con.Account__c != null){
                    contactAccountMap.put(con.Id, con.Account__c);
                    contactMap.put(con.Id, con);
                }
            }
      
            for(String contactId : contactAccountMap.keySet()){
                Contact con = contactMap.get(contactId);
                Account acc = new Account();
                acc.Id = contactAccountMap.get(contactId);
              
                for(String field : accFields)
                {
                    String contactField;
                    if(field == 'Account__pc' || field == 'Identifier__c' || field == 'Identifier__pc' ){
                        continue;
                    }
                    if(field.endsWith('__pc')){
                        contactField = field.replace('__pc', '__c');
                    }
                    else if(field.startsWith('Person') ){
                        contactField = field.remove('Person');
                    }
                    else{
                        contactField = field;
                    }
                    
                    if(conFields.contains(contactField) && con.get(contactField) != oldMap.get(con.Id).get(contactField)){
                        acc.put(field, con.get(contactField));
                    }
                }
                pAccList.add(acc);
            }
            System.debug('@@@@DEBUG contactChange :: pAccList = '+ pAccList.size() + ' --- ' + pAccList );
            if( !pAccList.isEmpty() ){
                TriggerExclusion.excludeTrigger('Account', true);
                update pAccList;
                TriggerExclusion.excludeTrigger('Account', false);
            }
        }
        catch(Exception e){
            loggerDataPool.buildLogDataPool('ContactBL', e);
        }
       
    }
}