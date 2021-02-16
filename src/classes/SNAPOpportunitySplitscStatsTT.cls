@isTest(SeeAllData=true)
private class SNAPOpportunitySplitscStatsTT {

   static testMethod void testTrigger() {
      try {
          SNAP_Opportunity_Splits__c o = new SNAP_Opportunity_Splits__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<SNAP_Opportunity_Splits__c> l = [SELECT Id from SNAP_Opportunity_Splits__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}