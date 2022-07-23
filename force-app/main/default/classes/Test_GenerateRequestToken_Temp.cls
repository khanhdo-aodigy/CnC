@isTest(SeeAllData=true)
public class Test_GenerateRequestToken_Temp {
public static testmethod void Test_ReqToken() 
{
 	Test.startTest();
    String TestToken = GenerateRequestToken_Temp.getRequestToken();
    System.assert(TestToken=='test_token');
    Test.stopTest();
}
}