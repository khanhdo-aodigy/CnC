@IsTest
private with sharing class common_LookupInputControllerTest
{
    @TestSetup
    private static void makeData()
    {
        // create some sample accounts
        List<Account> accounts = new List<Account>();

        accounts.add(new Account(
            Name = 'Sample Account 1',
            Phone = '123456789',
            AccountNumber = 'VIP125412652'
        ));

        accounts.add(new Account(
            Name = 'Sample Account 2',
            Phone = '987654321',
            AccountNumber = 'COMM65698565'
        ));

        insert accounts;
    }

    /**
     * Search by default field Name
     */
    @IsTest
    private static void searchByName1()
    {
        List<String> searchFields   = new List<String>();

        String searchKey            = 'Sample Account 1';

        List<String> displayFields  = new List<String> { 'Name', 'Phone', 'AccountNumber' };

        String conditions           = '';

        List<Account> result = common_LookupInputController.simpleSearch('Account', searchFields, searchKey, displayFields, conditions);

        // should return only 1 record
        System.assert(result.size() == 1, 'Number of accounts returned: ' + result.size());

        // should return sample account 1
        System.assert(result[0].AccountNumber == 'VIP125412652', 'Retrieved account number: ' + result[0].AccountNumber);
    }

    /**
     * Explicitly search by field Name
     */
    @IsTest
    private static void searchByName2()
    {
        List<String> searchFields   = new List<String>{ 'Name' };

        String searchKey            = 'Sample Account 2';

        List<String> displayFields  = new List<String> { 'Name', 'Phone', 'AccountNumber' };

        String conditions           = 'Phone = \'987654321\'';

        List<Account> result = common_LookupInputController.simpleSearch('Account', searchFields, searchKey, displayFields, conditions);

        // should return only 1 record
        System.assert(result.size() == 1, 'Number of accounts returned: ' + result.size());

        // should return sample account 1
        System.assert(result[0].AccountNumber == 'COMM65698565', 'Retrieved account number: ' + result[0].AccountNumber);
    }

    /**
     * Search with a keyword and extra conditions
     */
    @IsTest
    private static void searchWithCondition1()
    {
        List<String> searchFields   = new List<String>{ 'AccountNumber' };

        String searchKey            = 'COMM65698565';

        List<String> displayFields  = new List<String> { 'Name', 'Phone', 'AccountNumber' };

        String conditions           = 'Phone = \'123456789\'';

        List<Account> result = common_LookupInputController.simpleSearch('Account', searchFields, searchKey, displayFields, conditions);

        // should return no record
        System.assert(result.size() == 0, 'Number of accounts returned: ' + result.size());
    }

    /**
     * Search with a keyword and extra conditions
     */
    @IsTest
    private static void searchWithCondition2()
    {
        List<String> searchFields   = new List<String>{ 'Name' };

        String searchKey            = 'Sample Account';

        List<String> displayFields  = new List<String> { 'Name', 'Phone', 'AccountNumber' };

        String conditions           = 'Phone = \'123456789\'';

        List<Account> result = common_LookupInputController.simpleSearch('Account', searchFields, searchKey, displayFields, conditions);

        // should return only 1 record
        System.assert(result.size() == 1, 'Number of accounts returned: ' + result.size());

        // should return sample account 1
        System.assert(result[0].AccountNumber == 'VIP125412652', 'Retrieved account number: ' + result[0].AccountNumber);
    }

    /**
     * Search with no input
     */
    @IsTest
    private static void searchWithNullInput()
    {
        List<Account> result = common_LookupInputController.search(null);

        System.assert(result == null, 'Result is not null: ' + JSON.serialize(result));
    }

    /**
     * Search without any object name
     */
    @IsTest
    private static void searchWithNoObjectName()
    {
        List<Account> result = common_LookupInputController.search(new common_LookupInputController.SearchInputs());

        System.assert(result == null, 'Result is not null: ' + JSON.serialize(result));
    }

    /**
     * Search with no search key provided
     */
    @IsTest
    private static void searchWithNoSearchKey()
    {
        common_LookupInputController.SearchInputs input = new common_LookupInputController.SearchInputs();
        input.objectName = 'Account';

        List<Account> result = common_LookupInputController.search(input);

        System.assert(result == null, 'Result is not null: ' + JSON.serialize(result));
    }

    @IsTest
    private static void searchWithDefaultDisplayFields()
    {
        List<String> searchFields   = new List<String> { 'Name' };

        String searchKey            = 'Sample Account 1';

        List<String> displayFields  = new List<String>();

        String conditions           = '';

        List<Account> result = common_LookupInputController.simpleSearch('Account', searchFields, searchKey, displayFields, conditions);

        // should return only 1 record
        System.assert(result.size() == 1, 'Number of accounts returned: ' + result.size());

        // should return sample account 1 but without AccountNumber field
        System.debug('populated field:' + result[0].getPopulatedFieldsAsMap().containsKey('AccountNumber'));
        
        System.assert(!result[0].getPopulatedFieldsAsMap().containsKey('AccountNumber'), 'Account number retrirved');
        
        System.assert(result[0].Name == searchKey, 'Retrieved account name: ' + result[0].Name);
    }
}