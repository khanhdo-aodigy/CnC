global class GetCBSDetails {   

global static List<String> l = new List<String>();
    
@Invocablemethod
global static List<String> initialMethod(List<String> values)
    {   
        List<String> sVar = New List<String>();
                   
      	for (String val : values)
        {
            String vBookingID = val.substringBefore(',');
            String vFranchiseCode = val.substringAfter(',');
            
            system.debug('Booking ID..' + vBookingID);
            System.debug('vFranchiseCode..' + vFranchiseCode);
    		String sVar1 = GetServiceBookingDetails.calloutToExternal(vBookingID,vFranchiseCode);
            system.debug('cbsjson2apex in get....' + sVar1);
            sVar.add(sVar1);
    	} 
        
        //return l;
        return sVar;
        
    }
}