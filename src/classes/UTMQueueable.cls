/**
 * Created by ewong on 12/17/2019.
 */
//Eddie Wong
//Date: 12/17/2019
//W-013648
//To store UTM value from lead/contact into new custom object UTM_fields_tracking__c

public without sharing class UTMQueueable{
    private Map<String, Lead> leadUTMToUTM;
    private Map<String, Contact> contactUTMToUTM; 
    //private Boolean isUpdateTrigger;


    public static void executeUTM(Map<String, Lead> leadUTMToUTM, Map<String,Contact> contactUTMToUTM){
        Recursionhandler.IsLeadUTMTriggerExecuted    = true;
        Recursionhandler.IsContactUTMTriggerExecuted = true;
        //  System.debug('inside UTMQueueable 3' + leadUTMToUTM.size()); //eddie add

        List<UTM_fields_tracking__c> lUTMTrack = new List<UTM_fields_tracking__c>();
        List<UTM_fields_tracking__C> cUTMTrack = new List<UTM_fields_tracking__c>();
        List<Lead> leadCleanUp       = new List<Lead>();
        List<Contact> contactCleanUp = new List<Contact>();

        // Added by: Sharma Nemani | W-002464 | Case: 00310603 |Date: 01/29/2020 --> START
        Map<Id,Set<Id>> mapLeadIdAndCampaignId = new Map<Id,Set<Id>>();
        List<UTM_fields_tracking__c> lstUTM_fields_tracking = new List<UTM_fields_tracking__c>();
        //System.debug('inside UTMQueueable 5' + leadUTMToUTM.size());
        if(leadUTMToUTM != null && leadUTMToUTM.size() > 0){
            System.debug('inside lstUTM_fields_tracking'); //eddie add
            lstUTM_fields_tracking = [select Lead__c,Campaign__c from UTM_fields_tracking__c where Lead__c IN : leadUTMToUTM.keySet()];
            System.debug('inside lstUTM_fields_tracking ' + lstUTM_fields_tracking.size());
        }

        for(UTM_fields_tracking__c uft : lstUTM_fields_tracking){
            if(mapLeadIdAndCampaignId.containsKey(uft.Lead__c)){
                System.debug('inside mapLeadIdAndCampaignId.containsKey('); //eddie add
                mapLeadIdAndCampaignId.get(uft.Lead__c).add(uft.Campaign__c);
            }else{
                System.debug('inside mapLeadIdAndCampaignId.containsKey( - 2'); //eddie add
                mapLeadIdAndCampaignId.put(uft.Lead__c,new Set<Id>{uft.Campaign__c});
            }
        }
        // Sharma Nemani | W-002464 | Case: 00310603 |Date: 01/29/2020 --> START

        //Query for Lead records
        if(leadUTMToUTM != null && !leadUTMToUTM.isEmpty()){
            List<Lead> leadList = [Select Id,UTM_Campaign_Name__c,UTM_Source__c,UTM_Medium__c,CPC_Keyword__c,CPC_Ad_Group__c,Most_Recent_Campaign_ID__c
            From Lead
            Where Id IN :leadUTMToUTM.keySet()];
            //Instantiate new UTM_fields_tracking__c object and populate the UTM values from the corresponding lead
            System.debug('inside !leadList.isEmpty() '); //eddie add
            for (Lead l : leadList) {
                // Added by: Sharma Nemani | W-002464 | Case: 00310603 |Date: 01/29/2020 --> START
                if(mapLeadIdAndCampaignId.size() > 0 && l.Most_Recent_Campaign_ID__c!=null && mapLeadIdAndCampaignId.containskey(l.Id) && mapLeadIdAndCampaignId.get(l.id).contains(l.Most_Recent_Campaign_ID__c)){
                    System.debug('inside mapLeadIdAndCampaignId.size() > 0');
                    continue;
                }
                // Sharma Nemani | W-002464 | Case: 00310603 |Date: 01/29/2020 --> START
                System.debug('outside of mapLeadIdAndCampaignId.size() > 0');//eddie add
                System.debug('eddie inside l.Most_Recent_Campaign_ID__c' + l.Most_Recent_Campaign_ID__c);
                System.debug('eddie insied l.UTM_Campaign_Name__c;' + l.UTM_Campaign_Name__c);
                UTM_fields_tracking__c utmFieldTrack = new UTM_fields_tracking__c();
                utmFieldTrack.UTM_Campaign_Name__c   = l.UTM_Campaign_Name__c;
                utmFieldTrack.UTM_Content__c         = l.CPC_Ad_Group__c;
                utmFieldTrack.UTM_Medium__c          = l.UTM_Medium__c;
                utmFieldTrack.UTM_Source__c          = l.UTM_Source__c;
                utmFieldTrack.UTM_Term__c            = l.CPC_Keyword__c;
                utmFieldTrack.Lead__c                = l.Id;
                utmFieldTrack.Campaign__c            = l.Most_Recent_Campaign_ID__c;
                lUTMTrack.add(utmFieldTrack);

                //To blank out the UTM fields in lead after the UTM values have been copied over to object - UTM_fields_tracking__c
                l.UTM_Campaign_Name__c = '';
                l.UTM_Medium__c        = '';
                l.UTM_Source__c        = '';
                l.CPC_Ad_Group__c      = '';
                l.CPC_Keyword__c       = '';
                leadCleanUp.add(l);
            }

        }
        //Query for Contact records
        else if(contactUTMToUTM != null && !contactUTMToUTM.isEmpty()){
            List<Contact> contactList = [Select Id,UTM_Campaign_Name__c,UTM_Source__c,UTM_Medium__c,cpc_ad_group__c ,cpc_keyword__c,Most_Recent_Campaign_ID__c
            From Contact
            Where Id IN :contactUTMToUTM.keySet()];
            //Instantiate new UTM_fields_tracking__c object and populate the UTM values from the corresponding contact
            for (Contact contact : contactList) {
                UTM_fields_tracking__c utmFieldTrack = new UTM_fields_tracking__c();
                utmFieldTrack.UTM_Campaign_Name__c   = contact.UTM_Campaign_Name__c;
                utmFieldTrack.UTM_Content__c         = contact.cpc_ad_group__c;
                utmFieldTrack.UTM_Medium__c          = contact.UTM_Medium__c;
                utmFieldTrack.UTM_Source__c          = contact.UTM_Source__c;
                utmFieldTrack.UTM_Term__c            = contact.cpc_keyword__c;
                utmFieldTrack.Contact__c             = contact.Id;
                utmFieldTrack.Campaign__c            = contact.Most_Recent_Campaign_ID__c;
                cUTMTrack.add(utmFieldTrack);

                //To blank out the UTM fields in Contact after the UTM values have been copied over to object - UTM_fields_tracking__c
                contact.UTM_Campaign_Name__c = '';
                contact.UTM_Medium__c        = '';
                contact.UTM_Source__c        = '';
                contact.cpc_ad_group__c      = '';
                contact.cpc_keyword__c       = '';
                contactCleanUp.add(contact);
            }

        }

        if (lUTMTrack != null && !lUTMTrack.isEmpty()){
            System.debug('inside lUTMTrack != null' + lUTMTrack.size()); //eddie add
            try{
                insert lUTMTrack;
            } catch(Exception ex){
                System.debug('Inside catch exception');
                trigger.new[0].addError(ex.getMessage());
            }
        }

        if (cUTMTrack != null && !cUTMTrack.isEmpty()){
            try{
                insert cUTMTrack;
            } catch(Exception ex){
                System.debug('Inside catch exception');
                trigger.new[0].addError(ex.getMessage());
            }
        }

        if (leadCleanUp != null && !leadCleanUp.isEmpty()){
            try {
                update leadCleanUp;
            } catch (Exception ex) {
                System.debug('Inside leadCleanUp catch exception');
                trigger.new[0].addError(ex.getMessage());

            }
        }

        if (contactCleanUp != null && !contactCleanUp.isEmpty()){
            try {
                update contactCleanUp;
            } catch (Exception ex) {
                System.debug('Inside leadCleanUp catch exception');
                trigger.new[0].addError(ex.getMessage());

            }
        }
    }
}