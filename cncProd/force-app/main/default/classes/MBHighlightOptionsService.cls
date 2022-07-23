public with sharing class MBHighlightOptionsService {
    public static List<MB_Stock_Vehicle_Master__c> getStocksForBatchBuildSpec(Map<String, Boolean> comparedBuildSpecIds) {
        List<MB_SVM_Spec__c> svmSpecs = [SELECT ID, MB_Stock_Vehicle_Master__c, Build_Spec_Comparison__c, Description__c, SVM_Spec_Compared_ID__c
                                         FROM MB_SVM_Spec__c 
                                         WHERE Build_Spec_Comparison__c IN :comparedBuildSpecIds.keySet()];
        system.debug('Result of SVM Specs:: ' + svmSpecs);

        Map<Id, List<MB_SVM_Spec__c>> svmSpecsByMBSVMIds = new Map<Id, List<MB_SVM_Spec__c>>();
        for (MB_SVM_Spec__c spec : svmSpecs) {
            if (svmSpecsByMBSVMIds.containsKey(spec.MB_Stock_Vehicle_Master__c)) {
                svmSpecsByMBSVMIds.get(spec.MB_Stock_Vehicle_Master__c).add(spec);
            } else {
                svmSpecsByMBSVMIds.put(spec.MB_Stock_Vehicle_Master__c, new List<MB_SVM_Spec__c>{spec});
            }
        }

        Map<Id, MB_Stock_Vehicle_Master__c> mbSVMs = new Map<Id, MB_Stock_Vehicle_Master__c>([SELECT Id, Name, Highlight_Options__c, hasHighlightOptions__c, Batch_Processed__c
                                                                                              FROM MB_Stock_Vehicle_Master__c
                                                                                              WHERE Id in :svmSpecsByMBSVMIds.keySet()]);

        List<MB_SVM_Spec__c> tmpSVMSpecs;
        MB_Stock_Vehicle_Master__c tmpSVM;
        String tmpHLOs;
        List<MB_Stock_Vehicle_Master__c> mbSVMsToUpdate = new List<MB_Stock_Vehicle_Master__c>();
        for (Id key : mbSVMs.keySet()) {
            tmpSVMSpecs = svmSpecsByMBSVMIds.get(key);
            tmpSVM = mbSVMs.get(key);
            tmpHLOs = String.isEmpty(tmpSVM.Highlight_Options__c) ? '' : tmpSVM.Highlight_Options__c;
            tmpSVM.Highlight_Options__c = processHLOsForBuildSpec(tmpSVMSpecs, comparedBuildSpecIds, tmpHLOs);
            tmpSVM.hasHighlightOptions__c = String.isEmpty(tmpSVM.Highlight_Options__c) ? false : true;
            mbSVMsToUpdate.add(tmpSVM);
        }

        system.debug('MB SVMs to update:: ' + mbSVMsToUpdate.size());
        return mbSVMsToUpdate;
    }

    public static List<MB_Stock_Vehicle_Master__c> getStocksForBatchSVMSpec(List<MB_SVM_Spec__c> svmSpecs) {
        Set<String> comparedSVMSpecIds = new Set<String>();
        for (MB_SVM_Spec__c spec : svmSpecs) {
            comparedSVMSpecIds.add(spec.Build_Spec_Comparison__c);
        }
        system.debug('Size of SVM Spec Compared ID::' + comparedSVMSpecIds.size());

        List<MB_Build_Spec__c> buildSpecs = [SELECT ID, Build_Spec_Compared_ID__c, Highlight_Option__c, Batch_Processed__c, MB_Build_Spec_ID__c
                                             FROM MB_Build_Spec__c
                                             WHERE MB_Build_Spec_ID__c IN :comparedSVMSpecIds AND Highlight_Option__c = true];

        Set<String> hloBuildSpecs = new Set<String>();
        if (buildSpecs.size() > 0) {
            for (MB_Build_Spec__c spec : buildSpecs) {
                hloBuildSpecs.add(spec.MB_Build_Spec_ID__c);
            }
            system.debug('hloBuildSpecs:: ' + hloBuildSpecs);
        }

        Map<Id, List<MB_SVM_Spec__c>> svmSpecsByMBSVMIds = new Map<Id, List<MB_SVM_Spec__c>>();
        for (MB_SVM_Spec__c spec : svmSpecs) {
            if (svmSpecsByMBSVMIds.containsKey(spec.MB_Stock_Vehicle_Master__c)) {
                svmSpecsByMBSVMIds.get(spec.MB_Stock_Vehicle_Master__c).add(spec);
            } else {
                svmSpecsByMBSVMIds.put(spec.MB_Stock_Vehicle_Master__c, new List<MB_SVM_Spec__c>{spec});
            }
        }

        Map<Id, MB_Stock_Vehicle_Master__c> mbSVMs = new Map<Id, MB_Stock_Vehicle_Master__c>([SELECT Id, Name, Highlight_Options__c, hasHighlightOptions__c, Batch_Processed__c
                                                                                              FROM MB_Stock_Vehicle_Master__c
                                                                                              WHERE Id in :svmSpecsByMBSVMIds.keySet()]);

        List<MB_SVM_Spec__c> tmpSVMSpecs;
        MB_Stock_Vehicle_Master__c tmpSVM;
        String tmpHLOs;
        List<MB_Stock_Vehicle_Master__c> mbSVMsToUpdate = new List<MB_Stock_Vehicle_Master__c>();
        for (Id key : mbSVMs.keySet()) {
            tmpSVM = mbSVMs.get(key);
            tmpSVMSpecs = svmSpecsByMBSVMIds.get(key);
            tmpHLOs = String.isEmpty(tmpSVM.Highlight_Options__c) ? '' : tmpSVM.Highlight_Options__c;
            tmpSVM.Highlight_Options__c = processHLOsForSVMSpec(tmpSVMSpecs, hloBuildSpecs, tmpHLOs);
            tmpSVM.hasHighlightOptions__c = String.isEmpty(tmpSVM.Highlight_Options__c) ? false : true;
            tmpSVM.Batch_Processed__c = true;
            mbSVMsToUpdate.add(tmpSVM);
        }

        system.debug('MB SVMs to update:: ' + mbSVMsToUpdate.size());
        return mbSVMsToUpdate;
    }

    /**
     * This method to process HLOs for Batch from MB SVM Spec/MB SVM
     * If any new coming SVM Specs is HLO then add spec to HLO list in MB SVM
     */
    private static String processHLOsForSVMSpec(List<MB_SVM_Spec__c> specs, Set<String> hloBuildSpecs, String hloList)
    {
        String result;
        for (MB_SVM_Spec__c spec : specs) {
            if (String.isNotEmpty(hloList) && hloList.contains(spec.Description__c)) continue;
            if (hloBuildSpecs.contains(spec.Build_Spec_Comparison__c)) {
                hloList += spec.Description__c + '; ';
            }
        }
		result = hloList;

        return result;
    }

    /**
     * This method to process HLOs for Batch from MB Build Spec
     * If Build Spec updated to HLO then add spec to HLO list in MB SVM
     * If Build Spec updated to Non-HLO then remove spec from HLO list in MB SVM if existed
     */
    private static String processHLOsForBuildSpec(List<MB_SVM_Spec__c> svmSpecs, Map<String, Boolean> comparedBuildSpecIds, String hloList) {
        String result;
        for (MB_SVM_Spec__c spec : svmSpecs) {
            if (!comparedBuildSpecIds.get(spec.Build_Spec_Comparison__c)) {
                if (String.isNotEmpty(hloList) && hloList.contains(spec.Description__c)) {
                    hloList = hloList.replace(spec.Description__c + ';', ' ');
                }
            } else {
                if (String.isNotEmpty(hloList) && hloList.contains(spec.Description__c)) continue;
                hloList += spec.Description__c + '; ';
            }
        }
        result = hloList;

        return result;
    }
}