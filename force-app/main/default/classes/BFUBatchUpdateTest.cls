@isTest
private class BFUBatchUpdateTest{
    
    @testSetup
    private static void setup() {
        List<Branch_Code_Name_Mapping__c> branchCodes = new List<Branch_Code_Name_Mapping__c>();

        Branch_Code_Name_Mapping__c kia = new Branch_Code_Name_Mapping__c();
        kia.Name = 'Kia';
        kia.Branch_Code__c = 'CCK';
        kia.PC_Code__c = 'KIAPC';
        branchCodes.add(kia);
        
        Branch_Code_Name_Mapping__c cit = new Branch_Code_Name_Mapping__c();
        cit.Name = 'Citroen';
        cit.Branch_Code__c = 'CCF';
        cit.PC_Code__c = 'CITPC';
        branchCodes.add(cit);
        
        Branch_Code_Name_Mapping__c mb = new Branch_Code_Name_Mapping__c();
        mb.Name = 'MB';
        mb.Branch_Code__c = 'CCI';
        mb.PC_Code__c = 'MBP';
        branchCodes.add(mb);
        
        Branch_Code_Name_Mapping__c mit = new Branch_Code_Name_Mapping__c();
        mit.Name = 'Mitsubishi';
        mit.Branch_Code__c = 'CCA';
        mit.PC_Code__c = 'MITPC';
        branchCodes.add(mit);
        
        insert branchCodes;
    }
    
