global class ScheduleCreateECRTasksonAgreement implements Schedulable {
   global void execute(SchedulableContext sc) {
      CreateECRTasksonAgreement obj = new CreateECRTasksonAgreement(); 
      database.executebatch(obj);
   }
}