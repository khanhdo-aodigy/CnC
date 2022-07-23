public class MultiPickListController {

    @AuraEnabled
    public static List <String> getPiklistValues(String casefieldname, String recordtype) {
        List<String> plValues = new List<String>();
        
        //Get the object type from object name. Here I've used custom object Book.
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Case');
                                                                    
        //Describe the sObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
         
        //Get the specific field information from field name. Here I've used custom field Genre__c of Book object.
        Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get(casefieldname).getDescribe();
        
        //Get the picklist field values.
        List<Schema.PicklistEntry> picklistvalues = objFieldInfo.getPicklistValues();
         
        //Add the picklist values to list.
        for(Schema.PicklistEntry plv: picklistvalues) {
            if ((recordtype == 'Enquiry and Request') && (casefieldname=='Case_Type__c'))
            {
                if ((plv.getValue()=='Sales Product') || (plv.getValue()=='Aftersales Product') ||
                   (plv.getValue()=='Digital Related') || (plv.getValue()=='Others') ||
                    (plv.getValue()=='Boutique') || (plv.getValue()=='Parts & Accessories')
                   )
                    {
                        plValues.add(plv.getValue());
                    }
             
            }
            else
            {
                plValues.add(plv.getValue());
            }
            
            
        }
        plValues.sort();
        return plValues;
    }
}