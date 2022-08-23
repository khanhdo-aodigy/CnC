public without sharing class common_LookupInputController
{
    // TODO: switch to use input wrapper
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
            searchFields = new List<String> {'Name'};
        }

        if (displayFields == null || displayFields.isEmpty())
        {
            displayFields = new List<String> {'Id, Name'};
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