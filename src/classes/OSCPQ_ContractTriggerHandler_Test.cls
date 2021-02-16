/*------------------------------------------------------------------------+
ORIGINAL SHIFT CONFIDENTIAL
__________________
Copyright (C) 2019 Original Shift, Inc.
All Rights Reserved.
NOTICE: All information contained herein is, and remains the
property of Original Shift Inc.The intellectual and technical
concepts contained herein are proprietary to Original Shift, Inc.
and may be covered by U.S. and Foreign Patents, patents in process,
and are protected by trade secret or copyright law.

Original Shift(developer@originalshift.com)
Purpose: Tests the CPQ Contract Trigger & its handler
 
Details: - Tests Performs record type transition for the quote record for New-->Draft-->Submitted
		 - Tests Twin maps from the Quote to Opp on Insert/Update as appropriate
 
History:
Feb 08/19 - Original Shift - Initial Implementation
------------------------------------------------------------------------+*/
@isTest
public class OSCPQ_ContractTriggerHandler_Test {
    @testSetup
    static void setup(){
        Account acct = OSCPQ_TestFactory.createSingleAccount(true);
        List<Contract> contList = new List<Contract>();
        contList.add(OSCPQ_TestFactory.createSingleContract(acct, false));
        contList[0].SBQQ__RenewalForecast__c = true;
        contList[0].SBQQ__RenewalQuoted__c = true;
        contList.add(OSCPQ_TestFactory.createSingleContract(acct, false));
        contList[1].SBQQ__RenewalForecast__c = true;
        contList[1].SBQQ__RenewalQuoted__c = true;
        
        SBQQ.TriggerControl.disable();
        insert contList;
        SBQQ.TriggerControl.enable();
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(OSCPQ_TestFactory.createSingleOpp(acct, false));
        oppList[0].SBQQ__RenewedContract__c = contList[0].Id;
        oppList[0].Name = 'Child Opp';
        oppList.add(OSCPQ_TestFactory.createSingleOpp(acct, false));
        oppList[1].SBQQ__RenewedContract__c = contList[1].Id;
        oppList[1].Name = 'Master Opp';
        insert oppList;

        contList[0].SBQQ__RenewalOpportunity__c = oppList[0].Id;
        contList[1].SBQQ__RenewalOpportunity__c = oppList[1].Id;
        update contList;

        //Add quote to the Opp
        SBQQ__Quote__c q = OSCPQ_TestFactory.createSingleQuote(acct, oppList[0], true, true);
        
        //Add Products and Opp Products to the Opp
        Product2 prod = OSCPQ_TestFactory.createBasicRenewableProduct(1, true);
        List<PricebookEntry> pbeList = OSCPQ_TestFactory.createPBEntries(new List<Product2>{prod}, true);
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppList[0].Id,
                                                          PricebookEntryId = pbeList[0].Id,
                                                          Quantity = 1,
                                                          TotalPrice = 100
                                                          );
        insert oli;
        
    }
    
    @isTest static void testDeforecastOnlyProcess_sync(){
        //Setup baseline variables / retrieve data
        Contract nonMasterContract;
        List<Opportunity> oppList = [Select Id, Name, SBQQ__RenewedContract__c FROM Opportunity WHERE Name IN ('Child Opp', 'Master Opp')];
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
       
        Id childOppId;
        Id masterOppId;
        
        //Identify master & child opp, and retrieve Opp Lines and Quote for the child
        for(Opportunity o : oppList){
            if(o.Name == 'Child Opp'){
                childOppId = o.Id;
                oliList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :o.Id];
                quoteList = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :o.Id];
                system.assertEquals(1, oliList.size(), 'Expecting baseline of 1 product on the child Opp before co-terming simulation');
                system.assertEquals(1, quoteList.size(), 'Expecting baseline of 1 Quote on the child Opp before co-terming simulation');
                if(quoteList.size() > 1){
                    system.assert(quoteList[0].SBQQ__Primary__c == true, 'Expecting the quote on the child opp to be primary before co-terming simulation');
                }
            }
            else if(o.Name == 'Master Opp'){
                masterOppId = o.Id;
            }
        }
        
        
        //Modfiy & Inject custom settings for test
        CPQ_Setting__mdt testSettings = OSCPQ_Utils.getContractSettings('Default');
        testSettings.RenewCoTerm_DeforecastOrphans__c = 'Deforecast';
        testSettings.RenewalCoTerm_DeforecastAsync__c = false;
        
        OSCPQ_ContractTriggerHandler handler = new OSCPQ_ContractTriggerHandler('Default');
        handler.settings = testSettings;
        
        //Run the test by simulating the CPQ process (note: we are NOT running the actual trigger in this test, and are testing the methods directly due to the custom metadata)
        Test.startTest();
        nonMasterContract = [Select Id, SBQQ__RenewalOpportunity__c, RecordTypeId FROM Contract WHERE SBQQ__RenewalOpportunity__c = :childOppId LIMIT 1];
        Map<Id, Contract> oldContractValueMap = new Map<Id, Contract>();
        oldContractValueMap.put(nonMasterContract.Id, nonMasterContract.clone());
        nonMasterContract.SBQQ__RenewalOpportunity__c = masterOppId;
        handler.deforecastOrphanedOpps(new List<Contract>{nonMasterContract}, oldContractValueMap);
        
        Test.stopTest();
        
        //Validate that the master Opp now has no products and a de-primaries quote
        oppList = [SELECT Id FROM Opportunity WHERE Id = :childOppId];
        oliList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :childOppId];
        quoteList = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :childOppId];
        
        system.assertEquals(1, oppList.size(), 'Opp was fully deleted rather than just de-forecast');
        system.assertEquals(0, oliList.size(), 'Opp Products were not correctly de-forecast');
        system.assertEquals(1, quoteList.size(), 'Quote was fully deleted when it should only have been deforecast');
        system.assert(quoteList[0].SBQQ__Primary__c == false, 'Quote was not de-primaried');
    }
    
    @isTest static void testDeforecastOnlyProcess_async(){
        //Setup baseline variables / retrieve data
        Contract nonMasterContract;
        List<Opportunity> oppList = [Select Id, Name, SBQQ__RenewedContract__c FROM Opportunity WHERE Name IN ('Child Opp', 'Master Opp')];
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
       
        Id childOppId;
        Id masterOppId;
        
        //Identify master & child opp, and retrieve Opp Lines and Quote for the child
        for(Opportunity o : oppList){
            if(o.Name == 'Child Opp'){
                childOppId = o.Id;
                oliList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :o.Id];
                quoteList = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :o.Id];
                system.assertEquals(1, oliList.size(), 'Expecting baseline of 1 product on the child Opp before co-terming simulation');
                system.assertEquals(1, quoteList.size(), 'Expecting baseline of 1 Quote on the child Opp before co-terming simulation');
                if(quoteList.size() > 1){
                    system.assert(quoteList[0].SBQQ__Primary__c == true, 'Expecting the quote on the child opp to be primary before co-terming simulation');
                }
            }
            else if(o.Name == 'Master Opp'){
                masterOppId = o.Id;
            }
        }
        
        
        //Modfiy & Inject custom settings for test
        CPQ_Setting__mdt testSettings = OSCPQ_Utils.getContractSettings('Default');
        testSettings.RenewCoTerm_DeforecastOrphans__c = 'Deforecast';
        testSettings.RenewalCoTerm_DeforecastAsync__c = true;
        
        OSCPQ_ContractTriggerHandler handler = new OSCPQ_ContractTriggerHandler('Default');
        handler.settings = testSettings;
        
        //Run the test by simulating the CPQ process (note: we are NOT running the actual trigger in this test, and are testing the methods directly due to the custom metadata)
        Test.startTest();
        nonMasterContract = [Select Id, SBQQ__RenewalOpportunity__c, RecordTypeId FROM Contract WHERE SBQQ__RenewalOpportunity__c = :childOppId LIMIT 1];
        Map<Id, Contract> oldContractValueMap = new Map<Id, Contract>();
        oldContractValueMap.put(nonMasterContract.Id, nonMasterContract.clone());
        nonMasterContract.SBQQ__RenewalOpportunity__c = masterOppId;
        handler.deforecastOrphanedOpps(new List<Contract>{nonMasterContract}, oldContractValueMap);
        
        Test.stopTest();
        
        //Validate that the master Opp now has no products and a de-primaries quote
        oppList = [SELECT Id FROM Opportunity WHERE Id = :childOppId];
        oliList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :childOppId];
        quoteList = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :childOppId];
        
        system.assertEquals(1, oppList.size(), 'Opp was fully deleted rather than just de-forecast');
        system.assertEquals(0, oliList.size(), 'Opp Products were not correctly de-forecast');
        system.assertEquals(1, quoteList.size(), 'Quote was fully deleted when it should only have been deforecast');
        system.assert(quoteList[0].SBQQ__Primary__c == false, 'Quote was not de-primaried');
    }
    
    @isTest static void testDeforecastAndDelete_sync(){
        //Setup baseline variables / retrieve data
        Contract nonMasterContract;
        List<Opportunity> oppList = [Select Id, Name, SBQQ__RenewedContract__c FROM Opportunity WHERE Name IN ('Child Opp', 'Master Opp')];
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
       
        Id childOppId;
        Id masterOppId;
        
        //Identify master & child opp, and retrieve Opp Lines and Quote for the child
        for(Opportunity o : oppList){
            if(o.Name == 'Child Opp'){
                childOppId = o.Id;
                oliList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :o.Id];
                quoteList = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :o.Id];
                system.assertEquals(1, oliList.size(), 'Expecting baseline of 1 product on the child Opp before co-terming simulation');
                system.assertEquals(1, quoteList.size(), 'Expecting baseline of 1 Quote on the child Opp before co-terming simulation');
                if(quoteList.size() > 1){
                    system.assert(quoteList[0].SBQQ__Primary__c == true, 'Expecting the quote on the child opp to be primary before co-terming simulation');
                }
            }
            else if(o.Name == 'Master Opp'){
                masterOppId = o.Id;
            }
        }
        
        
        //Modfiy & Inject custom settings for test
        CPQ_Setting__mdt testSettings = OSCPQ_Utils.getContractSettings('Default');
        testSettings.RenewCoTerm_DeforecastOrphans__c = 'DeforecastAndDelete';
        testSettings.RenewalCoTerm_DeforecastAsync__c = false;
        
        OSCPQ_ContractTriggerHandler handler = new OSCPQ_ContractTriggerHandler('Default');
        handler.settings = testSettings;
        
        //Run the test by simulating the CPQ process (note: we are NOT running the actual trigger in this test, and are testing the methods directly due to the custom metadata)
        Test.startTest();
        nonMasterContract = [Select Id, SBQQ__RenewalOpportunity__c, RecordTypeId FROM Contract WHERE SBQQ__RenewalOpportunity__c = :childOppId LIMIT 1];
        Map<Id, Contract> oldContractValueMap = new Map<Id, Contract>();
        oldContractValueMap.put(nonMasterContract.Id, nonMasterContract.clone());
        nonMasterContract.SBQQ__RenewalOpportunity__c = masterOppId;
        handler.deforecastOrphanedOpps(new List<Contract>{nonMasterContract}, oldContractValueMap);
        
        Test.stopTest();
        
        //Validate that the master Opp now has no products and a de-primaries quote
        oppList = [SELECT Id FROM Opportunity WHERE Id = :childOppId];
        quoteList = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :childOppId];
        
        system.assertEquals(0, oppList.size(), 'Opp was not fully deleted');
        system.assertEquals(0, quoteList.size(), 'Quote was not fully deleted');
    }
    
    @isTest static void testNoDeforecast(){
        //Setup baseline variables / retrieve data
        Contract nonMasterContract;
        List<Opportunity> oppList = [Select Id, Name, SBQQ__RenewedContract__c FROM Opportunity WHERE Name IN ('Child Opp', 'Master Opp')];
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
       
        Id childOppId;
        Id masterOppId;
        
        //Identify master & child opp, and retrieve Opp Lines and Quote for the child
        for(Opportunity o : oppList){
            if(o.Name == 'Child Opp'){
                childOppId = o.Id;
                oliList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :o.Id];
                quoteList = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :o.Id];
                system.assertEquals(1, oliList.size(), 'Expecting baseline of 1 product on the child Opp before co-terming simulation');
                system.assertEquals(1, quoteList.size(), 'Expecting baseline of 1 Quote on the child Opp before co-terming simulation');
                if(quoteList.size() > 1){
                    system.assert(quoteList[0].SBQQ__Primary__c == true, 'Expecting the quote on the child opp to be primary before co-terming simulation');
                }
            }
            else if(o.Name == 'Master Opp'){
                masterOppId = o.Id;
            }
        }
        
        
        //Modfiy & Inject custom settings for test
        CPQ_Setting__mdt testSettings = OSCPQ_Utils.getContractSettings('Default');
        testSettings.RenewCoTerm_DeforecastOrphans__c = 'No';
        testSettings.RenewalCoTerm_DeforecastAsync__c = false;
        
        OSCPQ_ContractTriggerHandler handler = new OSCPQ_ContractTriggerHandler('Default');
        handler.settings = testSettings;

        //Run the test by simulating the CPQ process (note: we are NOT running the actual trigger in this test, and are testing the methods directly due to the custom metadata)
        Test.startTest();
        nonMasterContract = [Select Id, SBQQ__RenewalOpportunity__c, RecordTypeId FROM Contract WHERE SBQQ__RenewalOpportunity__c = :childOppId LIMIT 1];
        Map<Id, Contract> oldContractValueMap = new Map<Id, Contract>();
        oldContractValueMap.put(nonMasterContract.Id, nonMasterContract.clone());
        nonMasterContract.SBQQ__RenewalOpportunity__c = masterOppId;

        handler.deforecastOrphanedOpps(new List<Contract>{nonMasterContract}, oldContractValueMap);

        Test.stopTest();
        
        //Validate that the master Opp now has no products and a de-primaries quote
        oppList = [SELECT Id FROM Opportunity WHERE Id = :childOppId];
        quoteList = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :childOppId];
        oliList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :childOppId];
        
        system.assertEquals(1, oppList.size(), 'Opp was deleted when it should not have been');
        system.assertEquals(1, quoteList.size(), 'Quote was deleted when it should not have been');
        system.assertEquals(1, oliList.size(), 'Opp Products were deleted when they should not have been');
    }
    
    @isTest static void testTrigger(){
        //Setup baseline variables / retrieve data
        Contract nonMasterContract;
        List<Opportunity> oppList = [Select Id, Name, SBQQ__RenewedContract__c FROM Opportunity WHERE Name IN ('Child Opp', 'Master Opp')];
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
       
        Id childOppId;
        Id masterOppId;
        
        //Identify master & child opp, and retrieve Opp Lines and Quote for the child
        for(Opportunity o : oppList){
            if(o.Name == 'Child Opp'){
                childOppId = o.Id;
                oliList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :o.Id];
                quoteList = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :o.Id];
                system.assertEquals(1, oliList.size(), 'Expecting baseline of 1 product on the child Opp before co-terming simulation');
                system.assertEquals(1, quoteList.size(), 'Expecting baseline of 1 Quote on the child Opp before co-terming simulation');
                if(quoteList.size() > 1){
                    system.assert(quoteList[0].SBQQ__Primary__c == true, 'Expecting the quote on the child opp to be primary before co-terming simulation');
                }
            }
            else if(o.Name == 'Master Opp'){
                masterOppId = o.Id;
            }
        }
        
        
        //Run the test by simulating the CPQ Process by updating the non-master contract to point to the master renewal opp
        Test.startTest();
        nonMasterContract = [Select Id, SBQQ__RenewalOpportunity__c, RecordTypeId FROM Contract WHERE SBQQ__RenewalOpportunity__c = :childOppId LIMIT 1];
        nonMasterContract.SBQQ__RenewalOpportunity__c = masterOppId;
        update nonMasterContract;
        Test.stopTest();
    }
    
    @isTest static void testTwinMapFromQuote() {
        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity opp = OSCPQ_TestFactory.createSingleOpp(acct, false);
        opp.Name = 'ThisTestOpp';
        insert opp;
        SBQQ__Quote__c quote = OSCPQ_TestFactory.createSingleQuote(acct, opp, true, false);
        quote.SBQQ__RenewalTerm__c = 36;
        insert quote;
        Order ord = OSCPQ_TestFactory.createSingleOrder(acct, opp, quote, true);
        
        Contract contract = OSCPQ_TestFactory.createSingleContract(acct, false);
        contract.SBQQ__Quote__c = quote.Id;
        contract.SBQQ__Opportunity__c = opp.Id;
        contract.SBQQ__Order__c = ord.Id;
        
        List<Contract> contractList = new List<Contract>{contract};
        
        OSCPQ_ContractTriggerHandler handler = new OSCPQ_ContractTriggerHandler('Default');
        handler.settings.TwinMapping_MapToContract__c = 'FROM_QUOTE';
        
        Test.startTest();
        handler.onBeforeInsert(contractList);
        system.assert(contractList[0].SBQQ__RenewalTerm__c == 36);
        handler.settings.TwinMapping_MapToContract__c = 'FROM_OPP';
        handler.onBeforeInsert(contractList);
        handler.settings.TwinMapping_MapToContract__c = 'FROM_ORDER';
        handler.onBeforeInsert(contractList);
        Test.stopTest();
    }
    
    @isTest static void testPopulateOnNewOpp() {    
        //Setup baseline variables / retrieve data
        Contract nonMasterContract;
        List<Opportunity> oppList = [Select Id, Name, SBQQ__RenewedContract__c FROM Opportunity WHERE Name IN ('Child Opp', 'Master Opp')];
       
        Id childOppId;
        Id masterOppId;
        
        //Identify master & child opp, and retrieve Opp Lines and Quote for the child
        for(Opportunity o : oppList){
            if(o.Name == 'Child Opp'){
                childOppId = o.Id;
            }
            else if(o.Name == 'Master Opp'){
                masterOppId = o.Id;
            }
        }   
        
        Account acct = (Account)SmartFactory.createSObject('Account');
        insert acct;    
        
        Custom_Partner__c custPart = (Custom_Partner__c)SmartFactory.createSObject('Custom_Partner__c');
        custPart.OpportunityId__c = childOppId;
        custPart.AccountToId__c = acct.Id;
        custPart.Role__c = 'Value Added Reseller';
        insert custPart;
        
        Contract masterContract = [Select Id, SBQQ__RenewalOpportunity__c, RecordTypeId FROM Contract WHERE SBQQ__RenewalOpportunity__c = :masterOppId LIMIT 1];
        masterContract.SBQQ__Opportunity__c = childOppId;
        
        Test.startTest();
        update masterContract;
        Test.stopTest();
    }
}