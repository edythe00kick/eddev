@isTest
public class Test_SetNextTaskPlanDateTriggeronTask{
    static testmethod void checkTask(){
        List<Task> taskstobeupdated = new List<Task>();
        List<Task> taskstobedeleted = new List<Task>();
        List<Task> taskstobeinserted = new List<Task>();
    
        Lead newLead = new Lead(Company ='TestNewLead',LastName= 'Test',LeadSource = 'Web',Status = '1 - Not Contacted', CurrencyIsoCode = 'USD');
        insert newLead;
        Task tt = new Task( WhoId = newlead.id,Subject='email:',Status='Not Started',Priority='Normal',ActivityDate=date.today().adddays(2) );
        Task tt1 = new Task( WhoId = newlead.id,Subject='test',Status='Not Started',Priority='Normal',ActivityDate=date.today().adddays(1) );
        Task tt2 = new Task( WhoId = newlead.id,Subject='testcomplete',Status='completed',Priority='Normal',ActivityDate=date.today().adddays(1) );      

        Lead newLeadd1 = new Lead(Company ='TestNewLeadd',LastName= 'Testt',LeadSource = 'Web',Status = 'open', CurrencyIsoCode = 'USD');
        insert newLeadd1;
        Task tt8 = new Task( WhoId = newleadd1.id,Subject='testlead',Status='completed',Priority='Normal',ActivityDate=date.today().adddays(1) );
        Lead newLeadd2 = new Lead(Company ='TestNewLeadd',LastName= 'Testt',LeadSource = 'Web',Status = 'open', CurrencyIsoCode = 'USD');
        insert newLeadd2;
        Task tt9 = new Task( WhoId = newleadd2.id,Subject='testlead2',Status='completed',Priority='Normal',Task_Completion_Date__c=date.today().adddays(1),ActivityDate=date.today().adddays(1) );
        Task tt10 = new Task( WhoId = newleadd2.id,Subject='testlead2',Status='completed',Priority='Normal',Task_Completion_Date__c=date.today().adddays(3),ActivityDate=date.today().adddays(3) );
        
        Lead newLeadd = new Lead(Company ='TestNewLeadd',LastName= 'Testt',LeadSource = 'Web',Status = '1 - Not Contacted', CurrencyIsoCode = 'USD');
        insert newLeadd;
        Task tt3 = new Task( WhoId = newleadd.id,Subject='testlead',Status='Not Started',Priority='Normal',ActivityDate=date.today().adddays(1) ); 
 
        Account a = new Account(name='TestAccountt',phone='9876543201',CurrencyIsoCode='USD' );
        insert a;
        Contact c = new Contact(accountid=a.id,lastname='testcontact',email='test@gmail.com',CurrencyIsoCode='USD');
        insert c;
       // Opportunity o = new Opportunity(accountid=a.id,name='testopportunity',CurrencyIsoCode='USD',stagename='1 - Identification',closedate=system.today().adddays(2));
       // insert o;
        Task t = new Task(subject='email:',whoid=c.id,whatid=a.id,Status='In Progress',Priority='Normal',ActivityDate=system.today().adddays(2));
        //Task t1 = new Task(subject='test',whatid=o.id,Status='In Progress',Priority='Normal',ActivityDate=system.today().adddays(1));
        Task t5 = new Task(subject='test',whoid=c.id,whatid=a.id,Status='completed',Priority='Normal',ActivityDate=system.today());
        Task t15 = new Task(subject='test',whoid=c.id,whatid=a.id,Status='completed',Priority='Normal',Task_Completion_Date__c=date.today().adddays(3),ActivityDate=date.today().adddays(3));
        Task t16 = new Task(subject='test',whoid=c.id,whatid=a.id,Status='completed',Priority='Normal',Task_Completion_Date__c=date.today().adddays(4),ActivityDate=date.today().adddays(4));


        Account aa = new Account(name='TestAccountt',phone='9876543201',CurrencyIsoCode='USD' );
        insert aa;
        Task t3 = new Task(subject='email:',whatid=aa.id,Status='In Progress',Priority='Normal',ActivityDate=system.today().adddays(1));
        Contact ccc = new Contact(accountid=aa.id,lastname='testcontactt',email='test@gmail.com',CurrencyIsoCode='USD');
        insert ccc;
        Task t7 = new Task(subject='email:', whoid=ccc.id,whatid=aa.id,Status='In Progress',Priority='Normal',ActivityDate=system.today().adddays(1));
        


        Account acc = new Account(name='TestAccountt',phone='9876543201',CurrencyIsoCode='USD' );
        insert acc;
//        Opportunity op = new Opportunity(accountid=acc.id,name='testopportunitty',CurrencyIsoCode='USD',stagename='1 - Identification',closedate=system.today().adddays(2));
//        insert op; 
        Task t8 = new Task(subject='email:',Status='completed',Priority='Normal',ActivityDate=system.today().adddays(1));      
        Task t12 = new Task(subject='email:',Status='not started',Priority='Normal',ActivityDate=system.today().adddays(3));
        Task t13 = new Task(subject='test',Status='completed',Priority='Normal',Task_Completion_Date__c=date.today().adddays(3),ActivityDate=date.today().adddays(3));
        Task t14 = new Task(subject='test',Status='completed',Priority='Normal',Task_Completion_Date__c=date.today().adddays(4),ActivityDate=date.today().adddays(4));
        Task t4 = new Task(subject='email:',whoid=ccc.id,Status='In Progress',Priority='Normal',ActivityDate=system.today().adddays(1));
        
      /* Account b = new Account(name='TestAccountt',phone='9876543201',CurrencyIsoCode='USD' );
        insert b;
        Account d = new Account(name='TestAccountt',phone='9876543201',CurrencyIsoCode='USD' );
        insert d;
        Contact cc = new Contact(accountid=d.id,lastname='testcontact',email='test@gmail.com',CurrencyIsoCode='USD');
        insert cc;
        Opportunity oo = new Opportunity(accountid=b.id,name='testopportunity',CurrencyIsoCode='USD',stagename='1 - Identification',closedate=system.today().adddays(2));
        insert oo;
        Task t4 = new Task(subject='email:',whoid=cc.id,whatid=oo.id,Status='In Progress',Priority='Normal',ActivityDate=system.today().adddays(1));*/
       // Task t6 = new Task(subject='test',whoid=cc.id,whatid=oo.id,Status='completed',Priority='Normal',Task_Completion_Date__c=date.today().adddays(1),ActivityDate=date.today().adddays(1));
        
       test.startTest();
 
        taskstobeinserted.add(tt);
        taskstobeinserted.add(tt1);
        taskstobeinserted.add(tt2);
        taskstobeinserted.add(tt3);
        taskstobeinserted.add(tt8);
        taskstobeinserted.add(tt9);
        taskstobeinserted.add(tt10);
        taskstobeinserted.add(t);
        taskstobeinserted.add(t12);
        taskstobeinserted.add(t13);
        taskstobeinserted.add(t14);
        taskstobeinserted.add(t15);
        taskstobeinserted.add(t16);        
        
        //taskstobeinserted.add(t1);
        taskstobeinserted.add(t3);
       // taskstobeinserted.add(t6);
        taskstobeinserted.add(t5);
        taskstobeinserted.add(t4);
        taskstobeinserted.add(t7);
        taskstobeinserted.add(t8);
        insert taskstobeinserted;
        
        taskstobeupdated.add(tt);
        //taskstobeupdated.add(t1);
        taskstobeupdated.add(t3);
        taskstobeupdated.add(t4);
        update taskstobeupdated;
        
        taskstobedeleted.add(tt2); 
        taskstobedeleted.add(tt3);
        taskstobedeleted.add(t);
        //taskstobedeleted.add(t1);
        taskstobedeleted.add(t4);        
        taskstobedeleted.add(t3);
      //  taskstobedeleted.add(t6);
        taskstobedeleted.add(t7);
        taskstobedeleted.add(t12);
        delete taskstobedeleted;
        
        test.stopTest();

    }   
    
