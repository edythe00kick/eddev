/*
Test Class for Lithium Search Controller
Developed By:- Grazitti Interactive
*/
@isTest
public class LithiumSearchControllerTest{
    
    public LithiumSearchControllerTest(){}
    
    public static testMethod void lithiumTest(){        //Test Method for Salesforce case and lithium platform's response
        Case caserecord = new case(Subject='Test this Code',Description='This Description',Products__c ='Data',Business_System_Category__c='Feature Enhancement',Business_System__c='SFDC',Requested_Completion_Date__c=Date.today().AddDays(7),Case_Category__c='SDK',Severity__c='SEV 1');
        insert caserecord;
        Lithium_Search_Configuration__c searchConfiguration = new Lithium_Search_Configuration__c();
        searchConfiguration.Lithium_Endpoint_URL__c='https://community.alteryx.com';
        searchConfiguration.Lithium_Search_Results_Per_Page__c=5;
        insert searchConfiguration;
        Pagereference pref= page.Lithium_search_console;
        Test.setcurrentPage(pref);
        pref.getParameters().put('searchText', 'test');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caserecord);
        Lithium_search_controller lsc = new Lithium_search_controller(sc);
        pref.getParameters().put('searchText', 'test');
        lsc.next();
        lsc.gotoPrevious();
        lsc.gotoNext();
        lsc.previous();
        lsc.channelType = 'DayAgo';
        lsc.getResult();
        lsc.sf_cases();
        lsc.channelType = 'YearAgo';
        lsc.searchKnowledgeRecords();
        lsc.channelType = 'WeekAgo';
        lsc.searchKnowledgeRecords();
        lsc.channelType = 'MonthAgo';
        lsc.Forums=true;
        lsc.Blogs=true;
        lsc.Ideas=true;
        lsc.KnowledgeBase=true;
        lsc.Groups=true;
        lsc.Contests=true;
        lsc.searchKnowledgeRecords();             
    }
    public static testmethod void testauthClass(){           //Test Method for lithium authentication class
        Lithium_Search_Configuration__c searchConfiguration = new Lithium_Search_Configuration__c();
        searchConfiguration.Lithium_Endpoint_URL__c='https://communitystage.alteryx.com';
        searchConfiguration.Lithium_Search_Username__c='mudit_garg';
        searchConfiguration.Lithium_Search_Password__c='mudit@123';
        searchConfiguration.Lithium_Search_Results_Per_Page__c=5;
        insert searchConfiguration;
        Lithium_authentication authLithium = new Lithium_authentication();
        authLithium.authenticate();
    }
}