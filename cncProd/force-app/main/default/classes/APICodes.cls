/**************************************************
 * Class Name: APICodes
 * Description: Class to consolidate all SF API Messages.
 * 
 * Revision History
 * Developer Name       Date        Description
 * CGaylan              10
 **************************************************/  
public without sharing class APICodes {
    
    /******* Guest Booking *******/
    //Vehicle Number if not found
    public static final String ERR_100 = 'Err100-SF';
    
    //Vehicle Number is found, but there is no Mobile Number found in the Contact record
    public static final String ERR_101 = 'Err101-SF';
    
    //Vehicle Number is found, but the Mobile Number is not matching with the Mobile Number of the Contact record
    public static final String ERR_102 = 'Err102-SF';    
    
    //Vehicle Number is found, but is associated to one more than one car
    public static final String ERR_103 = 'Err103-SF';
    
    //Vehicle Number and Mobile Number are blank
    public static final String ERR_104 = 'Err104-SF';  
        
}