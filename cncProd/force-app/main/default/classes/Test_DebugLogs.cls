@isTest(SeeAllData=true)
public class Test_DebugLogs {

    public static testmethod void test_DebugLogs() 
    {
        List<String> lst_Success = new List<String>();
        List<String> lst_Error = new List<String>();
        lst_Success.Add('Test_Success');
        lst_Error.Add('Test_Fail');
        
        Test.startTest();
        DebugLogs.getDebugLogs('Test', lst_Success, lst_Error);
        Test.stopTest();
    }
}