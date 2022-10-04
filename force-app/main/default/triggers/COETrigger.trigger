trigger COETrigger on COE__c (after insert, after update) {
	adglib_SObjectDomain.triggerHandler(COE.class);
}