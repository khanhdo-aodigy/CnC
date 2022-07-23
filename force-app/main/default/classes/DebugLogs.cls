//Class to send email with DWH Scheduler results.
public class DebugLogs {
public static void getDebugLogs(String DebugClassName, List<String> lst_Success, List<String> lst_Error)            
{
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();  
    List<Messaging.Emailfileattachment> Attachments = new List<Messaging.Emailfileattachment>(); 
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
    //Set list of people who should get the email
    List<String> sendTo = new List<String>();
    for(EmailRecipient__mdt md : [SELECT Id, RecipientEmailAddress__c 
    								FROM EmailRecipient__mdt 
    								WHERE DeveloperName = 'Payment_DMIIT'])
    {
    	sendTo.add( md.RecipientEmailAddress__c );
    }
    
    mail.setToAddresses(sendTo);
    
    //Set email contents - you can use variables!
    mail.setSubject('PFA Debug logs for: '+DebugClassName);
    String body = '';
    body += 'PFA Debug logs.';      
    mail.setHtmlBody(body);
    
    //Get values of success recrods into String from List
    String strSobjects ='';
    for(integer i=0;i<lst_Success.size();i++)
    {
        
        If(strSobjects == '')
        {
            strSobjects = String.valueOf(lst_Success[i]);
        }
        Else
        {
            strSobjects = strSobjects  + '\r'+String.valueOf(lst_Success[i]);
        }
    }
    
    //Get values of error recrods into String from List
    String strSobjects1 ='';
    for(integer i=0;i<lst_Error.size();i++)
    {
        
        If(strSobjects1 == '')
        {
            strSobjects1 = String.valueOf(lst_Error[i]);
        }
        Else
        {
            strSobjects1 = strSobjects1  + '\r'+String.valueOf(lst_Error[i]);
        }
    }
    
    //Create Success Log file attachment here.
    /*if(strSobjects!='')
    {
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName(DebugClassName+'_success.txt');
        efa.setBody(Blob.valueOf(strSobjects));
        efa.setContentType('text/plain'); 
        Attachments.add(efa);
    }*/
    //Create Error Log file attachment here.
    if(strSobjects1!='')
    {
        Messaging.Emailfileattachment efa_Error = new Messaging.Emailfileattachment();
        efa_Error.setFileName(DebugClassName+'_error.txt');
        efa_Error.setBody(Blob.valueOf(strSobjects1));
        efa_Error.setContentType('text/plain');   
        Attachments.add(efa_Error);        
        
        //Attach files to email message.
        mail.setFileAttachments(Attachments);
        
        //Add your email to the master list
        mails.add(mail);
        
        //Send all emails in the master list
        Messaging.sendEmail(mails);        
    }
}
}