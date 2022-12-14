/*  Allows programmatic retrieve of data generated by any report for further processing in Apex or attaching to emails.
Uses Page.getContent() by default but in future/scheduled context will fall back to REST GET (remember to add "Remote Site Setting" if you plan to use it like that).

Use with care, you might still hit heap size limits with bigger reports!
Of course it can fail anytime Salesforce changes the layout of report pages, their output or parameters that can be passed via URL etc.
*/
// TODO: add support for query string pv0 etc. params for runtime filtering?
public with sharing class KIAWarehousePaymentInfoReportController {
    public static final Set<String> validEncodings = new Set<String>{'UTF-8','MS932','Shift_JIS','GB18030','GB2312','Big5','EUC_KR','UTF-16','Big5-HKSCS','x-SJIS_0213'};
        public static final Set<String> validformats = new Set<String>{'printable','csv','xls'};
            public static final Set<String> validShowDetails = new Set<String>{'yes','no',null};
                
                public static String mockOutput; // to be used in unit test. getContent() can't be called in test, 
    // REST way means need to make a mock anyway (but then you'd need remote site setting for both production and all possible sandboxes...)
    
    // Basic options.
    public Id reportId {get;set;}
    public String format {get;set;} // See list above for available options
    
    public Boolean prettify {get;set;} /* If set we'll attempt to return only the core info without:
- headers: who run it, when, which company, what's the report title, filters used
- footers: "Confidential Information - Do Not Distribute" etc.
*/
    
    // Option for format = 'printable' only
    public String showDetails {get;set;} // like "show details" button. See list above for available options; null = fallback to however the report was saved
    
    // Option for format 'csv' and 'xls'
    public String encoding {get;set;} // See list above for available options
    
    private String requestUrl, output;
    private Boolean restRequestNeeded;
    
    public KIAWarehousePaymentInfoReportController(){
        prettify = true;
        restRequestNeeded = System.isFuture() || System.isScheduled(); // System.isBatch() too?
    }
    
    public String getOutput(){
        if(requestUrl == null) {
            getRequestUrl();
        }
        fetchData();
        if(prettify && output != null && output.length() > 0){
            prettify();
        }
        return output;
    }
    
    public String getRequestUrl(){
        sanitizeInput();
        requestUrl = '/' + reportId + '?';
        if(format == 'printable'){
            requestUrl += 'excel=1' + (showDetails != null ? '&details=' + showDetails : '');
        } else {
            requestUrl += 'export=1&xf=' + format + '&enc=' + encoding;
        }
        if(restRequestNeeded) {
            requestUrl = URL.getSalesforceBaseUrl().toExternalForm().replace('http:', 'https:') + requestUrl;
        }
        return requestUrl;
    }
    
    private void sanitizeInput(){
        if(reportId == null){
            throw new ReportExportException('Missing argument: reportId');
        } else  if(!String.valueOf(reportId).startsWith('00O')) {
            // Length - based check can be skipped - it will fail on attempt to assign too long string to Id variable
            throw new ReportExportException('Suspicious reportId: ' + reportId + '. Were you trying to export something other than a report?');
        }
        if(encoding == null || !validEncodings.contains(encoding)){
            encoding = 'UTF-8';
        }
        if(format == null || !validformats.contains(format)){
            format = 'xls';
        }
        if(!validShowDetails.contains(showDetails)){
            showDetails = null;
        }
    }
    
    private void fetchData(){
        if(Test.isRunningTest()){
            output = mockOutput;
        } else  if(restRequestNeeded){
            HttpRequest req = new HttpRequest();
            req.setEndpoint(requestUrl);
            req.setMethod('GET');
            req.setHeader('Cookie','sid=' + UserInfo.getSessionId());
            output = new Http().send(req).getBody();
        } else {
            output = new PageReference(requestUrl).getContent().toString();
        }
    }
    
    private void prettify(){
        Integer startIndex = 0;
        Integer stopIndex = output.length();
        
        if(format == 'csv'){
            stopIndex = output.lastIndexOf('\n\n\n');   // "lastindexOf" because we look for last occurence of 3 x "Enter". So it should work even if there's data in report (textarea?) that contains such line
        } else {
            String endToken = '';
            if(format == 'xls'){
                startIndex = output.indexOf('<table>');
                endToken = '</table>';
            } else if(format == 'printable'){
                startIndex = output.indexOf('<div id="">');
                endToken = '</table>\n</div>';
            }
            stopIndex = output.lastIndexOf(endToken) + endToken.length();
        }
        if(startIndex != -1 && stopIndex != -1) {
            output = output.substring(startIndex, stopIndex);
        }
    }
    
    public class ReportExportException extends Exception{}
}