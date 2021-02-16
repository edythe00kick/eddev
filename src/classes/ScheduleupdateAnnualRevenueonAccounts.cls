global class ScheduleupdateAnnualRevenueonAccounts implements Schedulable {
   global void execute(SchedulableContext sc) {
      updateAnnualRevenueonAccounts obj = new updateAnnualRevenueonAccounts(); 
      database.executebatch(obj,50);
   }
}