public without sharing class UpdatePortalUserQueueable implements Queueable
{
    public Set<Id> accountIdSet = new Set<Id>();

    public UpdatePortalUserQueueable( Set<Id> accountIds ) 
    {
        accountIdSet = accountIds;
    }

    public void execute(QueueableContext con)
    {
        System.debug('@@@@DEBUG UpdatePortalUserQueueable :: accountIdSet = ' + accountIdSet.size() + ' --- ' + accountIdSet );
        try{
            if( accountIdSet <> null && !accountIdSet.isEmpty() )
            {   
                List<User> portalUsers = new List<User>();
                portalUsers = [ SELECT Id, AccountId, Account.Salutation, Account.PersonMobilePhone, Salutation__c, MobilePhone
                                FROM User
                                WHERE AccountId IN :accountIdSet
                                AND Account.IsPersonAccount = true
                            ];
                System.debug('before update portalUsers =' + portalUsers);
                for(User portalUser: portalUsers) {
                    portalUser.Salutation__c = String.isNotBlank(portalUser.Account.Salutation) ? portalUser.Account.Salutation : portalUser.Salutation__c;
                    portalUser.MobilePhone = String.isNotBlank(portalUser.Account.PersonMobilePhone) ? portalUser.Account.PersonMobilePhone : portalUser.MobilePhone;
                }
                System.debug('after update portalUsers =' + portalUsers);
                if(!Test.isRunningTest()) {
                    update portalUsers;
                }
            }
        } catch (Exception ex) {
            loggerDataPool.buildLogDataPool('UpdatePortalUserQueueable', ex);
        }
    }
}