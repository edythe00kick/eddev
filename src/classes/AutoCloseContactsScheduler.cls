global class AutoCloseContactsScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC){
        AutoCloseContacts acc = new AutoCloseContacts();
        database.executeBatch(acc, 200);
    }

}