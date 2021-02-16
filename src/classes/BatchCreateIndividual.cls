/*
Author: Sergio Flores
Date: 08/15/2019
W-011320
When leads are created we will use a batch job to create the individual records for those leads that come in 
with an email that doesn't match an individual record
*/

global without sharing class  BatchCreateIndividual implements Database.Batchable<sObject>, Database.Stateful {
    
    global BatchCreateIndividual() {
    }
    
    global Database.queryLocator start(Database.BatchableContext bc) {
        
        String query = 'Select Id, FirstName, LastName, HasOptedOutOfEmail, Email, Communication_Opt_In__c, Double_Email_Opt_In__c, Email_Opt_In__c, Safe_to_Send__c FROM Lead'
            + ' WHERE CreatedDate >= YESTERDAY AND Email !=null';
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> leadRecords) {
        system.debug('BatchCreateIndividual lead records ' + leadRecords);
        Recursionhandler.IsleadTriggerExecuted = true;
        
        Map<String, Lead> leadEmailToLeadMap = new Map<String, Lead>();
        
        for(Lead lead : leadRecords) {
            
            leadEmailToLeadMap.put(lead.Email, lead);
            
        }

        //Adding toggle to execute individual functionality
        string toggleForIndividual = System.Label.Individual_Toggle;
        
        if(!leadEmailToLeadMap.isEmpty() && toggleForIndividual == 'True') {

            //Query for individual records matching contact email
            List<Individual> individualList = [Select Id, Email__c, HasOptedOutOfEmail__c, Communication_Opt_In__c, Double_Email_Opt_In__c, Email_Opt_In__c, Safe_to_Send__c
            From Individual Where Email__c IN : leadEmailToLeadMap.keySet()];
            system.debug('inside individual check ' + individualList);
            Map<String, Individual> individualEmailToIndividual = new Map<String,Individual>();
            List<Individual> individualsToInsert = new List<Individual>();
            List<Lead> leadsToUpdate = new List<Lead>();

            for(Individual i : individualList)
            {
                individualEmailToIndividual.put(i.Email__c, i);
            }
            for(Lead lead : leadRecords)
            {
                Individual i = individualEmailToIndividual.get(lead.Email);

                system.debug('individual ' + i);
                //If there was no individual record found then we must create a new one
                if(i == null)
                {
                    system.debug('inside creating new individual record batch class');
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
                }
                else {
                    system.debug('inside updating lead record batch class');
                    Lead updatedLead = new Lead();
                    updatedLead.Id = lead.Id;
                    updatedLead.Communication_Opt_In__c = i.Communication_Opt_In__c;
                    updatedLead.Double_Email_Opt_In__c = i.Double_Email_Opt_In__c;
                    updatedLead.Email_Opt_In__c = i.Email_Opt_In__c;
                    updatedLead.Safe_to_Send__c = i.Safe_to_Send__c;
                    updatedLead.HasOptedOutOfEmail = i.HasOptedOutOfEmail__c;
                    leadsToUpdate.add(updatedLead);
                }
            }
            if(!individualsToInsert.isEmpty())
            {
                try {
                    insert individualsToInsert;
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
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
        
        
        
        
    }
    
}