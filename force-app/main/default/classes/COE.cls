public inherited sharing class COE extends ADGLIB_SObjectDomain {
    
    public COE(List<COE__c> sObjectList) {
        super(sObjectList);
    }
    
    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new COE(sObjectList);
		}
	}    

    // public override void onBeforeInsert() {
    //     List<String> saIds   = new List<String>();
    //     List<String> mbSAIds = new List<String>();
    //     for (COE__c coe : (List<COE__c>)Records)
    //     {
    //         if (!String.isEmpty(coe.Sales_Agreement__c))
    //         {
    //             saIds.add(coe.Sales_Agreement__c);
    //             coe.Sales_Agreement_Unique_Id__c = coe.Sales_Agreement__c;
    //         }
    //         else if (!String.isEmpty(coe.MB_Sales_Agreement__c))
    //         {
    //             mbSAIds.add(coe.MB_Sales_Agreement__c);
    //             coe.MB_Sales_Agreement_Unique_Id__c = coe.MB_Sales_Agreement__c;
    //         }
    //     }

	// 	Map<String, COE__c> coeBySAId = new Map<String, COE__c>();
    //     for (COE__c coe : ([SELECT Id, Name, MB_Sales_Agreement__c, Sales_Agreement__c
    //                         FROM COE__c
    //                         WHERE Sales_Agreement__c IN :saIds
    //                         OR MB_Sales_Agreement__c IN :mbSAIds]))
    //     {
    //         if (!String.isEmpty(coe.Sales_Agreement__c))
    //         {
    //             coeBySAId.put(coe.Sales_Agreement__c, coe);
    //         }
    //         else if (!String.isEmpty(coe.MB_Sales_Agreement__c))
    //         {
    //             coeBySAId.put(coe.MB_Sales_Agreement__c, coe);
    //         }
    //     }

    //     if (!coeBySAId.isEmpty())
    //     {
    //         for (COE__c coe : (List<COE__c>)Records)
    //         {
    //             if (!String.isEmpty(coe.Sales_Agreement__c) && coeBySAId.containsKey(coe.Sales_Agreement__c))
    //             {
    //                 coe.addError('There\'s another COE (' + coeBySAId.get(coe.Sales_Agreement__c).Name + ') has been linked to this Sales Agreement. Please check again!');
    //             }
    //             else if (!String.isEmpty(coe.MB_Sales_Agreement__c) && coeBySAId.containsKey(coe.MB_Sales_Agreement__c))
    //             {
    //                 coe.addError('There\'s another COE (' + coeBySAId.get(coe.MB_Sales_Agreement__c).Name + ') has been linked to this Sales Agreement. Please check again!');
    //             }
    //         }
    //     }
    // }

    public override void onAfterInsert() {
        List<String> saIds   = new List<String>();
        List<String> mbSAIds = new List<String>();
        Map<Id, Id> mapSAIdAndPeriodId = new Map<Id, Id>();
        Map<Id, Id> mapMBSAIdAndPeriodId = new Map<Id, Id>();
        Set<Id> coeBidPeriodIds = new Set<Id>();

        for (COE__c coe : (List<COE__c>)Records)
        {
            if (!String.isEmpty(coe.Sales_Agreement__c))
            {
                saIds.add(coe.Sales_Agreement__c);
            }
            else if (!String.isEmpty(coe.MB_Sales_Agreement__c))
            {
                mbSAIds.add(coe.MB_Sales_Agreement__c);
            }

            if(String.isNotBlank(coe.COE_Bid_Period__c)) {
                coeBidPeriodIds.add(coe.COE_Bid_Period__c);

                if(String.isNotBlank(coe.Sales_Agreement__c)) {
                    mapSAIdAndPeriodId.put(coe.Sales_Agreement__c, coe.COE_Bid_Period__c);
                }

                if(String.isNotBlank(coe.MB_Sales_Agreement__c)) {
                    mapMBSAIdAndPeriodId.put(coe.MB_Sales_Agreement__c, coe.COE_Bid_Period__c);
                }
            }
        }

        updateRelatedSA((List<COE__c>)Records, saIds, mbSAIds);

        Set<Id> successBidIds = new Set<Id>();
        if(mapSAIdAndPeriodId.size() > 0 || mapMBSAIdAndPeriodId.size() > 0) {
            successBidIds = updateSuccessSACOEPeriod(mapSAIdAndPeriodId, mapMBSAIdAndPeriodId);
        }

        if(coeBidPeriodIds.size() > 0 && successBidIds.size() > 0) {
            updateFailSACOEPeriod(coeBidPeriodIds, successBidIds);
        }
    }

    private void updateFailSACOEPeriod(Set<Id> coeBidPeriodIds, Set<Id> successBidIds) {
        List<SA_COE_Bid_Period__c> saCOEBidPeriods = [  SELECT Id, Status__c, COE_Bid_Period__c, Sales_Agreement__c, MB_Sales_Agreement__c
                                                        FROM SA_COE_Bid_Period__c
                                                        WHERE COE_Bid_Period__c IN :coeBidPeriodIds
                                                        AND Id NOT IN :successBidIds
                                                    ];

        if(saCOEBidPeriods.size() > 0) {
            for(SA_COE_Bid_Period__c record : saCOEBidPeriods) {
                record.Status__c = 'Fail';
            }
            Database.update(saCOEBidPeriods);
        }

    }

    /**
     * For the SA/MB SA which has COE created (meaning bid successfully), update the corresponding SA_COE_Bid_Period__c's status to 'Success'
     */
    private Set<Id> updateSuccessSACOEPeriod(Map<Id, Id> mapSAIdAndPeriodId, Map<Id, Id> mapMBSAIdAndPeriodId){
        List<SA_COE_Bid_Period__c> saCOEBidPeriods = [  SELECT Id, Status__c, COE_Bid_Period__c, Sales_Agreement__c, MB_Sales_Agreement__c
                                                        FROM SA_COE_Bid_Period__c
                                                        WHERE   (   Sales_Agreement__c IN :mapSAIdAndPeriodId.keySet()
                                                                    AND COE_Bid_Period__c IN :mapSAIdAndPeriodId.values()
                                                                )
                                                                OR
                                                                ( 
                                                                    MB_Sales_Agreement__c IN :mapMBSAIdAndPeriodId.keySet()
                                                                    AND COE_Bid_Period__c IN :mapMBSAIdAndPeriodId.values()
                                                                )
                                                    ];
        System.debug('saCOEBidPeriods = ' + saCOEBidPeriods);
        List<SA_COE_Bid_Period__c> recordsToUpdate = new List<SA_COE_Bid_Period__c>();
        Set<Id> successBidIds = new Set<Id>();
        if(saCOEBidPeriods.size() > 0) {
            for(SA_COE_Bid_Period__c record: saCOEBidPeriods) {
                if(record.COE_Bid_Period__c == mapSAIdAndPeriodId.get(record.Sales_Agreement__c)
                    || record.COE_Bid_Period__c == mapMBSAIdAndPeriodId.get(record.MB_Sales_Agreement__c)
                ) {
                    record.Status__c = 'Success';
                    recordsToUpdate.add(record);
                    successBidIds.add(record.Id);
                }
            }

            if(recordsToUpdate.size() > 0) {
                Database.update(recordsToUpdate);
            }
        }
        return successBidIds;
    }


    private void updateRelatedSA(List<COE__c> coeList, List<String> saIds, List<String> mbSAIds) {
        Map<Id, Sales_Agreement__c> saById;
        Map<Id, MB_Sales_Agreement__c> mbSAById;
        if (!saIds.isEmpty())
        {
            saById =  new Map<Id, Sales_Agreement__c>([SELECT Id, COE__c, SOH_SONO__c, COE_Expiry_Date__c
                                                       FROM Sales_Agreement__c
                                                       WHERE Id IN :saIds]);
        }


        if (!mbSAIds.isEmpty())
        {
            mbSAById =  new Map<Id, MB_Sales_Agreement__c>([SELECT Id, COE__c, COE_Expiry_Date__c
                                                            FROM MB_Sales_Agreement__c
                                                            WHERE Id IN :mbSAIds]);
        }

        for (COE__c coe : coeList)
        {
            if (!String.isEmpty(coe.Sales_Agreement__c))
            {
                Sales_Agreement__c sa = saById.get(coe.Sales_Agreement__c);
                sa.COE__c             = coe.Id;
                sa.COE_Expiry_Date__c = coe.COH_EXPMONTH__c;
                sa.COE_Deposit__c     = coe.COH_DEPOSIT__c;
                sa.Verified_by_Sales_Consultant__c = false;
                sa.Submit_COE_Bidding__c = false;
            }
            else if (!String.isEmpty(coe.MB_Sales_Agreement__c))
            {
                MB_Sales_Agreement__c mbSA = mbSAById.get(coe.MB_Sales_Agreement__c);
                mbSA.COE__c                = coe.Id;
                mbSA.COE_Expiry_Date__c    = coe.COH_EXPMONTH__c;
                mbSA.COE_Deposit__c        = coe.COH_DEPOSIT__c;
                mbSA.COE_Number__c         = coe.COH_COENO__c;
            }
        }

        if (saById != null && !saById.isEmpty())
        {
            Database.update(saById.values(), false);
        }

        if (mbSAById != null && !mbSAById.isEmpty())
        {
            Database.update(mbSAById.values(), false);
        }
    }

    // public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
    //     List<String> coeIdsForSA   = new List<String>();
    //     List<String> coeIdsForMBSA = new List<String>(); 
    //     for (COE__c record : (List<COE__c>)Records)
    //     {
    //         COE__c oldRecord = (COE__c)existingRecords.get(record.Id);
    //         if (record.Sales_Agreement__c != oldRecord.Sales_Agreement__c && !String.isEmpty(record.Sales_Agreement__c))
    //         {
    //             coeIdsForSA.add(record.Id);
    //         }
    //         if (record.MB_Sales_Agreement__c != oldRecord.MB_Sales_Agreement__c && !String.isEmpty(record.MB_Sales_Agreement__c))
    //         {
    //             coeIdsForMBSA.add(record.Id);
    //         }
    //     }

    //     Map<String, Sales_Agreement__c> saByCOEId      = new Map<String, Sales_Agreement__c>();
    //     Map<String, MB_Sales_Agreement__c> mbSAByCOEId = new Map<String, MB_Sales_Agreement__c>();

    //     for (Sales_Agreement__c sa : [SELECT Id, COE__c, SOH_SONO__c
    //                                   FROM Sales_Agreement__c
    //                                   WHERE COE__c IN :coeIdsForSA])
    //     {
    //         saByCOEId.put(sa.COE__c, sa);
    //     }

    //     for (MB_Sales_Agreement__c mbSA : [SELECT Id, COE__c, Name
    //                                       FROM MB_Sales_Agreement__c
    //                                       WHERE COE__c IN :coeIdsForMBSA])
    //     {
    //         mbSAByCOEId.put(mbSA.COE__c, mbSA);
    //     }

    //     for (COE__c record : (List<COE__c>)Records)
    //     {
    //         COE__c oldRecord = (COE__c)existingRecords.get(record.Id);
    //         if (record.Sales_Agreement__c != oldRecord.Sales_Agreement__c)
    //         {
    //             if (saByCOEId.containsKey(record.Id))
    //             {
    //                 record.addError('Sales Agreement number ' + saByCOEId.get(record.Id).SOH_SONO__c + ' has been linked to this COE. Please check again!');
    //             }
    //             else
    //             {
    //                 record.Sales_Agreement_Unique_Id__c = String.isEmpty(record.Sales_Agreement__c) ? null : record.Sales_Agreement__c;
    //             }
    //         }
    //         if (record.MB_Sales_Agreement__c != oldRecord.MB_Sales_Agreement__c)
    //         {
    //             if (mbSAByCOEId.containsKey(record.Id))
    //             {
    //                 record.addError('Sales Agreement number ' + saByCOEId.get(record.Id).Name + ' has been linked to this COE. Please check again!');
    //             }
    //             else
    //             {
    //                 record.MB_Sales_Agreement_Unique_Id__c = String.isEmpty(record.MB_Sales_Agreement__c) ? null : record.MB_Sales_Agreement__c;
    //             }
    //         }
    //     }
    // }

    public override void onAfterUpdate(Map<Id, sObject> previousMap){

        Map<Id, String> changedCOEBySAId   = new Map<Id, String>();
        Map<Id, String> changedCOEByMBSAId = new Map<Id, String>();
        for (COE__c coe : (List<COE__c>)Records)
        {
            if (previousMap.get(coe.Id).get('Sales_Agreement__c') != coe.Sales_Agreement__c)
            {
                changedCOEBySAId.put(coe.Id, coe.Sales_Agreement__c);
            }
            if (previousMap.get(coe.Id).get('MB_Sales_Agreement__c') != coe.MB_Sales_Agreement__c)
            {
                changedCOEByMBSAId.put(coe.Id, coe.MB_Sales_Agreement__c);
            }
        }

        if (changedCOEBySAId.isEmpty() && changedCOEByMBSAId.isEmpty()) return;

        Map<Id, Sales_Agreement__c> saById = new Map<Id, Sales_Agreement__c>([SELECT Id, COE__c, SOH_SONO__c, COE_Expiry_Date__c
                                                                               FROM Sales_Agreement__c
                                                                               WHERE Id IN :changedCOEBySAId.values()]);

        Map<Id, MB_Sales_Agreement__c> mbSAById = new Map<Id, MB_Sales_Agreement__c>([SELECT Id, COE__c, COE_Expiry_Date__c
                                                                                       FROM MB_Sales_Agreement__c
                                                                                       WHERE Id IN :changedCOEByMBSAId.values()]);

        Map<Id, COE__c> coes = new Map<Id, COE__c>((List<COE__c>)Records);
        for (Id coeId : changedCOEBySAId.keySet())
        {
            COE__c coe = coes.get(coeId);
            Sales_Agreement__c sa = saById.get(coe.Sales_Agreement__c);
            if (sa != null)
            {
                sa.COE__c             = coe.Id;
                sa.COE_Expiry_Date__c = coe.COH_EXPMONTH__c;
                sa.COE_Deposit__c     = coe.COH_DEPOSIT__c;
            }
        }

        for (Id coeId : changedCOEByMBSAId.keySet())
        {
            COE__c coe = coes.get(coeId);
            MB_Sales_Agreement__c mbSA = mbSAById.get(coe.MB_Sales_Agreement__c);
            if (mbSA != null)
            {
                mbSA.COE__c             = coe.Id;
                mbSA.COE_Expiry_Date__c = coe.COH_EXPMONTH__c;
                mbSA.COE_Deposit__c     = coe.COH_DEPOSIT__c;
                mbSA.COE_Number__c      = coe.COH_COENO__c;
            }
        }

        Database.update(saById.values(), false);
        Database.update(mbSAById.values(), false);
    }
}