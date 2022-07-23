public with sharing class SDP_DefectFormController 
{
    @AuraEnabled
    public static Sales_Agreement__c initializeSalesAgreement(Id recordId)
    {
        Sales_Agreement__c returnSalesAgreement = new Sales_Agreement__c();
        SalesAgreementSelector salesAgreementSel = new SalesAgreementSelector();
        String objectName = recordId.getSobjectType().getDescribe().getName();
        
        if(objectName == 'Sales_Agreement__c')
        {
            returnSalesAgreement = (Sales_Agreement__c)(salesAgreementSel.selectSObjectsById(new Set<Id>{ recordId }))[0];
        }
        return returnSalesAgreement;
    }

    @AuraEnabled(cacheable=true)
    public static List<sObject> getRelatedRecords(String fieldReferenceValue, String objectName, String fieldName, Integer triggerSearch) 
    {
        List<sObject> listofRecords = new List<sObject>();
        String mainQueryCondition = ' ' + fieldName + '=\'' + fieldReferenceValue + '\' ORDER BY Name' ;
        system.debug(mainQueryCondition);
        listofRecords = ADGLIB_UtilityHelper.getSObjectRecords(objectName, mainQueryCondition, false);
        return listofRecords;
    }

    /**
     * Added by Phap to cater for Defect Header CR
     */
    @AuraEnabled
    public static Defect__c createDefect(String salesAgreementID)
    {
        Sales_Agreement__c salesAgreement = [SELECT ID, Opportunity__r.Contact_Person__c, Opportunity__r.Account__c, 
                                            PreferredServiceCenter__c, Defect_Header_URL__c 
                                            FROM Sales_Agreement__c 
                                            WHERE ID = :salesAgreementID];
                                            
        Defect_Header__c cDefectHeader = getDefectHeader(salesAgreementID);         // current defect header
        String dHeaderID = cDefectHeader != null? cDefectHeader.ID : null;

        // create new defect header if non-exsited
        if (cDefectHeader == null) 
        {
            Defect_Header__c dHeader = createDefectHeader(salesAgreement);
            dHeaderID = dHeader.ID;
        }

        // populate defect header URL in sales agreement
        if (cDefectHeader == null)
        {
            salesAgreement.Defect_Header_URL__c = URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Defect_Header__c/' + dHeaderID + '/view';
            update salesAgreement;
        }
        
        Defect__c defect = new Defect__c();
        defect.Sales_Agreement__c = salesAgreementID;
        defect.Defect_Header__c = dHeaderID;
        insert defect;
        return defect;
    }

    /**
     * Added by Phap to cater for Defect Header CR
     */
    @AuraEnabled
    public static Outstanding_Accessory__c createOA(String salesAgreementID)
    {
        Sales_Agreement__c salesAgreement = [SELECT ID, Opportunity__r.Contact_Person__c, Opportunity__r.Account__c, 
                                            PreferredServiceCenter__c, Defect_Header_URL__c 
                                            FROM Sales_Agreement__c 
                                            WHERE ID = :salesAgreementID];
                                            
        Defect_Header__c cDefectHeader = getDefectHeader(salesAgreementID);         // current defect header
        String dHeaderID = cDefectHeader != null? cDefectHeader.ID : null;

        // create new defect header if non-exsited
        if (cDefectHeader == null) 
        {
            Defect_Header__c dHeader = createDefectHeader(salesAgreement);
            dHeaderID = dHeader.ID;
        }

        // populate defect header URL in sales agreement
        if (cDefectHeader == null)
        {
            salesAgreement.Defect_Header_URL__c = URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Defect_Header__c/' + dHeaderID + '/view';
            update salesAgreement;
        }

        Outstanding_Accessory__c oa = new Outstanding_Accessory__c();
        oa.Sales_Agreement__c = salesAgreementID;
        oa.Defect_Header__c = dHeaderID;
        insert oa;
        return oa;
    }

    /**
     * Added by Phap to cater for Defect Header CR
     * Update the service center in sales agreement and related defect header
     * Assume that only 1 defect header per sales agreement therefore no need to provide defect header ID
     */
    @AuraEnabled
    public static void updateServiceCenter(String salesAgreementID, String sCenter)
    {
        System.debug('salesAgreementID :: ' + salesAgreementID);
        System.debug('sCenter :: ' + sCenter);

        if (salesAgreementID == null || sCenter == null) throw new AuraHandledException('updateServiceCenter method parameter(s) can not be null');
        
        Sales_Agreement__c salesAgreement = [SELECT PreferredServiceCenter__c FROM Sales_Agreement__c WHERE ID = :salesAgreementID];
        
        List<Defect_Header__c> dHeaders = [SELECT Service_Center__c FROM Defect_Header__c WHERE Sales_Agreement__c = :salesAgreementID];
        
        salesAgreement.PreferredServiceCenter__c = sCenter;
        
        for (Defect_Header__c dHeader : dHeaders) 
        {
            dHeader.Service_Center__c = sCenter;
        } 
        
        update salesAgreement;
        update dHeaders;
    }

    /**
     * Added by Phap to cater for Defect Header CR
     */
    private static Defect_Header__c getDefectHeader(String salesAgreementID)
    {
        List<Defect_Header__c> headers = [SELECT ID FROM Defect_Header__c WHERE Sales_Agreement__c = :salesAgreementID];
        if (headers.size() > 1) throw new AuraHandledException('There are more than one defect header linked to this sales agreement');
        Defect_Header__c result = headers.size() == 0? null : headers[0];
        return result;
    }

    /**
     * Added by Phap to cater for Defect Header CR
     */
    private static Defect_Header__c createDefectHeader(Sales_Agreement__c salesAgreement)
    {
        Defect_Header__c dHeader = new Defect_Header__c();
        dHeader.Sales_Agreement__c = salesAgreement.ID;
        dHeader.Status__c = 'New';
        dHeader.Account__c = salesAgreement.Opportunity__r.Account__c;
        dHeader.Contact__c = salesAgreement.Opportunity__r.Contact_Person__c;
        dHeader.Service_Center__c = salesAgreement.PreferredServiceCenter__c;
        insert dHeader;
        return dHeader;
    }    
}