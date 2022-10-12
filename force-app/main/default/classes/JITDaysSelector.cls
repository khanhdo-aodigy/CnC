public class JITDaysSelector extends ADGLIB_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            JIT_Day__c.JIT_Date__c,
            JIT_Day__c.No_of_Slots__c,
            JIT_Day__c.Opened_Slots__c,
            JIT_Day__c.Utilised_Slots__c,
            JIT_Day__c.Remaining_Slots__c,
            JIT_Day__c.Franchise__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return JIT_Day__c.sObjectType;
    }

    public JIT_Day__c selectById(Id recordId){
        adglib_QueryFactory query = newQueryFactory();      
        query.setCondition('Id = :recordId');

        return (JIT_Day__c)Database.query(query.toSOQL())[0];
    }

    public List<JIT_Day__c> selectByJITDate(Date jitDate){
        adglib_QueryFactory query = newQueryFactory();
        Integer jitDateMonth = jitDate.month();
        Integer jitDateYear  = jitDate.year();

        query.setCondition('CALENDAR_MONTH(JIT_Date__c) = :jitDateMonth AND CALENDAR_YEAR(JIT_Date__c) = :jitDateYear AND JIT_Date__c >= :jitDate');
        query.setOrdering('JIT_Date__c', ADGLIB_QueryFactory.SortOrder.ASCENDING);

        return Database.query(query.toSOQL());
    }

}