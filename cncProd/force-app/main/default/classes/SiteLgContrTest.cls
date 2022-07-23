/**
 * An apex page controller that exposes the site login functionality
 *
 */
@IsTest global with sharing class SiteLgContrTest {
    @IsTest(SeeAllData=true) global static void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        SiteLgContr slct = new SiteLgContr();
        slct.siteLoginLg();                        
        System.assertEquals(slct.siteLoginLg(),'test1');                           
    }
	
}