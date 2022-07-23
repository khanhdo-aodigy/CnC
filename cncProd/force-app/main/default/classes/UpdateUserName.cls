@RestResource(urlMapping='/UpdateUserName/v1/*')
global with sharing class UpdateUserName {
@HttpPost
global static Map<String, String> updateCarName(String oldUserName, String newUserName) 
{
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
       User[] userList;
      User user;
        String ErrorCode;
        String Errormsg;
        String jsonS;
        Map<String, String> responseMap =   new Map<String, String>();

 
JSONGenerator gen = JSON.createGenerator(true);

   try
    { 

userList = [SELECT Id FROM User WHERE Username = :oldUserName]; 
    
    
        user = userList[0];
        user.Username = newUserName;
        user.Email = newUserName;
        update user;
        gen.writeStartObject();     
        gen.writeStringField('UId','1001'); 
        gen.writeStringField('Status','Success');      
        gen.writeEndObject();   
        jsonS = gen.getAsString();
        res.statusCode=200;
        responseMap.put('Status', 'Success');
              
    }
    catch (DmlException e)
    { 
       Errormsg='Something went wrong. Please try again.';
       res.statusCode=400;
       throw new DmlException(Errormsg);      
    }  
        
    return responseMap;
    }
}