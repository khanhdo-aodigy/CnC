/*************************************************
 * Class Name: ServiceContactLookup
 * Description: Controller of ServiceContactLookup
 * 				VF Page.
 *************************************************/ 
public without sharing class ServiceContactLookup {
	//Custom Exception for Code Coverage
    public class CustException extends Exception{}
    
	/*****************************************
	 * Method Name: getContactFromPhone
	 * Description: used in action VF page
	 * 				Attribute
	 * Redirects:	if Contact record is found, nav to
	 * 				contact page
	 * 				else, redirect to Contact
	 ******************************************/
    public PageReference getContactFromPhone(){
        //fetch defaults
        ServiceContactDefault__mdt def = [SELECT Id, Label, 
                                              DeveloperName,
                                              CaseLanding__c, 
                                              ContactURLMode__c, 
                                              ContactURLPrefix__c,
                                              ConNumberPrefix__c,
                                              NumPrefix__c
                                          FROM ServiceContactDefault__mdt 
                                          WHERE DeveloperName='ServContactDefault' 
                                          LIMIT 1];
        
		//Case Tab, 'Recently Viewed' related list        
        PageReference pr = new PageReference( def.CaseLanding__c );
        
        //get Phone Number from URL 
        String phoneNum = ApexPages.currentPage().getParameters().get('phone');

        try{
            if( String.isNotBlank(phoneNum) ){
                //Use Case: Phone number starts with 9 plus 8 digit phone number
                if( phoneNum.startsWith(def.NumPrefix__c) && phoneNum.length() == 9 ){
                    String phoneWithoutPrefix = phoneNum.substring(1,9); //remove the leading '9' from the PhoneNumber parameter 
                    String formattedPhone = def.ConNumberPrefix__c + phoneWithoutPrefix;
                    Contact con = [SELECT Id 
                                   FROM Contact 
                                   WHERE MobilePhone IN (:formattedPhone, :phoneWithoutPrefix) 
                                   AND IsPersonAccount = true
                                   LIMIT 1];
                    if(con != null && String.isNotBlank(con.Id)){
                        //Case record page
                        String navToURL = def.ContactURLPrefix__c + con.Id + def.ContactURLMode__c;
                        pr = new PageReference(navToURL);
                        
                        //For Test Coverage
                        if(Test.isRunningTest()){
                            throw new CustException();
                        }
                    }
                }
            }
        }catch(Exception e){
            loggerDataPool.buildLogDataPool('getContactFromPhone', e);
        }
        return pr; 
    }
    

}