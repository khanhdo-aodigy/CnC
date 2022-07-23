@isTest
private class Test_BusinessHoursUtility {

    @isTest
    public static void TestGetNextBusinessDtTm (){
        DateTime targetDate = datetime.now();
       	BusinessHoursUtility.GetNextBusinessDtTm(targetDate);
    }
    
    @isTest
    public static void TestGetPrvWorkingDay (){
        DateTime targetDate = datetime.now();
       	BusinessHoursUtility.getPreviousWorkingDay(targetDate);
    }
 
    @isTest
    public static void TestGetBusiHrs(){
        Date startDate = date.today();
        Date endDate = date.today();
       	BusinessHoursUtility.GetBusinessHrs(startDate, endDate);
    }
    
    @isTest
    public static void TestIsBusiDtTm (){
        DateTime targetDate = datetime.now();
       	BusinessHoursUtility.IsBusinessDtTm(targetDate);
    }
    
    @isTest
    public static void TestAddWorkingDays (){
        DateTime StartDate = datetime.now();
        Integer NoofDays = 2;
       	BusinessHoursUtility.addWorkingDays(startDate, NoofDays);
    }
    
}