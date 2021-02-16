trigger UpdateDueDate on Task (before insert) {

    for(Task myTask : trigger.new) 

       if (myTask.ActivityDate == null)

           if ((myTask.Subject.startswith('Inbound call from')) || (myTask.Subject.startswith('Outbound call to')))

               myTask.ActivityDate = System.today();
}