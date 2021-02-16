public without sharing class LeadQueueable implements Queueable {
    private Map<String, Lead> leadEmailToLead;
    private Boolean emailChanged = false;

    public LeadQueueable(Map<String, Lead> leadEmailToLead, Boolean emailChanged) { 
        this.leadEmailToLead = leadEmailToLead;
        this.emailChanged = emailChanged;
    }

    public void execute(QueueableContext context) {
        Recursionhandler.IsleadTriggerExecuted = true;

        //Query for individual records matching Lead email
        List<Individual> individualList = [Select Id, Email__c, HasOptedOutOfEmail__c, Communication_Opt_In__c, Double_Email_Opt_In__c, Email_Opt_In__c, Safe_to_Send__c
        From Individual Where Email__c IN : leadEmailToLead.keySet()];
        system.debug('inside individual check ' + individualList);
        Map<String, Individual> individualEmailToIndividual = new Map<String,Individual>();
        Map<String, Individual> individualEmailToIndividual2 = new Map<String,Individual>();
        List<Individual> individualsToInsert = new List<Individual>();
        List<Individual> individualsToUpdate = new List<Individual>();
        List<Lead> leadsToUpdate = new List<Lead>();

        List<UTM_fields_tracking__c> lUTMTrack = new List<UTM_fields_tracking__c>(); //SF 03/13/2020 W-002464
        Set<Id> leadIds = new Set<Id>();

        for(Individual i : individualList)
        {
            individualEmailToIndividual.put(i.Email__c, i);
        }
        for(Lead lead : leadEmailToLead.values())
        {
            Individual i = individualEmailToIndividual.get(lead.Email);


            system.debug('individual ' + i);
            //If there was no individual record found then we must create a new one
            if(i == null)
            {
                system.debug('inside creating new individual record');
                Individual individual = new Individual();
                individual.Email__c = lead.Email;
                individual.Communication_Opt_In__c = lead.Communication_Opt_In__c;
                individual.Double_Email_Opt_In__c = lead.Double_Email_Opt_In__c;
                individual.Email_Opt_In__c = lead.Email_Opt_In__c;
                individual.Safe_to_Send__c = lead.Safe_to_Send__c;
                individual.LastName = lead.LastName;
                individual.FirstName = lead.FirstName;
                individual.HasOptedOutOfEmail__c = lead.HasOptedOutOfEmail;
                individualsToInsert.add(individual);

                //Sergio Flores
                //Date: 03/13/2020
                //W-002464
                //We need to handle net new leads if it creates a new individual record to also create new UTM and null out fields
                if (lead.Most_Recent_Campaign_ID__c != null
                        && (lead.UTM_Source__c      != null
                        || lead.UTM_Medium__c       != null))
                {
                    System.debug('inside lead handler utm field track individual');
                    UTM_fields_tracking__c utmFieldTrack = new UTM_fields_tracking__c();
                    utmFieldTrack.UTM_Campaign_Name__c   = lead.UTM_Campaign_Name__c;
                    utmFieldTrack.UTM_Content__c         = lead.CPC_Ad_Group__c;
                    utmFieldTrack.UTM_Medium__c          = lead.UTM_Medium__c;
                    utmFieldTrack.UTM_Source__c          = lead.UTM_Source__c;
                    utmFieldTrack.UTM_Term__c            = lead.CPC_Keyword__c;
                    utmFieldTrack.Lead__c                = lead.Id;
                    utmFieldTrack.Campaign__c            = lead.Most_Recent_Campaign_ID__c;
                    lUTMTrack.add(utmFieldTrack);
                    leadIds.add(lead.Id);

                }
            }
            //this checks to see if there is an individual found and we updated email
            //for email changes, we don't want to update opt fields, instead we should pull from
            //the individual
            else if(emailChanged)
            {
                system.debug('inside lead email changed, found individual, updating lead record');
                Lead updatedLead = new Lead();
                updatedLead.Id = lead.Id;
                updatedLead.Communication_Opt_In__c = i.Communication_Opt_In__c;
                updatedLead.Double_Email_Opt_In__c = i.Double_Email_Opt_In__c;
                updatedLead.Email_Opt_In__c = i.Email_Opt_In__c;
                updatedLead.Safe_to_Send__c = i.Safe_to_Send__c;
                updatedLead.HasOptedOutOfEmail = i.HasOptedOutOfEmail__c;
                leadsToUpdate.add(updatedLead);
            }
            //there was an individual record found so we have to update the existing record
            else {
                system.debug('inside found individual, opt fields changed need to update individual record');
                Individual individual = new Individual();
                individual.Id = i.Id;
                individual.Email__c = lead.Email;
                individual.Communication_Opt_In__c = lead.Communication_Opt_In__c;
                individual.Double_Email_Opt_In__c = lead.Double_Email_Opt_In__c;
                individual.Email_Opt_In__c = lead.Email_Opt_In__c;
                individual.Safe_to_Send__c = lead.Safe_to_Send__c;
                individual.LastName = lead.LastName;
                individual.FirstName = lead.FirstName;
                individual.HasOptedOutOfEmail__c = lead.HasOptedOutOfEmail;
                individualsToUpdate.add(individual);
            }
        }

        //Query all leads where we need to blank out the UTM fields //SF 03/13/2020 W-013648
        List<Lead> leadsToNullOutUTMList = [Select Id, UTM_Campaign_Name__c, UTM_Medium__c, UTM_Source__c, CPC_Ad_Group__c, CPC_Keyword__c From Lead Where Id IN : leadIds];

        for(Lead l : leadsToNullOutUTMList)
        {
            system.debug('inside nulling out UTM fields');
            l.UTM_Campaign_Name__c = '';
            l.UTM_Medium__c        = '';
            l.UTM_Source__c        = '';
            l.CPC_Ad_Group__c      = '';
            l.CPC_Keyword__c       = '';
        }

        Set<ID> leadIdSet = new Set<Id>();

        for(lead l : leadEmailToLead.values())
        {
            leadIdSet.add(l.Id);
        }
        //Query all leads with matching email
        List<lead> matchingEmailLeadsList = [Select Id, Email, HasOptedOutOfEmail, Communication_Opt_In__c, Double_Email_Opt_In__c, Email_Opt_In__c, Safe_to_Send__c
        From lead Where ID NOT IN : leadIdSet AND Email IN : leadEmailToLead.keySet()];

        system.debug('matchingEmailLeadsList ' + matchingEmailLeadsList);
        //if size is more than one meaning there are other leads with matching email then we must
        //update those leads with the individual record information
        //check to see if there is a matching individual and that this lead is not already in the
        //leadsIds set so we don't update this lead again
        if(!matchingEmailLeadsList.isEmpty() && matchingEmailLeadsList.size() > 0)
        {
            for(lead l : matchingEmailLeadsList)
            {
                Individual i = individualEmailToIndividual2.get(l.Email);

                system.debug('individual inside matchingEmailleadsList' + i);
                if(i !=null && !leadIds.contains(l.Id))
                {
                    //add this lead to update into the leadsToUpdate list
                    lead updatedLead = new lead();
                    updatedLead.Id = l.Id;
                    updatedLead.Communication_Opt_In__c = i.Communication_Opt_In__c;
                    updatedLead.Double_Email_Opt_In__c = i.Double_Email_Opt_In__c;
                    updatedLead.Email_Opt_In__c = i.Email_Opt_In__c;
                    updatedLead.Safe_to_Send__c = i.Safe_to_Send__c;
                    updatedLead.HasOptedOutOfEmail = i.HasOptedOutOfEmail__c;
                    leadsToUpdate.add(updatedLead);
                    leadIds.add(updatedLead.Id);
                }
            }
        }

        if(!individualsToInsert.isEmpty())
        {
            try {
                insert individualsToInsert;
                if(!lUTMTrack.isEmpty()) //SF 03/13/2020W-002464
                    insert lUTMTrack;
                if(!leadsToNullOutUTMList.isEmpty()) //SF 03/13/2020 W-002464
                    update leadsToNullOutUTMList;
            } catch(Exception ex){
                system.debug('inside catch exception');
                trigger.new[0].addError(ex.getMessage());
            }
        }

        if(!leadsToUpdate.isEmpty())
        {
            try {
                update leadsToUpdate;
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