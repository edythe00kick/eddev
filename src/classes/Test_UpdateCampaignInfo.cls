@isTest//(seealldata=true)
public class Test_UpdateCampaignInfo{
    static testmethod void UpdateCampaignInformation(){
        Test.startTest();
            Campaign cam= new Campaign (Name='TestCam',Program_Name__c='TestC',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5,Region__c = 'Global',Fiscal_Year__c='2016',Quarter__c='Q3',Campaign_Tactic__c='Email Web',Campaign_Offer__c ='Live Webinar',recordtypeid = Campaign.sObjectType.getDescribe().getRecordTypeInfosByName().get('Field Marketing Campaign Record Type').getRecordTypeId());
            insert cam;
            cam.Fiscal_Year__c='2015';
            update cam;
            /*CampaignHandler ah = new CampaignHandler();
            ah.bulkBefore();
            ah.bulkAfter();
            Sobject s =(Sobject)cam;
            ah.beforeInsert(s);
            ah.beforeUpdate(s,s); 
            ah.beforeDelete(s);
            ah.afterinsert(s);
            ah.afterupdate(s,s);
            ah.afterdelete(s);*/
        Test.stopTest();
    }
    static testmethod void UpdateCampaignInformation1(){
        Test.startTest();
            // wrote for covering a scenario in which the length of campaign name needs to be more than 80
            Campaign camp= new Campaign (Program_Name__c='TestC',Name='TestCamp',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5,Region__c = 'Global',Fiscal_Year__c='2016',Quarter__c='Q3',Campaign_Tactic__c='Email Web',Campaign_Offer__c ='Live Webinar',recordtypeid = Campaign.sObjectType.getDescribe().getRecordTypeInfosByName().get('Field Marketing Campaign Record Type').getRecordTypeId());
            insert camp;
        Test.stopTest();
    }
    static testmethod void UpdateCampaignInformation2(){
        Test.startTest();
            Campaign cam= new Campaign (Name='TestCam',Program_Name__c='TestC',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5,Region__c = 'Global',Fiscal_Year__c='2016',Quarter__c='Q3',Campaign_Tactic__c='Email Web',Campaign_Offer__c ='Live Webinar',recordtypeid = Campaign.sObjectType.getDescribe().getRecordTypeInfosByName().get('Field Marketing Campaign Record Type').getRecordTypeId());
            insert cam;
            cam.Region__c='AMS';
            update cam;
        Test.stopTest();    
    }
    static testmethod void UpdateCampaignInformation3(){
        Test.startTest();
            Campaign cam= new Campaign (Name='TestCam',Program_Name__c='TestC',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5,Region__c = 'Global',Fiscal_Year__c='2016',Quarter__c='Q3',Campaign_Tactic__c='Email Web',Campaign_Offer__c ='Live Webinar',recordtypeid = Campaign.sObjectType.getDescribe().getRecordTypeInfosByName().get('Field Marketing Campaign Record Type').getRecordTypeId());
            insert cam;
            cam.Quarter__c='Q4';
            update cam;
        Test.stopTest();    
    }
    static testmethod void UpdateCampaignInformation4(){
        Test.startTest();
            Campaign cam= new Campaign (Name='TestCam',Program_Name__c='TestC',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5,Region__c = 'Global',Fiscal_Year__c='2016',Quarter__c='Q3',Campaign_Tactic__c='Email Web',Campaign_Offer__c ='Live Webinar',recordtypeid = Campaign.sObjectType.getDescribe().getRecordTypeInfosByName().get('Field Marketing Campaign Record Type').getRecordTypeId());
            insert cam;
            cam.Campaign_Tactic__c='Web Direct';
            update cam;
        Test.stopTest();    
    }
    static testmethod void UpdateCampaignInformation5(){
        Test.startTest();
            Campaign cam= new Campaign (Name='TestCam',Program_Name__c='TestC',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5,Region__c = 'Global',Fiscal_Year__c='2016',Quarter__c='Q3',Campaign_Tactic__c='Email Web',Campaign_Offer__c ='Live Webinar',recordtypeid = Campaign.sObjectType.getDescribe().getRecordTypeInfosByName().get('Field Marketing Campaign Record Type').getRecordTypeId());
            insert cam;
            cam.Campaign_Offer__c='Case Study';
            update cam;
        Test.stopTest();    
    }
    static testmethod void UpdateCampaignInformation6(){
        Test.startTest();
            Campaign cam= new Campaign (Name='TestCam',Program_Name__c='TestC',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5,Region__c = 'Global',Fiscal_Year__c='2016',Quarter__c='Q3',Campaign_Tactic__c='Email Web',Campaign_Offer__c ='Live Webinar',recordtypeid = Campaign.sObjectType.getDescribe().getRecordTypeInfosByName().get('Field Marketing Campaign Record Type').getRecordTypeId());
            insert cam;
            cam.Program_Name__c='AMS';
            update cam;
        Test.stopTest();    
    }
    
    
    
}