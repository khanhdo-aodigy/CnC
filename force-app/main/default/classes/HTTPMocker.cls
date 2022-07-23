/********************************
 * Class Name: HTTPMocker
 * Description: Used for Test Class
 * 				on HTTP Mock Class.
 ********************************/ 
global class HTTPMocker implements HTTPCalloutMock{

    public String mockClass = '';
    public Boolean success = false;
    
    global HTTPMocker(String mocker, Boolean isSuccess){
        mockClass = mocker;
        success = isSuccess;
    }
    
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        Integer respCode = success ? 200 : 400;
        res.setStatusCode(respCode);
        
        if(String.isNotBlank(mockClass)){
            if(mockClass=='DWH_DelinkVehicles'){
                String body = '{"RV": [{ "FRANCHISECODE": "M","FRANCHISE": "MBT","REGNO": "GQ786T","COMM": " ","ENGINE": "60194200665112","CHASSIS": "VSA638064231169339","MAGIC": "3454","EDITED": ""}]}';
                res.setBody(body);
            }else if(mockClass=='DWH_GetCustomer_Data' || mockClass=='DWH_GetAllCustomer_Data' ){
                String body = '{"Customers":[{"MAGIC_CUSTOMER":96239,"CUSTOMER_DATASOURCE":"CCS01","MAGIC_MBPC":281135,"MAGIC_MBCV":0,"MAGIC_MF":0,"MAGIC_FUL":0,"CUSTOMER_TYPE":"Private","SALUTE":"Tan Test","SOCIALID":"SOCIALTEST","MAGIC":96239,"TITLE":"Dr","SURNAME":"Tan","FIRSTNAME":"Sample Customer","LASTNAME":null,"DOB":"1999-07-01T00:00:00","SEX":"M","PHONE005":"92356028","PHONE002":null,"EMAIL":"testemail@yahoo.com","ADDRESS001":"101 Test Road","ADDRESS002":"#08-06","ADDRESS003":"Singapore 219067","ADDRESS004":null,"ADDRESS005":null,"CITY":"","STATE":null,"COUNTRY":"","POSTCODE":0,"PDPA":null,"Preferred_Mode_Of_Contact":null,"CREATED":"12/14/2018 12:00:00 AM","EDITED":"7/8/2019 12:00:00 AM"},{"MAGIC_CUSTOMER":975410,"CUSTOMER_DATASOURCE":"CCS01","MAGIC_MBPC":234432,"MAGIC_MBCV":0,"MAGIC_MF":0,"MAGIC_FUL":0,"CUSTOMER_TYPE":"Private","SALUTE":"MrDWH","SOCIALID":"0909","MAGIC":975410,"TITLE":"Dr","SURNAME":"","FIRSTNAME":"TestCustomer2","LASTNAME":null,"DOB":"1994-07-01T00:00:00","SEX":"Female","PHONE005":"99887766","PHONE002":null,"EMAIL":"testCustomer2@gmail.com","ADDRESS001":"999 Sky Road","ADDRESS002":"#07-26","ADDRESS003":"Singapore 520999","ADDRESS004":null,"ADDRESS005":null,"CITY":"","STATE":null,"COUNTRY":"Japan","POSTCODE":0,"PDPA":false,"Preferred_Mode_Of_Contact":"SMS","CREATED":"12/14/2018 12:00:00 AM","EDITED":"10/4/2020 12:00:00 AM"},{"MAGIC_CUSTOMER":971091,"CUSTOMER_DATASOURCE":"CCS01","MAGIC_MBPC":234432,"MAGIC_MBCV":0,"MAGIC_MF":0,"MAGIC_FUL":0,"CUSTOMER_TYPE":"Private","SALUTE":"MrDWH","SOCIALID":"0909","MAGIC":971091,"TITLE":"Dr","SURNAME":"","FIRSTNAME":"TestCustomer3","LASTNAME":null,"DOB":"1987-09-01T00:00:00","SEX":"Female","PHONE005":"11223344","PHONE002":null,"EMAIL":"testCustomer3@gmail.com","ADDRESS001":"888 Sky Road","ADDRESS002":"#09-26","ADDRESS003":"Singapore 520888","ADDRESS004":null,"ADDRESS005":null,"CITY":"","STATE":null,"COUNTRY":"Taiwan","POSTCODE":0,"PDPA":true,"Preferred_Mode_Of_Contact":"SMS","CREATED":"12/14/2018 12:00:00 AM","EDITED":"10/4/2020 12:00:00 AM"}]}';
                res.setBody(body);
            }else if(mockClass=='DWH_GetRegisteredVehicals_Data' || mockClass=='DWH_GetAllRegisteredVehicals_Data' ){
                String body = '{"RV":[{"MAGIC_VEHICLE":10334,"VEHICLE_DATASOURCE":"CCS03","MAGIC_MBPC":0,"MAGIC_MBCV":0,"MAGIC_MF":376589,"MAGIC_FUL":309661,"MAGIC_CUSTOMER":149171,"FRANCHISECODE":"J","FRANCHISE":"MITPC","REGNO":"TESTREGNO","COMM":"09-0318 18","ENGINE":"4J11AC5258","CHASSIS":"GF7W0600657","REGDATE":"2019-05-31T00:00:00","COLLECTIONDATE":"0001-01-01T00:00:00","LASTSERV":"0001-01-01T00:00:00","IMILEAGEU":0,"NEXTSERV":"2019-06-28T00:00:00","NEXTSMIL":1000,"LASTSMILE":0,"SECURENO":"1129362727","WAREXPDT":"2018-01-01T00:00:00","WAREXTDT":"2024-05-31T00:00:00","SVCCRDBAL":0.0,"SVCCRDEXPDT":"2088-01-01T00:00:00","MAGIC":"10334","IMMOBIL":"","MODELYR":2018,"COLCODE":"P026","VARIANT":"","EXTContactID":286880,"DELDATE":"0001-01-01T00:00:00","CREATED":"2019-05-09T00:00:00","EDITED":"2019-07-22T00:00:00","LASTBATTERYCHANGEdate":"26/07/2019","SCRBAL":0.0},{"MAGIC_VEHICLE":10334,"VEHICLE_DATASOURCE":"CCS03","MAGIC_MBPC":0,"MAGIC_MBCV":0,"MAGIC_MF":376589,"MAGIC_FUL":309661,"MAGIC_CUSTOMER":191791,"FRANCHISECODE":"J","FRANCHISE":"MITPC","REGNO":"TESTREGNO","COMM":"09-0318 18","ENGINE":"4J11AC5258","CHASSIS":"GF7W9988007","REGDATE":"2019-05-31T00:00:00","COLLECTIONDATE":"0001-01-01T00:00:00","LASTSERV":"0001-01-01T00:00:00","IMILEAGEU":0,"NEXTSERV":"2019-06-28T00:00:00","NEXTSMIL":1000,"LASTSMILE":0,"SECURENO":"1129362727","WAREXPDT":"2018-01-01T00:00:00","WAREXTDT":"2024-05-31T00:00:00","SVCCRDBAL":0.0,"SVCCRDEXPDT":"2088-01-01T00:00:00","MAGIC":"10334","IMMOBIL":"","MODELYR":2020,"COLCODE":"P026","VARIANT":"CCA,MITPC,DWHL99","EXTContactID":286880,"DELDATE":"0001-01-01T00:00:00","CREATED":"2019-05-09T00:00:00","EDITED":"2019-07-22T00:00:00","LASTBATTERYCHANGEdate":"26/07/2019","SCRBAL":0.0}]}';
                res.setBody(body);
            }
        }
		
		return res;        
    }

}