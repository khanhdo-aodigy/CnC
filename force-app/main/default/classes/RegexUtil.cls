/** *****
 * Description : Util class to capture common regex checking 
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                        Description
 * 20210305             HS@aodigy.com               Created Initial Version
 * 
** *****/
public inherited sharing class RegexUtil {

    public static Boolean isValidMobileSG( String mobile_input )
    {
        String sgMobileRegex = '65[6|8|9]\\d{7}|\\+65[6|8|9]\\d{7}|\\+65\\s[6|8|9]\\d{7}';
        Pattern sgMobilePattern = Pattern.compile( sgMobileRegex );
        Matcher sgMobileMatcher = sgMobilePattern.matcher( mobile_input );
        return sgMobileMatcher.matches();
    }


    public static Boolean isValidEmail( String email_input )
    {
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern emailPattern = Pattern.compile( emailRegex );
        Matcher emailMatcher = emailPattern.matcher( email_input );
        return emailMatcher.matches();
    }

}