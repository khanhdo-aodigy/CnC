@isTest
public class dailyChecklistTest {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    public static testMethod void triggerTest(){
        Test.StartTest();
        Account acd = new Account();
        acd.name='XYZ Organization';
        insert acd;
        
        Contact c2 = new Contact();
        c2.FirstName = 'abcFirst';
        c2.LastName = 'AbZLast';
        c2.Email = 'xyzmail@mail.com';
        c2.AccountId = acd.id;
        c2.NRIC_Passport_No__c='345678';
        c2.MobilePhone='7867532';
        insert c2;
        
        Opportunity op1=new Opportunity();
        op1.name='op2';
        op1.Contact_person__c=c2.id;
        op1.Rating__c='Hot';
        op1.StageName='Open';
        op1.CloseDate=Date.today().addDays(2);
        insert op1;
        
        Trade_Plate__c tp2=new Trade_Plate__c(Name='12345',Active__c=true);
        insert tp2;
        
        Vehicle_Master__c v1=new Vehicle_Master__c(Name='Test v1',Comm_No__c='',Status__c='Available',Type__c='Showroom',Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert v1;
        
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c b = new Logo__c(filename__c='test2' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        Logo__c logo1 = new Logo__c(filename__c='test2' ,Branch_Code__c='CCF',Franchise_Code__c='CITPC');
        insert logo1;
        
        PageReference page2nd = Page.BookJoinQueuePage;
        ApexPages.currentPage().getParameters().put('id', v1.id);
        BookJoinController cont2nd = new BookJoinController();
        Test.setCurrentPage(page2nd);
        cont2nd.salesNRIC='';
        cont2nd.custNric='';
        cont2nd.custPost='5555';
        cont2nd.newPost=true;
        cont2nd.searchCustNric();
        cont2nd.postalChange();
        cont2nd.salesChange();
        cont2nd.searchCustPhone();
        cont2nd.searchSalesNric();
        cont2nd.oppSearch();
        cont2nd.save();
        cont2nd.cancel();
        
        Test.StopTest();
    }
    
    public static testMethod void dailyTest() {
        Test.StartTest();
        //user
        Profile p = [SELECT Id FROM Profile WHERE Name='KIA SALES'];
        User u2 = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert u2;
        //create Logo
        System.RunAs(u2) {
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c b = new Logo__c(filename__c='test2' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        Logo__c logo1 = new Logo__c(filename__c='test2' ,Branch_Code__c='CCF',Franchise_Code__c='CITPC');
        insert logo1;
        //create vehicles master
        Vehicle_Master__c v1=new Vehicle_Master__c(Name='Test v1',Comm_No__c='',Status__c='Available',Type__c='Showroom',Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert v1;
        Vehicle_Master__c v2=new Vehicle_Master__c(Name='Test v2',Comm_No__c='5678',Status__c='Available',Type__c='Test Drive');
        insert v2;
        //tp plate master
        Trade_Plate__c tp1=new Trade_Plate__c(Name='12345',Active__c=true,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert tp1;
        //question master
        Showroom_Questions_Master__c sq1=new Showroom_Questions_Master__c(Name='Q1 a',Active__c=true,Number__c=1,Type__c='Showroom');
        insert sq1;
        Showroom_Questions_Master__c sq2=new Showroom_Questions_Master__c(Name='Q2 a',Active__c=true,Number__c=2,Type__c='Showroom');
        insert sq2;
        Showroom_Questions_Master__c sq3=new Showroom_Questions_Master__c(Name='Q1 b',Active__c=true,Number__c=1,Type__c='General Cleanliness');
        insert sq3;
        Showroom_Questions_Master__c sq4=new Showroom_Questions_Master__c(Name='Q2 b',Active__c=true,Number__c=2,Type__c='General Cleanliness');
        insert sq4;
        
        //create account
        Account acc = new Account();
        acc.name='XYZ Organization';
        insert acc;
        
        //create postalcode
        Postal_Code__c pc1 = new Postal_Code__c();
        pc1.name='123456785';
        pc1.Address_Line_1__c='test 1';
        pc1.Address_Line_2__c='test 2';
        pc1.Address_Line_3__c='test 3';
        pc1.Country__c='test c';
        insert pc1;
        
        //create contact
        Contact c1 = new Contact();
        c1.FirstName = 'xyzFirst';
        c1.LastName = 'XyZLast';
        c1.Email = 'xyzmail@mail.com';
        c1.AccountId = acc.id;
        c1.NRIC_Passport_No__c='12345678';
        c1.Postal_Code__c=pc1.id;
        c1.MobilePhone='1234567';
        c1.Franchise_Code__c=u2.Franchise_Code__c;
        c1.Branch_Code__c=u2.Branch_Code__c;
        insert c1;
        
        Date today=date.today();
        //create test drive
        Test_Drive__c td = new Test_Drive__c();
        td.Model__c=v2.id;
        td.Prospect__c=c1.id;
        td.Date__c=today;
        td.NRIC__c='12345678';
        insert td;
        
        Attachment attach=new Attachment();     
        attach.Name='Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=td.id;
        attach.Description = td.id;
        attach.ContentType= 'img';
        insert attach; 
        
        Attachment attach2=new Attachment();     
        attach2.Name='Test Attachment';
        Blob bodyBlob2=Blob.valueOf('Unit Test Attachment Body');
        attach2.body=bodyBlob2;
        attach2.parentId=td.id;
        attach2.Description = td.id;
        attach2.ContentType= 'img';
        insert attach2; 
            
        Test_Drive__c td2 = new Test_Drive__c();
        td2.Model__c=v2.id;
        td2.Prospect__c=c1.id;
        td2.Date__c=today;
        td2.Status__c='Out';
        td2.Branch_Code__c=u2.Branch_Code__c;
        td2.Franchise_Code__c=u2.Franchise_Code__c;
        insert td2;
        
        Opportunity op=new Opportunity();
        op.name='op1';
        op.Contact_person__c=c1.id;
        op.Rating__c='Hot';
        op.StageName='Open';
        op.CloseDate=Date.today().addDays(2);
        op.Branch_Code__c=u2.Branch_Code__c;
        op.Franchise_Code__c=u2.Franchise_Code__c;
        insert op;
        
        
        Daily_Checklist__c dcc=new Daily_Checklist__c();
        
        insert dcc;
        
        PageReference pageRef = Page.DailyCheckListPage;
        DailyCheckListClass controller = new DailyCheckListClass(new ApexPages.StandardController(dcc));
        Test.setCurrentPage(pageRef);
        controller.getDailycheck();
        controller.doSubmit2();
        controller.doSubmit();
        controller.doCancel();
        
        PageReference pageNew = Page.TestDrive;
        TestDriveController cont = new TestDriveController();
        Test.setCurrentPage(pageNew);
        cont.fillList();
        cont.bookClick();
        cont.testid=td.id;
        cont.cancelClick();
        cont.outClick();
        cont.inClick();
        
        PageReference page2nd = Page.BookJoinQueuePage;
        ApexPages.currentPage().getParameters().put('id', v2.id);
        BookJoinController cont2nd = new BookJoinController();
        Test.setCurrentPage(page2nd);
        cont2nd.salesNRIC='12344321';
        cont2nd.custNric='12345678';
        cont2nd.searchSalesNric();
        cont2nd.searchCustNric();
        cont2nd.postalChange();
        cont2nd.salesChange();
        cont2nd.searchCustPhone();
        cont2nd.oppSearch();
        cont2nd.save();
        cont2nd.cancel();

        page2nd = Page.BookJoinQueuePage;
        ApexPages.currentPage().getParameters().put('id', v2.id);
        cont2nd = new BookJoinController();
        Test.setCurrentPage(page2nd);
        cont2nd.salesNRIC='';
        cont2nd.custNric='';
        cont2nd.searchSalesNric();
        cont2nd.searchCustNric();
        cont2nd.postalChange();
        cont2nd.salesChange();
        cont2nd.searchCustPhone();
        cont2nd.oppSearch();
        cont2nd.salesSearch=false;
        cont2nd.save();
        cont2nd.cancel();
        
        page2nd = Page.BookJoinQueuePage;
        ApexPages.currentPage().getParameters().put('id', v2.id);
        cont2nd = new BookJoinController();
        Test.setCurrentPage(page2nd);
        cont2nd.salesNRIC='';
        cont2nd.custNric='';
        cont2nd.searchSalesNric();
        cont2nd.searchCustNric();
        cont2nd.postalChange();
        cont2nd.salesChange();
        cont2nd.searchCustPhone();
        cont2nd.oppSearch();
        cont2nd.salesSearch=true;
        cont2nd.save();
        cont2nd.cancel();
        
        page2nd = Page.BookJoinQueuePage;
        ApexPages.currentPage().getParameters().put('id', v1.id);
        cont2nd = new BookJoinController();
        Test.setCurrentPage(page2nd);
        cont2nd.salesNRIC='12344321';
        cont2nd.custNric='12345678';
        cont2nd.searchCustNric();
        cont2nd.custPhone='';
        cont2nd.postalChange();
        //cont2nd.salesChange();
        cont2nd.searchCustPhone();
        //cont2nd.searchSalesNric();
        //cont2nd.oppSearch();
        //cont2nd.save();
        //cont2nd.cancel();
       
        VSMSHelperClass.testSend(c1.id,'Test Class','12345');
        ApexPages.currentPage().getParameters().put('id',td.id);
        ApexPages.StandardController tdd = new ApexPages.StandardController(td);
        /*TestDrivePDFext tddd  = new TestDrivePDFext(tdd);
        
        tddd.theTest.prospect__r.Country__c='Test 1';
        tddd.theTest.prospect__r.Unit_No_Floor__c='Test 1';
        tddd.theTest.prospect__r.Address_Line_3__c='Test 3';
        tddd.theTest.prospect__r.Address_Line_2__c='Test 2';
        tddd.theTest.prospect__r.Address_Line_1__c='Test 1';
        tddd.getData();
        
        Test_Drive__c tdc=new Test_Drive__c();
        tdc.status__c='Out';
        tdc.Date__c=today;
        insert tdc;
        System.schedule('ScheduleApexClassTest',CRON_EXP,new autoCheckIn());
        
        Helper_Class.AttachPDF(td2.id);
        page2nd = Page.TestDrivePDFPortal;
        ApexPages.currentPage().getParameters().put('id', tdc.id);
        TextDrivePDFPortal cont3nd = new TextDrivePDFPortal();
        cont3nd.goNext();*/
        Test.StopTest();
        }
    }
}