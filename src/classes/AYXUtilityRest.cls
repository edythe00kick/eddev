/*
* @author: JP Horton
* @description: A utility class to build rest utilities for use in Alteryx Workflows.
* @date : 2020-05-29
* @RestURL: /services/apexrest/AYXUtilityRest/
*
* Test Class: test_AYXUtilityRest
*/
@RestResource(urlmapping='/AYXUtilityRest/*')
global class AYXUtilityRest{

    /*
    * @author: JP Horton
    * @methodname: AYXUtilityRest.leadConvert
    * @parameters: a (LeadIDs separated by ;)
    *              b (targetIds separated by ; **mix of contact Ids and account Ids)
    * @return: List<Boolean> checkSuccess returns list of success/failures for each converted lead
    * @description: Convert Leads to contacts and accounts based on a list of LeadIds and TargetIds.
    * @RestURL: /leadConvert?a=[LeadIds]&b=[TargetIds]
    *
    */
    @HttpGet
    global static List<Boolean> leadConvert(){
        // Get parameters from URL

        System.debug('eddie inside leadConvert');
        String a = RestContext.request.params.get( 'a' ); //lead id list
        String b = RestContext.request.params.get( 'b' ); // target id list

        System.debug('eddie inside leadConvert 2' + a);
        System.debug('eddie inside leadConvert 3' + b);
        String[] leadIdString = a.split(';');
        String[] targetIdString = b.split(';');

        System.debug('eddie inside leadConvert 4' + leadIdString);
        System.debug('eddie inside leadConvert 5' + targetIdString);


        //Create maps for Lead to Account and Contacts
        Map<String,String> mapLeadToAccount = new Map<String,String>();
        Map<String,String> mapLeadToContact = new Map<String,String>();

        //Check that the size of lists are the same before continuing
        try{
            system.assertequals(leadIdString.size(), targetIdString.size());
        } catch(Exception e){return null;}//maybe more descriptive error handling

        //Checking for correct format of Ids and fill the maps
        for(Integer i = 0; i < leadIdString.size(); i++){
            if(targetIdString[i].left(3) == '001'){
                //Account Mapping
                mapLeadToAccount.put(leadIdString[i], targetIdString[i]);
                System.debug('eddie inside 001');
            }
            else if(targetIdString[i].left(3) == '003'){
                //Contact Mapping
                mapLeadToContact.put(leadIdString[i], targetIdString[i]);
                System.debug('eddie inside 003');
            }
            else{}//neither Account or Contact; do nothing
        }

        // build LeadConvert list for processing conversions
        list<Database.LeadConvert> leadConverts = createListLeadConverts(mapLeadToContact, mapLeadToAccount);

        List<Boolean> checkSuccess = new List<Boolean>();
        if( !leadConverts.isEmpty() ){
            //Convert Leads and build success list
            Database.LeadConvertResult[] lcrList = Database.convertLead(leadConverts, false);
            for(Database.LeadConvertResult lcr : lcrList)
                checkSuccess.add(lcr.isSuccess());
        }

        return checkSuccess;
    }

    private static List<Database.LeadConvert> createListLeadConverts(Map<String,String> mapIdStringLeadToContact, Map<String,String> mapIdStringLeadToAccount){
        // Guide to the Maps
        // mapContacts.get(mapIdStringLeadToContact.get(leadid))
        // Lead to Contact
        // Lead to Contact.AccountId
        // Lead to Contact.Account.OwnerId
        // mapAccounts.get(mapIdStringLeadToAccount.get(leadId))
        // Lead to Account.Id
        // Lead to Account.OwnerId

        //Pull relevant Object data from the account level for each type of lead conversion target
        Map<Id, Contact> mapContacts = new Map<Id,Contact>([SELECT Id, AccountId, Account.OwnerId FROM Contact WHERE Id IN: mapIdStringLeadToContact.values()]);
        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, OwnerId FROM Account WHERE Id IN: mapIdStringLeadToAccount.values()]);

        //Generate the List of Leads which will be converted; remove duplicates if any
        List<Lead> leadToContact = new List<Lead>([SELECT Id FROM Lead WHERE Id IN: mapIdStringLeadToContact.keySet()]);
        List<Lead> leadToAccount = new List<Lead>([SELECT Id FROM Lead WHERE Id IN: mapIdStringLeadToAccount.keySet() AND Id NOT IN: mapIdStringLeadToContact.keySet()]);

        //Build the list to store our leadConverts to return
        list<Database.LeadConvert> leadConverts = new list<Database.LeadConvert>();

        for(Lead l : leadToContact){
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(l.Id);
            lc.setConvertedStatus('4 - Converted');
            //map required information from mapContacts based on the input maps
            lc.setContactId(mapContacts.get(mapIdStringLeadToContact.get(l.Id)).Id);
            lc.setAccountId(mapContacts.get(mapIdStringLeadToContact.get(l.Id)).AccountId);
            lc.setOwnerId(mapContacts.get(mapIdStringLeadToContact.get(l.Id)).Account.OwnerId);
            lc.setDoNotCreateOpportunity(true);

            leadConverts.add(lc);
        }
        for(Lead l : leadToAccount){
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(l.Id);
            lc.setConvertedStatus('4 - Converted');
            //map required information from mapContacts based on the input maps
            lc.setAccountId(mapAccounts.get(mapIdStringLeadToAccount.get(l.Id)).Id);
            lc.setOwnerId(mapAccounts.get(mapIdStringLeadToAccount.get(l.Id)).OwnerId);
            lc.setDoNotCreateOpportunity(true);

            leadConverts.add(lc);
        }

        //return a single list of lead conversions
        return leadConverts;
    }
}