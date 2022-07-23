/** ******
 * Description: Utility class for callouts to Tooling API
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20220420           TPhan@aodigy.com    Created Initial Version. 
** ******/

public class ToolingAPIUtility 
{
    @future(callout = true)
    public static void updateModelGlobalValueSet(List<String> modelNames)
    {
        try
        {
            RequestBody reqBody                = new RequestBody();
            Metadata mtd                       = new Metadata();
            List<customValue> existingValueSet = new List<customValue>();
            String fullName = '';
    
            String baseURL    = URL.getSalesforceBaseUrl().toExternalForm();
            String apiVersion = getNewestAPIVersion(baseURL);
            String apiName    = 'Model';
            String queryURL   = '/services/data/v' + apiVersion + '/tooling/query?q=SELECT+Id,MasterLabel,Description,FullName,Metadata+FROM+GlobalValueSet+WHERE+DeveloperName=\'' + apiName + '\'';  
            
            String res           = sendHttpRequest(baseURL + queryURL, 'GET', null, false);
            ResponseBody resBody = (ResponseBody) JSON.deserialize(res, ResponseBody.class);
            queryURL             = resBody.records.get(0).attributes.url;
            fullName             = resBody.records.get(0).FullName;
            existingValueSet     = resBody.records.get(0).Metadata.customValue;
    
            for(String name : modelNames)
            {
                existingValueSet.add(new CustomValue(null, null, null, name, null, name));
            }
    
            System.debug('GlobalPicklistValue ::: ' + existingValueSet);
    
            mtd.customValue  = existingValueSet;
            mtd.masterLabel  = fullName;
            mtd.sorted       = true;
            reqBody.FullName = fullName;
            reqBody.Metadata = mtd;
    
            System.debug('RequestBody ::: ' + JSON.serialize(reqBody));
    
            sendHttpRequest(baseURL + queryURL + '?_HttpMethod=PATCH', 'POST', JSON.serialize(reqBody), true);
        }
        catch (Exception e)
        {
            loggerDataPool.buildLogDataPool('ToolingAPIUtility.updateModelGlobalValueSet', e);
        }
    }

    public static String getNewestAPIVersion(String baseURL)
    {
        String res                       = sendHttpRequest(baseURL + '/services/data', 'GET', null, false);
        List<VersionResponse> parsedList = (List<VersionResponse>) JSON.deserialize(res, List<VersionResponse>.class); 
        String latestVersion             = '0'; 
        
        for (VersionResponse item : parsedList)
        {
            if (latestVersion.compareTo(item.version) < 0)
            {
                latestVersion = item.version; 
            }
        }

        return latestVersion;
    }

    public static String sendHttpRequest(String endpoint, String method, String reqBody, Boolean doInsert)
    {
        Http http        = new Http();
        HttpRequest req  = new HttpRequest();
        HttpResponse res = new HttpResponse();

        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setHeader('Content-Type', 'application/json');
        if (String.isNotBlank(reqBody)) req.setBody(reqBody);

        res = http.send(req);

        if (doInsert)
        {
            serviceDataPool.buildServiceDataPoolHttp('updateModelGlobalValueSet', 'ToolingAPIUtility', '', req, res);
        }

        return res.getBody();
    }

    public class VersionResponse
    {
        public String label; 
        public String url; 
        public String version; 
    }

    public class ResponseBody
    {
        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public Object queryLocator;
        public String entityTypeName;
        public List<Record> records;
    }

    public class Record 
    {
		public Attribute attributes;
		public String Id;
		public String MasterLabel;
		public Object Description;
		public String FullName;
		public Metadata Metadata;
    }

    public class Metadata   
    {
        public List<CustomValue> customValue;
		public Object description;
		public String masterLabel;
		public Boolean sorted;
		public Object urls;
    }

    public class Attribute
    {
		public String type;
		public String url;
    }

    public class RequestBody
    {
        public Metadata Metadata;
        public String FullName;
    }

    public class Records 
    {
		public Attribute attributes;
		public String Id;
		public String MasterLabel;
		public Object Description;
		public String FullName;
		public Metadata Metadata;
    }

    public class customValue
    {
        public String color;
        public String description;
        public Boolean isActive;
        public String label;
        public String urls;
        public String valueName;

        public customValue(String color, String description, Boolean isActive, String label, String urls, String valueName)
        {
            this.color = color;
            this.description = description;
            this.isActive = isActive; 
            this.label = label;
            this.urls = urls;
            this.valueName = valueName;
        }
    }
}