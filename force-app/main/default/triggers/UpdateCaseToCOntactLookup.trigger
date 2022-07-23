trigger UpdateCaseToCOntactLookup on Case (before insert) {
    
    /*for (Case a:Trigger.new){
          if (a.ContactId==null && a.SuppliedEmail!=null ){
        List <Contact> Con = [Select ID, Email  from Contact where Email =:a.SuppliedEmail and ISPERSONACCOUNT = False];
        if(Con.size()>0 && a.SuppliedEmail != null){    
            for(Contact s: Con){
                if (a.SuppliedEmail == s.Email   ){
                    a.ContactId = s.ID;
                }    
                }
            }
        }
    }*/

}