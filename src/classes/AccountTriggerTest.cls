/*
 * Class Name - AccountTriggerTest
 * 
 * %W% %E% Grazitti Team
 * This is the test class for "AccountTrigger" trigger and "AccountHandler" 
 * class.
 */

/**
 * This class contains different methods to check the code coverage.
 * 
 * @author Hemendra Singh Rajawat
 * @version 1.0 July 31, 2018
 */

@isTest
public class AccountTriggerTest {

    /**
     * Test when a new account record is created.
     */
    @isTest
    public static void testScenario1() {
        Account acc = OrgWideTestUtil.createAccount(false);
		
        //Date 9-10 Sergio Flores
        //Updating code coverage by making territory metadata fields dynamic to User object
        //Grab the metadata fields here
        Territory_Mapping__mdt[] territoryMappingMetaData = [SELECT DeveloperName, MasterLabel, NamespacePrefix, Account_Field__c, Lead_Field__c, User_Field__c 
                                                             From Territory_Mapping__mdt];

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
		//Sales Region = Sales group, sales geo = Sales Region in terms of API Name
        User u = new User(Alias = 'test123', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test123test@grazitti.com');
		
        //Check to see the developername and assign the field to correct variable
        for(Territory_Mapping__mdt territoryMapping : territoryMappingMetaData)
        {
            if(territoryMapping.DeveloperName == 'Sales_Team')
                u.put(territoryMapping.User_Field__c, 'ANZ');
            if(territoryMapping.DeveloperName == 'Sales_Region')
                u.put(territoryMapping.User_Field__c, 'APAC');
            if(territoryMapping.DeveloperName == 'Sales_Territory')
                u.put(territoryMapping.User_Field__c, '00');
            if(territoryMapping.DeveloperName == 'Sales_Group')
                u.put(territoryMapping.User_Field__c, 'NA Enterprise Select');
        }
        
        insert u;

        System.runAs(u) {
            insert acc;
        }
    }

     /**
     * Test when an account record is updated.
     */
    @isTest
    public static void testScenario2() {
        Account acc = OrgWideTestUtil.createAccount(false);
		
        //Date 9-10 Sergio Flores
        //Updating code coverage by making territory metadata fields dynamic to User object
        //Grab the metadata fields here
        Territory_Mapping__mdt[] territoryMappingMetaData = [SELECT DeveloperName, MasterLabel, NamespacePrefix, Account_Field__c, Lead_Field__c, User_Field__c 
                                                             From Territory_Mapping__mdt];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        User u = new User(Alias = 'test123', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test123test@grazitti.com');
		
        //Check to see the developername and assign the field to correct variable
        for(Territory_Mapping__mdt territoryMapping : territoryMappingMetaData)
        {
            if(territoryMapping.DeveloperName == 'Sales_Team')
                u.put(territoryMapping.User_Field__c, 'ANZ');
            if(territoryMapping.DeveloperName == 'Sales_Region')
                u.put(territoryMapping.User_Field__c, 'APAC');
            if(territoryMapping.DeveloperName == 'Sales_Territory')
                u.put(territoryMapping.User_Field__c, '00'); 
            if(territoryMapping.DeveloperName == 'Sales_Group')
                u.put(territoryMapping.User_Field__c, 'NA Enterprise Select');
        }
        
        insert u;

         User u1 = new User(Alias = 'test124', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test124test@grazitti.com');
		
        //Check to see the developername and assign the field to correct variable
        for(Territory_Mapping__mdt territoryMapping : territoryMappingMetaData)
        {
            if(territoryMapping.DeveloperName == 'Sales_Team')
                u1.put(territoryMapping.User_Field__c, 'ANZ');
            if(territoryMapping.DeveloperName == 'Sales_Region')
                u1.put(territoryMapping.User_Field__c, 'APAC');
            if(territoryMapping.DeveloperName == 'Sales_Territory')
                u1.put(territoryMapping.User_Field__c, '00');
            if(territoryMapping.DeveloperName == 'Sales_Group')
                u1.put(territoryMapping.User_Field__c, 'NA Enterprise Select');
        }
        
        insert u1;

        System.runAs(u) {
            insert acc;
            acc.OwnerId = u1.Id;
            update acc;
        }
    }

    @testSetup static void setup(){
        //Insert Partner Tier Records
        List<Partner_Tier__c> partnerTierCSList = new List<Partner_Tier__c>();

        Partner_Tier__c associate = new Partner_Tier__c();
        associate.Name = 'Associate';
        associate.Current_Referral_Discount__c = '10%';
        associate.Current_Renewal_Discount__c = '10%';
        associate.Current_Reseller_Discount__c = '20%';
        associate.Referral_Discount_Cap__c = 10000.00;

        Partner_Tier__c preferred = new Partner_Tier__c();
        preferred.Name = 'Preferred';
        preferred.Current_Referral_Discount__c = '12.5%';
        preferred.Current_Renewal_Discount__c = '15%';
        preferred.Current_Reseller_Discount__c = '30%';
        preferred.Referral_Discount_Cap__c = 12500.00;
        
        Partner_Tier__c premier = new Partner_Tier__c();
        premier.Name = 'Premier';
        premier.Current_Referral_Discount__c = '15%';
        premier.Current_Renewal_Discount__c = '20%';
        premier.Current_Reseller_Discount__c = '40%';
        premier.Referral_Discount_Cap__c = 15000.00;

        Partner_Tier__c referral = new Partner_Tier__c();
        referral.Name = 'Referral';
        referral.Current_Referral_Discount__c = '10%';
        referral.Current_Renewal_Discount__c = '0%';
        referral.Current_Reseller_Discount__c = '0%';
        referral.Referral_Discount_Cap__c = 10000.00;

        partnerTierCSList.add(associate);
        partnerTierCSList.add(preferred);
        partnerTierCSList.add(premier);
        partnerTierCSList.add(referral);
        insert partnerTierCSList;

    }

    //Author: Sergio Flores
    //Date: 10/31/2018
    //W-010384 Test
    static testMethod void testAccountPartnerTierInsert()
    {

        test.startTest();

        Account acc = OrgWideTestUtil.createAccount(false);
        acc.Partner_Type__c = 'Master Reseller';
        acc.Partner_Tier__c = 'Premier';

        insert acc;

        Account acc1 = [Select Partner_Tier__c, Resale_Discount__c, Referral_Discount__c, Referral_Discount_Cap__c, Renewal_Margin__c From Account Where Id =: acc.Id]; 

        Partner_Tier__c ptCustomSetting = Partner_Tier__c.getValues(acc1.Partner_Tier__c);
                system.debug('Partner Tier Custom Setting ' + ptCustomSetting);
                system.assertEquals(acc1.Resale_Discount__c, ptCustomSetting.Current_Reseller_Discount__c);
                system.assertEquals(acc1.Referral_Discount__c, ptCustomSetting.Current_Referral_Discount__c);
                system.assertEquals(acc1.Referral_Discount_Cap__c, ptCustomSetting.Referral_Discount_Cap__c);
                system.assertEquals(acc1.Renewal_Margin__c, ptCustomSetting.Current_Renewal_Discount__c);

        test.stopTest();
                
    }

    //Author: Sergio Flores
    //Date: 10/31/2018
    //W-010384 Test
    static testMethod void testAccountPartnerTierUpdate()
    {
        Account acc = OrgWideTestUtil.createAccount(false);
        acc.Partner_Type__c = 'Master Reseller';
        acc.Partner_Tier__c = 'Associate';

        insert acc;

        test.startTest();

        Account acc1 = [Select Partner_Tier__c, Resale_Discount__c, Referral_Discount__c, Referral_Discount_Cap__c, Renewal_Margin__c From Account Where Id =: acc.Id];

        acc1.Partner_Tier__c = 'Premier';
        update acc1;

        Account updatedAccount = [Select Partner_Tier__c, Resale_Discount__c, Referral_Discount__c, Referral_Discount_Cap__c, Renewal_Margin__c From Account Where Id =: acc1.Id];

        Partner_Tier__c ptCustomSetting = Partner_Tier__c.getValues(updatedAccount.Partner_Tier__c);
                system.debug('Partner Tier Custom Setting ' + ptCustomSetting);
                system.assertEquals(updatedAccount.Resale_Discount__c, ptCustomSetting.Current_Reseller_Discount__c);
                system.assertEquals(updatedAccount.Referral_Discount__c, ptCustomSetting.Current_Referral_Discount__c);
                system.assertEquals(updatedAccount.Referral_Discount_Cap__c, ptCustomSetting.Referral_Discount_Cap__c);
                system.assertEquals(updatedAccount.Renewal_Margin__c, ptCustomSetting.Current_Renewal_Discount__c);


        test.stopTest();

    }

    //Author: Sergio Flores
    //Date: 10/24/2018
    //W-010475
    static testMethod void testOpportunityReferralFeeUpdate()
    {
        Account acc = OrgWideTestUtil.createPartnerAccount(true);
        
        Opportunity opp = OrgWideTestUtil.createOpportunity(false, acc.Id);
        opp.Partner_Account_Lookup__c = acc.Id;

        insert opp;

        

        //Now we have to update the account's Partner Tier so that the opportunity will update the Referral fee % 

        Account acc1 = [Select Id, Partner_Tier__c From Account Where Id =: acc.Id];

        acc1.Partner_Tier__c = 'Premier';

        update acc1;

        //Check that the opportunity refereal fee is the same to the parent account

        Opportunity opp1 = [Select Id, Referral_Discount__c, 	Partner_Account_Lookup__r.Referral_Discount__c 
                                              From Opportunity 
                                              Where isclosed = false AND Partner_Account_Lookup__c =: acc1.Id];
        
        String referral = opp1.Partner_Account_Lookup__r.Referral_Discount__c.removeEnd('%');
        Decimal accountReferralDiscount = Decimal.valueOf(referral);
        
        System.debug('Referral Discount ' + accountReferralDiscount);
        system.assertEquals(opp1.Referral_Discount__c, accountReferralDiscount); 

        
    }

    //Author: Sergio Flores
    //Date: 11/26/2018
    //W-010642
    static testMethod void testOpportunityReferralDiscountCapUpdate()
    {
        Account acc = OrgWideTestUtil.createPartnerAccount(false);
        acc.Partner_Tier__c = 'Premier';
        insert acc;

        acc.Referral_Discount__c = '20%';
        update acc;

        Account updatedAccount = [Select Partner_Tier__c, Resale_Discount__c, Referral_Discount__c, Referral_Discount_Cap__c, Renewal_Margin__c From Account Where Id =: acc.Id];

        List<Partner_Tier__c> ptCustomSetting = Partner_Tier__c.getall().values();

                for(Partner_Tier__c pc : ptCustomSetting)
                {
                    if(updatedAccount.Referral_Discount__c == pc.Current_Referral_Discount__c)
                    system.assertEquals(acc.Referral_Discount_Cap__c, pc.Referral_Discount_Cap__c);
                     
                }
        
    }
}