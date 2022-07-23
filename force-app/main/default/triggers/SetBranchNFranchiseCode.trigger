//trigger for set branch code and franchise code

trigger SetBranchNFranchiseCode on Contact (after insert) {
    List<Contact> conToInsert = new List<Contact>();
    if(trigger.isInsert && trigger.isAfter)
    {
            for(Contact c : trigger.new)
            {   
                system.debug('tata  '+ c.Branch_Code__c + '  '+ c.Franchise_Code__c);
                if(c.Branch_Code__c == null || c.Franchise_Code__c == null)
                {
                    Contact a=[select id, ownerId from Contact where id =:c.id];
                    User b =[select id, Branch_Code__c, Franchise_Code__c from User where id =: c.ownerId];
                    a.Branch_Code__c= b.Branch_Code__c;
                    a.Franchise_Code__c= b.Franchise_Code__c;
                    conToInsert.add(a);
                }
            }
            if(conToInsert.size()>0)
            {
                update conToInsert;
            }
    }
    
}