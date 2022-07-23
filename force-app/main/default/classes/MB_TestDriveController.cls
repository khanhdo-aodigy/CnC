/** *****
 * Description : Controller Class for MB Test Drive Modules
 * 
 * Change History
 * Date(YYYYMMDD)       Name                   Description
 * 20211018           TPhan@aodigy        Created Initial Version. 
 * ** *****/

public without sharing class MB_TestDriveController
{
    public class DailyLogWrapper
    {
        @AuraEnabled public List<CourtesyVehicleWrapper> courtesyVehicles {get; set;}
        @AuraEnabled public Boolean isNewLog                              {get; set;}
        @AuraEnabled public Boolean isClosedLog                           {get; set;}
    }

    public class CourtesyVehicleWrapper
    {
        @AuraEnabled public String  courtesyVehicleId   { get; set; }
        @AuraEnabled public String  vehName             { get; set; }
        @AuraEnabled public Decimal openingMileage      { get; set; }
        @AuraEnabled public Decimal closingMileage      { get; set; }
        @AuraEnabled public String  petrol              { get; set; }
        @AuraEnabled public String  regNo               { get; set; }
        @AuraEnabled public String  commNo              { get; set; }
        @AuraEnabled public String  remarks             { get; set; }
        @AuraEnabled public String  dailyLogId          { get; set; }
        @AuraEnabled public Decimal previousMileage     { get; set; }
        @AuraEnabled public String  previousPetrol      { get; set; }
    }

    public class TestDriveWrapper
    {
        @AuraEnabled public Courtesy_Vehicle__c vehicleInfo;
        @AuraEnabled public Boolean closingLogExist;
        @AuraEnabled public List<VehicleRequestWrapper> ownerRequests;
        @AuraEnabled public List<Vehicle_Request__c> queuedTestDriveRequests;
    }

    public class VehicleRequestWrapper
    {
        @AuraEnabled public Vehicle_Request__c reqInfo;
        @AuraEnabled public Boolean isCheckedOut;
        @AuraEnabled public Boolean isQueued;
    }

    public class FileMtd
    {
        public String fileName;
        public String baseData;

        public FileMtd(String name, String data)
        {
            this.fileName = name;
            this.baseData = data;
        }
    }

    @AuraEnabled(cacheable = true)
    public static DailyLogWrapper retrieveCourtesyVehiclesForMBTestDrive()
    {
        ADGLIB_SObjectUnitOfWork uow                     = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {MB_Test_Drive_Daily_Log__c.SObjectType});
        Map<Id, MB_Test_Drive_Daily_Log__c> dailyLogsMap = new Map<Id, MB_Test_Drive_Daily_Log__c>();
        DailyLogWrapper res                              = new DailyLogWrapper();
        Set<Id> courtesyVehIds                           = new Set<Id>();
        Set<Id> idsOfCVehWithNoTDVehReq                  = new Set<Id>();
        Set<Id> idsOfCVehWithNoOpeningLog                = new Set<Id>();
        Boolean isNewLogsCreated                         = false;
        Boolean isNewLogsClosed                          = false;

        try 
        {
            List<Courtesy_Vehicle__c> courtesyVehicles = CourtesyVehicleService.getCourtesyVehiclesByStatusAndBranchCode('MB_Test_Drive', 'Available', 'CCI', 'MBP');
            
            if (courtesyVehicles <> null && courtesyVehicles.size() > 0)
            {
                for (Courtesy_Vehicle__c veh : courtesyVehicles)
                {
                    courtesyVehIds.add(veh.Id);
                    idsOfCVehWithNoOpeningLog.add(veh.Id);
                }
                /** -------------------------------------------------- MODIFIED BY THIEU DANG VU - 12/01/2022 -------------------------------------------------- */
                List<MB_Test_Drive_Daily_Log__c> latestLogs = MBTestDriveDailyLogService.getMBTDDailyLogsByCreatedDateAndStatusAndVehicles(String.valueOfGmt(Date.today()), '', courtesyVehIds, '<', 'CreatedDate', true);
                system.debug('latestLogs @@ ' + JSON.serialize(latestLogs));
                /** --------------------------------------------------------------------- END ------------------------------------------------------------------- */

                List<MB_Test_Drive_Daily_Log__c> todayDailyLogs = MBTestDriveDailyLogService.getMBTDDailyLogsByCreatedDateAndStatusAndVehicles(String.valueOfGmt(Date.today()), '', courtesyVehIds, '=', null, null);
                if (todayDailyLogs <> null && todayDailyLogs.size() > 0)
                {
                    for (MB_Test_Drive_Daily_Log__c log : todayDailyLogs)
                    {
                        idsOfCVehWithNoOpeningLog.remove(log.Courtesy_Vehicle__c);
                    }

                    isNewLogsCreated = true;

                    idsOfCVehWithNoTDVehReq.addAll(courtesyVehIds);

                    List<Vehicle_Request__c> todayTDVehReq = VehicleRequestService.getTodayReqsByConditions(courtesyVehIds, null, null, null, null, 'CCI', 'MBP',
                                                                                                            'MB Test Drive Request', null, null, null, false);

                    if (todayTDVehReq <> null && todayTDVehReq.size() > 0)
                    {
                        for (Vehicle_Request__c req : todayTDVehReq)
                        {
                            idsOfCVehWithNoTDVehReq.remove(req.Courtesy_Vehicle__c);
                        }
                    }

                    if (todayDailyLogs.get(0).Closing_Mileage__c <> null) isNewLogsClosed = true;

                    dailyLogsMap = generateVehAndTDDailyLogMap(dailyLogsMap, todayDailyLogs);
                }
                else 
                {
                    Map<Id, MB_Test_Drive_Daily_Log__c> latestClosedLogByVehIds = new Map<Id, MB_Test_Drive_Daily_Log__c>();
                    for (MB_Test_Drive_Daily_Log__c log : latestLogs)
                    {
                        if (!latestClosedLogByVehIds.containsKey(log.Courtesy_Vehicle__c) && log.Status__c == 'Closed')
                        {
                            latestClosedLogByVehIds.put(log.Courtesy_Vehicle__c, log);
                        }
                    }
                    system.debug('latestClosedLogs @@ ' + JSON.serialize(latestClosedLogByVehIds));

                    if (!latestClosedLogByVehIds.isEmpty()) dailyLogsMap = generateVehAndTDDailyLogMap(dailyLogsMap, latestClosedLogByVehIds.values());
                }
                
                if (isNewLogsCreated && idsOfCVehWithNoOpeningLog.size() > 0)
                {
                    List<MB_Test_Drive_Daily_Log__c> newDailyLogs = new List<MB_Test_Drive_Daily_Log__c>();
                    for (Id rcdId : idsOfCVehWithNoOpeningLog)
                    {
                        newDailyLogs.add(new MB_Test_Drive_Daily_Log__c(Courtesy_Vehicle__c = rcdId, Status__c = 'Opened'));
                    }
                    dailyLogsMap = generateVehAndTDDailyLogMap(dailyLogsMap, newDailyLogs);
                }

                List<CourtesyVehicleWrapper> vehWrapperList = new List<CourtesyVehicleWrapper>();
                CourtesyVehicleWrapper vehWrapper;

                /** -------------------------------------------------- MODIFIED BY THIEU DANG VU - 11/01/2022 -------------------------------------------------- */
                Map<Id, MB_Test_Drive_Daily_Log__c> latestLogByVehicleIds = new Map<Id, MB_Test_Drive_Daily_Log__c>();
                for (MB_Test_Drive_Daily_Log__c log : latestLogs)
                {
                    if (!latestLogByVehicleIds.containsKey(log.Courtesy_Vehicle__c))
                    {
                        latestLogByVehicleIds.put(log.Courtesy_Vehicle__c, log);
                    }
                }
                /** --------------------------------------------------------------------- END ------------------------------------------------------------------- */
                system.debug('isNewLogsCreated:: ' + isNewLogsCreated);
                system.debug('dailyLogsMap:: ' + JSON.serialize(dailyLogsMap));
                for (Courtesy_Vehicle__c veh : courtesyVehicles)
                { 
                    vehWrapper                   = new CourtesyVehicleWrapper();
                    vehWrapper.courtesyVehicleId = veh.Id;
                    vehWrapper.vehName           = veh.Name;
                    vehWrapper.regNo             = veh.Registration_No__c;
                    vehWrapper.commNo            = veh.Comm_No__c;
                    vehWrapper.openingMileage    = dailyLogsMap.get(veh.Id) <> null ? (isNewLogsCreated ? dailyLogsMap.get(veh.Id).Opening_Mileage__c : dailyLogsMap.get(veh.Id).Closing_Mileage__c) : vehWrapper.openingMileage;
                    vehWrapper.closingMileage    = isNewLogsClosed ? dailyLogsMap.get(veh.Id).Closing_Mileage__c : (idsOfCVehWithNoTDVehReq.contains(veh.Id) ? dailyLogsMap.get(veh.Id).Opening_Mileage__c : vehWrapper.closingMileage);
                    vehWrapper.petrol            = dailyLogsMap.get(veh.Id) <> null ? dailyLogsMap.get(veh.Id).Petrol__c : vehWrapper.petrol;
                    vehWrapper.remarks           = isNewLogsCreated ? (dailyLogsMap.get(veh.Id) <> null ? dailyLogsMap.get(veh.Id).Remarks__c : vehWrapper.remarks) : vehWrapper.remarks;
                    vehWrapper.dailyLogId        = isNewLogsCreated ? (dailyLogsMap.get(veh.Id) <> null ? dailyLogsMap.get(veh.Id).Id : vehWrapper.dailyLogId) : vehWrapper.dailyLogId;
                    if (!latestLogByVehicleIds.isEmpty())
                    {
                        vehWrapper.previousMileage   = latestLogByVehicleIds.get(veh.Id) <> null ? (latestLogByVehicleIds.get(veh.Id).Status__c == 'Opened' ? latestLogByVehicleIds.get(veh.Id).Opening_Mileage__c : latestLogByVehicleIds.get(veh.Id).Closing_Mileage__c) : vehWrapper.previousMileage;
                        vehWrapper.previousPetrol    = latestLogByVehicleIds.get(veh.Id) <> null ? latestLogByVehicleIds.get(veh.Id).Petrol__c : vehWrapper.previousPetrol;
                    }

                    vehWrapperList.add(vehWrapper);
                }

                res.courtesyVehicles = vehWrapperList;
                res.isNewLog         = isNewLogsCreated;
                res.isClosedLog      = isNewLogsClosed;
            }
        }
        catch (Exception e)
        {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getLineNumber());
        }

        return res;
    }

    @AuraEnabled
    public static Boolean upsertMBTDDailyLogs(List<MB_Test_Drive_Daily_Log__c> records)
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {MB_Test_Drive_Daily_Log__c.SObjectType});
        try 
        {
            uow.registerUpsert(records);
            uow.commitWork();
        } 
        catch (Exception e) 
        {
            System.debug('Exception ::: ' + e);
            throw new AuraHandledException(e.getMessage() + ' ' + e.getLineNumber());
        }

        return true;
    }

    @AuraEnabled(cacheable = true)
    public static List<TestDriveWrapper> constructTestDriveWrapper() 
    {
        List<Courtesy_Vehicle__c> courtesyVehicles = CourtesyVehicleService.getCourtesyVehiclesByStatusAndBranchCode('MB_Test_Drive', 'Available', 'CCI', 'MBP');
        if (courtesyVehicles.size() == 0) return null;

        TestDriveWrapper tdWrapper;
        Set<Id> courtesyVehIds                                          = new Set<Id>();
        List<TestDriveWrapper> tdWrappers                               = new List<TestDriveWrapper>();
        Map<Id, List<Vehicle_Request__c>> queuedTDRequestByVehIds       = new Map<Id, List<Vehicle_Request__c>>();
        Map<Id, List<Vehicle_Request__c>> salesRepTodayTDReqsByVehIds   = new Map<Id, List<Vehicle_Request__c>>();
        Map<Id, MB_Test_Drive_Daily_Log__c> dailyLogsMap                = new Map<Id, MB_Test_Drive_Daily_Log__c>();

        for (Courtesy_Vehicle__c vehicle : courtesyVehicles)
        {
            tdWrapper = new TestDriveWrapper();
            tdWrapper.vehicleInfo = vehicle;
            tdWrappers.add(tdWrapper);
            courtesyVehIds.add(vehicle.Id);
        }
        
        List<Vehicle_Request__c> todayQueuedTDReqs  = VehicleRequestService.getTodayReqsByConditions(courtesyVehIds, null, null, 'Queued', null, 'CCI', 'MBP',
                                                                                                     'MB Test Drive Request', null, 'CreatedDate', false, false);
        queuedTDRequestByVehIds = generateVehAndTDReqMap(queuedTDRequestByVehIds, todayQueuedTDReqs);
 
        List<Vehicle_Request__c> salesRepTodayTDReqs = VehicleRequestService.getTodayReqsByConditions(courtesyVehIds, UserInfo.getUserId(), null, null, 'Test Drive', 'CCI', 'MBP',
                                                                                                      'MB Test Drive Request', null, 'CreatedDate', false, false);
        salesRepTodayTDReqsByVehIds = generateVehAndTDReqMap(salesRepTodayTDReqsByVehIds, salesRepTodayTDReqs);

        List<MB_Test_Drive_Daily_Log__c> todayDailyLogs  = MBTestDriveDailyLogService.getMBTDDailyLogsByCreatedDateAndStatusAndVehicles(String.valueOfGmt(Date.today()), 'Closed', courtesyVehIds, '=', null, null);
        dailyLogsMap = generateVehAndTDDailyLogMap(dailyLogsMap, todayDailyLogs);

        for (TestDriveWrapper wrapper : tdWrappers)
        {
            if (!queuedTDRequestByVehIds.isEmpty()) wrapper.queuedTestDriveRequests = queuedTDRequestByVehIds.get(wrapper.vehicleInfo.Id);

            if (!salesRepTodayTDReqsByVehIds.isEmpty())
            {
                List<Vehicle_Request__c> todayReqs = salesRepTodayTDReqsByVehIds.get(wrapper.vehicleInfo.Id);
                if (todayReqs != null && todayReqs.size() > 0)
                {
                    wrapper.ownerRequests = new List<VehicleRequestWrapper>();
                    for (Vehicle_Request__c request : todayReqs)
                    {
                        VehicleRequestWrapper vehReqWrapper            = new VehicleRequestWrapper();
                        vehReqWrapper.reqInfo                          = request;
                        vehReqWrapper.isQueued                         = request.Status__c == 'Queued';
                        vehReqWrapper.isCheckedOut = request.Status__c == 'Ongoing';
                        wrapper.ownerRequests.add(vehReqWrapper);
                    }
                }
            }

            wrapper.closingLogExist = dailyLogsMap.get(wrapper.vehicleInfo.Id) != null;
        }

        return tdWrappers;
    }

    @AuraEnabled(cacheable=true)
    public static List<Trade_Plate__c> getTradePlates()
    {
        List<Trade_Plate__c> tps = new List<Trade_Plate__c>();

        for (Trade_Plate__c tp : [SELECT Name, (SELECT Id
                                                FROM Vehicle_Requests__r 
                                                WHERE Status__c         = 'Ongoing'
                                                  AND RecordType.Name   = 'MB Test Drive Request'
                                                LIMIT 1)
                                  FROM Trade_Plate__c
                                  WHERE Branch_Code__c      = 'CCI'
                                    AND Franchise_Code__c   = 'MBP'
                                    AND Active__c           = true]) {

            if (tp.Vehicle_Requests__r.size() == 0) tps.add(tp);
        }

        return tps;
    }

    @AuraEnabled
    public static Boolean checkDailyLogExist(Id vehicleId)
    {
        List<MB_Test_Drive_Daily_Log__c> todayDailyLogs = MBTestDriveDailyLogService.getMBTDDailyLogsByCreatedDateAndStatusAndVehicles(String.valueOfGmt(Date.today()), '', new Set<Id>{vehicleId}, '=', null, null);

        return (todayDailyLogs.size() > 0);
    }

    @AuraEnabled
    public static String getProfile()
    {
        return [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
    }

    @AuraEnabled
    public static List<Account> searchPersonAccount(String mobile, String email, String moreConditions)
    {
        String str_filter = ' IsPersonAccount = true ';

        if (String.isNotBlank(mobile)) str_filter += ' AND PersonMobilePhone = ' + '\'' + mobile + '\''; 

        if (String.isNotBlank(email)) str_filter += ' AND PersonEmail = ' + '\'' + email + '\'';

        if (String.isNotBlank(moreConditions)) str_filter += moreConditions;

        System.debug('@@@searchPersonAccount :: ' + str_filter);

        List<Account> results = (List<Account>) ADGLIB_UtilityHelper.getSObjectRecords('Account', str_filter, true); 

        return results;
    }

    @AuraEnabled
    public static Vehicle_Request__c createVehicleRequest(Map<String, String> info, Map<String, String> frontLicense, Map<String, String> backLicense)
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Vehicle_Request__c.SObjectType, Courtesy_Vehicle__c.SObjectType});

        Vehicle_Request__c req = newRequest(info);

        if (String.isNotBlank(info.get('__matchPA')))
        {  
            Boolean pdpa = info.get('PDPA_Agreed__c') == 'true' ? true : false;
            AccountUtil.PAWrapper pAWrapper = new AccountUtil.PAWrapper('', info.get('FirstName'), info.get('LastName'), info.get('Full_Name__pc'), '', info.get('PersonMobilePhone'), null,
                                                                        info.get('Address_Line_1__pc'), info.get('Address_Line_2__pc'), info.get('Address_Line_3__pc'), info.get('Address_Line_4__pc'), '', '', 
                                                                        pdpa, '', '', '', '', '');
            AccountUtil.updatePA(paWrapper, info.get('__matchPA'));

            req.Account__c = info.get('__matchPA');
        }
        else 
        {
            req.Account__c = createProspect(info);
        }

        system.debug('new request :: ' + req);

        Courtesy_Vehicle__c vehicle;
        if ((req.Test_Drive_Type__c == 'Loan' || req.Test_Drive_Type__c == 'Maintenance') && req.Status__c == 'Ongoing')
        {
            vehicle = updatedVehicle(req.Test_Drive_Type__c, null, info.get('Courtesy_Vehicle__c'));
        }

        try {
            uow.registerNew(req);
            if (vehicle != null) {
                uow.registerDirty(vehicle);
            }
            uow.commitWork();

            List<FileMtd> fileMtdLst = new List<FileMtd>();
            if (!frontLicense.isEmpty() && frontLicense <> null)
            {
                fileMtdLst.add(new FileMtd(frontLicense.get('fileName'), frontLicense.get('body')));
            }
            if (!backLicense.isEmpty() && backLicense <> null)
            {
                fileMtdLst.add(new FileMtd(backLicense.get('fileName'), backLicense.get('body')));
            }
    
            if (fileMtdLst.size() > 0)
            {
                Map<Id, List<FileMtd>> fileConfiguration = new Map<Id, List<FileMtd>>();
                fileConfiguration.put(req.Id, fileMtdLst);
                createAttachment(fileConfiguration);
            }
        } 
        catch (Exception e)
        {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getLineNumber());
        }

        return req;
    }

    @AuraEnabled
    public static void generateIndemnityForm(String reqId)
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {ContentVersion.SObjectType, ContentDocument.SObjectType, ContentDocumentLink.SObjectType});
        Id cdID;
        try {
            Blob formContent;
            if (!Test.isRunningTest()) {
                formContent = new PageReference('/apex/MB_TestDrivePDF?id=' + reqId).getContent();
            } else {
                formContent = Blob.valueOf('Test');
            }
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.PathOnClient = '/' + 'IndemnityForm.pdf';
            cv.Origin = 'C';
            cv.OwnerId = UserInfo.getUserId();
            cv.Title = 'IndemnityForm.pdf';
            cv.VersionData = formContent;
            insert cv;

            cdID = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

            ContentDocument cd = [SELECT Description FROM ContentDocument WHERE ID = :cdID];
            cd.Description = 'IndemnityForm';
            update cd;

            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = cdID;
            cDocLink.LinkedEntityId = reqId;
            cDocLink.ShareType = 'I';
            cDocLink.Visibility = 'AllUsers';
            insert cDocLink;
        } catch (Exception e) {
            throw new AuraException('Error occured during generating Indemnity Form. Please contact your Administrator for more details!' + e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Vehicle_Request__c> getHistoryRequest(Id vehId, String paId) 
    {
        return VehicleRequestService.getTodayReqsByConditions(new Set<Id>{vehId}, null, paId, 'Completed', 'Test Drive', 'CCI', 'MBP',
                                                              'MB Test Drive Request', null, 'CreatedDate', false, false);
    }

    @AuraEnabled
    public static void processVehicleRequest(String type, String currReqId)
    {
        ADGLIB_SObjectUnitOfWork uow    = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Vehicle_Request__c.SObjectType, Courtesy_Vehicle__c.SObjectType});
        Vehicle_Request__c currReq      = VehicleRequestService.getTestDriveById(currReqId)[0];
        Courtesy_Vehicle__c vehicle;

        switch on (type) {
            when 'Check In' {
                currReq.Status__c   = 'Completed';
                currReq.Check_In__c = DateTime.now();
                vehicle             = updatedVehicle(null, true, currReq.Courtesy_Vehicle__c);
            }
            when 'Check Out' {
                List<Vehicle_Request__c> reqs = VehicleRequestService.getTodayReqsByConditions(new Set<Id>{currReq.Courtesy_Vehicle__c}, null, null, null, null, 'CCI', 'MBP', 'MB Test Drive Request',
                                                                                               '(Status__c = \'Ongoing\' OR Status__c = \'Queued\')', 'CreatedDate', false, true);
                if (reqs <> null && reqs.size() > 0) {
                    if (reqs[0].Status__c == 'Ongoing') {
                        throw new AuraHandledException('This vehicle is currently being checked-out by another Sales Rep. Please try again later!');
                    } else if (reqs[0].Status__c == 'Queued' && reqs[0].Id != currReqId) {
                        throw new AuraHandledException('You can not check-out. Please wait until your turn to check-out!');
                    }
                }
                currReq.Status__c    = 'Ongoing';
                currReq.Check_Out__c = DateTime.now();
            }
            when 'Cancel' {
                currReq.Status__c    = 'Cancelled';
            }
        }
        try 
        {
            uow.registerDirty(currReq);
            if (vehicle <> null) uow.registerDirty(vehicle);
            uow.commitWork();
        }
        catch(Exception e) 
        {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getLineNumber());
        }
    }

    private static Vehicle_Request__c newRequest(Map<String, String> info)
    {
        Map<String, Schema.DescribeFieldResult> descriptions = getFieldDescription(getFieldTokens(getObjectToken('Vehicle_Request__c')));
        Map<String,Schema.RecordTypeInfo> recType            = getVehicleRequestRtByDeveloperName();
        Vehicle_Request__c req                               = new Vehicle_Request__c();

        for (String api : info.keySet()) 
        {
            if (!descriptions.keySet().contains(api)) continue;
            if (!descriptions.get(api).isUpdateable()) continue;

            String valueAsText      = info.get(api);
            Schema.DisplayType type = descriptions.get(api).getType();
            switch on type {
                when BOOLEAN    { req.put(api, Boolean.valueOf( valueAsText ));  }
                when CURRENCY   { req.put(api, Decimal.valueOf( valueAsText ));  }
                when ID         { req.put(api, ID.valueOf( valueAsText ));       }
                when INTEGER    { req.put(api, Integer.valueOf( valueAsText ));  }
                when DOUBLE     { req.put(api, Double.valueOf( valueAsText ));   }
                when LONG       { req.put(api, Long.valueOf( valueAsText ));     }
                when PERCENT    { req.put(api, Decimal.valueOf( valueAsText ));  }
                when DATE       { req.put(api, getDate( valueAsText ));          }
                when else       { req.put(api, valueAsText);                     }
            }
        }

        req.RecordTypeId = recType.containsKey('MB_Test_Drive_Request') ? recType.get('MB_Test_Drive_Request').getRecordTypeId() : req.RecordTypeId;
        req.put('Branch_Code__c', 'CCI');
        req.put('Franchise_Code__c', 'MBP');

        List<Vehicle_Request__c> onGoingOrQueuedReqs = VehicleRequestService.getTodayReqsByConditions(new Set<Id>{info.get('Courtesy_Vehicle__c')}, null, null, null, null, 'CCI', 'MBP',
                                                                                                      'MB Test Drive Request', '(Status__c = \'Ongoing\' OR Status__c = \'Queued\')', 'CreatedDate', false, true);
        String status = onGoingOrQueuedReqs <> null && onGoingOrQueuedReqs.size() > 0 ? 'Queued' : 'Ongoing';
        if (status == 'Ongoing' && info.get('Test_Drive_Type__c') == 'Test Drive')
        {
            List<Vehicle_Request__c> testDrivesBySalesRep = VehicleRequestService.getTodayReqsByConditions(null, UserInfo.getUserId(), null, 'Ongoing', 'Test Drive', 'CCI', 'MBP',
                                                                                                           'MB Test Drive Request', null, null, null, true);
            if (testDrivesBySalesRep <> null && testDrivesBySalesRep.size() > 0)
            {
                throw new AuraHandledException('You currently have an Ongoing Test Drive of another vehicle. Please check-in your current test drive first!');
            }

            if (String.isNotBlank(info.get('__matchPA')))
            {
                List<Vehicle_Request__c> reqsByPA = VehicleRequestService.getTodayReqsByConditions(null, null, info.get('__matchPA'), 'Ongoing', 'Test Drive', 'CCI', 'MBP',
                                                                                                    'MB Test Drive Request', null, null, null, true);
                if (reqsByPA <> null && reqsByPA.size() > 0)
                {
                    throw new AuraHandledException('Customer currently have an Ongoing Test Drive. Please try again later!');
                }
            }
        }

        DateTime dtNow = status == 'Ongoing' ? DateTime.now() : null;
        req.put('Check_Out__c', dtNow);
        req.put('Status__c', status);

        return req;
    }

    private static Courtesy_Vehicle__c updatedVehicle(String reqType, Boolean isPresent, String vehicleId)
    {
        Courtesy_Vehicle__c vehicle                  = new Courtesy_Vehicle__c();
        vehicle.Id                                   = vehicleId;
        if (reqType <> null) vehicle.Status__c       = reqType == 'Loan' ? 'On Loan (Test Drive)' : 'Maintenance';
        if (isPresent <> null) vehicle.Is_Present__c = isPresent;


        return vehicle;
    }

    private static Map<String, Schema.RecordTypeInfo> getVehicleRequestRtByDeveloperName()
    {
        Schema.DescribeSObjectResult orderSObj                  = Schema.SObjectType.Vehicle_Request__c; 
        Map<String, Schema.RecordTypeInfo> rtMapByDeveloperName = orderSObj.getRecordTypeInfosByDeveloperName();
       
        return rtMapByDeveloperName;
    }

    private static Id createProspect(Map<String, String> info)
    {
        Account newProspect           = new Account ();
        newProspect.FirstName         = info.get('FirstName');
        newProspect.LastName          = info.get('LastName');
        newProspect.Full_Name__pc     = info.get('Full_Name__pc');
        newProspect.PersonMobilePhone = info.get('PersonMobilePhone');
        newProspect.PersonEmail       = info.get('PersonEmail');
        newProspect.Address_Line_1__pc= info.get('Address_Line_1__pc');
        newProspect.Address_Line_2__pc= info.get('Address_Line_2__pc');
        newProspect.Address_Line_3__pc= info.get('Address_Line_3__pc');
        newProspect.Address_Line_4__pc= info.get('Address_Line_4__pc');
        newProspect.PDPA__pc          = info.get('PDPA_Agreed__c') == 'true' ? 'SMS;Call;Email' : '';
        newProspect.SMS__pc           = info.get('PDPA_Agreed__c') == 'true' ? true : false;
        newProspect.Call__pc          = info.get('PDPA_Agreed__c') == 'true' ? true : false;
        newProspect.Fax__pc           = info.get('PDPA_Agreed__c') == 'true' ? true : false;
        newProspect.Email__pc         = info.get('PDPA_Agreed__c') == 'true' ? true : false;

        newProspect = AccountUtil.createProspect(newProspect);

        return newProspect.Id;
    }

    private static void createAttachment(Map<Id, List<FileMtd>> fileConfiguration)
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {ContentVersion.SObjectType});
        Map<Id, List<ContentVersion>> contentVersionMap = new Map<Id, List<ContentVersion>>();

        for (Id rcdId : fileConfiguration.keySet())
        {
            List<ContentVersion> contentVersionList = new List<ContentVersion>();

            for (FileMtd mtd : fileConfiguration.get(rcdId))
            {
                ContentVersion cv  = new ContentVersion();
                cv.Title           = mtd.fileName;
                cv.PathOnClient    = '/' + mtd.fileName;
                cv.VersionData     = EncodingUtil.base64Decode(EncodingUtil.urlDecode(mtd.baseData, 'UTF-8'));
                cv.ContentLocation = 'S';
                cv.Origin          = 'C';
                cv.OwnerId         = UserInfo.getUserId();
        
                contentVersionList.add(cv);
            }

            uow.registerNew(contentVersionList);
            contentVersionMap.put(rcdId, contentVersionList);
        }

        uow.commitWork();

        Map<Id, Id> contentVersionAndLinkedEntityIds = new Map<Id, Id>();
        for (Id rcdId : contentVersionMap.keySet())
        {
            for (ContentVersion cv : contentVersionMap.get(rcdId))
            {
                contentVersionAndLinkedEntityIds.put(cv.Id, rcdId);
            }
        }

        Map<Id, String> contentDocIdAndTitleMap = new Map<Id, String>();
        Map<Id, Id> contentDocAndContentVersionIds = new Map<Id, Id>();
        for (ContentVersion cv : [SELECT ContentDocumentId, Title FROM ContentVersion WHERE Id IN: contentVersionAndLinkedEntityIds.keySet()])
        {
            contentDocIdAndTitleMap.put(cv.ContentDocumentId, cv.Title);
            contentDocAndContentVersionIds.put(cv.ContentDocumentId, cv.Id);
        }

        List<ContentDocument> contentDocuments = new List<ContentDocument>();
        for (ContentDocument cd : [SELECT Id, Description FROM ContentDocument WHERE Id IN: contentDocIdAndTitleMap.keySet()])
        {
            cd.Description = contentDocIdAndTitleMap.get(cd.Id);
            contentDocuments.add(cd);
        }  
        uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {ContentDocument.SObjectType});    
        uow.registerDirty(contentDocuments);
        uow.commitWork();   

        uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {ContentDocumentLink.SObjectType});    
        for (ContentDocument cd : contentDocuments)
        {
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId   = cd.Id;
            cDocLink.LinkedEntityId      = contentVersionAndLinkedEntityIds.get(contentDocAndContentVersionIds.get(cd.Id));
            cDocLink.ShareType           = 'I';
            cDocLink.Visibility          = 'AllUsers';

            uow.registerNew(cDocLink);
        }
        uow.commitWork();   
    }

    private static Map<Id, MB_Test_Drive_Daily_Log__c> generateVehAndTDDailyLogMap(Map<Id, MB_Test_Drive_Daily_Log__c> res, List<MB_Test_Drive_Daily_Log__c> records)
    {       
        for (MB_Test_Drive_Daily_Log__c log : records)
        {
            res.put(log.Courtesy_Vehicle__c, log);
        }

        return res;
    }

    private static Map<Id, List<Vehicle_Request__c>> generateVehAndTDReqMap(Map<Id, List<Vehicle_Request__c>> reqByVehicleIds, List<Vehicle_Request__c> requests)
    {   
        for (Vehicle_Request__c req : requests)
        {
            if (reqByVehicleIds.containsKey(req.Courtesy_Vehicle__c))
            {
                reqByVehicleIds.get(req.Courtesy_Vehicle__c).add(req);
            }
            else
            {
                reqByVehicleIds.put(req.Courtesy_Vehicle__c, new List<Vehicle_Request__c>{req});
            }
        }

        return reqByVehicleIds;
    }

    private static Date getDate(String dateLiteral)
    {
        if (dateLiteral == null) return null;

        List<String> dateComponents = dateLiteral.split('-');
        Integer yyyy = Integer.valueOf(dateComponents[0]);
        Integer mm   = Integer.valueOf(dateComponents[1]);
        Integer dd   = Integer.valueOf(dateComponents[2]);

        return Date.newInstance(yyyy, mm, dd);
    }

    private static Schema.SObjectType getObjectToken(String Name) 
    {
        return Schema.getGlobalDescribe().get(Name);
    }

    private static Map<String, Schema.SObjectField> getFieldTokens(Schema.SObjectType token) 
    {
        return token.getDescribe().fields.getMap();
    }

    private static Map<String, Schema.DescribeFieldResult> getFieldDescription(Map<String, Schema.SObjectField> fieldTokens)
    {
        Map<String, Schema.DescribeFieldResult> fieldDescription = new map<string, Schema.DescribeFieldResult>();

        for (String fieldName : fieldTokens.keySet()) {
            fieldDescription.put(fieldTokens.get(fieldName).getDescribe().getName(), fieldTokens.get(fieldName).getDescribe());
        }

        return fieldDescription;
    }
}