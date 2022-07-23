@isTest
private class ADGLIB_CalloutUtilsTest {
	
    @isTest 
    private static void executeCallOutSuccess(){
        
   	 	ADGLIB_CalloutUtils callout = new ADGLIB_CalloutUtils();
        Test.setMock(HttpCalloutMock.class, new ADGLIB_CalloutMock());
		
		Map<String,List<String>> paramCol = new Map<String,List<String>>();
        Map<String,String> headerCol = new Map<String,String>();
        
        paramCol.put('param', new List<String>{'','','',''});                
        headerCol.put('header', 'header');
        
        callout.setReqEndpoint('http://www.aodigy.com')        	      
                .setReqMethod('POST')            
                .setHeader('Content-Type','application/json')
                .setParam('parameter1','')
                .setParam(paramCol)
                .setHeader('header1','valueHeader')
                .setHeader(headerCol)
                .setReqBody('body')
                .setTimeout(10000);
        
        System.Test.startTest();
        callout.send();
        System.Test.stopTest();
                
    }
    
    @isTest 
    private static void executeCallOutFailedNoMehtods(){
        
   	 	ADGLIB_CalloutUtils callout = new ADGLIB_CalloutUtils();
        Test.setMock(HttpCalloutMock.class, new ADGLIB_CalloutMock());
		
		Map<String,List<String>> paramCol = new Map<String,List<String>>();
        Map<String,String> headerCol = new Map<String,String>();
        
        paramCol.put('param', new List<String>{'','','',''});                
        headerCol.put('header', 'header');
        
        System.Test.startTest();
        Try{
          callout.setReqEndpoint('http://www.aodigy.com')        	      
                .setHeader('Content-Type','application/json')
                .setParam('parameter1','')
                .setParam(paramCol)
                .setHeader('header1','valueHeader')
                .setHeader(headerCol)
                .setReqBody('body')
                .setTimeout(10000);
          
          callout.send();
        }catch(Exception e){
          System.assert(e.getMessage().contains('No defined method'));
        }
        
        System.Test.stopTest();
                
    }
    

      @isTest 
    private static void executeCallOutFailedNoEndPoints(){
        
   	 	ADGLIB_CalloutUtils callout = new ADGLIB_CalloutUtils();
        Test.setMock(HttpCalloutMock.class, new ADGLIB_CalloutMock());
		
		Map<String,List<String>> paramCol = new Map<String,List<String>>();
        Map<String,String> headerCol = new Map<String,String>();
        
        paramCol.put('param', new List<String>{'','','',''});                
        headerCol.put('header', 'header');
        
        System.Test.startTest();
        Try{
          callout.setReqMethod('GET')      	      
                .setHeader('Content-Type','application/json')
                .setParam('parameter1','')
                .setParam(paramCol)
                .setHeader('header1','valueHeader')
                .setHeader(headerCol)
                .setReqBody('body')
                .setTimeout(10000);
          
          callout.send();
        }catch(Exception e){
          System.assert(e.getMessage().contains('No Endpoint'));
        }
        
        System.Test.stopTest();
                
    }


    @isTest 
    private static void executeCallOutFailedExceededTimeout(){
        
   	 	ADGLIB_CalloutUtils callout = new ADGLIB_CalloutUtils();
        Test.setMock(HttpCalloutMock.class, new ADGLIB_CalloutMock());
		
		Map<String,List<String>> paramCol = new Map<String,List<String>>();
        Map<String,String> headerCol = new Map<String,String>();
        
        paramCol.put('param', new List<String>{'','','',''});                
        headerCol.put('header', 'header');
        
        System.Test.startTest();
        Try{
          callout.setReqEndpoint('http://wwww.aodigy.com')
                .setReqMethod('GET')      	      
                .setHeader('Content-Type','application/json')
                .setParam('parameter1','')
                .setParam(paramCol)
                .setHeader('header1','valueHeader')
                .setHeader(headerCol)
                .convertBodyToJSON('')
                .setTimeout(140000);
          
          callout.send();
        }catch(Exception e){
          System.assert(e.getMessage().contains('Timeout exceeded, not more than 120000'));
        }
        
        System.Test.stopTest();
                
    }



}