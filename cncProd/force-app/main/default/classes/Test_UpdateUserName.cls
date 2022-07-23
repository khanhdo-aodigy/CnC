@isTest(seeAllData=true)
public class Test_UpdateUserName {

    static testMethod void testUser()
    {
        Test.startTest();
        User Testuser =  new User(Username='test_old@abc.com',LastName='test', Email='test_old@abc.com', Alias='testrun', TimeZoneSidKey='America/Denver', LocaleSidKey='en_GB', 
                                  EmailEncodingKey='UTF-8', ProfileId='00e28000000s2hr', LanguageLocaleKey='en_US');
        insert Testuser;
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/UpdateUserName/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        
        UpdateUserName.updateCarName('test_old@abc.com','test_new@abc.com');
        //System.assert(response.statusCode == 200);
        Test.stopTest();
    }
}