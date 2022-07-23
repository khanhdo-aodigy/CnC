public without sharing class BusinessHoursUtility {

    public static DateTime GetNextBusinessDtTm(DateTime targetDate){
        DateTime NextBusinessDtTm;
     
        // Get the default business hours
		BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true]; 
        NextBusinessDtTm = BusinessHours.nextStartDate(bh.Id, targetDate);
        system.debug('Next Business Date Time -> '+NextBusinessDtTm);
        return NextBusinessDtTm;
    }

  public static Datetime getPreviousWorkingDay(Datetime d){
        
      	BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true]; 
    
         //Check if new date is within working days
        if (!BusinessHours.isWithin(bh.Id, d))
        {
            //New date is not within working days, recursively call same function to get previous date by subtracting 1 day
            d = d.addDays(-1);
            return getPreviousWorkingDay(d);
        } else{
            //New date is within working days, return this date
            return d;
        }
    }
    
     public static long GetBusinessHrs(DateTime startDate, DateTime endDate){
        long BusinessHrs;

         // Get the default business hours
		BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true]; 
        BusinessHrs = BusinessHours.diff(bh.Id, startDate, endDate); 
        system.debug('Business hours between two dates..' + BusinessHrs); 
        return BusinessHrs;
    }
    
    /* To find whether the date time is within the default Business Hours */
    public static boolean IsBusinessDtTm(DateTime targetDate){
        Boolean IsBusinessDay;
        
          // Get the default business hours
		BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true]; 
       	IsBusinessDay = BusinessHours.isWithin(bh.id, targetDate);
        system.debug('Is within Business Hours  -> '+ IsBusinessDay);
        return IsBusinessDay;
    }
    
    public static Datetime addWorkingDays(Datetime startDate, Integer days)
    {
        // Get the default business hours
		BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true]; 
       	
        for (Integer elapsed = 0; elapsed < days; elapsed++)
        {
            //Add 1 day
            startDate = startDate.addDays(1);
            
            //Check if new date is within working days
            if (!BusinessHours.isWithin(bh.Id, startDate))
            { 
                //If new date is not within working days, get new working day
                startDate = BusinessHours.nextStartDate(bh.Id, startDate);
            }
        }
        return startDate;
    }
}