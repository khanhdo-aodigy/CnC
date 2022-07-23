/** ******
 * Description : Service class for Contact object
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                     Description
 * 20200928            HS@aodigy                Created Initial Version
 * 20210124            Hung@aodigy              Added getProspectContactsBySetEmail method
** ******/
public with sharing class ContactService {


    private static ContactSelector selector = new ContactSelector();

    public static List<Contact> getCustomerContactsByEmail( String email ){
        return selector.getPersonContactByContactEmails( new Set<String>{ email }, new Set<String>{'Customer'} );
    }

    public static List<Contact> getProspectContactsByEmail( String email ){
        return selector.getPersonContactByContactEmails( new Set<String>{ email }, new Set<String>{'Prospect'} );
    }
    public static List<Contact> getProspectContactsBySetEmail(Set<String> emails ){
        return selector.getPersonContactByContactEmails( emails, new Set<String>{'Prospect'} );
    }

    public static List<Contact> getProspectContactsByAccountId( Id accountId ){
        return selector.getPersonContactByAccountIds( new Set<Id>{ accountId }, new Set<String>{'Prospect'} );
    }

}