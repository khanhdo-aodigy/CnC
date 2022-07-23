/** *****
 * Description : Opportunity Owner Assignment on round-robin basis
 *               Logic inherited from Opportunity_Owner_Assignment.TRIG
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                         Description
 * 20201104            HS@aodigy                    Created Initial Version. Removed SOQL & DML in LOOP
 * 
** *****/ 
public without sharing class OpportunityRoundRobinAsgmt {
    
    public OpportunityRoundRobinAsgmt() {}

    public static void assignOppotunityOwner( List<Opportunity> lstOpportunities ){
    
        System.debug('@@@@DEBUG assignOppotunityOwner :: lstOpportunities = ' + lstOpportunities);
        if( lstOpportunities <> null && !lstOpportunities.isEmpty() )
        {
            List<Opportunity>  oppoToInsert = new List<Opportunity>(); 
            Map<String,List<User>> mapBranceScUsers = new Map<String,List<User>>();
            Decimal seq = 0;   

            global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults(); 

            for( User usr : [SELECT Id, Name, UserRole.Name
                             FROM User 
                             WHERE UserRole.Name IN ('KIAPC Sales Consultant','MITPC Sales Consultant','MBP Sales Consultant','CITPC Sales Consultant','Management') 
                             AND Is_Eligible_Opp_Owner__c = true 
                             AND IsActive = TRUE 
                             ORDER BY Id ASC ]){
                
                if( mapBranceScUsers.containsKey( usr.UserRole.Name ) ){
                    mapBranceScUsers.get( usr.UserRole.Name ).add( usr );
                }
                else{
                    mapBranceScUsers.put( usr.UserRole.Name, new List<User>{ usr } );
                }
            }
            System.debug('@@@@DEBUG assignOppotunityOwner :: mapBranceScUsers = ' + mapBranceScUsers);

            for(Opportunity oppo : lstOpportunities )
            {   
                if( String.isNotBlank( oppo.Branch_Code__c ) && oppo.LeadSource != 'Stock Reserved' && oppo.LeadSource != 'Walk-in' /* && oppo.LeadSource != 'TestDrive'*/)
                {
                    try
                    {
                        Opportunity newOpp = new Opportunity(Id = oppo.Id);
                        String roleName = '';

                        if(oppo.Branch_Code__c == 'CCK') {
                            roleName = 'KIAPC Sales Consultant'; 
                            seq = (Integer)JCC_GlobalVar.Opportunity_Seq_KIA__c;
                            seq = (seq == null) ? 1 : ++seq;
                            JCC_GlobalVar.Opportunity_Seq_KIA__c = seq;
                        }
                        else if(oppo.Branch_Code__c == 'CCA'){
                            roleName = 'MITPC Sales Consultant'; 
                            seq = (Integer)JCC_GlobalVar.Opportunity_Seq_MIT__c;
                            seq = (seq == null) ? 1 : ++seq;
                            JCC_GlobalVar.Opportunity_Seq_MIT__c = seq;
                        }
                        else if(oppo.Branch_Code__c == 'CCI'){
                            roleName = 'MBP Sales Consultant'; 
                            seq = (Integer)JCC_GlobalVar.Opportunity_Seq_MB__c;
                            seq = (seq == null) ? 1 : ++seq;
                            JCC_GlobalVar.Opportunity_Seq_MB__c = seq;
                        }
                        else if(oppo.Branch_Code__c == 'CCF'){
                            roleName = 'CITPC Sales Consultant'; 
                            seq = (Integer)JCC_GlobalVar.Opportunity_Seq_CIT__c;
                            seq = (seq == null) ? 1 : ++seq;
                            JCC_GlobalVar.Opportunity_Seq_CIT__c = seq;
                        }
                        
                        if( String.isBlank( roleName ) ) {
                            roleName = 'Management';
                        }
                        

                        if( mapBranceScUsers.containsKey( roleName ) )
                        {
                            Integer index = Math.MOD(Integer.valueOf(seq),mapBranceScUsers.get( roleName ).size());
                            newOpp.OwnerId = mapBranceScUsers.get( roleName ).get( index ).Id; 
                            oppoToInsert.add( newOpp );
                        }
                    }
                    catch(Exception e)
                    {
                        system.debug('System Exception has occured: '+e.getMessage());
                    }
                }
            }

            if(oppoToInsert.size()>0)
            {   
                upsert JCC_GlobalVar;
                update oppoToInsert;            
            }
        }
    
    }
}