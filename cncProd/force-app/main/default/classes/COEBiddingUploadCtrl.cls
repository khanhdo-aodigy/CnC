public inherited sharing class COEBiddingUploadCtrl {
    @AuraEnabled
    public static void readCSVFile(Id contentDocumentId, Id coeBidPeriodId, String franchise) {
        system.debug('cdId => ' + contentDocumentId + ' ' + 'coeBidPeriodId => ' + coeBidPeriodId + ' ' + 'franchise => ' + franchise);
        if (contentDocumentId != null) {
            // Get Content Version based on document id 
            ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId];
            // Split lines in CSV file
            List<String> lstCSVLines = cv.VersionData.toString().split('\n');
            if (lstCSVLines.size() == 1) {
                throw new AuraHandledException('File is empty!');
            }

            Map<String, List<Sales_Agreement__c>> saByFranchiseNRIC;
            Map<String, List<MB_Sales_Agreement__c>> mbSAByNRIC;
            if (!franchise.equals('MBP')) {
                saByFranchiseNRIC = new Map<String, List<Sales_Agreement__c>>();
                String saFranchiseNRIC;
                List<Sales_Agreement__c> sas = getRecords('Sales_Agreement__c', 'FranchiseCode__c', franchise, 'AND COE__c = null AND Submit_COE_Bidding__c = true');
                for (Sales_Agreement__c sa : sas) {
                    if (!String.isEmpty(sa.FranchiseCode__c) && !String.isEmpty(sa.NRIC_Number__c)) {
                        saFranchiseNRIC = sa.FranchiseCode__c + sa.NRIC_Number__c.right(4);
                        if (saByFranchiseNRIC.containsKey(saFranchiseNRIC)) {
                            saByFranchiseNRIC.get(saFranchiseNRIC).add(sa);
                        } else {
                            saByFranchiseNRIC.put(saFranchiseNRIC, new List<Sales_Agreement__c>{sa});
                        }
                    }
                }
            } else {
                mbSAByNRIC = new Map<String, List<MB_Sales_Agreement__c>>();
                String mbSANRIC;
                List<MB_Sales_Agreement__c> mbSAs = getRecords('MB_Sales_Agreement__c', null, null, 'COE__c = null AND Submit_COE_Bidding__c = true');
                for (MB_Sales_Agreement__c mbSA : mbSAs) {
                    if (!String.isEmpty(mbSA.CNRIC_Number__c)) {
                        mbSANRIC = mbSA.CNRIC_Number__c.right(4);
                        if (mbSAByNRIC.containsKey(mbSANRIC)) {
                            mbSAByNRIC.get(mbSANRIC).add(mbSA);
                        } else {
                            mbSAByNRIC.put(mbSANRIC, new List<MB_Sales_Agreement__c>{mbSA});
                        }
                    }
                }
            }

            Map<String, List<COE__c>> coesByNameMap = new Map<String, List<COE__c>>();
            try {
                for (Integer i = 1; i < lstCSVLines.size(); i++) {
                    COE__c coe = new COE__c();
                    String csvLine = lstCSVLines[i];
                    String prevLine = csvLine;
                    Integer startIndex;
                    Integer endIndex;
                    while (csvLine.indexOf('"') > -1) {
                        if (startIndex == null){
                            startIndex = csvLine.indexOf('"');
                            csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex + 1, csvLine.length());
                        } else {
                            if (endIndex == null){
                                endIndex = csvLine.indexOf('"');
                                csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex + 1, csvLine.length());
                            }
                        }

                        if (startIndex != null && endIndex != null){
                            String sub = csvLine.substring(startIndex, endIndex);
                            sub = sub.replaceAll(',', ':comma:');
                            csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                            startIndex = null;
                            endIndex = null;
                        }
                    }
                    List<String> csvRowData = new List<String>();
                    for (String column : csvLine.split(',')){
                        column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                        csvRowData.add(column);
                    }
                    // Skip empty row
                    if (csvRowData.size() == 0) {
                        continue;
                    }
                    // List<String> csvRowData = lstCSVLines[i].split(',');
                    coe.COH_COENO__c = csvRowData[1];                                                                                   // [1] COE Number
                    coe.COH_COECATEGORY__c = csvRowData[2];                                                                             // [2] COE Category
                    coe.COH_BIDDERNAME__c = csvRowData[3];                                                                              // [3] COE Bidder Name
                    coe.COH_BIDDERTYPE__c = csvRowData[4];                                                                              // [4] COE Bidder ID Type
                    coe.COH_BIDDERID__c = csvRowData[5];                                                                                // [5] COE Bidder ID
                    coe.COH_QP__c = !String.isEmpty(csvRowData[6]) ? Decimal.valueOf(csvRowData[6].replaceAll(',','')) : 0;             // [6] COE QP Amount
                    coe.COH_DEPOSIT__c = !String.isEmpty(csvRowData[7]) ? Decimal.valueOf(csvRowData[7].replaceAll(',','')) : 0;        // [7] COE Deposit
                    coe.COH_BALANCE__c = !String.isEmpty(csvRowData[8]) ? Decimal.valueOf(csvRowData[8].replaceAll(',','')) : 0;        // [8] COE Balance
                    coe.COH_ADMINFEE__c = !String.isEmpty(csvRowData[9]) ? Decimal.valueOf(csvRowData[9].replaceAll(',','')) : 0;       // [9] Admin Fee
                    coe.COH_EXPMONTH__c = !String.isEmpty(csvRowData[10]) ? Date.valueOf(csvRowData[10]) : null;                        // [10] COE Expiry Date
                    // coe.COH_STATUS__c = csvRowData[11];                                                                                 // [11] Status
                    coe.COE_Bid_Period__c = coeBidPeriodId;                                                                             // Assign lookup value to COE Bid Period
                    coe.Franchise__c = franchise;
                    if (coesByNameMap.containsKey(coe.COH_BIDDERNAME__c)) {
                        coesByNameMap.get(coe.COH_BIDDERNAME__c).add(coe);
                    } else {
                        coesByNameMap.put(coe.COH_BIDDERNAME__c, new List<COE__c>{coe});
                    }
                }
            } catch (Exception e) {
                throw new AuraHandledException('An error has occured while uploading file. File is not properly formatted, either missing columns or wrong data format. Please check and upload again!' + e.getMessage());
            }

            List<COE__c> coesToBeCreated;
            if (!coesByNameMap.isEmpty()) {
                coesToBeCreated = new List<COE__c>();
                for (String bidderNm : coesByNameMap.keySet()) {
                    // All COEs needs to be inserted
                    coesToBeCreated.addAll(coesByNameMap.get(bidderNm));
                    // CR - Only match COE with SA/MBSA when no more than 1 COE with same name in CSV file to be found
                    if (coesByNameMap.get(bidderNm).size() == 1) {
                        COE__c coeToBeMatched = coesByNameMap.get(bidderNm)[0];
                        String coeNRIC;
                        String bidderNmToMatch = coeToBeMatched.COH_BIDDERNAME__c.left(4);
                        if (!franchise.equals('MBP')) {
                            coeNRIC = coeToBeMatched.Franchise__c + coeToBeMatched.COH_BIDDERID__c.right(4);
                            Sales_Agreement__c sa = findMatchedSA(saByFranchiseNRIC, coeNRIC, bidderNmToMatch);
                            // Auto-link COE to SA only if 1 SA found
                            if (sa != null && checkMatchCOECondition(coeToBeMatched, sa, null)) {
                                coeToBeMatched.Sales_Agreement__c = sa.Id;
                            }
                        } else {
                            coeNRIC = coeToBeMatched.COH_BIDDERID__c.right(4);
                            MB_Sales_Agreement__c mbSA = findMatchedMBSA(mbSAByNRIC, coeNRIC, bidderNmToMatch);
                            // Auto-link COE to MBSA only if 1 MBSA found
                            if (mbSA != null && checkMatchCOECondition(coeToBeMatched, null, mbSA)) {
                                coeToBeMatched.MB_Sales_Agreement__c = mbSA.Id;
                            }
                        }
                    }
                }
            }

            system.debug('total coesToBeCreated :: ' + coesToBeCreated.size());
            system.debug('coesToBeCreated :: ' + coesToBeCreated);
            try {
                insert coesToBeCreated;
            } catch (Exception e) {
                String errorMsg = '';
                if (e.getMessage().contains('DUPLICATE_VALUE')) {
                    errorMsg = 'There are duplicates on TCOE Number or multiple COEs linked to the same Sales Agreement or COE has been linked to Sales Agreement before. Please check and upload the file again!';
                } else {
                    errorMsg = 'An error has occured while creating COE. ' + e.getMessage();
                }

                throw new AuraHandledException(errorMsg);
            }
        }
    }

    private static Sales_Agreement__c findMatchedSA(Map<String, List<Sales_Agreement__c>> saByFranchiseNRIC, String coeNRIC, String bidderNmToMatch) {
        List<Sales_Agreement__c> result = new List<Sales_Agreement__c>();
        if (saByFranchiseNRIC.containsKey(coeNRIC)) {
            for (Sales_Agreement__c sa : saByFranchiseNRIC.get(coeNRIC)) {
                // If there are many MBSA found then no need to auto-link COE to MBSA
                if (!String.isEmpty(sa.Customer_Full_Name__c) && sa.Customer_Full_Name__c.containsAny(bidderNmToMatch)) {
                    result.add(sa);
                }
            }
        }
        system.debug('Number of SAs found:: ' + result.size());
        if (!result.isEmpty() && result.size() == 1) return result[0];

        return null;
    }

    private static MB_Sales_Agreement__c findMatchedMBSA(Map<String, List<MB_Sales_Agreement__c>> mbSAByNRIC, String coeNRIC, String bidderNmToMatch) {
        List<MB_Sales_Agreement__c> result = new List<MB_Sales_Agreement__c>();
        if (mbSAByNRIC.containsKey(coeNRIC)) {
            for (MB_Sales_Agreement__c mbSA : mbSAByNRIC.get(coeNRIC)) {
                // If there are many MBSA found then no need to auto-link COE to MBSA
                if (!String.isEmpty(mbSA.Customer_Full_Name__c) && mbSA.Customer_Full_Name__c.containsAny(bidderNmToMatch)) {
                    result.add(mbSA);
                }
            }
        }
        system.debug('Number of MBSAs found:: ' + result.size());
        if (!result.isEmpty() && result.size() == 1) return result[0];

        return null;
    }

    private static Boolean checkMatchCOECondition(COE__c coe, Sales_Agreement__c sa, MB_Sales_Agreement__c mbSA) {
        Boolean matched = false;
        if (coe.COH_COECATEGORY__c != 'E' && coe.COH_BIDDERTYPE__c == 'Singapore NRIC' &&
            ((sa != null && coe.COH_COECATEGORY__c == sa.COECategory__c) || (mbSA != null && coe.COH_COECATEGORY__c == mbSA.COE_Category__c))) {
                matched = true;
        }

        return matched;
    }

    private static List<sObject> getRecords(String objNm, String fieldReference, String fieldValue, String additionalConditions) {
        String mainQueryCondition = '';
        if (String.isNotBlank(fieldReference) && String.isNotBlank(fieldValue)) {
            mainQueryCondition = fieldReference + ' = ' + '\'' + fieldValue + '\'';
        }
        
        if (additionalConditions != null && String.isNotBlank(additionalConditions)) {
            mainQueryCondition = mainQueryCondition + ' ' + additionalConditions;
        }

        List<sObject> records = ADGLIB_UtilityHelper.getSObjectRecords(objNm, mainQueryCondition, false); 

        return records;
    }
}