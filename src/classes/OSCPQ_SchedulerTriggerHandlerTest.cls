@isTest
public class OSCPQ_SchedulerTriggerHandlerTest {
    @isTest static void testInsertSingleOnce() {
        OSCPQ_Scheduler__c sch = new OSCPQ_Scheduler__c(OSCPQ_Schedule_Type__c = 'CPQ_RENEWAL_AUTOMATION',
                                                       	OSCPQ_Frequency__c = 'ONCE',
                                                       	OSCPQ_Start_Date_Time__c = DateTime.now().addSeconds(-10), //remove 10 seconds to ensure that the catchup mechanism fires
                                                        OSCPQ_Minutes__c = '60',
                                                        OSCPQ_Days__c = '',
                                                        OSCPQ_Scheduled_Job_Ids__c = ''
                                                       );
        List<OSCPQ_Scheduler__c> schList = new List<OSCPQ_Scheduler__c>();
        schList.add(sch);
        
        Test.startTest();
        OSCPQ_SchedulerTriggerHandler.beforeInsert(schList);
        Test.stopTest();
        
        List<String> scheduledJobList = (schList[0].OSCPQ_Scheduled_Job_Ids__c).split(',');
        
        List<CronTrigger> cronTriggerList = [SELECT ID FROM CronTrigger WHERE Id IN :scheduledJobList];
        System.assertEquals(1, cronTriggerList.size());
    }
    
    @isTest static void testInsertMultipleOnce() {
        Integer numIterations = 10;
        List<OSCPQ_Scheduler__c> schList = new List<OSCPQ_Scheduler__c>();
        
        for(Integer i=0; i< numIterations; i++){
            schList.add(new OSCPQ_Scheduler__c(OSCPQ_Schedule_Type__c = 'CPQ_RENEWAL_AUTOMATION',
                                               OSCPQ_Frequency__c = 'ONCE',
                                               OSCPQ_Start_Date_Time__c = DateTime.now().addHours(i+1),
                                               OSCPQ_Minutes__c = '60',
                                               OSCPQ_Days__c = '',
                                               OSCPQ_Scheduled_Job_Ids__c = ''
                                              ));
        }
        
        Test.startTest();
        OSCPQ_SchedulerTriggerHandler.beforeInsert(schList);
        Test.stopTest();
        
        List<String> scheduledJobList = new List<String>();
        for(OSCPQ_Scheduler__c curSch : schList) {
            scheduledJobList.addAll((curSch.OSCPQ_Scheduled_Job_Ids__c).split(','));
        }
        
        List<CronTrigger> cronTriggerList = [SELECT ID FROM CronTrigger WHERE Id IN :scheduledJobList];
        System.assertEquals(numIterations, cronTriggerList.size()); 
    }
    
    @isTest static void testDeleteSingleOnce() {
        OSCPQ_Scheduler__c sch = new OSCPQ_Scheduler__c(OSCPQ_Schedule_Type__c = 'CPQ_ORDER_AUTOMATION',
                                                       	OSCPQ_Frequency__c = 'ONCE',
                                                       	OSCPQ_Start_Date_Time__c = DateTime.now().addSeconds(-10), //remove 10 seconds to ensure that the catchup mechanism fires
                                                        OSCPQ_Minutes__c = '60',
                                                        OSCPQ_Days__c = '',
                                                        OSCPQ_Scheduled_Job_Ids__c = ''
                                                       );
        
        List<OSCPQ_Scheduler__c> schList = new List<OSCPQ_Scheduler__c>();
        schList.add(sch);
        OSCPQ_SchedulerTriggerHandler.beforeInsert(schList);
        
        List<String> scheduledJobList = (schList[0].OSCPQ_Scheduled_Job_Ids__c).split(',');
        
        List<CronTrigger> cronTriggerList = [SELECT ID FROM CronTrigger WHERE Id IN :scheduledJobList]; 
        System.assertEquals(scheduledJobList.size(), cronTriggerList.size(), 'Initial Size is off; should have ' + scheduledJobList.size() + ' created');
        
        Test.startTest();
        OSCPQ_SchedulerTriggerHandler.beforeDelete(schList);
        Test.stopTest();
                
        cronTriggerList = [SELECT ID FROM CronTrigger WHERE Id IN :scheduledJobList];
        System.assertEquals(0, cronTriggerList.size(), 'Not all scheduled jobs have been wiped');
    }
    
    @isTest static void testUpdateSingleOnce() {
        OSCPQ_Scheduler__c sch = new OSCPQ_Scheduler__c(OSCPQ_Schedule_Type__c = 'CPQ_RENEWAL_AUTOMATION',
                                                       	OSCPQ_Frequency__c = 'ONCE',
                                                       	OSCPQ_Start_Date_Time__c = DateTime.now().addSeconds(-10), //remove 10 seconds to ensure that the catchup mechanism fires
                                                        OSCPQ_Minutes__c = '60',
                                                        OSCPQ_Days__c = '',
                                                        OSCPQ_Scheduled_Job_Ids__c = ''
                                                       );
        List<OSCPQ_Scheduler__c> schList = new List<OSCPQ_Scheduler__c>();
        schList.add(sch);
        OSCPQ_SchedulerTriggerHandler.beforeInsert(schList);
        List<String> scheduledJobList = (schList[0].OSCPQ_Scheduled_Job_Ids__c).split(',');
        
        List<CronTrigger> cronTriggerList = [SELECT ID FROM CronTrigger WHERE Id IN :scheduledJobList]; 
        System.assertEquals(1, cronTriggerList.size(), 'Initial Size is off; should have 1 created');
        
        Test.startTest();
        OSCPQ_SchedulerTriggerHandler.beforeUpdate(schList);
        Test.stopTest();
        
        scheduledJobList = (schList[0].OSCPQ_Scheduled_Job_Ids__c).split(',');
        
        cronTriggerList = [SELECT ID FROM CronTrigger WHERE Id IN :scheduledJobList];
        System.assertEquals(1, cronTriggerList.size(), 'Not all scheduled jobs have been wiped');
    }
    
