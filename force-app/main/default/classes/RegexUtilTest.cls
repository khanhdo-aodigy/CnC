/** *****
 * Description : Test class for RegexUtil
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                        Description
 * 20210310             khanh.do@aodigy.com         Created Initial Version
 * 
** *****/
@isTest
private class RegexUtilTest {
    
	@isTest
    private static void testIsValidMobileSG_ValidMobile_ReturnTrue() {
        String mobileString = '6588889999';
        Boolean actualResult = RegexUtil.isValidMobileSG(mobileString);
        System.assertEquals(true, actualResult);            
    }
    
    @isTest
    private static void testIsValidMobileSG_InvalidMobile_ReturnFalse() {
        List<String> mobileStrings = new List<String>{'658888', '8488889999', '65888899AB'};
        for(String mobile: mobileStrings){
            Boolean actualResult = RegexUtil.isValidMobileSG(mobile);
        	System.assertEquals(false, actualResult);
        }                    
    }
    
    @isTest
    private static void testIsValidEmail_ValidEmail_ReturnTrue() {
        String mobileString = 'test@domain.com';
        Boolean actualResult = RegexUtil.isValidEmail(mobileString);
        System.assertEquals(true, actualResult);            
    }
    
    @isTest
    private static void testIsValidEmail_InvalidEmail_ReturnFalse() {
        List<String> emailStrings = new List<String>{'abczyz', 'mymaildomain.com', 'mymail$domain.com'};
        for(String email: emailStrings){
            Boolean actualResult = RegexUtil.isValidEmail(email);
        	System.assertEquals(false, actualResult);
        }                    
    }
}