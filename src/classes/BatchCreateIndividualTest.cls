/**
    Author: Sergio Flores
    Date: 08/28/2019
    W-012864

    Testing the following scenarios in this knowledge article Individual Object Functionality
    https://alteryx.my.salesforce.com/kAG2R000000KyuE 
*/

@isTest
public class BatchCreateIndividualTest {

    //Testing Scenario #1
    static testmethod void testBulkIndividualCreation() { 

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
        
        Test.startTest();

        BatchCreateIndividual bci = new BatchCreateIndividual();
        Id batchId = Database.executeBatch(bci);

        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(200, [Select Count() From Individual]);
    }

    //Testing Scenario #2
    static testmethod void testBulkLeadUpdate() {

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
            leads.add(l);
        }
        
        insert leads;

        Test.startTest();

        BatchCreateIndividual bci = new BatchCreateIndividual();
        Id batchId = Database.executeBatch(bci);

        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(100, [Select Count() From Individual]);

        List<Lead> updatedLeads = [Select Safe_to_Send__c From Lead];

        for(Lead l : updatedLeads)
        {
            System.assertEquals('No', l.Safe_to_Send__c);
        }
    }

}