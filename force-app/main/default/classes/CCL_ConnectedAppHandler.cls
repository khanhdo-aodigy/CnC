/** *****
 * Description : CCL Connected App Handler
 *               Contains methods for extending the behavior of CCL connected app.
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                        Description
 * 20210920             khanh.do@aodigy.com         Created Initial Version
 * 
** *****/
public class CCL_ConnectedAppHandler extends Auth.ConnectedAppPlugin {
    public override Map<String,String> customAttributes(Id userId, Id connectedAppId, Map<String,String> formulaDefinedAttributes, Auth.InvocationContext context)    {
        User u = [ SELECT Id, AccountId, ContactId
                   FROM User
                   WHERE Id = :userId            
        ];

        Person_Account_Profiling__c profiling = AccountUtil.createProfiling('CCL_Person_Account_Profiling_RT', new Account(Id = u.AccountId));
        formulaDefinedAttributes.put('Account_Profiling_ID', profiling.Id);
        return formulaDefinedAttributes;
    }
}