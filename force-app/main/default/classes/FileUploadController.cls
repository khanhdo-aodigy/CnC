public class FileUploadController {
 
    @AuraEnabled
    public static Integer createSurvey(Id fileLatestVersionId, Id userId, String surveyType){
        system.debug('surveyType: '+surveyType);
        switch on surveyType {
            when 'SFU'{
                return createSFU(fileLatestVersionId,userId,surveyType);
            }
            when 'CLI'{
                return createCLI(fileLatestVersionId,userId,surveyType);
            }
            when 'CSI'{
                return createCSI(fileLatestVersionId,userId,surveyType);
            }
            when 'RA'{
                return createRA(fileLatestVersionId,userId,surveyType);
            }
        }
        return null;
    }
    
    public static Integer createSFU(Id fileLatestVersionId, Id userId, String surveyType){
        ContentVersion cv = [ SELECT Id, VersionData 
                              FROM ContentVersion
                              WHERE Id = :fileLatestVersionId];
        System.debug(cv);
        try 
        {
            List<Case> casesToCreate = new List<Case>();
            Blob cvFileBody = cv.VersionData;
            String cvFileBodyAsString = cvFileBody.toString();
            String[] cvFileLines = cvFileBodyAsString.split('\n');
            System.debug(cvFileLines.size());
            ID recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Surveys').getRecordTypeId();
            Group QueueId = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name = 'Surveys'];
            List<String> RegisteredNumberIds = new List<String>();
            Map<String,Case> RegisterdCasesMap = new Map<String,case>();
            Map<String, Registered_Vehicle__c> RedsteredNumberID = new Map<String, Registered_Vehicle__c>();
            
            for(Integer i = 0; i < cvFileLines.size(); i++) {
                System.debug(cvFileLines[i]);
                if (i!=0)
                {                  
                    Case c = new Case();
                    String[] cvRecordData = cvFileLines[i].split(','); 
                    System.debug(cvRecordData);
                    c.Job_Order__c               = cvRecordData[0];
                    c.Job_Type__c                = cvRecordData[1];        
                    c.Job_Order_Invoice_Date__c  = cvRecordData[2];
                    c.Title__c                   = cvRecordData[3];
                    c.Customer_Name__c           = cvRecordData[4];
                    c.Car_Registration_Number__c = cvRecordData[5];
                    RegisteredNumberIds.add(cvRecordData[5]);
                    c.House_Telephone_Number__c  = cvRecordData[6];
                    c.Office_Telephone_Number__c = cvRecordData[7];
                    c.Phone_1__c                 = cvRecordData[8];
                    c.Service_Advisor__c         = cvRecordData[9];
                    c.FromDate__c                = cvRecordData[10];
                    c.ToDate__c                  = cvRecordData[11];
                    c.Location__c                = cvRecordData[12]; 
                    c.RecordTypeId               = recordTypeID;
                    c.Survey_Type__c             = surveyType;
                    c.OwnerId                    = QueueId.Id;
                    RegisterdCasesMap.put(cvRecordData[5],c);
                    System.debug(cvRecordData[5]);
                    casesToCreate.add(c);
                }
            }
           
            if (casesToCreate.size() > 0){
                List<Registered_Vehicle__c> vRegVehRecs = [ SELECT id, Contact__c,Registration_Number__c, Franchise__c, Branch__c 
                                                            FROM Registered_Vehicle__c 
                                                            WHERE Registration_Number__c in:RegisteredNumberIds ] ;
                for(Registered_Vehicle__c r :vRegVehRecs) 
                {    
                    for(case c: casesToCreate) 
                    {
                        String a = c.Car_Registration_Number__c;
                        RedsteredNumberID.put( c.Car_Registration_Number__c, r );
                        if( RegisterdCasesMap.containsKey(c.Car_Registration_Number__c) 
                                && ( RedsteredNumberID.get(c.Car_Registration_Number__c).Registration_Number__c == RegisterdCasesMap.get(c.Car_Registration_Number__c).Car_Registration_Number__c ) ) 
                        {
                            c.Registered_Vehicle__c = RedsteredNumberID.get(c.Car_Registration_Number__c).id;
                            c.ContactId             = RedsteredNumberID.get(c.Car_Registration_Number__c).Contact__c;
                            c.Franchise__c          = RedsteredNumberID.get(c.Car_Registration_Number__c).Franchise__c;
                            c.Branch__c             = RedsteredNumberID.get(c.Car_Registration_Number__c).Branch__c;
                        }
                    }
                }
                 
                insert casesToCreate;
                System.debug(casesToCreate.size());
                
                return casesToCreate.size();
            }
            return null;
        }
        catch(ListException le) {
            System.debug('Exception: ' + le + '. Cause: ' + le.getCause() + '. Error at line: ' + le.getLineNumber());
            AuraHandledException leException = new AuraHandledException('The columns are not properly formatted. Please ensure the number of columns is correct and comma is the List separator.');
            leException.setMessage('The columns are not properly formatted. Please ensure the number of columns is correct and comma is the List separator.');
            throw leException;
        }
        catch(Exception e) {            
            String validationErr = '';
            if(e.getMessage().startsWith('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,')) {
                validationErr = e.getMessage().replace('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,', '');
                throw new AuraHandledException(validationErr);
            } 
            else if(e.getMessage().startsWith('Insert failed. First exception on row 0; first error: STRING_TOO_LONG,')) {
                validationErr = e.getMessage().replace('Insert failed. First exception on row 0; first error: STRING_TOO_LONG,', 'Too many characters entered for');
                throw new AuraHandledException(validationErr);
            }
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled    
    public static ContentDocument getFileAfterUpload(Id fileId) {
        return [SELECT Id, LatestPublishedVersionId, Title FROM ContentDocument WHERE Id = :fileId];
    } 
    
    @AuraEnabled    
    public static void deleteFile(Id fileId) {
        delete [SELECT Id FROM ContentDocument WHERE Id = :fileId];
    } 
    
    public static Integer createCLI(Id fileLatestVersionId,Id userId,String surveyType){
        ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion
                             WHERE Id = :fileLatestVersionId];
        System.debug(cv);
        try {
            List<Case> casesToCreate = new List<Case>();
            Blob cvFileBody = cv.VersionData;
            String cvFileBodyAsString = cvFileBody.toString();
            String[] cvFileLines = cvFileBodyAsString.split('\n');
            ID recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Surveys').getRecordTypeId();
            Group QueueId = [SELECT id, name FROM group WHERE type='Queue' AND name = 'Surveys'];
            List<String> RegisteredNumberIds = new List<String>();
            map<string,Case> RegisterdCasesMap = new map<string,case>();
            map<string, Registered_Vehicle__c> RedsteredNumberID = new map<string, Registered_Vehicle__c>();
            for(Integer i = 0; i < cvFileLines.size(); i++) {
                if (i!=0)
                {         
                    Case c = new Case();
                    String[] cvRecordData = cvFileLines[i].split(',');                
                    c.Vehicle_Magic__c = cvRecordData[0];
                    c.Customer_Magic__c = cvRecordData[1];
                    c.First_Name__c = cvRecordData[2];      
                    c.Surname__c = cvRecordData[3];
                    c.Customer_Name__c = cvRecordData[4];
                    c.SocialID__c = cvRecordData[5];
                    c.SEX__c = cvRecordData[6];
                    c.DOB__c = cvRecordData[7]; 
                    c.Phone001__c = cvRecordData[8];
                    c.Phone002__c = cvRecordData[9];
                    c.Phone003__c = cvRecordData[10];
                    c.Phone004__c = cvRecordData[11];
                    c.Phone005__c = cvRecordData[12];
                    c.Email__c = cvRecordData[13];
                    c.Address001__c = cvRecordData[14];
                    c.Address002__c = cvRecordData[15];
                    c.Address003__c = cvRecordData[16];
                    c.Address004__c = cvRecordData[17];
                    c.Address005__c = cvRecordData[18];
                    c.NoMail__c = cvRecordData[19];
                    c.Sensitive__c = cvRecordData[20];              
                    c.List_Created_Date__c = cvRecordData[21];
                    c.List_Edited_Date__c = cvRecordData[22];
                    c.EDUSERID__c = cvRecordData[23]; 
                    c.Last_Mileage__c = decimal.valueOf(cvRecordData[24]);
                    c.Chasis_Number__c = cvRecordData[25];
                    c.Prodyr__c = cvRecordData[26];
                    c.ProdMth__c = cvRecordData[27];
                    c.Description = cvRecordData[28];
                    c.Model__c = cvRecordData[29];
                    c.Variant__c = cvRecordData[30];
                    c.FranchiseCode__c = cvRecordData[31];
                    c.Car_Registration_Number__c = cvRecordData[32];
                    RegisteredNumberIds.add(cvRecordData[32]);
                    c.Car_Registration_Date__c = cvRecordData[33];
                    c.Sales_Representative__c = cvRecordData[34];
                    c.FromDate__c = cvRecordData[35]; 
                    c.ToDate__c = cvRecordData[36]; 
                    c.RecordTypeId = recordTypeID;
                    c.Survey_Type__c = surveyType;
                    c.OwnerId = QueueId.Id;
                    RegisterdCasesMap.put(cvRecordData[32],c);  
                    casesToCreate.add(c);
                }
            }
            if (casesToCreate.size() > 0){
                List<Registered_Vehicle__c> vRegVehRecs =[SELECT id, Contact__c,Registration_Number__c, Franchise__c, Branch__c FROM Registered_Vehicle__c  WHERE 
                                                      Registration_Number__c in:RegisteredNumberIds ] ;
                for(Registered_Vehicle__c r :vRegVehRecs){
                    
                for(case c: casesToCreate){
                    RedsteredNumberID.put(c.Car_Registration_Number__c,r);
                        if(RegisterdCasesMap.containsKey(c.Car_Registration_Number__c) 
                           && (RedsteredNumberID.get(c.Car_Registration_Number__c).Registration_Number__c 
                           ==RegisterdCasesMap.get(c.Car_Registration_Number__c).Car_Registration_Number__c)){

                        c.Registered_Vehicle__c = RedsteredNumberID.get(c.Car_Registration_Number__c).id;
                             c.ContactId = RedsteredNumberID.get(c.Car_Registration_Number__c).Contact__c;
                             c.Franchise__c = RedsteredNumberID.get(c.Car_Registration_Number__c).Franchise__c;
                            c.Branch__c = RedsteredNumberID.get(c.Car_Registration_Number__c).Branch__c;
                        }
                }
                }
                insert casesToCreate;
                System.debug(casesToCreate.size());
                return casesToCreate.size();
            }
            return null;
        }catch(ListException le) {
            AuraHandledException leException = new AuraHandledException('The columns are not properly formatted. Please ensure the number of columns is correct and comma is the List separator.');
            leException.setMessage('The columns are not properly formatted. Please ensure the number of columns is correct and comma is the List separator.');
            throw leException;
        }catch(Exception e) {            
            String validationErr = '';
            if(e.getMessage().startsWith('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,')) {
                validationErr = e.getMessage().replace('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,', '');
                throw new AuraHandledException(validationErr);
            } else if(e.getMessage().startsWith('Insert failed. First exception on row 0; first error: STRING_TOO_LONG,')) {
                validationErr = e.getMessage().replace('Insert failed. First exception on row 0; first error: STRING_TOO_LONG,', 'Too many characters entered for');
                throw new AuraHandledException(validationErr);
            }
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static Integer createCSI(Id fileLatestVersionId,Id userId,String surveyType){
        ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion
                             WHERE Id = :fileLatestVersionId];

        System.debug(cv);
        try {
            List<Case> casesToCreate = new List<Case>();
            Blob cvFileBody = cv.VersionData;
            String cvFileBodyAsString = cvFileBody.toString();
            String[] cvFileLines = cvFileBodyAsString.split('\n');
            ID recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Surveys').getRecordTypeId();
            Group QueueId = [SELECT id, name FROM group WHERE type='Queue' AND name = 'Surveys'];            
            List<String> RegisteredNumberIds = new List<String>();
            map<string,Case> RegisterdCasesMap = new map<string,case>();
            map<string, Registered_Vehicle__c> RedsteredNumberID = new map<string, Registered_Vehicle__c>();
             for(Integer i = 0; i < cvFileLines.size(); i++) {
             
             }
            for(Integer i = 0; i < cvFileLines.size(); i++) {
                
                if (i!=0)
                {         
                    Case c = new Case();
                    String[] cvRecordData = cvFileLines[i].split(',');    
                    
                    c.Car_Registration_Date__c = cvRecordData[0];
                    system.debug(c.FromDate__c);
                    c.Customer_Name__c = cvRecordData[1];
                    c.Description = cvRecordData[2];
                    c.SEX__c = cvRecordData[3];
                    c.Email__c = cvRecordData[4];
                    system.debug(cvRecordData[4] + ' '+ c.Email__c);
                    c.Sales_Representative__c = cvRecordData[5];
                    c.Car_Registration_Number__c = cvRecordData[6];
                    RegisteredNumberIds.add(cvRecordData[6]);
                    c.Phone005__c = cvRecordData[7];               
                    c.Sensitive__c = cvRecordData[8];    
                    c.NoMail__c = cvRecordData[9];
                    c.Cash_Card_Issue__c = cvRecordData[10];
                    c.Ack_Recv__c = cvRecordData[11];
                    c.SMS_Sent__c = cvRecordData[12];
                    c.FromDate__c = cvRecordData[13]; 
                    system.debug(c.FromDate__c);
                    c.ToDate__c = cvRecordData[14]; 
                    c.RecordTypeId = recordTypeID;
                    c.Survey_Type__c = surveyType;
                    c.OwnerId = QueueId.Id;
                    RegisterdCasesMap.put(cvRecordData[6],c);
                    casesToCreate.add(c);
                }
            }
            if (casesToCreate.size() > 0){
                List<Registered_Vehicle__c> vRegVehRecs =[SELECT id, Contact__c,Registration_Number__c, Franchise__c, Branch__c FROM Registered_Vehicle__c  WHERE 
                                                      Registration_Number__c in:RegisteredNumberIds ] ;
                for(Registered_Vehicle__c r :vRegVehRecs){
                    
                for(case c: casesToCreate){
                    
                    RedsteredNumberID.put(c.Car_Registration_Number__c,r);
                        if(RegisterdCasesMap.containsKey(c.Car_Registration_Number__c) 
                           && (RedsteredNumberID.get(c.Car_Registration_Number__c).Registration_Number__c 
                           ==RegisterdCasesMap.get(c.Car_Registration_Number__c).Car_Registration_Number__c)){

                        c.Registered_Vehicle__c = RedsteredNumberID.get(c.Car_Registration_Number__c).id;
                        c.ContactId = RedsteredNumberID.get(c.Car_Registration_Number__c).Contact__c;
                        c.Franchise__c = RedsteredNumberID.get(c.Car_Registration_Number__c).Franchise__c;
                        c.Branch__c = RedsteredNumberID.get(c.Car_Registration_Number__c).Branch__c;
                        }
                }
                }
                insert casesToCreate;
                System.debug(casesToCreate.size());
                return casesToCreate.size();
            }
            return null;
        }catch(ListException le) {
            AuraHandledException leException = new AuraHandledException('The columns are not properly formatted. Please ensure the number of columns is correct and comma is the List separator.');
            leException.setMessage('The columns are not properly formatted. Please ensure the number of columns is correct and comma is the List separator.');
            throw leException;
        }catch(Exception e) {            
            String validationErr = '';
            if(e.getMessage().startsWith('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,')) {
                validationErr = e.getMessage().replace('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,', '');
                throw new AuraHandledException(validationErr);
            } else if(e.getMessage().startsWith('Insert failed. First exception on row 0; first error: STRING_TOO_LONG,')) {
                validationErr = e.getMessage().replace('Insert failed. First exception on row 0; first error: STRING_TOO_LONG,', 'Too many characters entered for');
                throw new AuraHandledException(validationErr);
            }
            System.debug('Exception: ' + e.getMessage() + '. Cause: ' + e.getCause() + '. Error at line: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static Integer createRA(Id fileLatestVersionId,Id userId,String surveyType){
        ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion
                             WHERE Id = :fileLatestVersionId];

        System.debug(cv);
        try {
            List<Case> casesToCreate = new List<Case>();
            Blob cvFileBody = cv.VersionData;
            String cvFileBodyAsString = cvFileBody.toString();
            String[] cvFileLines = cvFileBodyAsString.split('\n');
            ID recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Surveys').getRecordTypeId();
            Group QueueId = [SELECT id, name FROM group WHERE type='Queue' AND name = 'Surveys'];            
            List<String> RegisteredNumberIds = new List<String>();
            map<string,Case> RegisterdCasesMap = new map<string,case>();
            map<string, Registered_Vehicle__c> RedsteredNumberID = new map<string, Registered_Vehicle__c>();
             for(Integer i = 0; i < cvFileLines.size(); i++) {
             
             }
            for(Integer i = 0; i < cvFileLines.size(); i++) {
                
                if (i!=0)
                {         
                    Case c = new Case();
                    String[] cvRecordData = cvFileLines[i].split(',');    
                    
                    
                    c.Description = cvRecordData[0] + cvRecordData[1] + cvRecordData[2] + cvRecordData[3];
                    c.Car_Registration_Number__c = cvRecordData[1];
                    c.Priority = 'P4';
                    c.Status = 'New';
                    
                    RegisterdCasesMap.put(cvRecordData[1],c);
                    casesToCreate.add(c);
                }
            }
            if (casesToCreate.size() > 0){
                List<Registered_Vehicle__c> vRegVehRecs =[SELECT id, Contact__c,Registration_Number__c, Franchise__c, Branch__c FROM Registered_Vehicle__c  WHERE 
                                                      Registration_Number__c in:RegisteredNumberIds ] ;
                for(Registered_Vehicle__c r :vRegVehRecs){
                    
                for(case c: casesToCreate){
                    
                    RedsteredNumberID.put(c.Car_Registration_Number__c,r);
                        if(RegisterdCasesMap.containsKey(c.Car_Registration_Number__c) 
                           && (RedsteredNumberID.get(c.Car_Registration_Number__c).Registration_Number__c 
                           ==RegisterdCasesMap.get(c.Car_Registration_Number__c).Car_Registration_Number__c)){

                        c.Registered_Vehicle__c = RedsteredNumberID.get(c.Car_Registration_Number__c).id;
                        c.ContactId = RedsteredNumberID.get(c.Car_Registration_Number__c).Contact__c;
                        c.Franchise__c = RedsteredNumberID.get(c.Car_Registration_Number__c).Franchise__c;
                        c.Branch__c = RedsteredNumberID.get(c.Car_Registration_Number__c).Branch__c;
                        }
                }
                }
                insert casesToCreate;
                System.debug(casesToCreate.size());
                return casesToCreate.size();
            }
            return null;
        }catch(ListException le) {
            AuraHandledException leException = new AuraHandledException('The columns are not properly formatted. Please ensure the number of columns is correct and comma is the List separator.');
            leException.setMessage('The columns are not properly formatted. Please ensure the number of columns is correct and comma is the List separator.');
            throw leException;
        }catch(Exception e) {            
            String validationErr = '';
            if(e.getMessage().startsWith('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,')) {
                validationErr = e.getMessage().replace('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,', '');
                throw new AuraHandledException(validationErr);
            } else if(e.getMessage().startsWith('Insert failed. First exception on row 0; first error: STRING_TOO_LONG,')) {
                validationErr = e.getMessage().replace('Insert failed. First exception on row 0; first error: STRING_TOO_LONG,', 'Too many characters entered for');
                throw new AuraHandledException(validationErr);
            }
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}