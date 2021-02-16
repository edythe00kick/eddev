/*
* @name : Test_updateAnnualRevenueonAccounts : test code for the updateAnnualRevenueonAccounts.cls batch job
* @author : JP Horton
* @date : 20171103
* @modified : Cs 00182103 - JPH - 20171103 : Updated the Code coverage to 90%, removed seealldata = true
*/

@isTest
public class Test_updateAnnualRevenueonAccounts{

    public static testMethod void testupdateAnnualRevenueonAccounts() {
    
		Account a = TestUtils.getAccount('Test Account');
		a.dunsnumber = '11111111'; //shortened to 8 digits to capture the need for additional leading 0s
		a.Last_D_B_Information_Update_Date__c = system.today().addMonths(-4);
		insert a;
    
    	DandBcompany db1 = new DandBCompany(
    		DunsNumber = '011111111',
    		name = 'Test Account',
    		PriorYearRevenue = 100,
    		SalesTurnoverGrowthRate = 1,
    		SalesVolume = 400,
    		ParentOrHqBusinessName = 'Test Account Parent',
    		ParentOrHqDunsNumber = '222222222',
    		DomesticUltimateBusinessName = 'Domestic Name',
    		DomesticUltimateDunsNumber = '000000001',
    		GlobalUltimateBusinessName = 'Test Account Ultimate',
    		GlobalUltimateDunsNumber = '333333333');
    	DandBcompany db2 = new DandBCompany(
    		DunsNumber = '222222222',
    		name = 'Test Account Parent',
    		PriorYearRevenue = 1000,
    		SalesTurnoverGrowthRate = 1,
    		SalesVolume = 4000,
    		ParentOrHqBusinessName = 'Test Account Ultimate',
    		ParentOrHqDunsNumber = '333333333',
    		DomesticUltimateBusinessName = 'Domestic Name',
    		DomesticUltimateDunsNumber = '000000001',
    		GlobalUltimateBusinessName = 'Test Account Ultimate',
    		GlobalUltimateDunsNumber = '333333333');
    	DandBcompany db3 = new DandBCompany(
    		DunsNumber = '333333333',
    		name = 'Test Account Ultimate',
    		PriorYearRevenue = 10000,
    		SalesTurnoverGrowthRate = 1,
    		SalesVolume = 40000,
    		ParentOrHqBusinessName = 'Test Account Ultimate',
    		ParentOrHqDunsNumber = '333333333',
    		DomesticUltimateBusinessName = 'Domestic Name',
    		DomesticUltimateDunsNumber = '000000001',
    		GlobalUltimateBusinessName = 'Test Account Ultimate',
    		GlobalUltimateDunsNumber = '333333333');
    	DandBcompany db4 = new DandBCompany(
    		DunsNumber = '000000001',
    		name = 'Domestic Name',
    		PriorYearRevenue = 10000,
    		SalesTurnoverGrowthRate = 1,
    		SalesVolume = 40000,
    		ParentOrHqBusinessName = 'Test Account Ultimate',
    		ParentOrHqDunsNumber = '333333333',
    		DomesticUltimateBusinessName = 'Domestic Name',
    		DomesticUltimateDunsNumber = '000000001',
    		GlobalUltimateBusinessName = 'Domestic Name',
    		GlobalUltimateDunsNumber = '000000001');
    	insert db1;
    	insert db2;
    	insert db3;
    	insert db4;
       
       test.StartTest();
           updateAnnualRevenueonAccounts obj = new updateAnnualRevenueonAccounts();
           //obj.myAccountId = '\''+a.id+'\'';
           //obj.finalaccountmap.put(a.id,a);       
           Database.executeBatch(obj,50);
       test.StopTest(); 
       
           Account checkAcc1 = [SELECT Id, Global_Ultimate_Parent_Revenue__c, Secondary_Annual_Revenue__c, Parent_Annual_Revenue__c FROM Account WHERE Id =: a.Id];
           system.assertEquals(checkAcc1.Global_Ultimate_Parent_Revenue__c,20000);
           system.assertEquals(checkAcc1.Secondary_Annual_Revenue__c,null);
           system.assertEquals(checkAcc1.Parent_Annual_Revenue__c,2000);
     }
     