    @isTest
    private static void testBFUBatchUpdate(){
        String email = 'my.preferred.consultant@cyclecarriage.test';        
        String branchCode = 'CCA';
        
        //Account pa = Test_DataFactory.createPerson(true, 'lastName', 'Customer');
        //pa = [SELECT Id, PersonContactId From Account WHERE Id = :pa.Id];
        //Contact con = new Contact(Id = pa.PersonContactId);
        //con.Email = email;
        //update con;
        
        //Create Sales Consultant
        Profile profile = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%' LIMIT 1];
        
        User consultant = new User();
        consultant.ProfileId = profile.Id;
        consultant.LastName = 'mei';
        consultant.Email = email;
        consultant.Username = 'test_datafactory' +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
        consultant.LocaleSidKey = 'en_US';
        consultant.TimeZoneSidKey = 'GMT';
        consultant.Alias = 'mt';        
        consultant.LanguageLocaleKey = 'en_US';
        consultant.EmailEncodingKey = 'UTF-8';
        consultant.Is_Eligible_Opp_Owner__c = true;
        consultant.ExcludeFromPre_existingOpportuntity__c = true;
        consultant.IsActive = true;
        insert consultant;
        
        Campaign camp = new Campaign();
        camp.Name = 'Event - Fb';
        camp.Type = 'Events';
        camp.Branch_Code__c = branchCode;
        insert camp;
        
        String path = 'bulkfile1' + '.csv';
        ContentVersion contentVersion = new ContentVersion(
            Title = 'bulkfile1',   
            PathOnClient = path,
            VersionData = Blob.valueOf(getBlob10('bulkfile1')),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        List<BulkFileUpload__c> bulkFileUploads = new List<BulkFileUpload__c>();
        for(Integer i = 0; i <= 3; i++){
            BulkFileUpload__c bfu = new BulkFileUpload__c();         
            bfu.DocumentId__c = contentVersion.Id;
            bfu.Type__c = 'S';
            bfu.Branch_Code__c = branchCode;
            bfu.Email__c = email;
            bfu.EventDate__c = Date.today();
            bfu.Event_Name__c = camp.ID;
            bfu.Event_Time__c = '10:10';
            bfu.First_Name__c = 'fn name1';
            bfu.Last_Name__c = 'ln name1';
            bfu.Lead_Source__c = 'Saleswhale';
            bfu.Mobile__c = '96741073';
            //bfu.Models_Interested__c = modelCCA.Id;
            bfu.No_of_Pax__c = '';
            bfu.Preferred_Sales_Consultant__c = consultant.Email;
            bfu.Showroom__c = '';
            bfu.Status__c = 'O';
            bfu.Comments__c = 'testing';
    		bulkFileUploads.add(bfu);

        }
        insert bulkFileUploads;
        
        Test.startTest();
        BFUBatchUpdate bfuBatchUpdate = new BFUBatchUpdate(bulkFileUploads, contentVersion.Id);
        Database.executeBatch(bfuBatchUpdate);
        Test.stopTest();
    }
    
    static testmethod void test(){
        
        //create showrooms
        Showroom__c TestShow =  new 
            Showroom__c(Name='Alexandra',Address_Line_1__c='Address',City__c='SG',Country__c='SG');   
        insert TestShow;
        
        Showroom__c TestShow1 =  new 
            Showroom__c(Name='Ubi',Address_Line_1__c='Address',City__c='SG',Country__c='SG');   
        insert TestShow1;
        
        // create users
        Profile userProfile = [select id from profile where name like '%System Administrator%' limit 1];               
        
        User u = new user();
        u.LastName = 'michelle';
        u.Email = 'michelle.chong@cyclecarriage.com.sg';
        u.Username = 'test_datafactory' +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.Alias = 'ms';
        
        if(userProfile!=null) {
            u.ProfileID = userProfile.id; 
        }
        
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';    
        u.Is_Eligible_Opp_Owner__c = true;
        u.IsActive = true;
        insert u;
        
        User u1 = new user();
        u1.LastName = 'savita';
        u1.Email = 'savita.contract@jcclgroup.com';
        u1.Username = 'test_datafactory' +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
        u1.LocaleSidKey = 'en_US';
        u1.TimeZoneSidKey = 'GMT';
        u1.Alias = 'sa';
        
        if(userProfile!=null) {
            u1.ProfileID = userProfile.id; 
        }
        
        u1.LanguageLocaleKey = 'en_US';
        u1.EmailEncodingKey = 'UTF-8';
        u1.Is_Eligible_Opp_Owner__c = true;
        u1.IsActive = true;
        insert u1;
        
        User u2 = new user();
        u2.LastName = 'archana';
        u2.Email = 'archana.patlolla@jcclgroup.com';
        u2.Username = 'test_datafactory' +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
        u2.LocaleSidKey = 'en_US';
        u2.TimeZoneSidKey = 'GMT';
        u2.Alias = 'sa';
        
        if(userProfile!=null) {
            u2.ProfileID = userProfile.id; 
        }
        
        u2.LanguageLocaleKey = 'en_US';
        u2.EmailEncodingKey = 'UTF-8';
        u2.Is_Eligible_Opp_Owner__c = true;
        u2.IsActive = true;
        insert u2;
        
        User u3 = new user();
        u3.LastName = 'vince';
        u3.Email = 'vince.ng@cyclecarriage.com.sg';
        u3.Username = 'test_datafactory' +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
        u3.LocaleSidKey = 'en_US';
        u3.TimeZoneSidKey = 'GMT';
        u3.Alias = 'va';
        
        if(userProfile!=null) {
            u3.ProfileID = userProfile.id; 
        }
        
        u3.LanguageLocaleKey = 'en_US';
        u3.EmailEncodingKey = 'UTF-8';
        u3.Is_Eligible_Opp_Owner__c = true;
        u3.IsActive = true;
        insert u3;    
        
        User u4 = new user();
        u4.LastName = 'chuachri';
        u4.Email = 'christina.chua@cyclecarriage.com.sg';
        u4.Username = 'test_datafactory' +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
        u4.LocaleSidKey = 'en_US';
        u4.TimeZoneSidKey = 'GMT';
        u4.Alias = 'cha';
        
        if(userProfile!=null) {
            u4.ProfileID = userProfile.id; 
        }
        
        u4.LanguageLocaleKey = 'en_US';
        u4.EmailEncodingKey = 'UTF-8';
        u4.Is_Eligible_Opp_Owner__c = true;
        u4.IsActive = true;
        insert u4;
        
        User u5 = new user();
        u5.LastName = 'nilo';
        u5.Email = 'nilojan.alvis@jcclgroup.com';
        u5.Username = 'test_datafactory' +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
        u5.LocaleSidKey = 'en_US';
        u5.TimeZoneSidKey = 'GMT';
        u5.Alias = 'nj';
        
        if(userProfile!=null) {
            u5.ProfileID = userProfile.id; 
        }
        
        u5.LanguageLocaleKey = 'en_US';
        u5.EmailEncodingKey = 'UTF-8';
        u5.Is_Eligible_Opp_Owner__c = true;
        u5.IsActive = true;
        insert u5;  
        
        User u6 = new user();
        u6.LastName = 'peck';
        u6.Email = 'peckkim.chua@cyclecarriage.com.sg';
        u6.Username = 'test_datafactory' +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
        u6.LocaleSidKey = 'en_US';
        u6.TimeZoneSidKey = 'GMT';
        u6.Alias = 'pk';
        
        if(userProfile!=null) {
            u6.ProfileID = userProfile.id; 
        }
        
        u6.LanguageLocaleKey = 'en_US';
        u6.EmailEncodingKey = 'UTF-8';
        u6.Is_Eligible_Opp_Owner__c = true;
        u6.IsActive = true;
        insert u6;
        
        // create users to exclude from pre-existing opp
        User u11 = new user();
        u11.LastName = 'mei';
        u11.Email = 'meiting.koh@cyclecarriage.com.sg';
        u11.Username = 'test_datafactory' +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
        u11.LocaleSidKey = 'en_US';
        u11.TimeZoneSidKey = 'GMT';
        u11.Alias = 'mt';
        
        if(userProfile!=null) {
            u11.ProfileID = userProfile.id; 
        }
        
        u11.LanguageLocaleKey = 'en_US';
        u11.EmailEncodingKey = 'UTF-8';
        u11.Is_Eligible_Opp_Owner__c = false;
        u11.ExcludeFromPre_existingOpportuntity__c = true;
        u11.IsActive = true;
        insert u11;
        
        User u12 = new user();
        u12.LastName = 'bry';
        u12.Email = 'bryan.heng@cyclecarriage.com.sg';
        u12.Username = 'test_datafactory' +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
        u12.LocaleSidKey = 'en_US';
        u12.TimeZoneSidKey = 'GMT';
        u12.Alias = 'bh';
        
        if(userProfile!=null) {
            u12.ProfileID = userProfile.id; 
        }
        
        u12.LanguageLocaleKey = 'en_US';
        u12.EmailEncodingKey = 'UTF-8';
        u12.Is_Eligible_Opp_Owner__c = false;
        u12.ExcludeFromPre_existingOpportuntity__c = true;
        u12.IsActive = true;
        insert u12;

        Account acc = Test_DataFactory.createPerson(false, 'test'+String.valueOf(Math.random()).substring(2, 6), 'Customer');
        acc.Phone='9988998899';
        acc.PersonEmail = 'jimdigital19@gmail.com';
        insert acc;
        
        Account jccAcc = Test_DataFactory.createAccount(true, 'jccTestAccount000');

        //create contacts
        Contact con = new Contact();
        con.LastName            = 'test lname';
        // con.FirstName           = 'test fname'; 
        con.NRIC_Passport_No__c = 'test fname';
        con.Email               = 'jimdigital19@gmail.com';
        con.Birthdate = Date.today();
        con.AccountId  = jccAcc.id;
        con.Account__c = acc.Id;
        insert con;
        
        
        Account acc1 = Test_DataFactory.createPerson(false, 'test1'+String.valueOf(Math.random()).substring(2, 6), 'Customer');
        acc1.Phone='9988998898';
        acc1.PersonEmail = 'jimdigital29@gmail.com';
        insert acc1;

        Contact con1 = new Contact();
        con1.NRIC_Passport_No__c = 'test fname';
        con1.LastName = 'l name 22';
        con1.Email               = 'parishi@rhad.agency';
        con1.Birthdate  = Date.today();
        con1.AccountId  = jccAcc.id;
        con1.Account__c = acc1.Id;
        insert con1;
        
        Opportunity opptc1 = new Opportunity();
        opptc1.Name ='New test Opportunity contact - '+ 'test 1';
        opptc1.StageName = 'Open';
        opptc1.Amount = 3000;
        opptc1.CloseDate = Date.today().addDays(5);
        opptc1.Contact_Person__c = con.id;
        opptc1.Branch_Code__c = 'CCA';
        opptc1.OwnerId = u12.id;
        opptc1.Account__c = acc1.Id;
        insert opptc1;
        
        Campaign CampaignObj = new Campaign();
        CampaignObj.Name           = 'Event - Fb';
        CampaignObj.Type           = 'Events';
        CampaignObj.Branch_Code__c = 'CCK';
        insert CampaignObj;
        
        
        String path = 'bulkfile1' + '.csv';
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'bulkfile1',   
            PathOnClient = path,
            VersionData = Blob.valueOf(getBlob10('bulkfile1')),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        
        list<Model__c> models = new list<Model__c>();
        Model__c model_CCA = new Model__c(Name = 'CCA Model', Branch_Code__c = 'CCA', DWH_Model_ID__c = 'CCADWH', Franchise_Code__c = 'MITPC');
        insert model_CCA;
        
        Model__c model_CCF = new Model__c(Name = 'CCF Model', Branch_Code__c = 'CCF', DWH_Model_ID__c = 'CCFDWH', Franchise_Code__c = 'CITPC');
        insert model_CCF;
        
        Model__c model_CCK = new Model__c(Name = 'CCK Model', Branch_Code__c = 'CCK', DWH_Model_ID__c = 'CCKDWH', Franchise_Code__c = 'KIAPC');
        insert model_CCK;
        
        Model__c model_CCI = new Model__c(Name = 'CCI Model', Branch_Code__c = 'CCI', DWH_Model_ID__c = 'CCIDWH', Franchise_Code__c = 'MBP');
        insert model_CCI;
        
        BulkFileUpload__c s011 = new BulkFileUpload__c(); 
        
        s011.DocumentId__c = contentVersionSelect.Id;
        s011.Type__c = '';
        s011.Branch_Code__c='CCA';
        s011.Email__c='testing78900@yopmail.com'; 
        String eventdt11 = '10/10/2019';
        s011.EventDate__c=Date.parse(eventdt11);
        s011.Event_Name__c=CampaignObj.ID;
        s011.Event_Time__c='10:10';
        s011.First_Name__c='fn name1';
        s011.Last_Name__c='ln name1';
        s011.Lead_Source__c='Saleswhale';
        s011.Mobile__c='96741073';
        s011.Models_Interested__c = model_CCA.Id;
        s011.No_of_Pax__c='';
        s011.Preferred_Sales_Consultant__c='archana.pat33lolla@jcclgroup.com';
        s011.Showroom__c='';
        s011.Status__c = 'O';
        s011.Comments__c = 'testing';                                                              
        s011.SMS__c = true;
        s011.Call__c = true;
        s011.isEmail__c = true;
        s011.fax__c = true;
        insert s011;
        
        
        BulkFileUpload__c s01 = new BulkFileUpload__c(); 
        
        s01.DocumentId__c = contentVersionSelect.Id;
        s01.Type__c = '';
        s01.Branch_Code__c='CCF';
        s01.Email__c='testing78900@yopmail.com'; 
        String eventdt1 = '10/10/2019';
        s01.EventDate__c=Date.parse(eventdt1);
        s01.Event_Name__c=CampaignObj.ID;
        s01.Event_Time__c='10:10';
        s01.First_Name__c='fn name1';
        s01.Last_Name__c='ln name1';
        s01.Lead_Source__c='Saleswhale';
        s01.Mobile__c='96741073';
        s01.Models_Interested__c = model_CCF.Id;
        s01.No_of_Pax__c='';
        s01.Preferred_Sales_Consultant__c='michelle.chong@cyclecarriage.com.sg';
        s01.Showroom__c='';
        s01.Status__c = 'O';
        s01.Comments__c = 'testing';                                                              
        s01.SMS__c = true;
        s01.Call__c = true;
        s01.isEmail__c = true;
        s01.fax__c = true;
        insert s01;
        
        BulkFileUpload__c s = new BulkFileUpload__c(); 
        
        s.DocumentId__c = contentVersionSelect.Id;
        s.Type__c = '';
        s.Branch_Code__c='CCF';
        s.Email__c='testing78900@yopmail.com'; 
        String eventdt = '10/10/2019';
        s.EventDate__c=Date.parse(eventdt);
        s.Event_Name__c=CampaignObj.ID;
        s.Event_Time__c='10:10';
        s.First_Name__c='fn name1';
        s.Last_Name__c='ln name1';
        s.Lead_Source__c='Chat';
        s.Mobile__c='96741073';
        s.Models_Interested__c = model_CCF.Id;
        s.No_of_Pax__c='';
        s.Preferred_Sales_Consultant__c='mich.chong@cyclecarriage.com.sg';
        s.Showroom__c='';
        s.Status__c = 'O';
        s.Comments__c = 'testing';                                                              
        s.SMS__c = true;
        s.Call__c = true;
        s.isEmail__c = true;
        s.fax__c = true;
        insert s;
        
        
        BulkFileUpload__c xs = new BulkFileUpload__c(); 
        
        xs.DocumentId__c = contentVersionSelect.Id;
        xs.Type__c = '';
        xs.Branch_Code__c='CCF';
        xs.Email__c='testing78900@yopmail.com'; 
        eventdt = '10/10/2019';
        xs.EventDate__c=Date.parse(eventdt);
        xs.Event_Name__c=CampaignObj.ID;
        xs.Event_Time__c='10:10';
        xs.First_Name__c='fn name1';
        xs.Last_Name__c='ln name1';
        xs.Lead_Source__c='Saleswhale';
        xs.Mobile__c='96741073';
        xs.Models_Interested__c = model_CCF.Id;
        xs.No_of_Pax__c='';
        xs.Preferred_Sales_Consultant__c='savita.contract@jcclgroup.com';
        xs.Showroom__c='';
        xs.Status__c = 'O';
        xs.Comments__c = 'testing';                                                              
        xs.SMS__c = true;
        xs.Call__c = true;
        xs.isEmail__c = true;
        xs.fax__c = true;
        insert xs;
        
        
        BulkFileUpload__c xs1 = new BulkFileUpload__c(); 
        
        xs1.DocumentId__c = contentVersionSelect.Id;
        xs1.Type__c = '';
        xs1.Branch_Code__c='CCF';
        xs1.Email__c='testing78900@yopmail.com'; 
        eventdt = '10/10/2019';
        xs1.EventDate__c=Date.parse(eventdt);
        xs1.Event_Name__c=CampaignObj.ID;
        xs1.Event_Time__c='10:10';
        xs1.First_Name__c='fn name1';
        xs1.Last_Name__c='ln name1';
        xs1.Lead_Source__c='Saleswhale';
        xs1.Mobile__c='96741073';
        xs1.Models_Interested__c = model_CCF.Id;
        xs1.No_of_Pax__c='';
        xs1.Preferred_Sales_Consultant__c='archana.patlolla@jcclgroup.com';
        xs1.Showroom__c='';
        xs1.Status__c = 'O';
        xs1.Comments__c = 'testing';                                                              
        xs1.SMS__c = true;
        xs1.Call__c = true;
        xs1.isEmail__c = true;
        xs1.fax__c = true;
        insert xs1;
        
        BulkFileUpload__c s0 = new BulkFileUpload__c(); 
        
        s0.DocumentId__c = contentVersionSelect.Id;
        s0.Type__c = '';
        s0.Branch_Code__c='CCA';
        s0.Email__c='jimdigital19@gmail.com'; 
        eventdt = '10/10/2019';
        s0.EventDate__c=Date.parse(eventdt);
        s0.Event_Name__c=CampaignObj.ID;
        s0.Event_Time__c='10:10';
        s0.First_Name__c='fn name1';
        s0.Last_Name__c='ln name1';
        s0.Lead_Source__c='Chat';
        s0.Mobile__c='96741073';
        s0.Models_Interested__c = model_CCA.Id;
        s0.No_of_Pax__c='';
        s0.Preferred_Sales_Consultant__c='testxyz@123.com';
        s0.Showroom__c='';
        s0.Status__c = 'O';
        s0.Comments__c = 'testing';                                                              
        s0.SMS__c = true;
        s0.Call__c = true;
        s0.isEmail__c = true;
        s0.fax__c = true;
        insert s0;
        
        BulkFileUpload__c s2 = new BulkFileUpload__c(); 
        
        s2.DocumentId__c = contentVersionSelect.Id;
        s2.Type__c = '';
        s2.Branch_Code__c='CCA';
        s2.Email__c='jimdigital19@gmail.com'; 
        eventdt = '10/10/2019';
        s2.EventDate__c=Date.parse(eventdt);
        s2.Event_Name__c=CampaignObj.ID;
        s2.Event_Time__c='10:10';
        s2.First_Name__c='fn name1';
        s2.Last_Name__c='ln name1';
        s2.Lead_Source__c='Instagram';
        s2.Mobile__c='96741073';
        s2.Models_Interested__c = model_CCA.Id;
        s2.No_of_Pax__c='';
        s2.Preferred_Sales_Consultant__c='vince.ng@cyclecarriage.com.sg';
        s2.Showroom__c='';
        s2.Status__c = 'O';
        s2.Comments__c = 'testing';                                                      
        s2.SMS__c = true;
        s2.Call__c = true;
        s2.isEmail__c = true;
        s2.fax__c = true;
        insert s2;
        
        BulkFileUpload__c s3 = new BulkFileUpload__c(); 
        
        s3.DocumentId__c = contentVersionSelect.Id;
        s3.Type__c = '';
        s3.Branch_Code__c='CCA';
        s3.Email__c='jimdigital19@gmail.com'; 
        eventdt = '10/10/2019';
        s3.EventDate__c=Date.parse(eventdt);
        s3.Event_Name__c= CampaignObj.id;
        s3.Event_Time__c='10:10';
        s3.First_Name__c='fn name1';
        s3.Last_Name__c='ln name1';
        s3.Lead_Source__c='Instagram';
        s3.Mobile__c='96741073';
        s3.Models_Interested__c = model_CCA.Id;
        s3.No_of_Pax__c='';
        s3.Preferred_Sales_Consultant__c='michelle.chong@cyclecarriage.com.sg';
        s3.Showroom__c='';
        s3.Status__c = 'O';
        s3.Comments__c = 'testing';                                              
        s3.SMS__c = true;
        s3.Call__c = true;
        s3.isEmail__c = true;
        s3.fax__c = true;   
        insert s3;
        
        
        BulkFileUpload__c s31 = new BulkFileUpload__c(); 
        
        s31.DocumentId__c = contentVersionSelect.Id;
        s31.Type__c = '';
        s31.Branch_Code__c='CCA';
        s31.Email__c='jimdigital19@gmail.com'; 
        string eventdt31 = '10/10/2019';
        s31.EventDate__c=Date.parse(eventdt31);
        s31.Event_Name__c=CampaignObj.id;
        s31.Event_Time__c='10:10';
        s31.First_Name__c='fn name1';
        s31.Last_Name__c='ln name1';
        s31.Lead_Source__c='Instagram';
        s31.Mobile__c='96741073';
        s31.Models_Interested__c = model_CCA.Id;
        s31.No_of_Pax__c='';
        s31.Preferred_Sales_Consultant__c='archana.pat33lolla@jcclgroup.com';
        s31.Showroom__c='';
        s31.Status__c = 'O';
        s31.Comments__c = 'testing';                                              
        s31.SMS__c = true;
        s31.Call__c = true;
        s31.isEmail__c = true;
        s31.fax__c = true;   
        insert s31;
        
        
        BulkFileUpload__c s311 = new BulkFileUpload__c(); 
        
        s311.DocumentId__c = contentVersionSelect.Id;
        s311.Type__c = '';
        s311.Branch_Code__c='CCK';
        s311.Email__c='peterlumpengleong@gmail.com'; 
        string eventdt311 = '10/10/2019';
        s311.EventDate__c=Date.parse(eventdt311);
        s311.Event_Name__c=CampaignObj.id;
        s311.Event_Time__c='10:10';
        s311.First_Name__c='fn name1';
        s311.Last_Name__c='ln name1';
        s311.Lead_Source__c='Instagram';
        s311.Mobile__c='96741073';
        s311.Models_Interested__c = model_CCK.Id;
        s311.No_of_Pax__c='';
        s311.Preferred_Sales_Consultant__c='archana.patlolla@jcclgroup.com';
        s311.Showroom__c='';
        s311.Status__c = 'O';
        s311.Comments__c = 'testing';                                              
        s311.SMS__c = true;
        s311.Call__c = true;
        s311.isEmail__c = true;
        s311.fax__c = true;   
        insert s311;
        
        BulkFileUpload__c sr = new BulkFileUpload__c(); 
        sr.DocumentId__c = contentVersionSelect.Id;
        sr.Type__c = '';
        sr.Branch_Code__c='CCA';
        sr.Email__c='leehwa134@gmail.com'; 
        eventdt = '10/10/2019';
        sr.EventDate__c=Date.parse(eventdt);
        sr.Event_Name__c=campaignObj.id;
        sr.Event_Time__c='10:10';
        sr.First_Name__c='fn name1';
        sr.Last_Name__c='ln name1';
        sr.Lead_Source__c='Instagram';
        sr.Mobile__c='96741073';
        sr.Models_Interested__c = model_CCA.Id;
        sr.No_of_Pax__c='';
        sr.Preferred_Sales_Consultant__c='christina.chua@cyclecarriage.com.sg';
        sr.Showroom__c='Alexandra';
        sr.Status__c = 'O';
        sr.Comments__c = 'testing';                                              
        sr.SMS__c = true;
        sr.Call__c = true;
        sr.isEmail__c = true;
        sr.fax__c = true;     
        insert sr;
        
        BulkFileUpload__c sr1 = new BulkFileUpload__c(); 
        sr1.DocumentId__c = contentVersionSelect.Id;
        sr1.Type__c = '';
        sr1.Branch_Code__c='CCK';
        sr1.Email__c='gandhalasl188@gmail.com'; 
        eventdt = '10/10/2019';
        sr1.EventDate__c=Date.parse(eventdt);
        sr1.Event_Name__c=campaignObj.id;
        sr1.Event_Time__c='10:10';
        sr1.First_Name__c='fn name1';
        sr1.Last_Name__c='ln name1';
        sr1.Lead_Source__c='Instagram';
        sr1.Mobile__c='96741073';
        sr1.Models_Interested__c = model_CCK.Id;
        sr1.No_of_Pax__c='';
        sr1.Preferred_Sales_Consultant__c='christina.chua@cyclecarriage.com.sg';
        sr1.Showroom__c='Alexandra';
        sr1.Status__c = 'O';
        sr1.Comments__c = 'testing';                                      
        sr1.SMS__c = true;
        sr1.Call__c = true;
        sr1.isEmail__c = true;
        sr1.fax__c = true;        
        insert sr1;
        
        BulkFileUpload__c sr2 = new BulkFileUpload__c(); 
        sr2.DocumentId__c = contentVersionSelect.Id;
        sr2.Type__c = '';
        sr2.Branch_Code__c='CCF';
        sr2.Email__c='gandhalasl188@gmail.com'; 
        eventdt = '10/10/2019';
        sr2.EventDate__c=Date.parse(eventdt);
        sr2.Event_Name__c=campaignObj.id;
        sr2.Event_Time__c='10:10';
        sr2.First_Name__c='fn name1';
        sr2.Last_Name__c='ln name1';
        sr2.Lead_Source__c='Instagram';
        sr2.Mobile__c='96741073';
        sr2.Models_Interested__c = model_CCF.Id;
        sr2.No_of_Pax__c='';
        sr2.Preferred_Sales_Consultant__c='archana.pat33lolla@jcclgroup.com';
        sr2.Showroom__c='Alexandra';
        sr2.Status__c = 'O';
        sr2.Comments__c = 'testing';                                      
        sr2.SMS__c = true;
        sr2.Call__c = true;
        sr2.isEmail__c = true;
        sr2.fax__c = true;
        insert sr2;         
        
        
        BulkFileUpload__c sr3 = new BulkFileUpload__c(); 
        sr3.DocumentId__c = contentVersionSelect.Id;
        sr3.Type__c = '';
        sr3.Branch_Code__c='CCK';
        sr3.Email__c='leehwa134@gmail.com'; 
        eventdt = '10/10/2019';
        sr3.EventDate__c=Date.parse(eventdt);
        sr3.Event_Name__c=campaignObj.id;
        sr3.Event_Time__c='10:10';
        sr3.First_Name__c='fn name1';
        sr3.Last_Name__c='ln name1';
        sr3.Lead_Source__c='Saleswhale';
        sr3.Mobile__c='96741073';
        sr3.Models_Interested__c = model_CCK.Id;
        sr3.No_of_Pax__c='';
        sr3.Preferred_Sales_Consultant__c='archana.pat33lolla@jcclgroup.com';
        sr3.Showroom__c='Alexandra';
        sr3.Status__c = 'O';
        sr3.Comments__c = 'testing';                              
        sr3.SMS__c = true;
        sr3.Call__c = true;
        sr3.isEmail__c = true;
        sr3.fax__c = true;
        insert sr3; 
        
        
        BulkFileUpload__c sr4 = new BulkFileUpload__c(); 
        sr4.DocumentId__c = contentVersionSelect.Id;
        sr4.Type__c = '';
        sr4.Branch_Code__c='CCK';
        sr4.Email__c='xyzemail123@yopmail.com'; 
        eventdt = '10/10/2019';
        sr4.EventDate__c=Date.parse(eventdt);
        sr4.Event_Name__c=campaignObj.id;
        sr4.Event_Time__c='10:10';
        sr4.First_Name__c='fn name1';
        sr4.Last_Name__c='ln name1';
        sr4.Lead_Source__c='Chat';
        sr4.Mobile__c='96741073';
        sr4.Models_Interested__c = model_CCK.Id;
        sr4.No_of_Pax__c='';
        sr4.Preferred_Sales_Consultant__c='archana.patlolla@jcclgroup.com';
        sr4.Showroom__c='Alexandra';
        sr4.Status__c = 'O';
        sr4.Comments__c = 'testing';                      
        sr4.SMS__c = true;
        sr4.Call__c = true;
        sr4.isEmail__c = true;
        sr4.fax__c = true;
        insert sr4; 
        
        
        BulkFileUpload__c sr5 = new BulkFileUpload__c(); 
        sr5.DocumentId__c = contentVersionSelect.Id;
        sr5.Type__c = '';
        sr5.Branch_Code__c='CCK';
        sr5.Email__c='parishi@rhad.agency'; 
        eventdt = '10/10/2019';
        sr5.EventDate__c=Date.parse(eventdt);
        sr5.Event_Name__c=campaignObj.id;
        sr5.Event_Time__c='10:10';
        sr5.First_Name__c='fn name1';
        sr5.Last_Name__c='ln name1';
        sr5.Lead_Source__c='Instagram';
        sr5.Mobile__c='96741073';
        sr5.Models_Interested__c = model_CCK.Id;
        sr5.No_of_Pax__c='';
        sr5.Preferred_Sales_Consultant__c='nilojan.alvis@jcclgroup.com';
        sr5.Showroom__c='Alexandra';
        sr5.Status__c = 'O';
        sr5.Comments__c = 'testing';                      
        sr5.SMS__c = true;
        sr5.Call__c = true;
        sr5.isEmail__c = true;
        sr5.fax__c = true;
        insert sr5; 
        
        BulkFileUpload__c t = new BulkFileUpload__c(); 
        
        t.DocumentId__c = contentVersionSelect.Id;
        t.Type__c = '';
        t.Branch_Code__c='CCA';
        t.Email__c='andylohtm@gmail.com'; 
        eventdt = '10/10/2019';
        t.EventDate__c=Date.parse(eventdt);
        t.Event_Name__c=campaignObj.id;
        t.Event_Time__c='10:10';
        t.First_Name__c='fn name1';
        t.Last_Name__c='ln name1';
        t.Lead_Source__c='Chat';
        t.Mobile__c='96741073';
        t.Models_Interested__c = model_CCA.Id;
        t.No_of_Pax__c='';
        t.Preferred_Sales_Consultant__c='archana.pat33lolla@jcclgroup.com';
        t.Showroom__c='';
        t.Status__c = 'O';
        t.Comments__c = 'testing';              
        t.SMS__c = true;
        t.Call__c = true;
        t.isEmail__c = true;
        t.fax__c = true;
        insert t;
        
        
        BulkFileUpload__c t1 = new BulkFileUpload__c(); 
        
        t1.DocumentId__c = contentVersionSelect.Id;
        t1.Type__c = '';
        t1.Branch_Code__c='CCA';
        t1.Email__c='andylohtm@gmail.com'; 
        eventdt = '10/10/2019';
        t1.EventDate__c=Date.parse(eventdt);
        t1.Event_Name__c=campaignObj.id;
        t1.Event_Time__c='10:10';
        t1.First_Name__c='fn name1';
        t1.Last_Name__c='ln name1';
        t1.Lead_Source__c='Saleswhale';
        t1.Mobile__c='96741073';
        t1.Models_Interested__c = model_CCA.Id;
        t1.No_of_Pax__c='';
        t1.Preferred_Sales_Consultant__c='';
        t1.Showroom__c='';
        t1.Status__c = 'O';
        t1.Comments__c = 'testing';              
        t1.SMS__c = true;
        t1.Call__c = true;
        t1.isEmail__c = true;
        t1.fax__c = true;
        insert t1;
        
        BulkFileUpload__c t2 = new BulkFileUpload__c(); 
        
        t2.DocumentId__c = contentVersionSelect.Id;
        t2.Type__c = '';
        t2.Branch_Code__c='CCK';
        t2.Email__c='andylohtm@gmail.com'; 
        eventdt = '10/10/2019';
        t2.EventDate__c=Date.parse(eventdt);
        t2.Event_Name__c=campaignObj.id;
        t2.Event_Time__c='10:10';
        t2.First_Name__c='fn name1';
        t2.Last_Name__c='ln name1';
        t2.Lead_Source__c='Chat';
        t2.Mobile__c='96741073';
        t2.Models_Interested__c = model_CCK.Id;
        t2.No_of_Pax__c='';
        t2.Preferred_Sales_Consultant__c='christiana.chang=cyclecarriage.com.sg@example.com';
        t2.Showroom__c='';
        t2.Status__c = 'O';
        t2.Comments__c = 'testing';        
        t2.SMS__c = true;
        t2.Call__c = true;
        t2.isEmail__c = true;
        t2.fax__c = true;
        insert t2;
        
        BulkFileUpload__c s1 = new BulkFileUpload__c(); 
        s1.DocumentId__c = contentVersionSelect.Id;
        s1.Type__c = 'S';
        s1.Total_No_of_Recs__c = 4;
        s1.No_of_Recs_Failed__c = 0;
        s1.No_of_OK_Records__c = 4;
        s1.SMS__c = true;
        s1.Call__c = true;
        s1.isEmail__c = true;
        s1.fax__c = true;
        insert s1;	
        
        
        BulkFileUpload__c sr6 = new BulkFileUpload__c(); 
        sr6.DocumentId__c = contentVersionSelect.Id;
        sr6.Type__c = '';
        sr6.Branch_Code__c='CCK';
        sr6.Email__c='ben@gmail.com'; 
        eventdt = '10/10/2019';
        sr6.EventDate__c=Date.parse(eventdt);
        sr6.Event_Name__c=campaignObj.id;
        sr6.Event_Time__c='10:10';
        sr6.First_Name__c='fn name1';
        sr6.Last_Name__c='ln name1';
        sr6.Lead_Source__c='Instagram';
        sr6.Mobile__c='96741073';
        sr6.Models_Interested__c = model_CCK.Id;
        sr6.No_of_Pax__c='';
        sr6.Preferred_Sales_Consultant__c='archana.pat33lolla@jcclgroup.com';
        sr6.Showroom__c='Alexandra';
        sr6.Status__c = 'O';
        sr6.Comments__c = 'testing';
        sr6.SMS__c = true;
        sr6.Call__c = true;
        sr6.isEmail__c = true;
        sr6.fax__c = true;
        insert sr6;
        
        BulkFileUpload__c sr7 = new BulkFileUpload__c(); 
        sr7.DocumentId__c = contentVersionSelect.Id;
        sr7.Type__c = '';
        sr7.Branch_Code__c='CCK';
        sr7.Email__c='ben@gmail.com'; 
        eventdt = '10/10/2019';
        sr7.EventDate__c=Date.parse(eventdt);
        sr7.Event_Name__c=campaignObj.id;
        sr7.Event_Time__c='10:10';
        sr7.First_Name__c='fn name1';
        sr7.Last_Name__c='ln name1';
        sr7.Lead_Source__c='Instagram';
        sr7.Mobile__c='96741073';
        sr7.Models_Interested__c = model_CCK.Id;
        sr7.No_of_Pax__c='';
        sr6.Preferred_Sales_Consultant__c = '';
        sr7.Showroom__c='Alexandra';
        sr7.Status__c = 'O';
        sr7.Comments__c = 'testing';
        sr7.SMS__c = true;
        sr7.Call__c = true;
        sr7.isEmail__c = true;
        sr7.fax__c = true;
        insert sr7;
        
        List<BulkFileUpload__c> listBFU = [Select Id, Branch_Code__c, Name, DocumentId__c, 
                                           Email__c, EventDate__c, Event_Name__c, Event_Time__c,
                                           First_Name__c, Last_Name__c, Lead_Source__c, Mobile__c,
                                           Models_Interested__c, No_of_Pax__c, Preferred_Sales_Consultant__c,
                                           Showroom__c, comments__c
                                           from BulkFileUpload__c 
                                           where DocumentId__c =:contentVersionSelect.id AND Status__c='O'];
        Test.startTest();
        BFUBatchUpdate bfu = New BFUBatchUpdate(listBFU, contentVersionSelect.id);
        id batchId = Database.executeBatch(bfu, 100);
        Test.stopTest();
    }
    
    public static String getBlob10(String type){
        //add the other file types sample below
        return 'LEAD SOURCE,FIRST NAME,LAST NAME,MOBILE,EMAIL,MODELS INTERESTED,EVENT DATE,EVENT TIME,BRANCH CODE,PREFERRED SALES CONSULTANT,SHOWROOM,NO OF PAX,EVENT NAME,COMMENTS\nFacebook,Bulk,uploading,99999999,bfu33133@yopmail.com,a0rp0000000lVTfAAM,13/09/2019,10:00,CCK,,Alexandra,10,701O0000000SJMZIA4,comm1\nInstagram,Bulk,Upload Testing,90000000,bfu33133@yopmail.com,a0rp0000000lVTfAAM,10/9/2019,10:00,CCK,,1,1,701O0000000SJMZIA4,comm2\nFacebook,Bulk,Upload Testing,90000000,bfu33133@yopmail.com,a0rp0000000lVVhAAM,,,CCA,,,701O0000000SJMZIA4,,\nFacebook,Bulk,Upload Testing,90000000,bfu33133@yopmail.com,a0rp0000000lVRJAA2,,,CCF,,,701O0000000SJMZIA4,,'; 
    }    
    
    @isTest
    private static void testBFUBatchUpdate_ExistingOppWithInputBranchCode_WarmOpp(){
        String testEmail = 'fake@testmail.com';        
        String branchCode = 'CCA';
        
        Account customerAcc = Test_DataFactory.createPerson(false, 'A Cool Name', 'Customer');
        customerAcc.PersonEmail = testEmail;
        insert customerAcc;        
        
        Account testAcc = Test_DataFactory.createAccount(true, 'accName');
        Contact testCon = new Contact();
        testCon.Account__c = testAcc.Id;
        testCon.LastName = 'test lname';
        testCon.Branch_Code__c = branchCode;
        testCon.Email = testEmail;
        insert testCon;
        
        
        // create users to exclude from pre-existing opp
        Profile userProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Standard User%' LIMIT 1];
        
        User excludeUser = new user();
        excludeUser.ProfileId = userProfile.Id;
        excludeUser.LastName = 'mei';
        excludeUser.Email = 'meiting.koh@cyclecarriage.com.sg';
        excludeUser.Username = 'test_datafactory' +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
        excludeUser.LocaleSidKey = 'en_US';
        excludeUser.TimeZoneSidKey = 'GMT';
        excludeUser.Alias = 'mt';
        
        excludeUser.LanguageLocaleKey = 'en_US';
        excludeUser.EmailEncodingKey = 'UTF-8';
        excludeUser.Is_Eligible_Opp_Owner__c = false;
        excludeUser.ExcludeFromPre_existingOpportuntity__c = true;
        excludeUser.IsActive = true;
        insert excludeUser;
               
        Opportunity warmOpp = new Opportunity();
        warmOpp.Name ='Test';
        warmOpp.StageName = 'Open';
        warmOpp.Amount = 3000;
        warmOpp.Opportunity_Score__c = 30;
        warmOpp.CloseDate = Date.today().addDays(5);
        warmOpp.Contact_Person__c = testCon.Id;
        warmOpp.Branch_Code__c = branchCode;
        warmOpp.Franchise_Code__c = 'KIAPC';
        warmOpp.OwnerId = excludeUser.Id;
		insert warmOpp;
        
        String path = 'bulkfile1' + '.csv';
        ContentVersion contentVersion = new ContentVersion(
            Title = 'bulkfile1',   
            PathOnClient = path,
            VersionData = Blob.valueOf(getBlob10('bulkfile1')),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        Campaign camp = new Campaign();
        camp.Name = 'Event - Fb';
        camp.Type = 'Events';
        camp.Branch_Code__c = 'CCK';
        insert camp;
        
        Model__c modelCCA = new Model__c(Name = 'CCA Model', Branch_Code__c = 'CCA', DWH_Model_ID__c = 'CCADWH', Franchise_Code__c = 'MITPC');
        insert modelCCA;
               
        List<BulkFileUpload__c> bulkFileUploads = new List<BulkFileUpload__c>();
        for(Integer i = 0; i <= 3; i++){
            //Null Preferred_Sales_Consultant__c (PSC)
            BulkFileUpload__c nullPSCFile = new BulkFileUpload__c();         
            nullPSCFile.DocumentId__c = contentVersion.Id;
            nullPSCFile.Type__c = 'S';
            nullPSCFile.Branch_Code__c = branchCode;
            nullPSCFile.Email__c = testEmail;
            nullPSCFile.EventDate__c = Date.today();
            nullPSCFile.Event_Name__c = camp.ID;
            nullPSCFile.Event_Time__c = '10:10';
            nullPSCFile.First_Name__c = 'fn name1';
            nullPSCFile.Last_Name__c = 'ln name1';
            nullPSCFile.Lead_Source__c = 'Saleswhale';
            nullPSCFile.Mobile__c = '96741073';
            nullPSCFile.Models_Interested__c = modelCCA.Id;
            nullPSCFile.No_of_Pax__c = '';
            nullPSCFile.Preferred_Sales_Consultant__c = null;
            nullPSCFile.Showroom__c = '';
            nullPSCFile.Status__c = 'O';
            nullPSCFile.Comments__c = 'testing';
    		bulkFileUploads.add(nullPSCFile);

        }
        insert bulkFileUploads;
        


        Test.startTest();
        BFUBatchUpdate bfuBatchUpdate = New BFUBatchUpdate(bulkFileUploads, contentVersion.Id);
        Database.executeBatch(bfuBatchUpdate);
        Test.stopTest();
    }
    
    @isTest
    private static void testBFUBatchUpdate_ExistingOppWithInputBranchCode_NullScoreOpp(){
        String testEmail = 'fake@testmail.com';        
        String branchCode = 'CCA';
        
        Account customerAcc = Test_DataFactory.createPerson(false, 'A Cool Name', 'Customer');
        customerAcc.PersonEmail = testEmail;
        insert customerAcc;        
        
        Account testAcc = Test_DataFactory.createAccount(true, 'accName');
        Contact testCon = new Contact();
        testCon.Account__c = testAcc.Id;
        testCon.LastName = 'test lname';
        testCon.Branch_Code__c = branchCode;
        testCon.Email = testEmail;
        insert testCon;
        
        
        // create users to exclude from pre-existing opp
        Profile userProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Standard User%' LIMIT 1];
        
        User excludeUser = new user();
        excludeUser.ProfileId = userProfile.Id;
        excludeUser.LastName = 'mei';
        excludeUser.Email = 'meiting.koh@cyclecarriage.com.sg';
        excludeUser.Username = 'test_datafactory' +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
        excludeUser.LocaleSidKey = 'en_US';
        excludeUser.TimeZoneSidKey = 'GMT';
        excludeUser.Alias = 'mt';
        
        excludeUser.LanguageLocaleKey = 'en_US';
        excludeUser.EmailEncodingKey = 'UTF-8';
        excludeUser.Is_Eligible_Opp_Owner__c = false;
        excludeUser.ExcludeFromPre_existingOpportuntity__c = true;
        excludeUser.IsActive = true;
        insert excludeUser;
        
        Opportunity nullScoreOpp = new Opportunity();
        nullScoreOpp.Name ='Test';
        nullScoreOpp.StageName = 'Open';
        nullScoreOpp.Amount = 3000;
        nullScoreOpp.Opportunity_Score__c = null;
        nullScoreOpp.CloseDate = Date.today().addDays(5);
        nullScoreOpp.Contact_Person__c = testCon.Id;
        nullScoreOpp.Branch_Code__c = branchCode;
        nullScoreOpp.Franchise_Code__c = 'KIAPC';
        nullScoreOpp.OwnerId = excludeUser.Id;
        insert nullScoreOpp;
        
        String path = 'bulkfile1' + '.csv';
        ContentVersion contentVersion = new ContentVersion(
            Title = 'bulkfile1',   
            PathOnClient = path,
            VersionData = Blob.valueOf(getBlob10('bulkfile1')),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        Campaign camp = new Campaign();
        camp.Name = 'Event - Fb';
        camp.Type = 'Events';
        camp.Branch_Code__c = 'CCK';
        insert camp;
        
        Model__c modelCCA = new Model__c(Name = 'CCA Model', Branch_Code__c = 'CCA', DWH_Model_ID__c = 'CCADWH', Franchise_Code__c = 'MITPC');
        insert modelCCA;
               
        List<BulkFileUpload__c> bulkFileUploads = new List<BulkFileUpload__c>();
        for(Integer i = 0; i <= 3; i++){
            //Null Preferred_Sales_Consultant__c (PSC)
            BulkFileUpload__c nullPSCFile = new BulkFileUpload__c();         
            nullPSCFile.DocumentId__c = contentVersion.Id;
            nullPSCFile.Type__c = 'S';
            nullPSCFile.Branch_Code__c = branchCode;
            nullPSCFile.Email__c = testEmail;
            nullPSCFile.EventDate__c = Date.today();
            nullPSCFile.Event_Name__c = camp.ID;
            nullPSCFile.Event_Time__c = '10:10';
            nullPSCFile.First_Name__c = 'fn name1';
            nullPSCFile.Last_Name__c = 'ln name1';
            nullPSCFile.Lead_Source__c = 'Saleswhale';
            nullPSCFile.Mobile__c = '96741073';
            nullPSCFile.Models_Interested__c = modelCCA.Id;
            nullPSCFile.No_of_Pax__c = '';
            nullPSCFile.Preferred_Sales_Consultant__c = null;
            nullPSCFile.Showroom__c = '';
            nullPSCFile.Status__c = 'O';
            nullPSCFile.Comments__c = 'testing';
    		bulkFileUploads.add(nullPSCFile);

        }
        insert bulkFileUploads;
        


        Test.startTest();
        BFUBatchUpdate bfuBatchUpdate = New BFUBatchUpdate(bulkFileUploads, contentVersion.Id);
        Database.executeBatch(bfuBatchUpdate);
        Test.stopTest();
    }
    
    @isTest
    private static void testBFUBatchUpdate_ExistingOppWithInputBranchCode_HotOpp(){
        String testEmail = 'fake@testmail.com';        
        String branchCode = 'CCA';
        
        Account customerAcc = Test_DataFactory.createPerson(false, 'A Cool Name', 'Customer');
        customerAcc.PersonEmail = testEmail;
        insert customerAcc;
                
        Account testAcc = Test_DataFactory.createAccount(true, 'accName');
        Contact testCon = new Contact();
        testCon.Account__c = testAcc.Id;
        testCon.LastName = 'test lname';
        testCon.Branch_Code__c = branchCode;
        testCon.Email = testEmail;
        insert testCon;
        
        
        // create users to exclude from pre-existing opp
        Profile userProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Standard User%' LIMIT 1];
        
        User excludeUser = new user();
        excludeUser.ProfileId = userProfile.Id;
        excludeUser.LastName = 'mei';
        excludeUser.Email = 'meiting.koh@cyclecarriage.com.sg';
        excludeUser.Username = 'test_datafactory' +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
        excludeUser.LocaleSidKey = 'en_US';
        excludeUser.TimeZoneSidKey = 'GMT';
        excludeUser.Alias = 'mt';
        
        excludeUser.LanguageLocaleKey = 'en_US';
        excludeUser.EmailEncodingKey = 'UTF-8';
        excludeUser.Is_Eligible_Opp_Owner__c = false;
        excludeUser.ExcludeFromPre_existingOpportuntity__c = true;
        excludeUser.IsActive = true;
        insert excludeUser;
        
        Opportunity hotOpp = new Opportunity();
        hotOpp.Name ='Test';
        hotOpp.StageName = 'Open';
        hotOpp.Amount = 3000;
        hotOpp.Opportunity_Score__c = 65;
        hotOpp.CloseDate = Date.today().addDays(5);
        hotOpp.Contact_Person__c = testCon.Id;
        hotOpp.Branch_Code__c = branchCode;
        hotOpp.Franchise_Code__c = 'KIAPC';
        hotOpp.OwnerId = excludeUser.Id;
        insert hotOpp;
        
        String path = 'bulkfile1' + '.csv';
        ContentVersion contentVersion = new ContentVersion(
            Title = 'bulkfile1',   
            PathOnClient = path,
            VersionData = Blob.valueOf(getBlob10('bulkfile1')),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        Campaign camp = new Campaign();
        camp.Name = 'Event - Fb';
        camp.Type = 'Events';
        camp.Branch_Code__c = 'CCK';
        insert camp;
        
        Model__c modelCCA = new Model__c(Name = 'CCA Model', Branch_Code__c = 'CCA', DWH_Model_ID__c = 'CCADWH', Franchise_Code__c = 'MITPC');
        insert modelCCA;
               
        List<BulkFileUpload__c> bulkFileUploads = new List<BulkFileUpload__c>();
        for(Integer i = 0; i <= 3; i++){
            //Null Preferred_Sales_Consultant__c (PSC)
            BulkFileUpload__c nullPSCFile = new BulkFileUpload__c();         
            nullPSCFile.DocumentId__c = contentVersion.Id;
            nullPSCFile.Type__c = 'S';
            nullPSCFile.Branch_Code__c = branchCode;
            nullPSCFile.Email__c = testEmail;
            nullPSCFile.EventDate__c = Date.today();
            nullPSCFile.Event_Name__c = camp.ID;
            nullPSCFile.Event_Time__c = '10:10';
            nullPSCFile.First_Name__c = 'fn name1';
            nullPSCFile.Last_Name__c = 'ln name1';
            nullPSCFile.Lead_Source__c = 'Saleswhale';
            nullPSCFile.Mobile__c = '96741073';
            nullPSCFile.Models_Interested__c = modelCCA.Id;
            nullPSCFile.No_of_Pax__c = '';
            nullPSCFile.Preferred_Sales_Consultant__c = testEmail;
            nullPSCFile.Showroom__c = '';
            nullPSCFile.Status__c = 'O';
            nullPSCFile.Comments__c = 'testing';
    		bulkFileUploads.add(nullPSCFile);

        }
        insert bulkFileUploads;
        
        Test.startTest();
        BFUBatchUpdate bfuBatchUpdate = New BFUBatchUpdate(bulkFileUploads, contentVersion.Id);
        Database.executeBatch(bfuBatchUpdate);
        Test.stopTest();
    }
    
    @isTest
    private static void testBFUBatchUpdate_OppAndUserExist_HotOpp(){
        String testEmail = 'fake@testmail.com';        
        String branchCode = 'CCA';
        
        Account customerAcc = Test_DataFactory.createPerson(false, 'A Cool Name', 'Customer');
        customerAcc.PersonEmail = testEmail;
        insert customerAcc;
        
        Account testAcc = Test_DataFactory.createAccount(true, 'accName');
        Contact testCon = new Contact();
        testCon.Account__c = testAcc.Id;
        testCon.LastName = 'test lname';
        testCon.Branch_Code__c = branchCode;
        testCon.Email = testEmail;
        insert testCon;
        
        
        // create users to exclude from pre-existing opp
        Profile userProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Standard User%' LIMIT 1];
        
        User excludeUser = new user();
        excludeUser.ProfileId = userProfile.Id;
        excludeUser.LastName = 'mei';
        //excludeUser.Email = 'meiting.koh@cyclecarriage.com.sg';
        excludeUser.Email = testEmail;
        excludeUser.Username = 'test_datafactory' +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
        excludeUser.LocaleSidKey = 'en_US';
        excludeUser.TimeZoneSidKey = 'GMT';
        excludeUser.Alias = 'mt';
        
        excludeUser.LanguageLocaleKey = 'en_US';
        excludeUser.EmailEncodingKey = 'UTF-8';
        excludeUser.Is_Eligible_Opp_Owner__c = true;
        excludeUser.ExcludeFromPre_existingOpportuntity__c = true;
        excludeUser.IsActive = true;
        insert excludeUser;
        
        Opportunity hotOpp = new Opportunity();
        hotOpp.Name ='Test';
        hotOpp.StageName = 'Open';
        hotOpp.Amount = 3000;
        hotOpp.Opportunity_Score__c = 65;
        hotOpp.CloseDate = Date.today().addDays(5);
        hotOpp.Contact_Person__c = testCon.Id;
        hotOpp.Branch_Code__c = branchCode;
        hotOpp.Franchise_Code__c = 'KIAPC';
        hotOpp.OwnerId = excludeUser.Id;
        insert hotOpp;
        
        String path = 'bulkfile1' + '.csv';
        ContentVersion contentVersion = new ContentVersion(
            Title = 'bulkfile1',   
            PathOnClient = path,
            VersionData = Blob.valueOf(getBlob10('bulkfile1')),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        Campaign camp = new Campaign();
        camp.Name = 'Event - Fb';
        camp.Type = 'Events';
        camp.Branch_Code__c = 'CCK';
        insert camp;
        
        Model__c modelCCA = new Model__c(Name = 'CCA Model', Branch_Code__c = 'CCA', DWH_Model_ID__c = 'CCADWH', Franchise_Code__c = 'MITPC');
        insert modelCCA;
               
        List<BulkFileUpload__c> bulkFileUploads = new List<BulkFileUpload__c>();
        for(Integer i = 0; i <= 3; i++){
            BulkFileUpload__c nullPSCFile = new BulkFileUpload__c();         
            nullPSCFile.DocumentId__c = contentVersion.Id;
            nullPSCFile.Type__c = 'S';
            nullPSCFile.Branch_Code__c = branchCode;
            nullPSCFile.Email__c = testEmail;
            nullPSCFile.EventDate__c = Date.today();
            nullPSCFile.Event_Name__c = camp.ID;
            nullPSCFile.Event_Time__c = '10:10';
            nullPSCFile.First_Name__c = 'fn name1';
            nullPSCFile.Last_Name__c = 'ln name1';
            nullPSCFile.Lead_Source__c = 'Saleswhale';
            nullPSCFile.Mobile__c = '96741073';
            nullPSCFile.Models_Interested__c = modelCCA.Id;
            nullPSCFile.No_of_Pax__c = '';
            nullPSCFile.Preferred_Sales_Consultant__c = testEmail;
            nullPSCFile.Showroom__c = '';
            nullPSCFile.Status__c = 'O';
            nullPSCFile.Comments__c = 'testing';
    		bulkFileUploads.add(nullPSCFile);

        }
        insert bulkFileUploads;
        
        Test.startTest();
		BFUBatchUpdate bfuBatchUpdate = New BFUBatchUpdate(bulkFileUploads, contentVersion.Id);
        Database.executeBatch(bfuBatchUpdate);      
        Test.stopTest();
    }
    
    @isTest
    private static void testBFUBatchUpdate_NoOppExist(){
        String testEmail = 'fake@testmail.com';        
        String branchCode = 'CCA';
        
        Account customerAcc = Test_DataFactory.createPerson(false, 'A Cool Name', 'Customer');
        customerAcc.PersonEmail = testEmail;
        insert customerAcc;

        Account testAcc = Test_DataFactory.createAccount(true, 'accName');
        Contact testCon = new Contact();
        testCon.Account__c = testAcc.Id;
        testCon.LastName = 'test lname';
        testCon.Branch_Code__c = branchCode;
        testCon.Email = testEmail;
        insert testCon;
        
        
        // create users to exclude from pre-existing opp
        Profile userProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Standard User%' LIMIT 1];
        
        User excludeUser = new user();
        excludeUser.ProfileId = userProfile.Id;
        excludeUser.LastName = 'mei';
        //excludeUser.Email = 'meiting.koh@cyclecarriage.com.sg';
        excludeUser.Email = testEmail;
        excludeUser.Username = 'test_datafactory' +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
        excludeUser.LocaleSidKey = 'en_US';
        excludeUser.TimeZoneSidKey = 'GMT';
        excludeUser.Alias = 'mt';
        
        excludeUser.LanguageLocaleKey = 'en_US';
        excludeUser.EmailEncodingKey = 'UTF-8';
        excludeUser.Is_Eligible_Opp_Owner__c = true;
        excludeUser.ExcludeFromPre_existingOpportuntity__c = true;
        excludeUser.IsActive = true;
        insert excludeUser;
        
        String path = 'bulkfile1' + '.csv';
        ContentVersion contentVersion = new ContentVersion(
            Title = 'bulkfile1',   
            PathOnClient = path,
            VersionData = Blob.valueOf(getBlob10('bulkfile1')),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        Campaign camp = new Campaign();
        camp.Name = 'Event - Fb';
        camp.Type = 'Events';
        camp.Branch_Code__c = 'CCK';
        insert camp;
        
        Model__c modelCCA = new Model__c(Name = 'CCA Model', Branch_Code__c = 'CCA', DWH_Model_ID__c = 'CCADWH', Franchise_Code__c = 'MITPC');
        insert modelCCA;
               
        List<BulkFileUpload__c> bulkFileUploads = new List<BulkFileUpload__c>();
        for(Integer i = 0; i <= 3; i++){
            BulkFileUpload__c nullPSCFile = new BulkFileUpload__c();         
            nullPSCFile.DocumentId__c = contentVersion.Id;
            nullPSCFile.Type__c = 'S';
            nullPSCFile.Branch_Code__c = branchCode;
            nullPSCFile.Email__c = testEmail;
            nullPSCFile.EventDate__c = Date.today();
            nullPSCFile.Event_Name__c = camp.ID;
            nullPSCFile.Event_Time__c = '10:10';
            nullPSCFile.First_Name__c = 'fn name1';
            nullPSCFile.Last_Name__c = 'ln name1';
            nullPSCFile.Lead_Source__c = 'Saleswhale';
            nullPSCFile.Mobile__c = '96741073';
            nullPSCFile.Models_Interested__c = modelCCA.Id;
            nullPSCFile.No_of_Pax__c = '';
            nullPSCFile.Preferred_Sales_Consultant__c = testEmail;
            nullPSCFile.Showroom__c = '';
            nullPSCFile.Status__c = 'O';
            nullPSCFile.Comments__c = 'testing';
    		bulkFileUploads.add(nullPSCFile);

        }
        insert bulkFileUploads;
        
        Test.startTest();
		BFUBatchUpdate bfuBatchUpdate = New BFUBatchUpdate(bulkFileUploads, contentVersion.Id);
        Database.executeBatch(bfuBatchUpdate);      
        Test.stopTest();
    }
}