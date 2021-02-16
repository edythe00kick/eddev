@isTest
public class Test_LeadAssignmentRuletrigger {

 public static testMethod void myUnitTest() {
       Test.startTest();
     
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',OwnerId = Label.MQLStagingQueueId_Original);
        Insert newLead;
        Test.stopTest();
 }
 
 public static testMethod void myUnitTest1() {
       Test.startTest();
     
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web');
        Insert newLead;
        
        Lead l = [select id,ownerid from lead where id =: newLead.id];
        system.debug('lead owner id ==>'+l.ownerid );
        l.ownerId = Label.MQLStagingQueueId_Original;
        UtilityClass.fireAssignmentRuletriggerOnce = false;
        update l;
        
       Test.stopTest();
 }
 
 public static testMethod void myUnitTest2() {
       Test.startTest();
     
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web', Country = 'Denmark');
        Insert newLead;
        
        newLead.Country = 'United States';
        update newLead;
        
        newLead.Country = 'Denmark';
        update newLead;
        
       Test.stopTest();
 }

}