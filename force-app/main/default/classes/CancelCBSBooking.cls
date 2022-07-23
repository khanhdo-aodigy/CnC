global class CancelCBSBooking {   
    
@Invocablemethod
global static void initialMethod(List<String> vCaseId)
{
   
    case c = [select id, Booking_ID__c, FranchiseCode__c, CSE_Remarks__c, contact.NRIC__c, Appointment_Date__c,
              					Appointment_Time__c From Case where id=: vCaseId[0] Limit 1];
    if(c.id!=null || c.id!=''){
        String vBookingId = string.valueof(c.Booking_ID__c);
        String vFranchiseCode = c.FranchiseCode__c;
        String vNRIC = c.contact.NRIC__c;
        DateTime d = Date.Today() ;
		String currDateStr =  d.format('dd/MM/yyyy') ;
        Datetime myDateTime = DateTime.now();
		string currTime = myDateTime.format('hh:mm a');
        String vCSERemarks = c.CSE_Remarks__c + ' ' + 'Booking cancelled by customer via SMS on ' + currDateStr + ' ' + currTime;
        String responseToReturn = '';
        responseToReturn = CancelCBSRemarks.CancelBookingRemarks(vBookingId, vFranchiseCode,vNRIC);
        system.debug('response return-->' + responseToReturn);
    }       
}
    
}