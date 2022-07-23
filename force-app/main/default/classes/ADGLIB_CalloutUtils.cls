public virtual class ADGLIB_CalloutUtils {

    public class calloutException extends Exception{}
    public HttpRequest req;
    public HttpResponse rep;
    public Http httpProtocol; 

    private String reqMethod;
    private String reqEndpoint;
    private String body;
    private Integer timeout;
    private Map<String,String> headerMap;
    private Map<String,List<String>>  paramMap;
    

    public ADGLIB_CalloutUtils() {
        this.rep = new HttpResponse();
        this.httpProtocol = new Http(); 
        this.headerMap = new Map<String,String>();
        this.paramMap = new Map<String,List<String>>();
    }

    public virtual ADGLIB_CalloutUtils setReqEndpoint(String endpoint){
        this.reqEndpoint = endpoint;
        return this;
    }
    public virtual ADGLIB_CalloutUtils setReqBody(String body){
        this.body = body;
        return this;
    }
    public virtual ADGLIB_CalloutUtils setReqMethod(String method){
        this.reqMethod = method;
        return this;
    }

    public virtual ADGLIB_CalloutUtils setTimeout(Integer timeout){
        this.timeout = timeout;
        return this;
    }

    public virtual ADGLIB_CalloutUtils setHeader(String key, String value){
        this.headerMap.put(key,value);
        return this;
    }
    public virtual ADGLIB_CalloutUtils setParam(String key, String value ){


        if( paramMap.get(key) == null ) {
            paramMap.put(key,  new List<String>() );
        }
        
        paramMap.get(key).add(value);

        return this;
    }

    public virtual ADGLIB_CalloutUtils setHeader(Map<String,String> collectionHeaders){

        for( String header : collectionHeaders.keySet() ) {                        
            this.headerMap.put(header,collectionHeaders.get(header));
        }               
        return this;

    }

    public virtual ADGLIB_CalloutUtils setParam(Map<String,List<String>>  collectionParams){
      for(String parameter : collectionParams.keySet() ) {                        
            this.paramMap.put(parameter,collectionParams.get(parameter));
        }               

        return this;
    }

    public virtual ADGLIB_CalloutUtils convertBodyToJSON(Object bodyObj){
        this.body = JSON.serialize(bodyObj);
        return this;
    }


    public virtual String buildParams(String key, List<String> values){        
        String paramString = '';
        Integer count = 0;        
        for(String value : values){
            count++;
            paramString += value;
            paramString += (count == values.size()) ? '' : ',';
        }
        return paramString;
    }


    public virtual String buildQueryStringParam(){
        
        String queryString = this.reqEndpoint;
                
        if(!paramMap.isEmpty()){
            queryString  += '?';        
            Integer count = 0;  
            for(String key : paramMap.keySet() ) {                                                                 
                if(count==0){
                	queryString += key + '=' + buildParams(key,paramMap.get(key));    
                }else{
                    queryString += '&' + key + '=' + buildParams(key,paramMap.get(key));    
                }
                count++;                
            }
        }   
              
        return queryString;
    }
    

public virtual ADGLIB_CalloutUtils builder(){
    
        if(String.isEmpty(this.reqMethod)){
		  throw new calloutException('No defined method');           
        }
		
        if(String.isEmpty(this.reqEndpoint)){
		  throw new calloutException('No Endpoint');           
        }
        
        if(this.timeout!=null && this.timeout > 120000){
		  throw new calloutException('Timeout exceeded, not more than 120000');           
		}
                      	        
        this.req = new HttpRequest();              
        this.req.setEndpoint(this.reqEndpoint);      
        this.req.setMethod(this.reqMethod);      
        
        if(this.body!=null){
        	this.req.setBody(this.body);
        }
              
        if(this.timeout!=null){
        	this.req.setTimeout(this.timeout);
        }
                       
        if(!headerMap.isEmpty())        
        {
            for(String header : headerMap.keySet() ) {                        
                this.req.setHeader( header , headerMap.get( header ) );
            }
        }  
        
        if(!paramMap.isEmpty()){
            this.req.setEndpoint(buildQueryStringParam());
        }
                        
        return this;
    }

    public virtual HttpResponse send() {               
        try {       
            this.builder();
            this.rep = httpProtocol.send(this.req);             
        } catch(calloutException ex) {
            throw new calloutException(ex.getMessage());    
        }
        return rep;
    }

}