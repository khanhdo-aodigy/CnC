global with sharing class DeletePACleanUserDataBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    private final List<PA_Child_Object__mdt> childObjects = [SELECT Object_API_Name__c, Account_Lookup_API__c FROM PA_Child_Object__mdt WHERE Excluded__c = false];

    private List<Account> pasToBeDeleted     = new List<Account>();                 // Process and do logging for successful deleted PAs
    private List<User> usersToBeDeactivated  = new List<User>();                    // Process and do logging for successful deactivated Users
    private List<User> usersToBeRestored     = new List<User>();                    // Process and do logging for successful restored Users
    private List<String> errMsgs             = new List<String>();                  // Logging batch error result
    private Map<String, List<String>> result = new Map<String, List<String>>();     // Logging batch successful result
    private List<Logger_Data_Pool__c> logs   = new List<Logger_Data_Pool__c>();
    private Set<String> userIds;                                                    // For testing specific user id

    global DeletePACleanUserDataBatch() { }

    global DeletePACleanUserDataBatch(Set<String> userIds) {
        this.userIds = userIds;
    }

    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new DeletePACleanUserDataBatch());
    }

    global Database.QueryLocator start(Database.Batchablecontext bc) {
        String queryStr = 'SELECT Id, Alias, LastName, UserName, Email, Deletion_Request_Date__c, Deactivate_C_C_Account__c, IsActive FROM User WHERE IsActive = true AND Deactivate_C_C_Account__c = true AND Profile.Name = \'End User\'';

        if (userIds != null && userIds.size() > 0) {
            queryStr += ' AND Id IN :userIds ';
        }

        return Database.getQueryLocator(queryStr);
    }

    global void execute(Database.BatchableContext jobId, List<User> scope) {
        Date today                      = Date.today();
        // List<User> usersToBeDeactivated = new List<User>();
        // List<User> usersToBeRestored    = new List<User>();
        Map<String, User> userByEmails  = new Map<String, User>();
        Map<String, User> userByIds     = new Map<String, User>();

        for (User u : scope) {
            userByEmails.put(u.Email, u);
            userByIds.put(u.Id, u);
        }

        Map<Id, Account> paByIds = new Map<Id, Account>([SELECT Id, PersonEmail, Deletion_Request_Date__pc, IsCustomerPortal, RecordType.Name
                                                        FROM Account
                                                        WHERE IsPersonAccount = true AND PersonEmail IN :userByEmails.keySet()
                                                        ORDER BY PersonEmail NULLS LAST]);

        Set<String> paIdsToBeChecked = new Set<String>();
        for (Id paId : paByIds.keySet())
        {
            Account acc = paByIds.get(paId);

            if (acc.RecordType.Name == 'Customer')
            {
                User u = IDPAppService.reActivatedUser(userByEmails.get(acc.PersonEmail));
                usersToBeRestored.add(u);
            }
            else
            {
                paIdsToBeChecked.add(paId);
            }
        }

        system.debug('paIdsToBeChecked :: ' + paIdsToBeChecked);

        // If PA has any child object's records
        // PA and PA's user will be immediately restored
        Set<String> paIdsToBeRestored = new Set<String>();
        for (PA_Child_Object__mdt childObj : childObjects) {
            String accFieldName = childObj.Account_Lookup_API__c;

            if (String.isBlank(accFieldName)) continue;

            String query = ' SELECT count(Id) ';
            if (String.isNotBlank(accFieldName))
            {
                query += ', ' +  accFieldName;
            }

            query += ' FROM ' + childObj.Object_API_Name__c;

            if (childObj.Object_API_Name__c != 'Referral__c')
            {
                query += ' WHERE ' +  accFieldName + ' IN :paIdsToBeChecked ';
            }
            query += ' GROUP BY ' + accFieldName;

            List<AggregateResult> arChildObjGroupedResults = Database.query(query);

            if (arChildObjGroupedResults.size() == 0) continue;

            for (AggregateResult ar : arChildObjGroupedResults)
            {
                paIdsToBeRestored.add((Id)ar.get(childObj.Account_Lookup_API__c));
            }
        }

        // Handle seperately for Referral__c object
        List<Referral__c> referrals = [SELECT Referrer_Account__c, Referee_Account__c
                                       FROM Referral__c
                                       WHERE Referrer_Account__c IN :paIdsToBeChecked
                                         OR  Referee_Account__c  IN :paIdsToBeChecked];
        for (Referral__c ref : referrals)
        {
            if (!paIdsToBeRestored.contains(ref.Referrer_Account__c) && !paIdsToBeRestored.contains(ref.Referee_Account__c))
            {
                if (String.isNotBlank(ref.Referrer_Account__c)) 
                {
                    paIdsToBeRestored.add(ref.Referrer_Account__c);
                }
                if (String.isNotBlank(ref.Referee_Account__c))
                {
                    paIdsToBeRestored.add(ref.Referee_Account__c);
                }
            }
        }
        system.debug('paIdsToBeRestored :: ' + paIdsToBeRestored);

        // PA Id that not exist in PA Ids to be restored will be PA Ids to be deactivated
        Set<String> paIdsToBeDeactivated = new Set<String>(paIdsToBeChecked);
        paIdsToBeDeactivated.removeAll(paIdsToBeRestored);

        system.debug('paIdsToBeDeactivated :: ' + paIdsToBeDeactivated);
        for (Id paId : paIdsToBeDeactivated)
        {
            Account acc      = paByIds.get(paId);
            User u           = userByEmails.get(acc.PersonEmail);
            Integer noOfDays = u.Deletion_Request_Date__c.daysBetween(today);
            system.debug('noOfDays :: ' + noOfDays);
            String alias;
            String email;
            String userNm;
            String lastNm;
            if (noOfDays > 14)
            {
                u.IsActive = false;
                alias  = 'dummy_' + u.Alias;
                email  = 'dummy_' + u.Email;
                userNm = 'dummy_' + u.Username;
                lastNm = 'Dummy_' + u.LastName;
                u.Alias    = alias.length() < 8 ? alias : alias.substring(0,8);
                u.Email    = email.length() < 80 ? email : email.substring(0,80);
                u.Username = userNm.length() < 80 ? userNm : userNm.substring(0,80);
                u.LastName = lastNm.length() < 8 ? lastNm : lastNm.substring(0,8);

                usersToBeDeactivated.add(u);
                pasToBeDeleted.add(acc);
            }
        }

        for (Id paId : paIdsToBeRestored)
        {
            Account acc = paByIds.get(paId);
            User u      = IDPAppService.reActivatedUser(userByEmails.get(acc.PersonEmail));
            usersToBeRestored.add(u);
        }

        system.debug('restored users: ' + usersToBeRestored);
        system.debug('deactivated users: ' + usersToBeDeactivated);
        system.debug('deleted PAs: ' + pasToBeDeleted);

        TriggerExclusion.excludeTrigger('User', true);
        if (usersToBeDeactivated.size() > 0)
        {
            try
            {
                List<String> succeedDeactivatedUsers = new List<String>();
                Database.SaveResult[] userDeactivatedResult = Database.update(usersToBeDeactivated, false);
                for (Integer i = 0; i < userDeactivatedResult.size(); i++)
                {
                    if (!userDeactivatedResult[i].isSuccess())
                    {
                        for (Database.Error err : userDeactivatedResult[i].getErrors())
                        {
                            errMsgs.add(userDeactivatedResult[i].Id + ' ' + err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                    else
                    {
                        succeedDeactivatedUsers.add(userDeactivatedResult[i].Id + ' -- ' + userByIds.get(userDeactivatedResult[i].Id).UserName);
                    }
                }
                result.put('Deactivate Users', succeedDeactivatedUsers);
            }
            catch (Exception e)
            {
                logs.add(new Logger_Data_Pool__c(Instance__c = 'De_Activate_User_C_C_Account_Exception', Message__c = JSON.serialize(e.getMessage())));
            }
        }

        if (usersToBeRestored.size() > 0)
        {
            OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'do-not-reply@ccc.cyclecarriage.com.sg' LIMIT 1];
            List<Messaging.SingleEmailMessage> notifiedUserEmails = new List<Messaging.SingleEmailMessage>();
            String subject = 'Your C&C Account and related information has been restored';

            try 
            {
                List<String> succeedRestoredUsers = new List<String>();
                Database.SaveResult[] userRestoredResult = Database.update(usersToBeRestored, false);
                for (Integer i = 0; i < userRestoredResult.size(); i++)
                {
                    if (!userRestoredResult[i].isSuccess())
                    {
                        for (Database.Error err : userRestoredResult[i].getErrors())
                        {
                            errMsgs.add(userRestoredResult[i].Id + ' ' + err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                    else
                    {
                        String userEmail = userByIds.get(userRestoredResult[i].Id).Email;

                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setOrgWideEmailAddressId(owa.Id);
                        mail.setToAddresses(new List<String>{userEmail});
                        mail.setSubject(subject);
                        String body = 'Please be informed that your C&C Account ' + userEmail + ' has been restored.';
                        mail.setPlainTextBody(body);
                        notifiedUserEmails.add(mail);

                        succeedRestoredUsers.add(userRestoredResult[i].Id + ' -- ' + userByIds.get(userRestoredResult[i].Id).UserName);
                    }
                }

                Messaging.sendEmail(notifiedUserEmails, false);

                result.put('Restored Users', succeedRestoredUsers);
            }
            catch (Exception e) 
            {
                logs.add(new Logger_Data_Pool__c(Instance__c = 'Restore_C_C_Account_Exception', Message__c = JSON.serialize(e.getMessage())));
            }
        }
        TriggerExclusion.excludeTrigger('User', false);

        if (errMsgs.size() > 0)
        {
            logs.add(new Logger_Data_Pool__c(Instance__c = 'Delete_PA_Clean_User_Data_Batch', 
                                             Message__c = JSON.serialize(errMsgs)));
        }

        if (logs.size() > 0)
        {
            insert logs;
        }
    }

    global void finish(Database.BatchableContext bc) {
        if (pasToBeDeleted.size() > 0)
        {
            System.enqueueJob(new DeletePACleanUserDataQueueable(pasToBeDeleted, errMsgs, logs, result));
        }
        else
        {
            sendFinishedEmail(errMsgs, result);
        }
    }

    public class DeletePACleanUserDataQueueable implements Queueable
    {
        public List<Account> pas;
        public List<String> errMsgs;
        public List<Logger_Data_Pool__c> logs;
        public Map<String, List<String>> result;

        public DeletePACleanUserDataQueueable(List<Account> pas, List<String> errMsgs, List<Logger_Data_Pool__c> logs, Map<String, List<String>> result)
        {
            this.pas     = pas;
            this.errMsgs = errMsgs;
            this.logs    = logs;
            this.result  = result;
        }

        public void execute(QueueableContext qc)
        {
            try
            {
                // Need to set IsCustomerPortal = false and update PA first
                TriggerExclusion.excludeTrigger('Account', true);

                Map<String, Account> paByIds = new Map<String, Account>();

                for (Account acc : pas)
                {
                    acc.IsCustomerPortal = false;

                    paByIds.put(acc.Id, acc);
                }
                update pas;

                Database.DeleteResult[] paResult = Database.delete(pas, false);

                List<String> succeedDeletedPAs = new List<String>();
                for (Integer i = 0; i < paResult.size(); i++)
                {
                    if (!paResult[i].isSuccess())
                    {
                        for (Database.Error err : paResult[i].getErrors())
                        {
                            errMsgs.add(paResult[i].Id + ' ' + err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                    else
                    {
                        succeedDeletedPAs.add(paResult[i].Id + ' -- ' + paByIds.get(paResult[i].Id).PersonEmail);
                    }
                }
                TriggerExclusion.excludeTrigger('Account', false);

                result.put('Deleted PAs', succeedDeletedPAs);
            }
            catch (Exception e)
            {
                logs.add(new Logger_Data_Pool__c(Instance__c = 'Delete_PA_C_C_Account_Exception', Message__c = JSON.serialize(e.getMessage())));
            }

            sendFinishedEmail(errMsgs, result);
        }
    }

    private static void sendFinishedEmail(List<String> errMsgs, Map<String, List<String>> result)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'thieudang.vu@aodigy.com'});
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.saveAsActivity = false;
        mail.setSubject('DeletePACleanUserDataBatch Run Result - ' + Datetime.now().format());
        String body;
        if (!errMsgs.isEmpty())
        {
            for (Integer i = 0; i < errMsgs.size(); i++)
            {
                body = 'DeletePACleanUserDataBatch Got Exception !!!\n';
                body += String.valueof(i + 1) + ' ' + errMsgs[i]+ '\r\n';
            }
        } 
        else
        {
            body = 'DeletePACleanUserDataBatch Successfully Run !!!\n';

            if (!result.isEmpty())
            {
                for (String key : result.keySet())
                {
                    body += ' - ' + key + ':\n';
                    for (String batchResult : result.get(key))
                    {
                        body += batchResult;
                    }
                    body += '\n';
                }
            }
            else
            {
                body += 'No PAs and Users to be proccessed.';
            }
        }

        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
}