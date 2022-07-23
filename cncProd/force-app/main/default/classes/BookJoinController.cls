/** *****
 * Description : BookJoinController
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                          Description
 * 20151118            Billy Cheng                   Created Initial Version. 
 * 20200908            khanh.do@aodigy.com           Added PA - Phase 2 Changes
 * 
** *****/
public without sharing class BookJoinController {
    public List<User> salesRep{get;set;}
    public Vehicle_Master__c vehicle{get;set;}
    public Contact customer{get;set;}
    public Opportunity opp{get;set;}
    public Test_Drive__c test{get;set;}
    public String salesNRIC{get;set;}
    public String salesName{get;set;}
    
    public String custNric{get;set;}
    public String custPhone{get;set;}
    public String custPost{get;set;}
    
    public String branchCode{get;set;}
    public String franchiseCode{get;set;}
    
    public Boolean customerSearch{get;set;}
    public Boolean salesSearch{get;set;}
    public Boolean oppSearch{get;set;}
    public Boolean newPost{get;set;}
    
    public String logo1{get;set;}
    public String logo2{get;set;}
    public ID ownId{get;set;}
    public ID rtid{get;set;}
    
    public List<test_drive__c> historyTest {get;set;}
    
    public BookJoinController(){
        String id = ApexPages.currentPage().getParameters().get('id');
        vehicle = [SELECT id,name,Registration_No__c FROM Vehicle_Master__c WHERE id=:id];
        
        ownId = UserInfo.getUserId();
        User a = [SELECT Branch_Code__c,Franchise_Code__c FROM User WHERE id=: ownId];
        branchCode = a.Branch_Code__c;
        franchiseCode = a.Franchise_Code__c;
        
        if( String.isNotBlank( franchiseCode ) ){
            rtid = [SELECT Id,SobjectType,Name FROM RecordType WHERE Name =:franchiseCode AND SobjectType ='Opportunity' limit 1].Id;
        }
        else{
            rtid = null;
        }
        
        logo1 = [SELECT filename__c FROM Logo__c WHERE Branch_Code__c = '' AND Franchise_Code__c = '' limit 1].filename__c;
        logo2 = [SELECT filename__c FROM Logo__c WHERE Branch_Code__c = :branchCode limit 1].filename__c;
        
        customer = new Contact();
        test = new Test_Drive__c();
        opp = new Opportunity();
        opp.RecordTypeId = rtid;
        
        Date today = Date.today();
        test.Model__c = vehicle.id;
        test.Date__c  = today;
        test.Branch_Code__c = branchCode;
        test.Franchise_Code__c = franchiseCode;
        salesSearch = false;
        oppSearch   = false;
        custNric    = '';
        custPhone   = '';
        custPost    = '';
        newPost     = false;
        historyTest = new List<Test_drive__c>();
    }
    
    public pageReference searchSalesNric(){
        salesSearch = false;
        test.OwnerID = null;
        if( String.isNotBlank( salesNRIC ) ){
            salesRep = [SELECT Id, /*Nric__c,*/ Name, Branch_Code__c, Franchise_Code__c 
                        FROM User 
                        WHERE /*nric__c =:salesNRIC 
                        AND*/ IsActive = true 
                        AND Branch_Code__c =:branchCode 
                        AND Franchise_Code__c =:franchiseCode LIMIT 1
                        ];
            if (salesRep.size()>0){
                salesSearch  = true;
                test.OwnerID = salesRep[0].Id;
                salesName    = salesRep[0].Name;
            }
            if (salesSearch == true && customerSearch == true){
                oppSearch();
            }
        }
        return null;
    }

    public pageReference searchCustNric(){
        historyTest = new List<Test_drive__c>();
        customerSearch = false;
        List<Contact> temp = [SELECT Id, Name, Branch_Code__c, Franchise_Code__c 
                              FROM Contact
                              WHERE NRIC_Passport_No__c = :custNric
                              AND Branch_Code__c = :branchCode 
                              AND Franchise_Code__c = :franchiseCode
                              AND IsPersonAccount = true];

        if (temp.size()>0 && custNric!=''){
            customerSearch = true;
            customer = [SELECT Id,Name,NRIC_Passport_No__c,Lastname,Mobilephone,Email,Postal_Code__c,Birthdate,Unit_No_Floor__c,
                               Gender__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
                               Country__c,Branch_Code__c,Franchise_Code__c,OwnerID
                        FROM Contact
                        WHERE NRIC_Passport_No__c = :custNric
                        AND Branch_Code__c = :branchCode
                        AND Franchise_Code__c = :franchiseCode
                        AND IsPersonAccount = true];

            custPhone = customer.Mobilephone;
            List<Postal_Code__c> temp2 = [SELECT id,Name,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,Country__c 
                                          FROM Postal_code__c 
                                          WHERE id=:customer.Postal_Code__c];
            newPost = true;
            if (temp2.size()>0){
                newPost  = false;
                custPost = temp2[0].Name;
                customer.Address_Line_1__c = temp2[0].Address_Line_1__c;
                customer.Address_Line_2__c = temp2[0].Address_Line_2__c;
                customer.Address_Line_3__c = temp2[0].Address_Line_3__c;
                customer.Country__c        = temp2[0].Country__c;
            }
            test.Prospect__c = customer.id;
            historyTest = [ SELECT Date__c,Owner.Name,Sales_Rep_Mobile__c,Model__r.name,Count_Day__c,Branch_Code__c,Franchise_Code__c
                            FROM test_drive__c 
                            WHERE customer_nric__c = :customer.NRIC_Passport_No__c
                            AND Branch_Code__c = :branchCode
                            AND Franchise_Code__c = :franchiseCode
                            ORDER BY Count_Day__c];
        }
        else{
            customer = new Contact();
            custPhone = '';
            test.Prospect__c = null;
        }

        /*
        if (custNric!='' && custNric!=null){
            customerSearch=true;
        }*/
        if( salesSearch == true && customerSearch == true ){
            oppSearch();
        }
        return null;
    }

    public pageReference searchCustPhone(){
        if( String.isNotBlank( custPhone ) ){
            customerSearch = false;
            historyTest = new List<Test_drive__c>();
            List<Contact> temp = [SELECT id,Name 
                                  FROM Contact
                                  WHERE MobilePhone =:custPhone
                                  AND Branch_Code__c =:branchCode
                                  AND Franchise_Code__c =:franchiseCode
                                  AND IsPersonAccount = true ];
            if (temp.size()>0){
                customerSearch=true;
                customer = [SELECT Id, Name, NRIC_Passport_No__c, Lastname, Mobilephone, Email, Postal_Code__c, Birthdate, Unit_No_Floor__c, Gender__c,
                                   Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Country__c, Branch_Code__c, Franchise_Code__c, OwnerID
                            FROM Contact
                            WHERE MobilePhone =:custPhone
                            AND Branch_Code__c =:branchCode
                            AND Franchise_Code__c =:franchiseCode
                            AND IsPersonAccount = true
                            ORDER BY createdDate DESC
                            LIMIT 1];

                custNric=customer.NRIC_Passport_No__c;
                List<Postal_Code__c> temp2 = [SELECT Id, Name, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Country__c 
                                              FROM Postal_code__c 
                                              WHERE Id =:customer.Postal_Code__c];
                newPost = true;
                if (temp2.size()>0){
                    newPost = false;
                    custPost=temp2[0].Name;
                    customer.Address_Line_1__c = temp2[0].Address_Line_1__c;
                    customer.Address_Line_2__c = temp2[0].Address_Line_2__c;
                    customer.Address_Line_3__c = temp2[0].Address_Line_3__c;
                    customer.Country__c        = temp2[0].Country__c;
                }

                test.Prospect__c = customer.Id;
                historyTest = [SELECT Date__c, Owner.Name, Sales_Rep_Mobile__c, Model__r.Name, Count_Day__c, Branch_Code__c, Franchise_Code__c 
                               FROM Test_drive__c 
                               WHERE customer_nric__c =:customer.NRIC_Passport_No__c 
                               AND Branch_Code__c =:branchCode 
                               AND Franchise_Code__c=:franchiseCode 
                               ORDER BY Count_Day__c];
            }
            else{
                customer = new Contact();
                test.Prospect__c = null;
            }
            if (salesSearch == true && customerSearch == true){
                oppSearch();
            }
        }
        return null;
    }

    public pageReference postalChange(){
        newPost = true;
        List<Postal_Code__c> temp = [SELECT Id, Name, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Country__c FROM Postal_code__c WHERE Name =:custPost];
        customer.Postal_Code__c = null;
        if( temp.size() > 0 ){
            newPost=false;
            customer.Address_Line_1__c = temp[0].Address_Line_1__c;
            customer.Address_Line_2__c = temp[0].Address_Line_2__c;
            customer.Address_Line_3__c = temp[0].Address_Line_3__c;
            customer.Country__c        = temp[0].Country__c;
            customer.Postal_Code__c    = temp[0].id;
        }
        return null;
    }

    public pageReference salesChange(){
        salesSearch=false;
        salesRep=[SELECT Id, /*Nric__c,*/ Branch_Code__c, Franchise_Code__c FROM User WHERE Id =:test.OwnerID AND Branch_Code__c =:branchCode AND Franchise_Code__c =:franchiseCode LIMIT 1];
        if( salesRep.size() > 0 ){
            //salesNRIC   = salesRep[0].nric__c;
            salesSearch = true;
        }
        if( salesSearch == true && customerSearch == true ){
            oppSearch();
        }
        return null;
    }

    public void oppSearch(){
        List<Opportunity> temp = [SELECT Id, Name, Old_Car_No__c, Name_Used_Car__c, Make_Model__c, Date_of_Registration__c, Branch_Code__c, Franchise_Code__c 
                                  FROM Opportunity 
                                  WHERE StageName = 'Open' 
                                  AND OwnerId =:test.OwnerID 
                                  AND Contact_Person__c =:customer.Id 
                                  AND Contact_Person__c !=null
                                  AND Branch_Code__c =:branchCode 
                                  AND Franchise_Code__c =:franchiseCode];
        if( temp.size() > 0 ){
            opp = temp[0];
            test.Opportunity__c = opp.Id;
        }
    }

    public String formatString(String theOld){
        String temp = '';
        String[] s = theOld.split(' ');
        Integer i = 0;
        List<String> newString =  new List<String>();
        for(String str:s)
        {
            i = str.length();
            String x,y,finalstring;
            x = str.substring(0,1).toUpperCase();
            y = str.substring(1,i).toLowerCase();
            finalstring = x + y  ;
            newString.add(finalstring);
        }
        String xyz = String.valueOf(newString);
        temp = xyz.replace(',','');
        temp = temp.replace('(','');
        temp = temp.replace(')','');
        return temp;
    }

    public pageReference save(){
        Date today = date.today();
        List<Test_Drive__c> theTests=new List<Test_Drive__c>();
        Boolean newCust = false;
        if (customer.Address_Line_1__c != null){
            customer.Address_Line_1__c = formatString(customer.Address_Line_1__c);
        }
        if (customer.Address_Line_2__c != null){
            customer.Address_Line_2__c = formatString(customer.Address_Line_2__c);
        }
        if (customer.Address_Line_3__c != null){
            customer.Address_Line_3__c = formatString(customer.Address_Line_3__c);
        }
        if (customer.Country__c!=null){
            customer.Country__c=formatString(customer.Country__c);
        }
        if (salesSearch == false){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Input Sales Rep'));
            return null;
        }
        else{
            theTests = [SELECT Id, Name, Branch_Code__c, Franchise_Code__c 
                        FROM Test_Drive__c 
                        WHERE Date__c =:today 
                        AND Status__c <> 'In' 
                        AND Status__c <> 'Cancel Queue' 
                        AND OwnerID =:test.OwnerID 
                        AND Branch_Code__c =:branchCode 
                        AND Franchise_Code__c =:franchiseCode];
            if (theTests.size()>0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'One Sales Rep can able to book one Vehicle only. Please cancel your existing booking in order to book new vehicle.'));
                return null;
            }
        }
        if ( customer.Lastname == null || customer.Lastname == '' ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Please fill the name.'));
            return null;
        }
        else{
            theTests = [SELECT Id, Name, Branch_Code__c, Franchise_Code__c 
                        FROM Test_Drive__c
                        WHERE Date__c =:today 
                        AND Status__c <>'In' 
                        AND Status__c <>'Cancel Queue' 
                        AND Customer_NRIC__c =:custNric 
                        AND Branch_Code__c =:branchCode 
                        AND Franchise_Code__c =:franchiseCode];
            if ( theTests.size() > 0 ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'This customer already have active TestDrive session. Please cancel before make a new one.'));
                return null;
            }
        }

        if ( custPhone == null || custPhone == '' ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Please fill the mobile number.'));
            return null;
        }
        
        if ( vehicle.Registration_No__c == null || vehicle.Registration_No__c == '' ){
            if (test.Trade_Plate__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Trade Plate is needed. This Model dont have Registration No.'));
                return null;
            }
            else{
                theTests = [SELECT Id, Name, Branch_Code__c, Franchise_Code__c 
                            FROM Test_Drive__c 
                            WHERE Date__c =:today 
                            AND Status__c<>'In' 
                            AND Status__c<>'Cancel Queue' 
                            AND Trade_Plate__c =:test.Trade_Plate__c 
                            AND Model__c <>:vehicle.id 
                            AND Branch_Code__c =:branchCode 
                            AND Franchise_Code__c =:franchiseCode];
                if (theTests.size()>0){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'This trade plate already registered for Active test drive now.'));
                    return null;
                }
            }
        }
        else{
            if ( test.Trade_Plate__c != null ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'This Model have Registration No. Trade Plate is not needed'));
                return null;
            }
        }

        if ( newPost == true ){
            Postal_Code__c pac = new Postal_Code__c();
            pac.Name = custPost;
            pac.Address_Line_1__c = customer.Address_Line_1__c;
            pac.Address_Line_2__c = customer.Address_Line_2__c;
            pac.Address_Line_3__c = customer.Address_Line_3__c;
            pac.Country__c        = customer.Country__c;
            insert pac;
        }

        if ( test.Prospect__c == null ){
            if (custNric == null || custNric == '' ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Customer NRIC is needed'));
                return null;
            }
            customer.NRIC_Passport_No__c = custNric;
            customer.Mobilephone         = custPhone;
            customer.ownerid             = salesRep[0].id;
            customer.Branch_Code__c      = branchCode;
            customer.Franchise_Code__c   = franchiseCode;
            //add by taufik 24 feb 2016 make all customer have account to share
            Account acc = [SELECT Id FROM Account WHERE Branch_Code__c =:branchCode AND Franchise_Code__c =:franchiseCode AND Name =:franchiseCode];
            customer.AccountID = acc.Id;
            //end add
            insert customer;
            test.Prospect__c = customer.Id;
            newCust = true;
        }
        else{
            //add for share
            if (ownId!=customer.ownerID){
              /*  ContactShare conShr = new ContactShare();
                conShr.ContactId = customer.id;
                conShr.UserOrGroupId = ownId;
                conShr.ContactAccessLevel = 'Edit';
                conShr.RowCause = Schema.ContactShare.RowCause.Manual;
                Database.SaveResult sr = Database.insert(conShr,false);*/
            }
            //end add
            customer.NRIC_Passport_No__c = custNric;
            customer.Mobilephone = custPhone;
            update customer;
        }

        opp.Test_Drive__c = true;
        if (test.Opportunity__c == null){
            opp.Contact_Person__c = customer.id;
            opp.ownerid           = test.OwnerID;
            opp.StageName         = 'Open';
            opp.CloseDate         = today.addDays(30);
            opp.Name              = customer.Lastname+' - TD '+ vehicle.name;
            opp.Branch_Code__c    = branchCode;
            opp.Franchise_Code__c = franchiseCode;
            insert opp;
            test.Opportunity__c = opp.id;
        }
        else{
            update opp;
        }

        theTests = [SELECT Id, Name, Branch_Code__c, Franchise_Code__c 
                    FROM Test_Drive__c 
                    WHERE Model__c=:vehicle.id 
                    AND Date__c =:today 
                    AND Status__c <> 'In' 
                    AND Status__c <> 'Cancel Queue' 
                    AND Branch_Code__c =:branchCode 
                    AND Franchise_Code__c =:franchiseCode];
        
        if ( theTests.size() <= 0 ){
            test.Check_Out__c = DateTime.now();
            test.Status__c    = 'Out';
        }
        insert test;
        return new Pagereference('/apex/TestDrive');
        //return new Pagereference('/apex/TestDrive?gid='+test.id);
    }

    public pageReference cancel(){
        return new Pagereference('/apex/TestDrive');
    }
}