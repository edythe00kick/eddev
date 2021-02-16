/**
    Author: Sergio Flores
    Date: 08/28/2019
    W-012864

    Testing the following scenarios in this knowledge article Individual Object Functionality
    https://alteryx.my.salesforce.com/kAG2R000000KyuE 
*/

@isTest
public class LeadQueueableTest {

    //Testing Scenario #3
    static testMethod void testEmailChangeNoIndividualFound()
    {
        List<Lead> leads = new List<Lead>();

        
        // insert 100 leads
        for (Integer i=0; i<200; i++) 
        {
            Lead l = new Lead();
            l.FirstName = 'Test First Name';
            l.LastName = 'Test Last Name';
            l.Street = '3345 Michelson Dr #400';
            l.City = 'Irvine';
            l.State = 'CA';
            l.PostalCode = '92612';
            l.Country = 'United States';
            l.Company = '123 Fake Company';
            l.Email = 'newLead' + i + '@gmail.com';
            leads.add(l);
        }
        
        insert leads;

        test.startTest();

        List<Lead> insertedLeads= [Select Id, Email From Lead];

        system.assertequals(200,insertedLeads.size());

        List<Lead> leadsToUpdate = new List<Lead>();

        Integer counter = 0;

        for(Lead l : insertedLeads)
        {
            counter = counter + 1;
            l.Email = 'newLead123' + counter + '@gmail.com';
            leadsToUpdate.add(l);
        }

        update leadsToUpdate;

        test.stopTest();

        List<Individual> individualList = [Select Id From Individual];

        system.assertequals(200,individualList.size());

    }

    //Testing Scenario #4
    static testMethod void testEmailChangeIndividualFound()
    {
        List<Individual> individuals = new List<Individual>();

        for(Integer i=0; i<100; i++)
        {
            //Create Individual
            Individual individual = new Individual();
            individual.Email__c = 'newLead' + i + '@gmail.com';
            individual.Communication_Opt_In__c = false;
            individual.Double_Email_Opt_In__c = false;
            individual.Email_Opt_In__c = false;
            individual.Safe_to_Send__c = 'No';
            individual.LastName = 'Test Last Name';
            individual.FirstName = 'Test First Name';
            individual.HasOptedOutOfEmail__c = true;

            individuals.add(individual);
        }

        insert individuals;
        
        List<Lead> leads = new List<Lead>();

        
        // insert 100 leads
        for (Integer i=0; i<100; i++) 
        {
            Lead l = new Lead();
            l.FirstName = 'Test First Name';
            l.LastName = 'Test Last Name';
            l.Street = '3345 Michelson Dr #400';
            l.City = 'Irvine';
            l.State = 'CA';
            l.PostalCode = '92612';
            l.Country = 'United States';
            l.Company = '123 Fake Company';
            l.Email = 'newLead123' + i + '@gmail.com';
            leads.add(l);
        }
        
        insert leads;

        test.startTest();

        List<Lead> insertedLeads= [Select Id, Email From Lead];

        system.assertequals(100,insertedLeads.size());

        List<Lead> leadsToUpdate = new List<Lead>();

        Integer counter = -1;

        for(Lead l : insertedLeads)
        {
            counter = counter + 1;
            l.Email = 'newLead' + counter + '@gmail.com';
            leadsToUpdate.add(l);
        }

        update leadsToUpdate;

        test.stopTest();

        List<Individual> individualList = [Select Id From Individual];

        system.assertequals(100,individualList.size());

        List<Lead> updatedLeads = [Select Safe_to_Send__c From Lead];

        for(Lead l : updatedLeads)
        {
            System.assertEquals('No', l.Safe_to_Send__c);
        }

    }

    //Testing Scenario #5
    static testMethod void testOptFieldsUpdatedNoIndividualFound()
    {
        List<Lead> leads = new List<Lead>();

        // insert 100 leads
        for (Integer i=0; i<100; i++) 
        {
            Lead l = new Lead();
            l.FirstName = 'Test First Name';
            l.LastName = 'Test Last Name';
            l.Street = '3345 Michelson Dr #400';
            l.City = 'Irvine';
            l.State = 'CA';
            l.PostalCode = '92612';
            l.Country = 'United States';
            l.Company = '123 Fake Company';
            l.Email = 'newLead' + i + '@gmail.com';
            leads.add(l);
        }
        
        insert leads;

        test.startTest();

        List<Lead> insertedLeads= [Select Id, Email From Lead];

        system.assertequals(100,insertedLeads.size());

        List<Lead> leadsToUpdate = new List<Lead>();

        for(Lead l : insertedLeads)
        {
            l.HasOptedOutOfEmail = true;
            leadsToUpdate.add(l);
        }

        update leadsToUpdate;

        test.stopTest();

        List<Individual> individualList = [Select Id, Safe_to_Send__c From Individual];

        system.assertequals(100,individualList.size());

        for(Individual i : individualList)
        {
            System.assertEquals('No', i.Safe_to_Send__c);
        }

        List<Lead> updatedLeads = [Select Safe_to_Send__c From Lead];

        for(Lead l : updatedLeads)
        {
            System.assertEquals('No', l.Safe_to_Send__c);
        }
    }

    //Testing Scenario #6
    static testMethod void testOptFieldsUpdatedIndividualFound()
    {
        List<Individual> individuals = new List<Individual>();

        for(Integer i=0; i<100; i++)
        {
            //Create Individual
            Individual individual = new Individual();
            individual.Email__c = 'newLead' + i + '@gmail.com';
            individual.Communication_Opt_In__c = false;
            individual.Double_Email_Opt_In__c = false;
            individual.Email_Opt_In__c = false;
            individual.Safe_to_Send__c = 'No';
            individual.LastName = 'Test Last Name';
            individual.FirstName = 'Test First Name';
            individual.HasOptedOutOfEmail__c = true;

            individuals.add(individual);
        }

        insert individuals;
        
        List<Lead> leads = new List<Lead>();

        
        // insert 100 leads
        for (Integer i=0; i<100; i++) 
        {
            Lead l = new Lead();
            l.FirstName = 'Test First Name';
            l.LastName = 'Test Last Name';
            l.Street = '3345 Michelson Dr #400';
            l.City = 'Irvine';
            l.State = 'CA';
            l.PostalCode = '92612';
            l.Country = 'United States';
            l.Company = '123 Fake Company';
            l.Email = 'newLead' + i + '@gmail.com';
            l.HasOptedOutOfEmail = true;
            leads.add(l);
        }
        
        insert leads;

        test.startTest();

        List<Lead> insertedLeads= [Select Id, Email From Lead];

        system.assertequals(100,insertedLeads.size());

        List<Lead> leadsToUpdate = new List<Lead>();

        for(Lead l : insertedLeads)
        {
            l.HasOptedOutOfEmail = false;
            leadsToUpdate.add(l);
        }

        update leadsToUpdate;

        test.stopTest();

        List<Individual> individualList = [Select Id, Safe_to_Send__c From Individual];

        system.assertequals(100,individualList.size());

        for(Individual i : individualList)
        {
            System.assertEquals('Yes', i.Safe_to_Send__c);
        }

        List<Lead> updatedLeads = [Select Safe_to_Send__c From Lead];

        for(Lead l : updatedLeads)
        {
            System.assertEquals('Yes', l.Safe_to_Send__c);
        }

    }

}