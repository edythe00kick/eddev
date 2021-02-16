global class scheduleUpdateTeamMemberRolesNew implements Schedulable {

    public static void scheduleJobs(){
        System.schedule('Scheduled Job 1', '0 0 * * * ?', new scheduleUpdateTeamMemberRolesNew());
        System.schedule('Scheduled Job 5', '0 20 * * * ?', new scheduleUpdateTeamMemberRolesNew());
        System.schedule('Scheduled Job 9', '0 40 * * * ?', new scheduleUpdateTeamMemberRolesNew());
    }
    global void execute(SchedulableContext sc) {
      UpdateAccountWithTeamMemberRolesNew  a = new UpdateAccountWithTeamMemberRolesNew();
      ID batchprocessid = Database.executeBatch(a);
   }
}