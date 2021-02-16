global class AutoCloseLeadsScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC){
        AutoCloseLeads acl = new AutoCloseLeads();
        database.executeBatch(acl, 50);
    }

}