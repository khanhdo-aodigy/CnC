/** *****
 * Description : TestDriveController_ipad
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                          Description
 * 20160405            NAIT Admin                    Created Initial Version. 
 * 20200908            khanh.do@aodigy.com           Added PA - Phase 2 Changes. Removed Lead Reference
 * 
** *****/
public without sharing class TestDriveController_ipad {
    
    List<Vehicle_Master__c> testvehimaster=new List<Vehicle_Master__c>();
    public List<testDriveWrap> theLists{get;set;}

    public Boolean errTradePlate {get;set;}
    public String pdfId {get;set;}
    public String branchCode {get;set;}
    public String franchiseCode {get;set;}
    public String logo1 {get;set;}
    public String logo2 {get;set;}
    public String tradePlateName {get;set;}
    public String contactId {get;set;}
    public String testdrive_id {get;set;}

    public String vehiId {
        get;
        set {
            vehiId = value;
        }
    }

    public String testId {
        get;
        set {
            testId = value;
        }
    }

    public class testDriveWrap
    {
        Set<String> managerRoleName = new Set<String>{'CITPC Sales Manager','KIAPC Sales Manager','MITPC Sales Manager'};
        public List<Test_Drive__c> theTests {get;set;}
        public Vehicle_Master__c vehicle {get;set;}
        public String Comno {get;set;}
        public Boolean show {get;set;}
        public Boolean showQueue {get;set;}
        public Boolean disableBook {get;set;}

        public testDriveWrap(Vehicle_Master__c test)
        {
            Date today = date.today();
            vehicle = test;
            theTests = [SELECT Id, Name, Owner.Name, OwnerID, Sales_Rep_Mobile__c, Status__c, Branch_Code__c, Franchise_Code__c, Date__c, Owner.Profile.Name
                        FROM Test_Drive__c
                        WHERE Model__c = :vehicle.id
                        AND (CreatedDate = TODAY OR Owner.Profile.Name IN: managerRoleName)
                        AND Status__c<>'In'
                        ORDER BY Status__c, Name];

            if (theTests.size()>0)
            {
                showQueue = false;
                for(Test_Drive__c td : theTests)
                {
                    if( td.Status__c == 'Out')
                    {
                        disableBook = true;
                    }                    
                }
            }

            if ( vehicle.Comm_No__c == null || vehicle.Comm_No__c == '' )
            {
                if ( vehicle.Registration_No__c == null || vehicle.Registration_No__c == '' )
                {
                    Comno = '';
                }
                else
                {
                    Comno = vehicle.Registration_No__c;
                }
            }
            else
            {
                if (vehicle.Registration_No__c == null || vehicle.Registration_No__c == '' )
                {
                    Comno = vehicle.Comm_No__c;
                }
                else
                {
                    Comno = vehicle.Comm_No__c +'/'+vehicle.Registration_No__c;
                }
            }
        }
    }

    public TestDriveController_ipad()
    {
        Id userId = UserInfo.getUserId();
        User a = [SELECT Branch_Code__c, Franchise_Code__c FROM User WHERE Id =:userId ];
        branchCode    = a.Branch_Code__c;
        franchiseCode = a.Franchise_Code__c;

        logo1 = [SELECT FileName__c FROM Logo__c WHERE Branch_Code__c = '' AND Franchise_Code__c='' LIMIT 1].FileName__c;
        logo2 = [SELECT FileName__c FROM Logo__c WHERE Branch_Code__c =:branchCode LIMIT 1].FileName__c;

        pdfId = '';
        fillList();

        String getId = apexpages.currentpage().getparameters().get('gid');
        if ( getId != null && getId != '' )
        {
            pdfId = getId;
        }
        errTradePlate = false;
        testdrive_id = ApexPages.currentPage().getParameters().get('testdrive_id');
        contactId    = ApexPages.currentPage().getParameters().get('contact_id');
    }

    public void fillList()
    {
        theLists = new List<testDriveWrap>();

        testvehimaster = [SELECT Id, Name, Comm_No__c, Registration_No__c, Branch_Code__c, Franchise_Code__c
                          FROM Vehicle_Master__c 
                          WHERE Status__c = 'Available' 
                          AND Type__c = 'Test Drive' 
                          AND Branch_Code__c =:branchCode 
                          AND Franchise_Code__c =:franchiseCode];
        for (Vehicle_Master__c vehi:testvehimaster)
        {
            theLists.add( new testDriveWrap(vehi) );
        }
    }

    public pageReference bookClick(){
        //Passed Lead Id and Test Drive Id to next Page
        System.debug('id='+vehiId+'&testdrive_id='+testdrive_id+'&contactId='+contactId);
        return new Pagereference('/apex/BookJoinQueuePage_ipad?id='+vehiId+'&testdrive_id='+testdrive_id+'&contactId='+contactId);
    }

    public pageReference outClick()
    {
        Set<String> managerRoleName = new Set<String>{'CITPC Sales Manager','KIAPC Sales Manager','MITPC Sales Manager'};
        Test_Drive__c temp = [SELECT id,status__c,Check_Out__c,Check_In__c,Trade_Plate__c,Trade_Plate__r.name,Branch_Code__c,Franchise_Code__c
                              FROM Test_Drive__c 
                              WHERE id=:testid];

        List<Test_Drive__c> theTests=new List<Test_Drive__c>();
        Date today = date.today();

        theTests = [SELECT id,name,Branch_Code__c,Franchise_Code__c 
                    FROM Test_Drive__c 
                    WHERE (Date__c=:today OR Owner.Profile.Name IN: managerRoleName) 
                    AND Status__c <> 'In'
                    AND Trade_Plate__c =:temp.Trade_Plate__c 
                    AND ID !=:temp.id 
                    AND Branch_Code__c =:branchCode 
                    AND Franchise_Code__c=:franchiseCode];

        if ( theTests.size() <= 0 || temp.Trade_Plate__c == null )
        {
            temp.status__c    = 'Out';
            temp.Check_Out__c = DateTime.now();
            update temp;
            fillList();
        }
        else
        {
            tradePlateName = temp.Trade_Plate__r.name;
            errTradePlate = true;
        }

        return null;
    }

    public pageReference inClick()
    {
        Date today = date.today();
        Test_Drive__c temp = [SELECT Id, Opportunity__r.ID,Opportunity__r.Opportunity_Score__c, status__c, Check_Out__c, Check_In__c, Branch_Code__c, Franchise_Code__c 
                              FROM Test_Drive__c
                              WHERE Id =:testid];
        Decimal oppScore = temp.Opportunity__r.Opportunity_Score__c;
        if (oppScore != null) 
        {
            oppScore = oppScore.intValue() + 40;
        }
        else
        {
            oppScore =40;
        }

        if(temp.Opportunity__r.Id != null) {
            
            Opportunity opp = new Opportunity(id=temp.Opportunity__r.ID);
            opp.StageName            = 'Test Driven';
            opp.Opportunity_Score__c = oppScore;
            temp.status__c           = 'In';
            temp.Check_In__c         = DateTime.now();
            update temp;
            update opp;
            fillList();
        } else {
            System.debug('TestDriveController_ipad - inClick - testDrive.Opportunity__r.Id is null');
        }
        
        return null;
    }
}