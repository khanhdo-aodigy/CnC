public with sharing class UpdatePDPA {
    public static void updatePDPA(Contact contact, Boolean isSMS) {
        contact.SMS__c = isSMS;
    }
 
    public static void updatePDPA(Contact contact, Boolean isSMS, Boolean isCall, Boolean isEmail) {
        contact.SMS__c = isSMS;
        contact.Call__c = isCall;
        contact.Email__c = isEmail;
    }
 
    public static void updatePDPA(Contact contact, Boolean isSMS, Boolean isCall, Boolean isEmail, Boolean isFax) {
        contact.SMS__c = isSMS;
        contact.Call__c = isCall;
        contact.Email__c = isEmail;
        contact.Fax__c = isFax;
    }

    public static void updateConsentPDPA(Account personAcc, Boolean consent) {
        personAcc.PDPA__pc  = consent ? 'SMS;Call;Email' : '';
        personAcc.SMS__pc   = consent;
        personAcc.Call__pc  = consent;
        personAcc.Email__pc = consent;
        personAcc.Fax__pc   = consent;
    }
 
    public static void updatePDPA(Account personAcc, Boolean isSMS, Boolean isCall, Boolean isEmail) {
        personAcc.SMS__pc = isSMS;
        personAcc.Call__pc = isCall;
        personAcc.Email__pc = isEmail;
    }
 
    public static void updatePDPA(Account personAcc, Boolean isSMS, Boolean isCall, Boolean isEmail, Boolean isFax) {
        personAcc.SMS__pc = isSMS;
        personAcc.Call__pc = isCall;
        personAcc.Email__pc = isEmail;
        personAcc.Fax__pc = isFax;
    }
 
    public static void updatePDPA(Contact contact, String stringPDPA) {
        Map <String, Schema.SObjectField> fieldMap = contact.getSobjectType().getDescribe().fields.getMap();
        if(String.isNotBlank(stringPDPA)) {
            List<String> values = stringPDPA.split(';');
            for(String item: values) {
                String fieldName = item.trim() + '__c';
                System.debug(fieldName);
                
                if(fieldMap.containsKey(fieldName)){
                    contact.put(fieldName, true);
                }
            }
        }
    }
}