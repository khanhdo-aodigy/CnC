//trigger for set branch code and franchise code

trigger OpposetBranchNFranchiseCode on Opportunity (after insert ) {
    List<Opportunity> oppoToInsert = new List<Opportunity>();
    if(trigger.isInsert && trigger.isAfter)
    {
            for(Opportunity c : trigger.new)
            {   
                system.debug('tata  '+ c.Branch_Code__c + '  '+ c.Franchise_Code__c);
                if(c.Branch_Code__c == null || c.Franchise_Code__c == null)
                {
                    Opportunity a=[select id, ownerId from Opportunity where id =:c.id];
                    User b =[select id, Branch_Code__c, Franchise_Code__c from User where id =: c.ownerId];
                    a.Branch_Code__c= b.Branch_Code__c;
                    a.Franchise_Code__c= b.Franchise_Code__c;
                    oppoToInsert.add(a);
                }
            }
            if(oppoToInsert.size()>0)
            {
                update oppoToInsert;
            }
    }
    
    

}