	public static testMethod void testupdateAnnualRevenueonAccounts2() {
    
		Account a1 = TestUtils.getAccount('Test Account');
		a1.dunsnumber = '111111111';
		a1.Last_D_B_Information_Update_Date__c = system.today().addMonths(-4);
		insert a1;
		Account a2 = TestUtils.getAccount('Test Account Parent');
		a2.dunsnumber = '222222222';
		a2.Last_D_B_Information_Update_Date__c = system.today().addMonths(-4);
		insert a2;
		Account a3 = TestUtils.getAccount('Test Account Ultimate');
		a3.dunsnumber = '333333333';
		a3.Last_D_B_Information_Update_Date__c = system.today().addMonths(-4);
		insert a3;
    
    	DandBcompany db1 = new DandBCompany(
    		DunsNumber = '111111111',
    		name = 'Test Account',
    		PriorYearRevenue = 100,
    		SalesTurnoverGrowthRate = 1,
    		SalesVolume = 400,
    		ParentOrHqBusinessName = 'Test Account Parent',
    		ParentOrHqDunsNumber = '222222222',
    		DomesticUltimateBusinessName = 'Domestic Name',
    		DomesticUltimateDunsNumber = '000000001',
    		GlobalUltimateBusinessName = 'Test Account Ultimate',
    		GlobalUltimateDunsNumber = '333333333');
    	DandBcompany db2 = new DandBCompany(
    		DunsNumber = '222222222',
    		name = 'Test Account Parent',
    		PriorYearRevenue = 1000,
    		SalesTurnoverGrowthRate = 1,
    		SalesVolume = 4000,
    		ParentOrHqBusinessName = 'Test Account Ultimate',
    		ParentOrHqDunsNumber = '333333333',
    	    DomesticUltimateBusinessName = '',
    		DomesticUltimateDunsNumber = '000000000',
    		GlobalUltimateBusinessName = 'Test Account Ultimate',
    		GlobalUltimateDunsNumber = '333333333');
    	DandBcompany db3 = new DandBCompany(
    		DunsNumber = '333333333',
    		name = 'Test Account Ultimate',
    		PriorYearRevenue = 10000,
    		SalesTurnoverGrowthRate = 1,
    		SalesVolume = 40000,
    		ParentOrHqBusinessName = '',
    		ParentOrHqDunsNumber = '000000000',
    		DomesticUltimateBusinessName = 'Domestic Name',
    		DomesticUltimateDunsNumber = '000000001',
    		GlobalUltimateBusinessName = 'Test Account Ultimate',
    		GlobalUltimateDunsNumber = '000000000');
    	 DandBcompany db4 = new DandBCompany(
    		DunsNumber = '000000001',
    		name = 'Domestic Name',
    		PriorYearRevenue = 100000,
    		SalesTurnoverGrowthRate = 1,
    		SalesVolume = 400000,
    		ParentOrHqBusinessName = '',
    		ParentOrHqDunsNumber = '000000000',
    		DomesticUltimateBusinessName = 'Domestic Name',
    		DomesticUltimateDunsNumber = '000000001',
    		GlobalUltimateBusinessName = 'Test Account Ultimate',
    		GlobalUltimateDunsNumber = '333333333');
    	insert db1;
    	insert db2;
    	insert db3;
    	insert db4;
       
       test.StartTest();
           updateAnnualRevenueonAccounts obj = new updateAnnualRevenueonAccounts();
           //obj.myAccountId = '\''+a1.id+'\',\''+a3.Id+'\',\''+a2.Id+'\'';
           //obj.finalaccountmap.put(a1.id,a1);
           Database.executeBatch(obj,50);
       test.StopTest();
       
           Account checkAcc1 = [SELECT Id, Global_Ultimate_Parent_Revenue__c, Secondary_Annual_Revenue__c, Parent_Annual_Revenue__c FROM Account WHERE Id =: a1.Id];
           system.assertEquals(checkAcc1.Global_Ultimate_Parent_Revenue__c,20000);
           system.assertEquals(checkAcc1.Parent_Annual_Revenue__c,2000);
           
           Account checkAcc2 = [SELECT Id, Global_Ultimate_Parent_Revenue__c, Secondary_Annual_Revenue__c, Parent_Annual_Revenue__c FROM Account WHERE Id =: a2.Id];
           system.assertEquals(checkAcc2.Global_Ultimate_Parent_Revenue__c,20000);
           system.assertEquals(checkAcc2.Parent_Annual_Revenue__c,20000);
           
           Account checkAcc3 = [SELECT Id, Global_Ultimate_Parent_Revenue__c, Secondary_Annual_Revenue__c, Parent_Annual_Revenue__c FROM Account WHERE Id =: a3.Id];
           system.assertEquals(checkAcc3.Global_Ultimate_Parent_Revenue__c,20000);
           system.assertEquals(checkAcc3.Parent_Annual_Revenue__c,20000); 
     }
     
}