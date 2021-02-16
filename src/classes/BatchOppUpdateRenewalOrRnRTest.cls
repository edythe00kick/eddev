/**
 * Created by ewong on 5/13/2020.
 */

@IsTest
public class BatchOppUpdateRenewalOrRnRTest {

    @testSetup static void setup(){
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        List<SBQQ__Quote__c> quoteToUpdate = new List<SBQQ__Quote__c>();
        List<Account> accToUpdate = new List<Account>();
        List<Contract> conToUpdate = new List<Contract>();

        Account accOne = OrgWideTestUtil.createAccount(false);
        accOne.Type = 'Customer';
        accToUpdate.add(accOne);
        insert accToUpdate;

        Product2 renewableProd = OSCPQ_TestFactory.createBasicRenewableProduct(1, true);

        Opportunity oppOne = OrgWideTestUtil.createOpportunity(false, accOne.Id);
        oppOne.Type = 'ECUR';
        oppOne.StageName = '5 - Closed Won';
        oppToUpdate.add(oppOne);

        Opportunity oppTwo = OrgWideTestUtil.createOpportunity(false, accOne.Id);
        oppTwo.Type = 'ECUR';
        oppToUpdate.add(oppTwo);

        insert oppToUpdate;

        SBQQ.TriggerControl.disable();

        SBQQ__Quote__c quoteOne = OrgWideTestUtil.createSingleQuote(accOne, oppOne, true, false);
        SBQQ__Quote__c quoteTwo = OrgWideTestUtil.createSingleQuote(accOne, oppTwo, false, false);
        quoteOne.Purchase_Type__c = 'Renewal';
        quoteOne.Proposal_Accepted_Date__c = date.newInstance(2020, 03, 31);
        quoteOne.SBQQ__StartDate__c = System.today() + 10;
        quoteTwo.Purchase_Type__c = 'New Business';
        quoteToUpdate.add(quoteOne);
        quoteToUpdate.add(quoteTwo);
        insert quoteToUpdate;

        Contract conOne = OrgWideTestUtil.createSingleContract(accOne, false, oppOne);
        conOne.SBQQ__Quote__c = quoteOne.Id;
        conOne.EndDate = System.today() + 9;
        conToUpdate.add(conOne);

        Contract conTwo = OrgWideTestUtil.createSingleContract(accOne, false, oppTwo);
        conTwo.SBQQ__Quote__c = quoteTwo.Id;
        conTwo.EndDate = System.today() - 1;
        conToUpdate.add(conTwo);

        insert conToUpdate;

        SBQQ__Subscription__c subOne = OrgWideTestUtil.createSingleSubscription(conOne, renewableProd, true);
        SBQQ__Subscription__c subTwo = OrgWideTestUtil.createSingleSubscription(conTwo, renewableProd, true);

        Related_Contract__c rContractOne = OrgWideTestUtil.createRelatedContract(true, oppOne, conOne);
        Related_Contract__c rContractTwo = OrgWideTestUtil.createRelatedContract(true, oppOne, conTwo);

        //SBQQ.TriggerControl.enable();
    }

