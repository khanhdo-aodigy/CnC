public with sharing class EnvelopeStatus {
    /**
     -- Trigger handle for Docusign Envelope Status object
     -- Author: Mai Dang Phap at dangphap.mai@aodigy.com
     -- Changelog v1.0: provide trigger handling methods for Docusign Envelope Status object [Mai Dang Phap]
     -- Changelog v1.1: add logic for MB Sales Agreement [Mai Dang Phap] [16 Sep 2020]
     */

    /**
     * Store the context of populate agreement ID
     */
    private static Map<String, SObject> errorContext_POPULATE_AGREEMENT_ID = new Map<String, SObject>();
    
    /**
     * Store the context of updating approval status
     */
    private static Map<String, SObject> errorContext_UPDATE_AGREEMENT_APPROVAL = new Map<String, SObject>();
    
    /**
     * Count the number of triggered record that connect to eithe SA or MBSA
     */
    private static Integer connection = 0;

    public static void handleBeforeInsert(List<SObject> triggerNew) 
    {
        List<dsfs__DocuSign_Status__c> newRecords = (List<dsfs__DocuSign_Status__c>) triggerNew;

        try {
            connectSA(newRecords);
            connectMBSA(newRecords);
        } catch (Exception e) {
            logError(e, 'Before Insert', triggerNew, errorContext_POPULATE_AGREEMENT_ID);
            return;
        }

        try {
            if (connection < triggerNew.size()) logMissing(triggerNew, errorContext_POPULATE_AGREEMENT_ID);
        } catch (Exception e) {
            // fail silent, non-critical function
        }
        
    }

    public static void handleBeforeUpdate(List<SObject> triggerNew, Map<ID, SObject> triggerOldMap) 
    {
        List<dsfs__DocuSign_Status__c> newRecords = (List<dsfs__DocuSign_Status__c>) triggerNew;
        Map<ID, dsfs__DocuSign_Status__c> id_oldRecord = (Map<ID, dsfs__DocuSign_Status__c>) triggerOldMap;

        try {
            updateApproval(newRecords, id_oldRecord);
            updateApprovalMBSA(newRecords, id_oldRecord);
        } catch (Exception e) {
            logError(e, 'handleBeforeUpdate_UpdateApprovalStatus', triggerNew, errorContext_UPDATE_AGREEMENT_APPROVAL);
        }
    }

    /**
     * Link new create Docusign Status record to its originated MB Sales Agreement base on envelope ID
     */
    private static void connectMBSA(List<dsfs__DocuSign_Status__c> triggerNew)
    {
        Map<String, dsfs__DocuSign_Status__c> envID_dsRecord = new Map<String, dsfs__DocuSign_Status__c>();

        for (dsfs__DocuSign_Status__c ds: triggerNew) 
        {
            if (ds.MB_Sales_Agreement__c != null) continue;                     // not handle docusign status record alrd lookup to a sales agreement
            envID_dsRecord.put(ds.dsfs__DocuSign_Envelope_ID__c, ds);
        }

        List<MB_Sales_Agreement__c> MBSAs = [SELECT Id, Latest_Docusign_Envelope__c, Latest_UCA_Docusign_Envelope__c, 
                                                    Latest_YF_Docusign_Envelope__c, Latest_SA_UCA_Docusign_Envelope__c, Approval_Status__c
                                            FROM MB_Sales_Agreement__c
                                            WHERE Latest_Docusign_Envelope__c IN :envID_dsRecord.keySet()
                                            OR Latest_UCA_Docusign_Envelope__c IN :envID_dsRecord.keySet()
                                            OR Latest_YF_Docusign_Envelope__c IN :envID_dsRecord.keySet()
                                            OR Latest_SA_UCA_Docusign_Envelope__c IN :envID_dsRecord.keySet()];

        if (envID_dsRecord.keySet().size() < 1) return;                         // no record to process
        if (MBSAs.size() < 1) return;                                           // no matching MB Sales Agreement to process

        /* -------- MODIFIED BY THIEU DANG VU - Thu 5th Nov 2020 -- START --------*/
        Set<String> DSA_EnvelopeIDs = new Set<String>();
        Set<String> UCA_EnvelopeIDs = new Set<String>();
        Set<String> YF_EnvelopeIDs = new Set<String>();                             // ADDED BY THIEU DANG VU - May 6th 2021 - Envelopes for Yellow Form
        Set<String> SAUCA_EnvelopeIDs = new Set<String>();                          // ADDED BY THIEU DANG VU - May 6th 2021 - Envelopes for Sales & UCA Form
        Map<String, MB_Sales_Agreement__c> envID_saRecord = new Map<String, MB_Sales_Agreement__c>();

        for (MB_Sales_Agreement__c MBSA : MBSAs) 
        {
            errorContext_POPULATE_AGREEMENT_ID.put('Related MB Sales Agreement @' + DateTime.now().format('dd/MM/yyyy HH:mm'), MBSA);

            if (MBSA.Latest_Docusign_Envelope__c != null)
            {
                DSA_EnvelopeIDs.add(MBSA.Latest_Docusign_Envelope__c);
                envID_saRecord.put(MBSA.Latest_Docusign_Envelope__c, MBSA);
            }

            if (MBSA.Latest_UCA_Docusign_Envelope__c != null)
            {
                UCA_EnvelopeIDs.add(MBSA.Latest_UCA_Docusign_Envelope__c);
                envID_saRecord.put(MBSA.Latest_UCA_Docusign_Envelope__c, MBSA);
            }
            // ADDED BY THIEU DANG VU - May 6th 2021 - Update YF Envelope IDs
            if (MBSA.Latest_YF_Docusign_Envelope__c != null)
            {
                YF_EnvelopeIDs.add(MBSA.Latest_YF_Docusign_Envelope__c);
                envID_saRecord.put(MBSA.Latest_YF_Docusign_Envelope__c, MBSA);
            }
            // ADDED BY THIEU DANG VU - June 3rd 2021 - Update Sales & UCA Envelope IDs
            if (MBSA.Latest_SA_UCA_Docusign_Envelope__c != null)
            {
                SAUCA_EnvelopeIDs.add(MBSA.Latest_SA_UCA_Docusign_Envelope__c);
                envID_saRecord.put(MBSA.Latest_SA_UCA_Docusign_Envelope__c, MBSA);
            }
        }
        List<MB_Sales_Agreement__c> updatingAgreement = new List<MB_Sales_Agreement__c>();
        for (String envelopeID : envID_dsRecord.keySet()) 
        {
            Boolean isDSA = DSA_EnvelopeIDs.contains(envelopeID);
            Boolean isUCA = UCA_EnvelopeIDs.contains(envelopeID);
            Boolean isYF = YF_EnvelopeIDs.contains(envelopeID);                    // ADDED BY THIEU DANG VU - May 6th 2021 - Envelopes for Yellow Form
            Boolean isSAUCA = SAUCA_EnvelopeIDs.contains(envelopeID);              // ADDED BY THIEU DANG VU - June 3rd 2021 - Envelopes for Sales & UCA Form
            MB_Sales_Agreement__c MBSA = envID_saRecord.get(envelopeID);
            dsfs__DocuSign_Status__c ds = envID_dsRecord.get(envelopeID);

            // Write the SA lookup field base on envelope ID
            if (isDSA || isUCA || isYF || isSAUCA) {                               // MODIFIED BY THIEU DANG VU - June 3rd 2021 - Envelopes for Yellow Form and Sales & UCA Form
                ds.MB_Sales_Agreement__c = MBSA.ID;
                errorContext_POPULATE_AGREEMENT_ID.put('Connected MB Sales Agreement @' + DateTime.now().format('dd/MM/yyyy HH:mm'), MBSA);
                connection++;
            }
            // Default the approval status on related SA record to not approved
            if (isDSA || isSAUCA) {
                MBSA.Approval_Status__c = 'Not Approved';
                updatingAgreement.add(MBSA);
                errorContext_POPULATE_AGREEMENT_ID.put('Defaulted Sales Agreement @' + DateTime.now().format('dd/MM/yyyy HH:mm'), MBSA);
            }
        }
        if (updatingAgreement.size() > 0) update updatingAgreement;
        /* -------- MODIFIED BY THIEU DANG VU - Thu 5th Nov 2020 -- END --------*/
    }

    /**
     -- populate the envelope's related SA base on envelope ID
     */
    private static void connectSA(List<dsfs__DocuSign_Status__c> triggerNew) 
    {

        Map<String, dsfs__DocuSign_Status__c> envID_dsRecord = new Map<String, dsfs__DocuSign_Status__c>();

        for (dsfs__DocuSign_Status__c ds: triggerNew) 
        {
            if (ds.SalesAgreement__c != null) continue;                     // not handle docusign status record alrd lookup to a sales agreement
            envID_dsRecord.put(ds.dsfs__DocuSign_Envelope_ID__c, ds);
        }

        if (envID_dsRecord.keySet().size() < 1) return;                     // no record to process

        // querry related SAs base on envelope ID
        List<Sales_Agreement__c> SAs = [SELECT ID, DocuSign_Envelope_ID__c, UCA_Docusign_Envelope_ID__c, ApprovalStatus__c 
                                        FROM Sales_Agreement__c 
                                        WHERE DocuSign_Envelope_ID__c IN :envID_dsRecord.keySet() 
                                        OR UCA_Docusign_Envelope_ID__c IN :envID_dsRecord.keySet()];
        
        Set<String> DSA_EnvelopeIDs = new Set<String>();
        Set<String> UCA_EnvelopeIDs = new Set<String>();
        Map<String, Sales_Agreement__c> envID_saRecord = new Map<String, Sales_Agreement__c>();

        for (Sales_Agreement__c sa : SAs) 
        {
            errorContext_POPULATE_AGREEMENT_ID.put('Related Sales Agreement @' + DateTime.now().format('dd/MM/yyyy HH:mm'), sa);

            if (sa.DocuSign_Envelope_ID__c != null)
            {
                DSA_EnvelopeIDs.add(sa.DocuSign_Envelope_ID__c);
                envID_saRecord.put(sa.DocuSign_Envelope_ID__c, sa);
            }

            if (sa.UCA_Docusign_Envelope_ID__c != null)
            {
                UCA_EnvelopeIDs.add(sa.UCA_Docusign_Envelope_ID__c);
                envID_saRecord.put(sa.UCA_Docusign_Envelope_ID__c, sa);
            }
        }

        List<Sales_Agreement__c> updatingAgreement = new List<Sales_Agreement__c>();

        // loop the trigger records and populate SA look up field
        for (String envelopeID : envID_dsRecord.keySet()) 
        {
            Boolean isDSA = DSA_EnvelopeIDs.contains(envelopeID);
            Boolean isUCA = UCA_EnvelopeIDs.contains(envelopeID);
            Sales_Agreement__c sa = envID_saRecord.get(envelopeID);
            dsfs__DocuSign_Status__c ds = envID_dsRecord.get(envelopeID);

            // write the SA lookup field base on envelope ID
            if (isDSA || isUCA) {
                ds.SalesAgreement__c = sa.ID;
                errorContext_POPULATE_AGREEMENT_ID.put('Connected Sales Agreement @' + DateTime.now().format('dd/MM/yyyy HH:mm'), sa);
                connection++;
            }

            // default the approval status on related SA record to not approved
            if (isDSA) {
                sa.ApprovalStatus__c = 'Not Approved';
                updatingAgreement.add(sa);
                errorContext_POPULATE_AGREEMENT_ID.put('Defaulted Sales Agreement @' + DateTime.now().format('dd/MM/yyyy HH:mm'), sa);
            }
        }
        if (updatingAgreement.size() > 0) update updatingAgreement;
    }

    /**
     -- update related SA's approval status field
     */
    private static void updateApproval(List<dsfs__DocuSign_Status__c> triggerNew, Map<ID, dsfs__DocuSign_Status__c> triggerOldMap)
    {
        Map<ID, dsfs__DocuSign_Status__c> saID_dsRecord = new Map<ID, dsfs__DocuSign_Status__c>();
        
        for (dsfs__DocuSign_Status__c ds: triggerNew)
        {
            String previousStatus = triggerOldMap.get(ds.ID).dsfs__Envelope_Status__c;
            
            String newStatus = ds.dsfs__Envelope_Status__c;
            
            if (newStatus != previousStatus) saID_dsRecord.put(ds.SalesAgreement__c, ds);
        }

        if (saID_dsRecord.keySet().size() < 1) return;                                      // no record to process

        // querry related SAs base on envelope ID
        Map<ID, Sales_Agreement__c> saID_saRecord = new Map<ID, Sales_Agreement__c>([SELECT ID, DocuSign_Envelope_ID__c, UCA_Docusign_Envelope_ID__c, ApprovalStatus__c 
                                                                                     FROM Sales_Agreement__c 
                                                                                     WHERE ID IN :saID_dsRecord.keySet()]);

        List<ID> updateVSMS = new List<ID>();                                               // Store the ID of agreement that need to write back to VSMS
        List<Sales_Agreement__c> updateAgreements = new List<Sales_Agreement__c>();

        // loop envelope status record, update related SA's approval status accordingly
        for (ID saID : saID_dsRecord.keySet())
        {
            dsfs__DocuSign_Status__c ds = saID_dsRecord.get(saID);
            Sales_Agreement__c sa = saID_saRecord.get(saID);
            
            if (sa == null) continue;                                                   // check for safe

            errorContext_UPDATE_AGREEMENT_APPROVAL.put('Related Sales Agreement @' + DateTime.now().format('dd/MM/yyyy HH:mm'), sa);

            String ds_EnvelopeID = ds.dsfs__DocuSign_Envelope_ID__c;       // envelepe ID of triggered docusign status
            String sa_EnvelopeID = sa.DocuSign_Envelope_ID__c;             // newest envelope ID store in SA record
            
            if (ds_EnvelopeID != sa_EnvelopeID) continue;                  // business rule, user can generate multiple envelopes per SA record. Update SA status only when newest DS status changed.

            String approval = sa.ApprovalStatus__c;
            String envelopeStatus = saID_dsRecord.get(saID).dsfs__Envelope_Status__c;

            // Update agreement approval status
            if (envelopeStatus == 'Completed' && approval != 'Approved') {
                sa.ApprovalStatus__c = 'Approved';
                updateAgreements.add(sa);
                updateVSMS.add(saID);
                errorContext_UPDATE_AGREEMENT_APPROVAL.put('Updated Sales Agreement @' + DateTime.now().format('dd/MM/yyyy HH:mm'), sa);
                // actionTaken = true;
            }

            if (envelopeStatus != 'Completed' && approval != 'Not Approved') {
                sa.ApprovalStatus__c = 'Not Approved';
                updateAgreements.add(sa);
                errorContext_UPDATE_AGREEMENT_APPROVAL.put('Updated Sales Agreement @' + DateTime.now().format('dd/MM/yyyy HH:mm'), sa);
                // actionTaken = true;
            }            
        }

        if (!Test.isRunningTest() && updateVSMS.size() > 0) {
            try {
                updateVSMS(updateVSMS);
            } 
            catch (Exception e) {
                // VSMS_CallOutToUpdateStatus do the error logging
            } 
        }
        
        // list<Sales_Agreement__c> updatingAgreement = saID_saRecord.values();
        if (updateAgreements.size() > 0) update updateAgreements;
    }

    /* -------- MODIFIED BY THIEU DANG VU - Thu 5th Nov 2020 -- START --------*/
    /**
     -- update related MB SA's approval status field
     */
    private static void updateApprovalMBSA(List<dsfs__DocuSign_Status__c> triggerNew, Map<ID, dsfs__DocuSign_Status__c> triggerOldMap)
    {
        Map<ID, dsfs__DocuSign_Status__c> mbSAID_dsRecord = new Map<ID, dsfs__DocuSign_Status__c>();
        
        for (dsfs__DocuSign_Status__c ds: triggerNew)
        {
            String previousStatus = triggerOldMap.get(ds.ID).dsfs__Envelope_Status__c;
            
            String newStatus = ds.dsfs__Envelope_Status__c;
            
            if (newStatus != previousStatus) mbSAID_dsRecord.put(ds.MB_Sales_Agreement__c, ds);
        }

        if (mbSAID_dsRecord.keySet().size() < 1) return;                                      // no record to process

        // Query related SAs base on envelope ID
        Map<ID, MB_Sales_Agreement__c> mbSAMap = new Map<ID, MB_Sales_Agreement__c>([SELECT ID, Latest_Docusign_Envelope__c, Latest_UCA_Docusign_Envelope__c, 
                                                                                            Latest_YF_Docusign_Envelope__c, Latest_SA_UCA_Docusign_Envelope__c, Approval_Status__c,
                                                                                            Newly_Added_SA_Spec__c, Removed_SA_Spec__c, Change_Request_Form_Verified__c
                                                                                    FROM MB_Sales_Agreement__c 
                                                                                    WHERE ID IN :mbSAID_dsRecord.keySet()]);

        // List<ID> updateVSMS = new List<ID>();                                               // Store the ID of agreement that need to write back to VSMS
        List<MB_Sales_Agreement__c> updateAgreements = new List<MB_Sales_Agreement__c>();

        // Loop envelope status record, update related SA's approval status accordingly
        for (ID mbSAID : mbSAID_dsRecord.keySet())
        {
            dsfs__DocuSign_Status__c ds = mbSAID_dsRecord.get(mbSAID);
            MB_Sales_Agreement__c MBSA = mbSAMap.get(mbSAID);
            
            if (MBSA == null) continue;                                                   // check for safe

            errorContext_UPDATE_AGREEMENT_APPROVAL.put('Related MB Sales Agreement @' + DateTime.now().format('dd/MM/yyyy HH:mm'), MBSA);

            String ds_EnvelopeID = ds.dsfs__DocuSign_Envelope_ID__c;                        // envelepe ID of triggered docusign status
            String mbSA_EnvelopeID = MBSA.Latest_Docusign_Envelope__c;                      // newest envelope ID store in MB SA record
            String mbSA_YF_EnvelopeID = MBSA.Latest_YF_Docusign_Envelope__c;                // ADDED BY THIEU DANG VU - May 6th 2021 - Yellow Form CR
            String mbSA_SAUCA_EnvelopeID = MBSA.Latest_SA_UCA_Docusign_Envelope__c;         // ADDED BY THIEU DANG VU - June 3rd 2021 - Sales & UCA Form
            
            // if (ds_EnvelopeID != mbSA_EnvelopeID) continue;                     // business rule, user can generate multiple envelopes per SA record. Update SA status only when newest DS status changed.
            String envelopeStatus;
            if ((ds_EnvelopeID == mbSA_EnvelopeID) || (ds_EnvelopeID == mbSA_SAUCA_EnvelopeID)) {
                String approval = MBSA.Approval_Status__c;
                envelopeStatus = mbSAID_dsRecord.get(mbSAID).dsfs__Envelope_Status__c;
    
                // Update agreement approval status
                if (envelopeStatus == 'Completed' && approval != 'Approved') {
                    MBSA.Approval_Status__c = 'Approved';
                    updateAgreements.add(MBSA);
                    errorContext_UPDATE_AGREEMENT_APPROVAL.put('Updated MB Sales Agreement @' + DateTime.now().format('dd/MM/yyyy HH:mm'), MBSA);
                }
    
                if (envelopeStatus != 'Completed' && approval != 'Not Approved') {
                    MBSA.Approval_Status__c = 'Not Approved';
                    updateAgreements.add(MBSA);
                    errorContext_UPDATE_AGREEMENT_APPROVAL.put('Updated MB Sales Agreement @' + DateTime.now().format('dd/MM/yyyy HH:mm'), MBSA);
                }
            } else if (ds_EnvelopeID == mbSA_YF_EnvelopeID) {                               // ADDED BY THIEU DANG VU - May 6th 2021
                // Clear Newly Added SA Spec and Removed SA Spec fields after YF completed sign
                envelopeStatus = mbSAID_dsRecord.get(mbSAID).dsfs__Envelope_Status__c;
                if (envelopeStatus == 'Completed') {
                    MBSA.Newly_Added_SA_Spec__c = null;
                    MBSA.Removed_SA_Spec__c = null;
                    MBSA.Change_Request_Form_Verified__c = true;
                    updateAgreements.add(MBSA);
                    errorContext_UPDATE_AGREEMENT_APPROVAL.put('Updated MB Sales Agreement @' + DateTime.now().format('dd/MM/yyyy HH:mm'), MBSA);
                }
            }
        }

        if (updateAgreements.size() > 0) update updateAgreements;
    }
    /* -------- MODIFIED BY THIEU DANG VU - Thu 5th Nov 2020 -- END --------*/

    /**
     -- Callout to update the approval status in VSMS
     */
    private static void updateVSMS(List<ID> IDs) 
    {
        for (ID recordID : IDs) {
            VSMS_CallOutToUpdateStatus.callOutToUpdateStatus(recordID);
        }
    }

    /**
     -- log error to Service Data Pool object
     */
    @testVisible
    private static void logError(Exception e, String serviceName, List<SObject> triggerContext, Map<String, SObject> extraContext) 
    {
        if (Test.isRunningTest()) system.debug('Error Message In Logging: ' + e.getMessage());
        if (Test.isRunningTest()) system.debug('Error Stack Trace In Logging: ' + e.getStackTraceString());
        
        Logger_Data_Pool__c log = new Logger_Data_Pool__c();
        
        log.Name = 'Trigger error at ' + DateTime.now().format('dd/MM/yyyy HH:mm');
        
        log.Instance__c = 'EnvelopeStatus';
        
        log.Type__c = serviceName;
        
        log.Message__c = e.getMessage();
        
        log.Line_Number__c = e.getLineNumber();
        
        log.Stack_Trace__c = e.getStackTraceString();
        
        log.Cause__c = '[Cause]'
                        + '\n' 
                        + e.getCause() 
                        +'\n'
                        + '\n'
                        + '[Trigger Context]'
                        + '\n' 
                        + JSON.serialize(triggerContext) 
                        +'\n' 
                        + '\n'
                        + '[Extra Context]'
                        + '\n';
        
        for (string ctx : extraContext.keySet()) {
            log.Cause__c = log.Cause__c + '--- ' + ctx + ' ---\n' + JSON.serialize(extraContext.get(ctx)) + '\n\n';
        }
        
        log.Message__c = log.Message__c.left(100000);
        
        log.Stack_Trace__c = log.Stack_Trace__c.left(100000);
        
        log.Cause__c = log.Cause__c.left(100000);
        
        insert log;
    }

    /**
     -- log missing record in before insert
     */
    private static void logMissing(List<SObject> triggerContext, Map<String, SObject> extraContext) 
    {
        Logger_Data_Pool__c log = new Logger_Data_Pool__c();
        
        log.Name = 'Missing Record_' + DateTime.now().format('dd/MM/yyyy HH:mm');
        
        log.Instance__c = 'EnvelopeStatus';
        
        log.Type__c = 'Before Insert';
        
        log.Cause__c =  '[Trigger Context]' 
                        + '\n'
                        + JSON.serialize(triggerContext) 
                        + '\n'
                        + '\n' 
                        + '[Extra Context]'
                        + '\n';
        
        for (string ctx : extraContext.keySet()) 
        {
            log.Cause__c += '--- ' + ctx + ' ---\n' + JSON.serialize(extraContext.get(ctx)) + '\n\n';
        }
        
        log.Cause__c = log.Cause__c.left(100000);
        
        insert log;
    }
}