    @isTest static void testInsertSingleHourly() {
        OSCPQ_Scheduler__c sch = new OSCPQ_Scheduler__c(OSCPQ_Schedule_Type__c = 'CPQ_RENEWAL_AUTOMATION',
                                                       	OSCPQ_Frequency__c = 'HOURLY',
                                                       	OSCPQ_Start_Date_Time__c = DateTime.now().addSeconds(-10), //remove 10 seconds to ensure that the catchup mechanism fires
                                                        OSCPQ_Minutes__c = '15',
                                                        OSCPQ_Days__c = '',
                                                        OSCPQ_Scheduled_Job_Ids__c = ''
                                                       );
        List<OSCPQ_Scheduler__c> schList = new List<OSCPQ_Scheduler__c>();
        schList.add(sch);
        
        Test.startTest();
        OSCPQ_SchedulerTriggerHandler.beforeInsert(schList);
        Test.stopTest();
        
        List<String> scheduledJobList = (schList[0].OSCPQ_Scheduled_Job_Ids__c).split(',');
        
        List<CronTrigger> cronTriggerList = [SELECT ID FROM CronTrigger WHERE Id IN :scheduledJobList];
        System.assertEquals(4, cronTriggerList.size(), 'Expecting 4 schedules: at 0/15/30/45 minutes');
    }
    
    @isTest static void testInsertSingleDaily() {
        OSCPQ_Scheduler__c sch = new OSCPQ_Scheduler__c(OSCPQ_Schedule_Type__c = 'CPQ_RENEWAL_AUTOMATION',
                                                       	OSCPQ_Frequency__c = 'DAILY',
                                                       	OSCPQ_Start_Date_Time__c = DateTime.now().addSeconds(-10), //remove 10 seconds to ensure that the catchup mechanism fires
                                                        OSCPQ_Minutes__c = '15',
                                                        OSCPQ_Days__c = 'MON;TUE;WED',
                                                        OSCPQ_Scheduled_Job_Ids__c = ''
                                                       );
        List<OSCPQ_Scheduler__c> schList = new List<OSCPQ_Scheduler__c>();
        schList.add(sch);
        
        Test.startTest();
        OSCPQ_SchedulerTriggerHandler.beforeInsert(schList);
        Test.stopTest();
        
        List<String> scheduledJobList = (schList[0].OSCPQ_Scheduled_Job_Ids__c).split(',');
        
        List<CronTrigger> cronTriggerList = [SELECT ID FROM CronTrigger WHERE Id IN :scheduledJobList];
        System.assertEquals(1, cronTriggerList.size());
    }
    
    @isTest static void testInsertSingleMonthly() {
        OSCPQ_Scheduler__c sch = new OSCPQ_Scheduler__c(OSCPQ_Schedule_Type__c = 'CPQ_RENEWAL_AUTOMATION',
                                                       	OSCPQ_Frequency__c = 'MONTHLY',
                                                       	OSCPQ_Start_Date_Time__c = DateTime.now().addSeconds(-10), //remove 10 seconds to ensure that the catchup mechanism fires
                                                        OSCPQ_Minutes__c = '60',
                                                        OSCPQ_Days__c = '',
                                                        OSCPQ_Scheduled_Job_Ids__c = ''
                                                       );
        List<OSCPQ_Scheduler__c> schList = new List<OSCPQ_Scheduler__c>();
        schList.add(sch);
        
        Test.startTest();
        OSCPQ_SchedulerTriggerHandler.beforeInsert(schList);
        Test.stopTest();
        
        List<String> scheduledJobList = (schList[0].OSCPQ_Scheduled_Job_Ids__c).split(',');
        
        List<CronTrigger> cronTriggerList = [SELECT ID FROM CronTrigger WHERE Id IN :scheduledJobList];
        System.assertEquals(1, cronTriggerList.size());
    }
    
    @isTest static void testTrigger() {
        OSCPQ_Scheduler__c sch = new OSCPQ_Scheduler__c(OSCPQ_Schedule_Type__c = 'CPQ_RENEWAL_AUTOMATION',
                                                       	OSCPQ_Frequency__c = 'MONTHLY',
                                                       	OSCPQ_Start_Date_Time__c = DateTime.now().addSeconds(50),
                                                        OSCPQ_Minutes__c = '60',
                                                        OSCPQ_Days__c = '',
                                                        OSCPQ_Scheduled_Job_Ids__c = ''
                                                       );
        
        Test.startTest();
        insert sch;
        sch.OSCPQ_Frequency__c = 'HOURLY';
        update sch;
        List<String> schJobList = sch.OSCPQ_Scheduled_Job_Ids__c.split(',');
        
        delete sch;
        
        Test.stopTest();
        
        List<CronTrigger> cronTriggerList = [SELECT ID FROM CronTrigger WHERE Id IN :schJobList];
        System.assertEquals(0, cronTriggerList.size());
    }
}