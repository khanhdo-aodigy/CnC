/**********************************************
 * Class Name: FileHelper
 * Description: Generates PDF file for given records
 * Created By : Savita
 * Created Date : 25th July 2019
 **********************************************/
 
 
public without sharing class FileHelper{

 /*
 * Method Name: generateFile
 * Description: Referenced in Queueable class for PDF file generation. Invoked by Event Registration and Payment triggers.
 * Created By : Savita
 * Created Date : 25th July 2019
 */  
    public static Map<String,String> generateFile(String recId, String filename,Pagereference Pg){
        Map<String,String> erWithPublicURL = new Map<String, String>();
        try{
            Map<String,String> cvWithER = new Map<String,String>();
            List<ContentVersion> conVerList = new List<ContentVersion>();
            List<ContentDistribution> cdlList =  new List<ContentDistribution>();
                        
            ContentVersion conVer = new ContentVersion();
            conVer.PathOnClient = 'Invoice.pdf'; 
            conVer.Title = 'Invoice-'+filename+'.pdf'; 
            
            if(!Test.isRunningTest()){
                conVer.VersionData = Pg.getcontentAsPdf();
            }else{
                conVer.VersionData = Blob.valueOf('Test');
            }
            
            conVerList.add(conVer);
            cvWithER.put(conVer.Title, recId);
            
            if( !conVerList.isEmpty() ){
                Set<String> succesConverId = new Set<String>();
                for(Database.SaveResult res : Database.insert(conVerList)){
                    if(res.isSuccess()){
                        succesConverId.add(res.id);
                    }                      
                }
                
                if(succesConverId!=null && !succesConverId.isEmpty()){
                    List<ContentDocumentLink> cdList =  new List<ContentDocumentLink>();
                    for(ContentVersion conDoc : [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id IN: succesConverId]){
                        ContentDocumentLink cDe = new ContentDocumentLink();
                        cDe.ContentDocumentId = conDoc.ContentDocumentId;
                        cDe.LinkedEntityId = cvWithER.get(conDoc.Title) ; 
                        cDe.ShareType = 'V'; 
                        cDe.Visibility = 'AllUsers';
                        cdList.add(cDe);
                        
                        ContentDistribution cd = new ContentDistribution();
                        cd.Name = 'Payment Invoice-Promos';
                        cd.ContentVersionId = conDoc.id;
                        cd.PreferencesAllowViewInBrowser= true;
                        cd.PreferencesLinkLatestVersion=true;
                        cd.PreferencesNotifyOnVisit=false;
                        cd.PreferencesPasswordRequired=false;
                        cd.PreferencesAllowOriginalDownload= true;
                        cdlList.add(cd);      
                    }
                    insert cdList;  
                    Set<Id> insertedcdlList = new Set<Id>();                                     
                    for(Database.SaveResult res : Database.insert(cdlList, false)){
                        if(res.isSuccess()){
                            insertedcdlList.add(res.id);
                        }
                    }
                    if(!insertedcdlList.isempty()){
                            for(ContentDistribution cd : [Select DistributionPublicUrl,ContentVersionId,ContentVersion.Title from ContentDistribution where Id IN: insertedcdlList]){
                                erWithPublicURL.put(cvWithER.get(cd.ContentVersion.Title), cd.DistributionPublicUrl);
                            }                    
                         FileHelper.UpdateURLonPayment(erWithPublicURL);  
                    }
                          
                } 
                
            }            
        }
        catch(Exception e){
              loggerDataPool.buildLogDataPool('generateFile', e);
        }
        return erWithPublicURL;
    }
     
/*
 * Method Name: UpdateURLonPayment
 * Description: Updates Payment record with invoice PDF link generated on Event Registration 
 * Created By : Savita
 * Created Date : 25th July 2019
 */    
    public static void UpdateURLonPayment(Map<String,String> evntIdWithPDFlink){
      try{
          List<Invoice__c> invUrlList= new List<Invoice__c>();
          Set<Id> invIds = new Set<Id>();
          if(!evntIdWithPDFlink.isEmpty()){
                  for(Id recId : evntIdWithPDFlink.Keyset()){
                      String sobjectType = recId.getSObjectType().getDescribe().getName();                     
                      if(sobjectType == 'Invoice__c'){
                          // Updating payment record with pdf url
                          Invoice__c invNewInstance = new Invoice__c (Id = recId); 
                          invNewInstance.InvoicePdfURL__c = evntIdWithPDFlink.get(invNewInstance.id);
                          invUrlList.add(invNewInstance);    
                      }
                      else if(sobjectType == 'Event_Registration__c'){
                          // Updating payment record with pdf url from Event Registration record
                          Id payMentId= [select id,Payment__c from Event_Registration__c where Id=: recId].Payment__c ;
                          Invoice__c invNewInstance = new Invoice__c (Id = payMentId);
                          invNewInstance.InvoicePdfURL__c = evntIdWithPDFlink.get(recId);
                          invUrlList.add(invNewInstance);   
                      }
                  }
              if(!invUrlList.IsEmpty()){
                      update invUrlList;
                  }    
              }
          }
      
      catch(Exception e){
          loggerDataPool.buildLogDataPool('updatePDFurl_Paid', e);
      }
    
    }   

}