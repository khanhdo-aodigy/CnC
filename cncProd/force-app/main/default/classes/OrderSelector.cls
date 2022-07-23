/** ******
 * Description : Selector Class for Custom Order object
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        Description
 * 20200211            HS          Created Initial Version. 
 * 20200608            TP          Added selectById method.
 * 20200625            TP          Added selectByOrderNo method.
** ******/
public class OrderSelector extends ADGLIB_SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList() {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Order__c');
    }
    
    public Schema.SObjectType getSObjectType() {
        return Order__c.sObjectType;
    }
    
    //SELECT ORDER BY ESHOP ORDER NUMBER OR THE SELECTED CONTACT (i.e. External ID field)
    public Order__c selectByEshopOrderID( String strEshopOrderID, String cntId ){
        List<Order__c> lstOrders = new List<Order__c>();
        adglib_QueryFactory query = newQueryFactory();      
        query.setCondition( ' OrderID__c = :strEshopOrderID AND Contact__c = :cntId ' ); 
        lstOrders = Database.query( query.toSOQL() );
        return ( !lstOrders.isEmpty() ? lstOrders.get(0) : null );
    }


    //GET Order__c Schema.RecordTypeInfo By DeveloperName
    public Map<String,Schema.RecordTypeInfo> getOrderRtByDeveloperName(){
        Schema.DescribeSObjectResult orderSObj = Schema.SObjectType.Order__c; 
        Map<String,Schema.RecordTypeInfo> rtMapByDeveloperName = orderSObj.getRecordTypeInfosByDeveloperName();
        return rtMapByDeveloperName;
    }

    //Select Order By ID 
    public Order__c selectById(String recordId){
        adglib_QueryFactory query = newQueryFactory();  
        query.setCondition('OrderID__c = :recordId'); 
        
        return (Order__c)(!Database.query(query.toSOQL()).isEmpty() ? Database.query(query.toSOQL())[0] : null);
    }

    //Select Order By Order Number
    public Order__c selectByOrderNo(String orderNumber){
        adglib_QueryFactory query = newQueryFactory();  
        query.setCondition('Name = :orderNumber'); 
        
        return (Order__c)(!Database.query(query.toSOQL()).isEmpty() ? Database.query(query.toSOQL())[0] : null);
    }
}