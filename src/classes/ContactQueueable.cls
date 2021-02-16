public without sharing class ContactQueueable implements Queueable {
    private Map<String, Contact> contactEmailToContact;
    private Boolean isInsertTrigger;
    private Boolean emailChanged = false;

    public ContactQueueable(Map<String, Contact> contactEmailToContact, Boolean isInsertTrigger, Boolean emailChanged) {
        this.contactEmailToContact = contactEmailToContact;
        this.isInsertTrigger = isInsertTrigger;
        this.emailChanged = emailChanged;

    }

    public void execute(QueueableContext context) {
        RecursionHandler.IsContactTriggerExecuted = true;
        System.debug('inside executeCreateIndividualRecord queuable ' + contactEmailToContact + ' '+ isInsertTrigger + ' ' + emailChanged);

        //Query for individual records matching contact email
        List<Individual> individualList = [Select Id, Email__c, HasOptedOutOfEmail__c, Communication_Opt_In__c, Double_Email_Opt_In__c, Email_Opt_In__c, Safe_to_Send__c
        From Individual Where Email__c IN : contactEmailToContact.keySet()];

        system.debug('inside individual check ' + individualList);
        Map<String, Individual> individualEmailToIndividual = new Map<String,Individual>();
        Map<String, Individual> individualEmailToIndividual2 = new Map<String,Individual>();//This will be used to map the new individual records we will update
        //Since we won't update the individual records in this execution, we need to track the new values so we can use the new values to update the duplicate contacts
        List<Individual> individualsToInsert = new List<Individual>();
        List<Individual> individualsToUpdate = new List<Individual>();
        List<Contact> contactsToUpdate = new List<Contact>();
        Set<Id> contactIds = new Set<Id>(); //This is used for checking to see that we don't update same contact

        List<UTM_fields_tracking__c> lUTMTrack = new List<UTM_fields_tracking__c>(); //SF 03/13/2020 W-002464
        Set<Id> contactIdsToNull = new Set<Id>();

        for(Individual i : individualList)
        {
            individualEmailToIndividual.put(i.Email__c, i);
        }
        for(Contact c : contactEmailToContact.values())
        {
            Individual i = individualEmailToIndividual.get(c.Email);


            system.debug('individual ' + i); 
            //If there was no individual record found then we must create a new one
            if(i == null)
            {
                system.debug('inside creating new individual record');
                Individual individual = new Individual();
                individual.Email__c = c.Email;
                individual.Communication_Opt_In__c = c.Communication_Opt_In__c;
                individual.Double_Email_Opt_In__c = c.Double_Email_Opt_In__c;
                individual.Email_Opt_In__c = c.Email_Opt_In__c;
                individual.Safe_to_Send__c = c.Safe_to_Send__c;
                individual.LastName = c.LastName;
                individual.FirstName = c.FirstName;
                individual.HasOptedOutOfEmail__c = c.HasOptedOutOfEmail;
                individualsToInsert.add(individual);

                //Sergio Flores
                //Date: 03/13/2020
                //W-002464
                //We need to handle net new leads if it creates a new individual record to also create new UTM and null out fields
                if (c.Most_Recent_Campaign_ID__c != null
                        && (c.UTM_Source__c      != null
                        || c.UTM_Medium__c       != null))
                {
                    System.debug('inside contact handler utm field track individual');
                    UTM_fields_tracking__c utmFieldTrack = new UTM_fields_tracking__c();
                    utmFieldTrack.UTM_Campaign_Name__c   = c.UTM_Campaign_Name__c;
                    utmFieldTrack.UTM_Content__c         = c.CPC_Ad_Group__c;
                    utmFieldTrack.UTM_Medium__c          = c.UTM_Medium__c;
                    utmFieldTrack.UTM_Source__c          = c.UTM_Source__c;
                    utmFieldTrack.UTM_Term__c            = c.CPC_Keyword__c;
                    utmFieldTrack.Contact__c                = c.Id;
                    utmFieldTrack.Campaign__c            = c.Most_Recent_Campaign_ID__c;
                    lUTMTrack.add(utmFieldTrack);
                    contactIdsToNull.add(c.Id);

                }
            }
            //this checks to see if an individual was found and if we are inserting a new lead or contact
            //if so then we have to grab the individual information and populate on new lead or contact
            else if(isInsertTrigger)
            {
                system.debug('inside found individual, updating contact record');
                Contact updatedContact = new Contact();
                updatedContact.Id = c.Id;
                updatedContact.Communication_Opt_In__c = i.Communication_Opt_In__c;
                updatedContact.Double_Email_Opt_In__c = i.Double_Email_Opt_In__c;
                updatedContact.Email_Opt_In__c = i.Email_Opt_In__c;
                updatedContact.Safe_to_Send__c = i.Safe_to_Send__c;
                updatedContact.HasOptedOutOfEmail = i.HasOptedOutOfEmail__c;
                contactsToUpdate.add(updatedContact);
                contactIds.add(updatedContact.Id);
            }
            //this checks to see if there is an individual found and we updated email
            //for email changes, we don't want to update opt fields, instead we should pull from
            //the individual
            else if(emailChanged)
            {
                system.debug('inside contact email changed, found individual, updating contact record');
                Contact updatedContact = new Contact();
                updatedContact.Id = c.Id;
                updatedContact.Communication_Opt_In__c = i.Communication_Opt_In__c;
                updatedContact.Double_Email_Opt_In__c = i.Double_Email_Opt_In__c;
                updatedContact.Email_Opt_In__c = i.Email_Opt_In__c;
                updatedContact.Safe_to_Send__c = i.Safe_to_Send__c;
                updatedContact.HasOptedOutOfEmail = i.HasOptedOutOfEmail__c;
                contactsToUpdate.add(updatedContact);
                contactIds.add(updatedContact.Id);
            }
            //this is an update and there was an individual record found so we have to update the existing individual record
            else {
                system.debug('inside found individual, opt fields changed need to update individual record');
                Individual individual = new Individual();
                individual.Id = i.Id;
                individual.Email__c = c.Email;
                individual.Communication_Opt_In__c = c.Communication_Opt_In__c;
                individual.Double_Email_Opt_In__c = c.Double_Email_Opt_In__c;
                individual.Email_Opt_In__c = c.Email_Opt_In__c;
                individual.Safe_to_Send__c = c.Safe_to_Send__c;
                individual.LastName = c.LastName;
                individual.FirstName = c.FirstName;
                individual.HasOptedOutOfEmail__c = c.HasOptedOutOfEmail;
                individualsToUpdate.add(individual);
                individualEmailToIndividual2.put(individual.Email__c, individual);
            }
        }

        //Query all leads where we need to blank out the UTM fields //SF 03/13/2020 W-002464
        List<Contact> contactsToNullOutUTMList = [Select Id, UTM_Campaign_Name__c, UTM_Medium__c, UTM_Source__c, CPC_Ad_Group__c, CPC_Keyword__c From Contact Where Id IN : contactIdsToNull];

        for(Contact c : contactsToNullOutUTMList)
        {
            system.debug('inside nulling out UTM fields');
            c.UTM_Campaign_Name__c = '';
            c.UTM_Medium__c        = '';
            c.UTM_Source__c        = '';
            c.CPC_Ad_Group__c      = '';
            c.CPC_Keyword__c       = '';
        }

        if(isInsertTrigger == false)
        {
            Set<ID> contactIdSet = new Set<Id>();

            for(Contact c : contactEmailToContact.values())
            {
                contactIdSet.add(c.Id);
            }
            //Query all contacts with matching email
            List<Contact> matchingEmailContactsList = [Select Id, Email, Communication_Opt_In__c, Double_Email_Opt_In__c, Email_Opt_In__c, Safe_to_Send__c
            From Contact Where ID NOT IN : contactIdSet AND Email IN : contactEmailToContact.keySet()];

            system.debug('matchingEmailContactsList ' + matchingEmailContactsList);
            //if size is more than one meaning there are other contacts with matching email then we must
            //update those contacts with the individual record information
            //check to see if there is a matching individual and that this contact is not already in the
            //contactsIds set so we don't update this contact again
            if(!matchingEmailContactsList.isEmpty() && matchingEmailContactsList.size() > 0)
            {
                for(Contact c : matchingEmailContactsList)
                {
                    Individual i = individualEmailToIndividual2.get(c.Email);

                    system.debug('individual inside matchingEmailContactsList' + i);
                    if(i !=null && !contactIds.contains(c.Id))
                    {
                        //add this contact to update into the contactsToUpdate list
                        Contact updatedContact = new Contact();
                        updatedContact.Id = c.Id;
                        updatedContact.Communication_Opt_In__c = i.Communication_Opt_In__c;
                        updatedContact.Double_Email_Opt_In__c = i.Double_Email_Opt_In__c;
                        updatedContact.Email_Opt_In__c = i.Email_Opt_In__c;
                        updatedContact.Safe_to_Send__c = i.Safe_to_Send__c;
                        updatedContact.HasOptedOutOfEmail = i.HasOptedOutOfEmail__c;
                        contactsToUpdate.add(updatedContact);
                        contactIds.add(updatedContact.Id);
                    }

                }
            }
        }
        if(!individualsToInsert.isEmpty())
        {
            try {
                insert individualsToInsert;
                if(!lUTMTrack.isEmpty()) //SF 03/13/2020 W-002464
                    insert lUTMTrack;
                if(!contactsToNullOutUTMList.isEmpty()) //SF 03/13/2020 W-002464
                    update contactsToNullOutUTMList;
            } catch(Exception ex){
                system.debug('inside catch exception');
                trigger.new[0].addError(ex.getMessage());
            }
        }

        if(!contactsToUpdate.isEmpty())
        {
            try {
                update contactsToUpdate;
            } catch(Exception ex){
                system.debug('inside catch exception');
                trigger.new[0].addError(ex.getMessage());
            }
        }

        if(!individualsToUpdate.isEmpty())
        {
            try {
                update individualsToUpdate;
            } catch(Exception ex){
                system.debug('inside catch exception');
                trigger.new[0].addError(ex.getMessage());
            }
        }
    }

}