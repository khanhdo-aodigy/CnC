/** ******
 * Description : Test class for LookUpComponentDesignAttribute.cls
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                            Description
 * 20200908             TP@aodigy.com                   Created Initial Version. 
 * 
***** **/

@isTest
private class LookUpComponentDesignAttributeTest 
{
	@isTest
    static void Test_getValues()
    {
		LookUpComponentDesignAttribute attr = new LookUpComponentDesignAttribute();
		VisualEditor.DynamicPickListRows rows = attr.getValues();  
    }
    
    @isTest
    static void Test_getDefaultValue()
    {
		LookUpComponentDesignAttribute attr = new LookUpComponentDesignAttribute();
		VisualEditor.DataRow rows = attr.getDefaultValue();  
    }   
}