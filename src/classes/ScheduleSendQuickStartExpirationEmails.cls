global class ScheduleSendQuickStartExpirationEmails implements Schedulable {
   global void execute(SchedulableContext sc) {
      SendQuickStartExpirationEmails obj = new SendQuickStartExpirationEmails(); 
      database.executebatch(obj);
   }
}