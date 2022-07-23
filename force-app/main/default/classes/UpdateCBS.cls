global class UpdateCBS {   
    
@Invocablemethod
global static void initialMethod(List<String> vCaseId)
{
   
    case c = [select id, Booking_ID__c, FranchiseCode__c, CSE_Remarks__c, Appointment_Date__c,
              					Appointment_Time__c From Case where id=: vCaseId[0] Limit 1];
    if(c.id!=null || c.id!=''){
        String vBookingId = string.valueof(c.Booking_ID__c);
        String vFranchiseCode = c.FranchiseCode__c;
        String vComments =  c.CSE_Remarks__c + ' ' + 'Booking confirmed by customer via SMS on ' + c.Appointment_Date__c + ' ' + c.Appointment_Time__c;    
        String vCSERemarks = c.CSE_Remarks__c + ' ' + 'Booking confirmed by customer via SMS on ' + c.Appointment_Date__c + ' ' + c.Appointment_Time__c;    
        UpdateCBSRemarks.UpdBookingRemarks(vBookingId, vFranchiseCode,vComments,vCSERemarks);
        c.CSE_Remarks__c = vCSERemarks;
        update c;
    }       
}
    
}