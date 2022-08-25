public with sharing class ADGLIB_CommaSeparatedValuesFileReader
{
    private String fileContent;

    private Boolean hasHeader = true;

    private List<List<String>> table = new List<List<String>>();

    public ADGLIB_CommaSeparatedValuesFileReader(String fileContent, Boolean hasHeader)
    {
        this.fileContent    = fileContent;
        System.debug('fileContent :: ' + JSON.serialize(fileContent));
        this.hasHeader      = hasHeader;
    }

    /**
     * ====================================================================================================================
     * start reading @fileContent and return @this for chaining
     * ====================================================================================================================
     */
    public ADGLIB_CommaSeparatedValuesFileReader read()
    {
        this.prevalidate();
        this.consume();
        this.validate();
        return this;
    }

    public List<List<String>> exportResult()
    {
        return this.table;
    }

    public List<Map<String, String>> exportResultAsMap()
    {
        System.assert(this.hasHeader, 'File reader must be set @hasHeader=true before getting result as map');

        System.assert(this.table.size() > 1, 'No consumed data for exporting');

        List<Map<String, String>> result = new List<Map<String, String>>();

        // TODO: perform validate
        System.debug('table before exporting :: ' + JSON.serialize(this.table));
        
        List<String> headers = this.table[0];

        for (Integer i = 1; i < this.table.size(); i++)
        {

            Map<String, String> row = new Map<String, String>();

            for (Integer j = 0; j < headers.size(); j++)
            {
                
                row.put(headers[j], table[i][j]);
            }

            result.add(row);
        }

        System.debug('table after exporting :: ' + JSON.serialize(result));

        return result;
    }

    /**
     * ====================================================================================================================
     * validate csv format before tokenized
     * ====================================================================================================================
     */
    private void prevalidate()
    {
        // check if csv have content
        System.assert(String.isNotBlank(this.fileContent), 'Empty file content');

        // check if csv have data
        Integer minLine = hasHeader? 1 : 0;

        System.assert(this.fileContent.split('\n').size() > minLine, 'File do not have data to proceed');

    }

    /**
     * ====================================================================================================================
     * consume @fileContent and arrange data into @table
     * ====================================================================================================================
     */
    private void consume()
    {
        this.sanitizeContentWithinDoubleQuote();

        this.sanitizeSpecialCharacters();

        this.handleEmptyCell();

        this.tokenize();
    }

    /**
     * ====================================================================================================================
     * for content within double quote, sanitize comma by replacing it with comma anchor string
     * ====================================================================================================================
     */
    private void sanitizeContentWithinDoubleQuote()
    {
        final Pattern DOUBLE_QUOTE_PATTERN = Pattern.compile(DOUBLE_QUOTE_REGEX);

        final Matcher DOUBLE_QUOTE_MATCHER = DOUBLE_QUOTE_PATTERN.matcher(this.fileContent);
        
        while (DOUBLE_QUOTE_MATCHER.find())
        {
            String content = DOUBLE_QUOTE_MATCHER.group(1);
            
            if (content.contains(','))
            {
                String replacedContent = content.replace(COMMA, COMMA_ANCHOR);

                this.fileContent = this.fileContent.replace(content, replacedContent);
            }

        }

        System.debug(this.fileContent.split(',').size());
    }

    /**
     * ====================================================================================================================
     * sanitize special characters from @fileContent
     * ====================================================================================================================
     */
    private void sanitizeSpecialCharacters()
    {
        this.fileContent = this.fileContent.remove('\r');
    }

    /**
     * ==============================================================================================================================
     * empty cell will have 2 consecutive comma, add an extra space between them so that the splitting of @tokenize can work properly
     * ==============================================================================================================================
     */
    private void handleEmptyCell()
    {
        this.fileContent = this.fileContent.replace(',,', ', ,');
    }

    /**
     * start spliting @fileContent and arrange data into @table
     */
    private void tokenize()
    {
        List<String> lines = this.fileContent.split('\n');

        for (String line : lines)
        {
            List<String> cells = line.split(',');

            List<String> row = new List<String>();

            for (String cell : cells)
            {
                // erase double quote if any
                cell = cell.remove(DOUBLE_QUOTE);

                // revert comma anchor string back to comma
                cell = cell.replace(COMMA_ANCHOR, COMMA);

                row.add(cell);
            }

            this.table.add(row);
        }
    }

    /**
     * ====================================================================================================================
     * validate csv format after tokenized
     * ====================================================================================================================
     */
    private void validate()
    {

    }

    
    private static final String DOUBLE_QUOTE_REGEX = '"([^"]*)"';
    
    private static final String NOW = String.valueOf(Datetime.now().getTime());
    private static final String DOUBLE_QUOTE = '"';
    private static final String DOUBLE_QUOTE_ANCHOR = String.format(':quote{0}:', new List<String> { NOW });
    
    private static final String COMMA = ',';
    private static final String COMMA_ANCHOR = String.format(':comma{0}:', new List<String> { NOW });
}
