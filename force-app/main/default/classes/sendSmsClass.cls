global without sharing class sendSmsClass {
    static Boolean justTest = false;
    
    public static void sendSms(String phone,String msg) {
        
        if (phone==null || phone==''){
            return;
        }
        if (msg==null || msg==''){
            return;
        }
        if (msg.length()<160){
            sendSingle(phone,msg,phone);
        }else{
            sendLong(phone,msg,phone);
        }
    }
    
    public static void sendSms2(String phone,String msg,String fromPhone) {
        
        if (phone==null || phone==''){
            return;
        }
        if (msg==null || msg==''){
            return;
        }
        if (msg.length()<160){
            sendSingle(phone,msg,fromPhone);
        }else{
            sendLong(phone,msg,fromPhone);
        }
    }
    
    @future (callout=true)
    public static void sendSingle(String phone,String msg,String fromPhone) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        
        string url = Label.SMS_url;
        string username = Label.SMS_APIID;
        string password = Label.SMS_APIPWD;
        string newphone = phone.replaceAll('[^0-9]', '');
        string newphone2 = fromPhone.replaceAll('[^0-9]', '');
        
        if (newphone.left(2)!='65'){
            newphone = '65' + newphone;
        }
        if (newphone2.left(2)!='65'){
            newphone2 = '65' + newphone2;
        }
        
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody('ID='+ EncodingUtil.urlEncode(username,'UTF-8') +'&Password='+ EncodingUtil.urlEncode(password,'UTF-8') +'&Mobile='+ EncodingUtil.urlEncode(newphone,'UTF-8') +'&Type=A&Message='+ EncodingUtil.urlEncode(msg,'UTF-8')+'&OrigNumber='+EncodingUtil.urlEncode(newphone2,'UTF-8'));
           
        if (justTest==false){
            if (!Test.isRunningTest()) res = h.send(req);
        }
        
        //System.debug('Response '+res.getBody());
    }
    
    @future (callout=true)
    public static void sendLong(String phone,String msg,String fromPhone) {
        
        Decimal result = msg.length();
        result = math.ceil(result / 153);
        String MessagePart = '0'+result;
        String responseText='';
        
        for (Integer i=1; i<=result; i++) {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res;
            
            string url = Label.SMS_url;
            string username = Label.SMS_APIID;
            string password = Label.SMS_APIPWD;
            string newphone = phone.replaceAll('[^0-9]', '');
            string newphone2 = fromPhone.replaceAll('[^0-9]', '');
            String userheader = '0500030F'+MessagePart+ '0'+i;
            
            //prosess the message;
            String tempmsg=msg.mid((i - 1) * 153, 153);
            
            if (newphone.left(2)!='65'){
                newphone = '65' + newphone;
            }
            if (newphone2.left(2)!='65'){
                newphone2 = '65' + newphone2;
            }
            
            req.setEndpoint(url);
            req.setMethod('POST');
            
            req.setBody('ID='+ EncodingUtil.urlEncode(username,'UTF-8') +'&Password='+ EncodingUtil.urlEncode(password,'UTF-8') +'&Mobile='+ EncodingUtil.urlEncode(newphone,'UTF-8') +'&Type=A&Message='+ EncodingUtil.urlEncode(tempmsg,'UTF-8')+'&OrigNumber='+EncodingUtil.urlEncode(newphone2,'UTF-8')+'&UserHeader='+EncodingUtil.urlEncode(userheader,'UTF-8'));
               
            if (justTest==false){
                if (!Test.isRunningTest()) res = h.send(req);
            }
            
            //responseText = responseText +'//'+res.getBody();
        }
        
        //System.debug('Response '+responseText);
    }
    
    public static void testSend(){
        string phone='65123456';
        string msg='test test';
        justTest=true;
        sendSms(phone,msg);
        msg='test test tes test test test test test test tes test test test test test test tes test test test test test test tes test test test test test test tes test test test test test test tes test test test test ';
        sendSms(phone,msg);
    }
}