    testMethod static void testRenewalScenarioOne() {  //Contract #1 has later end date. Contract 2 will flip to terminated/renewed

        Test.startTest();
        System.debug('eddie inside testRenewalScenarioOne');

        BatchOppUpdateRenewalOrRnR bRRR = new BatchOppUpdateRenewalOrRnR();
        Id batchId = Database.executeBatch(bRRR);
        System.debug('Eddie inside after opps added to RnR batch 1');
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Opportunity WHERE StageName = '5 - Closed Won' AND Type = 'ECUR']);
        System.assertEquals(1, [SELECT Count() FROM Opportunity WHERE StageName = 'Closed - Consolidated' AND Type = 'ECUR']);
        System.assertEquals(1, [SELECT Count() FROM Contract WHERE Status = 'Terminated' AND Status_Category__c = 'Renewed']);
        System.assertEquals(2, [SELECT Count() FROM SBQQ__Subscription__c WHERE SBQQ__RenewedDate__c = 2020-03-31]);
    }

    testMethod static void testRenewalScenarioTwo() {     //Both related contract enddate are beyond quote start date. None will fip to terminated/renewed
        List<Contract> conToUpdate = new List<Contract>();

        for(Contract con : [SELECT Id FROM Contract LIMIT 2]){
            Contract cont = new Contract();
            cont.Id = con.Id;
            cont.EndDate = System.today() + 30;
            conToUpdate.add(cont);
        }
        update conToUpdate;

        Test.startTest();
        System.debug('eddie inside testRenewalScenarioTwo');

        BatchOppUpdateRenewalOrRnR bRRR = new BatchOppUpdateRenewalOrRnR();
        Id batchId = Database.executeBatch(bRRR);
        System.debug('Eddie inside testRenewalScenarioTwo batch class 1');
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Opportunity WHERE StageName = '5 - Closed Won' AND Type = 'ECUR']);
        System.assertEquals(1, [SELECT Count() FROM Opportunity WHERE StageName = 'Closed - Consolidated' AND Type = 'ECUR']);
        System.assertEquals(0, [SELECT Count() FROM Contract WHERE Status = 'Terminated' AND Status_Category__c = 'Renewed']);
        System.assertEquals(2, [SELECT Count() FROM SBQQ__Subscription__c WHERE SBQQ__RenewedDate__c = 2020-03-31]);
    }

    testMethod static void testRenewalScenarioThree() {  // Both contracts should flip to terminated/renewed

        Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c WHERE Purchase_Type__c = 'Renewal' LIMIT 1];
        quote.SBQQ__StartDate__c =  System.today();
        update quote;

        Contract conOne = [SELECT Id FROM Contract WHERE EndDate != YESTERDAY LIMIT 1];
        conOne.EndDate = System.today() - 1;
        update conOne;

        Contract conTwo = [SELECT Id FROM Contract WHERE EndDate = YESTERDAY LIMIT 1];
        conTwo.EndDate = System.today() + 20;
        update conTwo;


        System.debug('eddie inside testRenewalScenarioThree');

        BatchOppUpdateRenewalOrRnR bRRR = new BatchOppUpdateRenewalOrRnR();
        Id batchId = Database.executeBatch(bRRR);
        System.debug('Eddie inside testRenewalScenarioThree batch class 1');
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Opportunity WHERE StageName = '5 - Closed Won' AND Type = 'ECUR']);
        System.assertEquals(1, [SELECT Count() FROM Opportunity WHERE StageName = 'Closed - Consolidated' AND Type = 'ECUR']);
        System.assertEquals(2, [SELECT Count() FROM Contract WHERE Status = 'Terminated' AND Status_Category__c = 'Renewed']);
        System.assertEquals(2, [SELECT Count() FROM SBQQ__Subscription__c WHERE SBQQ__RenewedDate__c = 2020-03-31]);
    }

    testMethod static void testRipAndReplaceScenarioOne() {   //Both contracts should flip to terminated/contract extended

        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c WHERE Purchase_Type__c = 'Renewal' LIMIT 1];
        quote.Purchase_Type__c = 'Upsell Rip & Replace';
        quote.SBQQ__StartDate__c = System.today();
        update quote;

        Test.startTest();
        System.debug('eddie inside testRipAndReplaceScenarioOne');

        BatchOppUpdateRenewalOrRnR bRRR = new BatchOppUpdateRenewalOrRnR();
        Id batchId = Database.executeBatch(bRRR);
        System.debug('Eddie inside testRipAndReplaceScenarioOne after opps added to RnR batch 2');
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Opportunity WHERE StageName = '5 - Closed Won' AND Type = 'ECUR']);
        System.assertEquals(1, [SELECT Count() FROM Opportunity WHERE StageName = 'Closed - Rip & Replace' AND Type = 'ECUR']);
        System.assertEquals(2, [SELECT Count() FROM Contract WHERE Status = 'Terminated' AND Status_Category__c = 'Contract Extended']);
        System.assertEquals(2, [SELECT Count() FROM SBQQ__Subscription__c WHERE SBQQ__TerminatedDate__c = 2020-03-31]);
    }

    testMethod static void testRipAndReplaceScenarioTwo() {   //None of the contracts should flip to terminated/contract extended

        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c WHERE Purchase_Type__c = 'Renewal' LIMIT 1];
        quote.Purchase_Type__c = 'Upsell Rip & Replace';
        update quote;

        Test.startTest();
        System.debug('eddie inside testRipAndReplaceScenarioTwo');

        BatchOppUpdateRenewalOrRnR bRRR = new BatchOppUpdateRenewalOrRnR();
        Id batchId = Database.executeBatch(bRRR);
        System.debug('Eddie inside testRipAndReplaceScenarioTwo after opps added to RnR batch 2');
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Opportunity WHERE StageName = '5 - Closed Won' AND Type = 'ECUR']);
        System.assertEquals(1, [SELECT Count() FROM Opportunity WHERE StageName = 'Closed - Rip & Replace' AND Type = 'ECUR']);
        System.assertEquals(0, [SELECT Count() FROM Contract WHERE Status = 'Terminated' AND Status_Category__c = 'Contract Extended']);
        System.assertEquals(2, [SELECT Count() FROM SBQQ__Subscription__c WHERE SBQQ__TerminatedDate__c = 2020-03-31]);
    }
}