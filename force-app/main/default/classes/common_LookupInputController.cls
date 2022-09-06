/*==========================================================================================================================================================================
 * Controller for common_LookupInput component
 * Created By: Aodigy Team
 * Create Date: Aug 2022
 * History
 *          DATE::                              BY::                                TICKET::                                            CHANGELOG
 *          18 Aug 2022                         dangphap.mai@aodigy.com             US-Ship-000008                                       init
 * ========================================================================================================================================================================== 
 */
public inherited sharing class common_LookupInputController
{
    /**
     * Simplify entry for searching with @searchKey and @conditions
     * @param objectName API name of object for searching
     * @param searchFields list of fields to apply @searchKey filtering
     * @param searchKey searching keyword
     * @param displayFields list of fields to return on result
     * @param conditions extra conditions beside @searchKey
     */
    @AuraEnabled(cacheable=true)
    public static List<SObject> simpleSearch(String objectName, List<String> searchFields, String searchKey, List<String> displayFields, String conditions)
    {
        SearchInputs input      = new SearchInputs();
        input.objectName        = objectName;
        input.searchFields      = searchFields;
        input.searchKey         = searchKey;
        input.displayFields     = displayFields;
        input.conditions        = conditions;

        return search(input);
    }

    /**
     * Perform searching with @input
     * @TODO apply @enforceFLS, @enforeceSharingSetting and @enforceCRUD logic
     * @param input input for searching
     */
    @AuraEnabled(cacheable=true)
    public static List<SObject> search(SearchInputs input)
    {
        System.debug('Input for searching :: ' + input);

        if (input == null)
        {
            return null;
        }

        // unpack inputs
        String objectName           = input.objectName;
        List<String> searchFields   = input.searchFields;
        String searchKey            = input.searchKey;
        List<String> displayFields  = input.displayFields;
        String conditions           = input.conditions;

        System.debug(displayFields);

        // pre-check on input
        if (objectName == null || String.isEmpty(objectName))
        {
            return null;
        }

        if (searchKey == null || String.isEmpty(searchKey))
        {
            return null;
        }

        if (searchFields == null || searchFields.isEmpty())
        {
            searchFields = new List<String> { 'Name' };
        }

        if (displayFields == null || displayFields.isEmpty())
        {
            displayFields = new List<String> { 'Id, Name' };
        }
        
        // search
        String soql = String.format('SELECT {0} FROM {1} WHERE {2}', new List<String>{
            String.join(displayFields, ', '),
            objectName,
            generateSearchingCondition(searchFields, searchKey, conditions)
        });

        System.debug(soql);

        return Database.query(soql);
    }

    /**
     * Generate searching condition clause
     * @param searchFields list of fields to apply @searchKey filtering
     * @param searchKey searching keyword
     * @param conditions extra conditions beside @searchKey
     */
    private static String generateSearchingCondition(List<String> searchFields, String searchKey, String conditions)
    {
        String result = '';

        for (String field : searchFields)
        {
            // add OR condition
            result += String.isNotEmpty(result)? ' OR ' :'';
            
            // add main searching condition
            result += String.format('{0} LIKE {1}', new List<String> {
                field, '\'%' + searchKey + '%\''
            });
        }

        if (String.isNotEmpty(conditions))
        {
            result = '(' + result + ')' + ' AND ' + conditions;
        }

        return result;
    }

    public class SearchInputs
    {
        @AuraEnabled
        public String objectName;

        @AuraEnabled
        public List<String> searchFields;

        @AuraEnabled
        public String searchKey;

        @AuraEnabled
        public List<String> displayFields;

        @AuraEnabled
        public String conditions;

        @AuraEnabled
        public Boolean enforceFLS;

        @AuraEnabled
        public Boolean enforeceSharingSetting;

        @AuraEnabled
        public Boolean enforceCRUD;
    }
}