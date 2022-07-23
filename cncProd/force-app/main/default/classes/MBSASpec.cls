public inherited sharing class MBSASpec extends ADGLIB_SObjectDomain {
    public MBSASpec(List<MB_SA_Spec__c> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new MBSASpec(sObjectList);
		}
    }

    public override void onAfterInsert() {
        Map<Id, MB_SA_Spec__c> addnlSpecByMBSAIds = new Map<Id, MB_SA_Spec__c>();
        for (MB_SA_Spec__c spec : (List<MB_SA_Spec__c>)Records) {
            if (spec.Fit_Type__c.equals('O') && spec.PRINT__c.equals('Y')) {
                addnlSpecByMBSAIds.put(spec.MB_Sales_Agreement__c, spec);
            }
        }

        if (addnlSpecByMBSAIds.isEmpty()) return;

        List<MB_Sales_Agreement__c> mbSAs = new List<MB_Sales_Agreement__c>([SELECT Id, Newly_Added_SA_Spec__c, Removed_SA_Spec__c, Sales_Agreement_Version__c, Sales_and_UCA_Version__c
                                                                            FROM MB_Sales_Agreement__c
                                                                            WHERE Id IN :addnlSpecByMBSAIds.keySet()]);

        String addnlSpecStr;
        for (MB_Sales_Agreement__c mbSA : mbSAs) {
            if (mbSA.Sales_Agreement_Version__c == 1 && mbSA.Sales_and_UCA_Version__c == 1) continue;

            addnlSpecStr = String.isBlank(mbSA.Newly_Added_SA_Spec__c) ? '' : mbSA.Newly_Added_SA_Spec__c;

            MB_SA_Spec__c spec = addnlSpecByMBSAIds.get(mbSA.Id);
            String description = '(' + spec.Product_Code__c + ')' + ' ' + spec.Description__c;

            if (String.isBlank(mbSA.Removed_SA_Spec__c)) {
                addnlSpecStr += description + ';';
            } else {
                if (!mbSA.Removed_SA_Spec__c.contains(spec.Product_Code__c)) {
                    addnlSpecStr += description + ';';
                } else {
                    mbSA.Removed_SA_Spec__c = mbSA.Removed_SA_Spec__c.replace(description + ';', '');
                }
            }

            mbSA.Newly_Added_SA_Spec__c = addnlSpecStr;
        }

        Database.update(mbSAs, false);
    }

    public override void onAfterDelete() {
        Map<Id, MB_SA_Spec__c> deletionSpecsByMBSAId = new Map<Id, MB_SA_Spec__c>();
        for (MB_SA_Spec__c spec : (List<MB_SA_Spec__c>)Records) {
            if (spec.Fit_Type__c.equals('O') && spec.PRINT__c.equals('Y')) {
                deletionSpecsByMBSAId.put(spec.MB_Sales_Agreement__c, spec);
            }
        }

        if (deletionSpecsByMBSAId.isEmpty()) return;

        List<MB_Sales_Agreement__c> mbSAs = new List<MB_Sales_Agreement__c>([SELECT Id, Newly_Added_SA_Spec__c, Removed_SA_Spec__c, Sales_Agreement_Version__c, Sales_and_UCA_Version__c
                                                                            FROM MB_Sales_Agreement__c
                                                                            WHERE Id IN :deletionSpecsByMBSAId.keySet()]);

        String addnlSpecStr;
        String deletionSpecStr;
        for (MB_Sales_Agreement__c mbSA : mbSAs) {
            if (mbSA.Sales_Agreement_Version__c == 1 && mbSA.Sales_and_UCA_Version__c == 1) continue;

            deletionSpecStr = String.isBlank(mbSA.Removed_SA_Spec__c) ? '' : mbSA.Removed_SA_Spec__c;

            MB_SA_Spec__c spec = deletionSpecsByMBSAId.get(mbSA.Id);
            String description = '(' + spec.Product_Code__c + ')' + ' ' + spec.Description__c;

            if (!String.isBlank(mbSA.Newly_Added_SA_Spec__c) && mbSA.Newly_Added_SA_Spec__c.contains(spec.Product_Code__c)) {
                mbSA.Newly_Added_SA_Spec__c =  mbSA.Newly_Added_SA_Spec__c.replace(description + ';', '');
            } else if (!deletionSpecStr.contains(spec.Product_Code__c)) {
                deletionSpecStr += description + ';';
            }

            mbSA.Removed_SA_Spec__c = deletionSpecStr;
        }

        Database.update(mbSAs, false);
    }

    /** ADDED BY THIEU DANG VU - 16/09/2021 - MB CR ------- START */
    /**
     * When SVC/RSVC/BVC updated
     * New SVC spec will be displayed in Addition Spec
     * Old SVC spec will be display in Deletion Spec
     */
    public override void onAfterUpdate(Map<Id, sObject> existingRecords) {
        Map<Id, MB_SA_Spec__c> updateSpecByMBSAId = new Map<Id, MB_SA_Spec__c>();
        Map<Id, String> oldSpecById = new Map<Id, String>();
        Boolean isSVCOrBoutique = false;

        for (MB_SA_Spec__c spec : (List<MB_SA_Spec__c>)Records) {
            isSVCOrBoutique = spec.Product_Code__c.startsWith('SVC') || spec.Product_Code__c.startsWith('RSVC') ||
                              spec.Product_Code__c.startsWith('BOUTVC');
            if (spec.Fit_Type__c.equals('O') && spec.PRINT__c.equals('Y') && isSVCOrBoutique) {
                MB_SA_Spec__c oldSpec = (MB_SA_Spec__c)existingRecords.get(spec.Id);
                if (spec.Invoice_Value__c == oldSpec.Invoice_Value__c) continue;

                oldSpecById.put(spec.Id, '(' + oldSpec.Product_Code__c + ')' + ' ' + oldSpec.Description__c);
                updateSpecByMBSAId.put(spec.MB_Sales_Agreement__c, spec);
            }
        }

        if (updateSpecByMBSAId.isEmpty()) return;

        List<MB_Sales_Agreement__c> mbSAs = new List<MB_Sales_Agreement__c>([SELECT Id, Newly_Added_SA_Spec__c, Removed_SA_Spec__c, Sales_Agreement_Version__c, Sales_and_UCA_Version__c
                                                                            FROM MB_Sales_Agreement__c
                                                                            WHERE Id IN :updateSpecByMBSAId.keySet()]);

        String addnlSpecStr;
        String deletionSpecStr;
        for (MB_Sales_Agreement__c mbSA : mbSAs) {
            if (mbSA.Sales_Agreement_Version__c == 1 && mbSA.Sales_and_UCA_Version__c == 1) continue;

            addnlSpecStr = String.isBlank(mbSA.Newly_Added_SA_Spec__c) ? '' : mbSA.Newly_Added_SA_Spec__c;
            deletionSpecStr = String.isBlank(mbSA.Removed_SA_Spec__c) ? '' : mbSA.Removed_SA_Spec__c;

            MB_SA_Spec__c spec = updateSpecByMBSAId.get(mbSA.Id);
            String description = '(' + spec.Product_Code__c + ')' + ' ' + spec.Description__c;

            if (!deletionSpecStr.contains(oldSpecById.get(spec.Id))) {
                if (addnlSpecStr.contains(oldSpecById.get(spec.Id))) {
                    addnlSpecStr = addnlSpecStr.replace(oldSpecById.get(spec.Id), description);
                } else {
                    addnlSpecStr += description + ';';
                    deletionSpecStr += oldSpecById.get(spec.Id) + ';';
                }
            }

            if (deletionSpecStr.contains(spec.Product_Code__c)) {
                addnlSpecStr = addnlSpecStr.replace(description + ';', '');
                deletionSpecStr = deletionSpecStr.replace(description + ';', '');
            }

            mbSA.Removed_SA_Spec__c = deletionSpecStr;
            mbSA.Newly_Added_SA_Spec__c = addnlSpecStr;
        }

        Database.update(mbSAs, false);
    }
    /** ADDED BY THIEU DANG VU - 16/09/2021 - MB CR ------- END */
}