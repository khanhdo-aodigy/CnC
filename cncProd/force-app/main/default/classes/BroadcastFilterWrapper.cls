/** ******
 * Description : Wrapper Class. Targeted objects - Registered Vehicle, RA and Non C&C 
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name       Description
 * 20200302            HS         Created Initial Version
 * 20210902            TPhan      Added param vehicleType, registrationDate and Mileage - Removed searchKey and hobbies
** ******/
public with sharing class BroadcastFilterWrapper 
{
    
    @AuraEnabled public String vehicleType { get; set; }
    @AuraEnabled public String[] models { get; set; }
    @AuraEnabled public String[] variants { get; set; }
    @AuraEnabled public String[] branches { get; set; }
    @AuraEnabled public String bdayMonthFrom { get; set; }
    @AuraEnabled public String bdayMonthTo { get; set; }
    @AuraEnabled public String lastLoginFrom { get; set; }
    @AuraEnabled public String lastLoginTo { get; set; }
    @AuraEnabled public String carAgeFrom { get; set; }
    @AuraEnabled public String carAgeTo { get; set; }
    @AuraEnabled public String upcomingServiceDateFrom { get; set; }
    @AuraEnabled public String upcomingServiceDateTo { get; set; }
    @AuraEnabled public String lastServiceDateFrom { get; set; }    
    @AuraEnabled public String lastServiceDateTo { get; set; }
    @AuraEnabled public String registrationDateFrom { get; set; }
    @AuraEnabled public String registrationDateTo { get; set; }
    @AuraEnabled public String MileageFrom { get; set; }
    @AuraEnabled public String MileageTo { get; set; }
}