     static testmethod void checkTask1(){
        Account at = new Account(name='TestAccountt',phone='9876543201',CurrencyIsoCode='USD' );
        insert at;
       // Task t3 = new Task(subject='email:',whatid=aa.id,Status='In Progress',Priority='Normal',ActivityDate=system.today().adddays(1));
        Contact ct = new Contact(accountid=at.id,Last_Task_Completed__c='test',lastname='testcontactt',email='test@gmail.com',CurrencyIsoCode='USD');
        insert ct;
        Task t79 = new Task(subject='email:', whoid=ct.id,whatid=at.id,Status='In Progress',Priority='Normal',ActivityDate=system.today().adddays(1));
        insert t79;
        
        Account att = new Account(name='TestAccountt',phone='9876543201',CurrencyIsoCode='USD' );
        insert att;
       // Task t3 = new Task(subject='email:',whatid=aa.id,Status='In Progress',Priority='Normal',ActivityDate=system.today().adddays(1));
        Contact ctt = new Contact(accountid=att.id,Next_Task_Planned__c ='email',Next_Task_Planned_Date__c =system.today().adddays(1),lastname='testcontactt',email='test@gmail.com',CurrencyIsoCode='USD');
        insert ctt;
        Task t799 = new Task(subject='email', whoid=ctt.id,whatid=att.id,Status='In Progress',Priority='Normal',ActivityDate=system.today().adddays(1));
        insert t799;
        Task t7999 = new Task(subject='email', whoid=ctt.id,whatid=att.id,Status='Completed',Priority='Normal',ActivityDate=system.today().adddays(1));
        insert t7999;
        
     }
    
}