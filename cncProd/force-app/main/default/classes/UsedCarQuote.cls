public with sharing class UsedCarQuote extends ADGLIB_SObjectDomain {
    public UsedCarQuote(List<Used_Car_Quote__c> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new UsedCarQuote(sObjectList);
		}
	}

    public override void onBeforeUpdate(Map<Id,SObject> oldMap) {
        List<Id> inactiveQuoteIds = new List<Id>();
        for (Used_Car_Quote__c quote : (List<Used_Car_Quote__c>)Records) {  
            Used_Car_Quote__c oldQuote = (Used_Car_Quote__c)oldMap.get(quote.Id);
            if(oldQuote.Status__c != 'Open') {
                quote.addError('Only active quotes can be updated');
            }

            if( (quote.Intended_Deregistration_Date__c != oldQuote.Intended_Deregistration_Date__c
                    || quote.COE_Expiry_Date__c != oldQuote.COE_Expiry_Date__c
                )
                &&
                (quote.Intended_Deregistration_Date__c != null && quote.COE_Expiry_Date__c != null)
            ){
                quote.Remaining_COE__c = calculateRemainingDays(quote.Intended_Deregistration_Date__c, quote.COE_Expiry_Date__c);
                quote.Remaining_COE_Years__c = getRemainingYears(quote.Remaining_COE__c);
            }

            if (quote.RPA_Error__c != oldQuote.RPA_Error__c && String.isNotBlank(quote.RPA_Error__c)) {
                quote.Status__c = 'Failed';
            }

            if(quote.Vehicle_Make__c != oldQuote.Vehicle_Make__c && String.isNotBlank(quote.Vehicle_Make__c)
                            || quote.Chassis_No__c != oldQuote.Chassis_No__c && String.isNotBlank(quote.Chassis_No__c)
                
             ){
                quote.RPA_Status__c = 'Successful';
            }
            
        }
    }

    public override void onAfterUpdate(Map<Id,SObject> oldMap) {
        try {
            System.debug('*** oldMap = ' + oldMap);
            List<Used_Car_Quote__c> errorQuotes = new List<Used_Car_Quote__c>();
            List<Used_Car_Quote__c> successQuotes = new List<Used_Car_Quote__c>();

            for (Used_Car_Quote__c quote : (List<Used_Car_Quote__c>)Records) {  
                Used_Car_Quote__c oldQuote = (Used_Car_Quote__c)oldMap.get(quote.Id);

                if (quote.RPA_Error__c != oldQuote.RPA_Error__c && String.isNotBlank(quote.RPA_Error__c)) {
                    errorQuotes.add(quote);
                } else if(quote.Vehicle_Make__c != oldQuote.Vehicle_Make__c && String.isNotBlank(quote.Vehicle_Make__c)
                            || quote.Chassis_No__c != oldQuote.Chassis_No__c && String.isNotBlank(quote.Chassis_No__c)
                
                ){
                    successQuotes.add(quote);
                }
            }

            System.debug('*** errorQuotes = ' + errorQuotes);
            if(errorQuotes.size() > 0) {
                createErrorNotification(errorQuotes);
            }

            System.debug('*** successQuotes = ' + successQuotes);
            if(successQuotes.size() > 0) {
                createSuccessNotification(successQuotes);
                for(Used_Car_Quote__c quote: successQuotes) {
                    RAP_SendVehicleDetailsAPI.sendVehicleDetails(quote.ID);
                }                
            }
        } catch (Exception ex) {
            loggerDataPool.buildLogDataPool('UsedCarQuote', ex);
        }
    }

    @testVisible
    private void createErrorNotification(List<Used_Car_Quote__c> failedQuotes) {

        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Generic_Notification'];

        String listViewPage = '{' +
                                '       type: \'standard__objectPage\',' +
                                '       attributes: {' +
                                '           objectApiName: \'Used_Car_Quote__c\',' +
                                '           actionName: \'list\'' +
                                '       }' +
                                '}';

        for(Used_Car_Quote__c failedQuote: failedQuotes) {
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Error creating used car quote.');
            notification.setBody(' Vehicle No: ' + failedQuote.Vehicle_No__c
                                + '\n Customer NRIC: ' + failedQuote.Customer_NRIC__c
                                + '\n Error: ' + failedQuote.RPA_Error__c);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetPageRef(listViewPage);
            notification.send(new Set<String>{failedQuote.CreatedById});
            System.debug('*** notification = ' + notification);
        }
        
    }

    @testVisible
    private void createSuccessNotification(List<Used_Car_Quote__c> successQuotes) {

        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Generic_Notification'];

        for(Used_Car_Quote__c quote: successQuotes) {
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Used car quote ' + quote.Name + ' created successfully!');
            notification.setBody(' Vehicle No.: ' + quote.Vehicle_No__c
                                + '\n Customer NRIC: ' + quote.Customer_NRIC__c
                            );
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(quote.Id);
            notification.send(new Set<String>{quote.CreatedById});
            System.debug('*** notification = ' + notification);
        }
        
    }

    @testVisible
    private Decimal getRemainingYears(String remainingCOE) {
        List<String> temp = new List<String>();
        Matcher m = Pattern.compile('([0-9]+)').matcher(remainingCOE);
        While (m.find()) {
            temp.add(m.group());
        }
        System.debug(temp);
        Decimal years = (Decimal.valueOf(temp[0]) + Decimal.valueOf(temp[1])/12 + Decimal.valueOf(temp[2])/365).setScale(2);
        System.debug(years);
        return years;
    }

    @testVisible
    private String calculateRemainingDays(Date startDate, Date endDate) {
        Integer years = 0, months = 0, days = 0;

        Integer totalMonths = startDate.monthsBetween(endDate);
        years = (Integer)Math.FLOOR((totalMonths/12));
        months = totalMonths - years*12;
        Date mockDate = startDate.addMonths(totalMonths);

        if(startDate.day() < endDate.day()) {
            days = mockDate.daysBetween(endDate);
        } else if(startDate.day() > endDate.day()) {
            mockDate = startDate.addMonths(totalMonths -1);
            days = mockDate.daysBetween(endDate);
            if(months == 0) {
                years -= 1;
                months = 11;
            } else {
                months -= 1;            
            }
        }
              
        System.debug('Start date = ' + startDate);
        System.debug('End date = ' + endDate);
        System.debug('mockDate = ' + mockDate);
        System.debug('totalMonths = ' + totalMonths);
        System.debug('years = ' + years);
        System.debug('months = ' + months);
        System.debug('days = ' + days);

        String result = years + ' Year(s) ' + months + ' Month(s) ' + days + ' Day(s)';
        System.debug('result = ' + result);
        return result;
    }
}