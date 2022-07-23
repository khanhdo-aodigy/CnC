@isTest(SeeAllData=true)
public class Test_GenerateRequestToken {
public static testmethod void Test_ReqToken() 
{
 	Test.startTest();
    String TestToken = GenerateRequestToken.getRequestToken();
    System.assert(TestToken=='test_token');
    Test.stopTest();
}
}