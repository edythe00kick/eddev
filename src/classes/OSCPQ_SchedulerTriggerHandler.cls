/*
 * Handler for the OS CPQ Scheduler Trigger Handler.
 */
public class OSCPQ_SchedulerTriggerHandler {
	static final string cronNameDelim = ': '; //Delimiter between the scheduled job type & cron expression for the scheduled job name
    static final string jobIdListDelim = ',';
    
    /*
     * Method called on trigger Before Insert.
     *    Creates new Cron Jobs and writes their Ids to
     *    the OSCPQ_Scheduled_Job_Ids__c field
     */
    public static void beforeInsert(List<OSCPQ_Scheduler__c> newSchedulers){
        createNewSchedules(newSchedulers);
    }
    
    public static void beforeUpdate(List<OSCPQ_Scheduler__c> updatedSchedulers){
        //Fetch and delete existing cron jobs
        for(OSCPQ_Scheduler__c scheduler : updatedSchedulers){
            List<CronTrigger> jobsToDelete = getJobs(scheduler.OSCPQ_Scheduled_Job_Ids__c);
            for(CronTrigger jobToDelete : jobsToDelete){
                System.abortJob(jobToDelete.Id);
            }
            scheduler.OSCPQ_Scheduled_Job_Ids__c = '';
        }
       	
        
        //Generate new schedules
        createNewSchedules(updatedSchedulers);
        
    }
    
    public static void beforeDelete(List<OSCPQ_Scheduler__c> deletedSchedulers){
        //Fetch and delete existing cron jobs
        for(OSCPQ_Scheduler__c scheduler : deletedSchedulers){
            List<CronTrigger> jobsToDelete = getJobs(scheduler.OSCPQ_Scheduled_Job_Ids__c);
            for(CronTrigger jobToDelete : jobsToDelete){
                System.abortJob(jobToDelete.Id);
            }
        }
    }
    
    /*
     * Helper method that takes a comma-delimited string of CronTrigger Ids
     *   and returns a list of CronTriggers
     * Params: jobIdSTring = Comma-delimited string of Ids
     */
    private static List<CronTrigger> getJobs(String jobIdString){
        List<CronTrigger> cronList = new List<CronTrigger>();
        if(jobIdString != null && jobIdString != ''){
            List<Id> cronIdList = new List<Id>(); //List of Cron Ids that will be used for a Query
            
            List<String> strSplitList = jobIdString.split(jobIdListDelim);
            //Loop through the strings split, ensure that they are Ids, and add to a list of Ids
            for(string strSplit : strSplitList){
                if(strSplit InstanceOf Id){
                    cronIdList.add(strSplit);
                }
            }
            
            if(!cronIdList.isEmpty()){
                cronList = [Select Id FROM CronTrigger WHERE Id IN :cronIdList];
            }
        }
        
        return cronList;
    }
    
    /*
     * 	Helper method to generate a cron string.
     * 	   	Only supports basic secs/mins/hrs/dates (will not support a single "run every 1st and 30th of the month" experessions)
     *     	Any null parameters will be treated as a * (repeat) and a -1 value as ? (not specified)
     * 		Example, to create an exp that will run at the 30 minute mark of every hour of every day:
     *         cronExpGenerator(null, 30, null, null, null, null, null);
     * 		Params:
     * 			sec = run at 'this second'
     * 			min = run at 'this minute mark'
     * 			hr = 'run on this hour'. 24-hour format (ex: 3pm = 15)
     * 			dayMo = day of the month
     * 			mo = month numerical format (1-12)
     * 			wkDays = comma-delimited list of days of the week to run this on (Ex: SUN,MON,TUE,WED,THU,FRI,SAT)
     * 			year = specific year to run
     * 		NOTE: when used in scheduling, the system.scheudle method will use the running user's timezone for the basis of all schedules.
     */
    private static String cronExpGenerator(integer sec, integer min, integer hr, integer dayMo, integer mo, string wkDays, integer year){
        String cronExp = '';
        
        String secParam = (sec != null) ? ((sec != -1) ? String.valueOf(sec) : '?') : '*';
        String minParam = (min != null) ? ((min != -1) ? String.valueOf(min) : '?') : '*';
        String hrParam = (hr != null) ? ((hr != -1) ? String.valueOf(hr) : '?') : '*';
        String dayMoParam = (dayMo != null) ? ((dayMo != -1) ? String.valueOf(dayMo) : '?') : '*';
        String moParam = (mo != null) ? ((mo != -1) ? String.valueOf(mo) : '?') : '*';
        String wkDaysParam = (wkDays != null) ? wkDays : '?';
        String yearParam = (year != null) ? String.valueOf(year) : null; //leave year null as it is an optional param
        
        cronExp = secParam + ' '
            	+ minParam + ' '
            	+ hrParam + ' '
            	+ dayMoParam + ' '
            	+ moParam + ' '
            	+ wkDaysParam;
        cronExp += (yearParam != null) ? ' ' + yearParam : '';
        
        return cronExp;
    }
    
    /*
     * Helper method that generates a list of chron expressions to schedule for a given schedule record.
     */
    private static String[] generateChronExpFromSchedulerRecord(OSCPQ_Scheduler__c sch){
        
        String[] cronExpList = new String[]{};

        if(sch.OSCPQ_Frequency__c == 'ONCE'){
            DateTime dt = sch.OSCPQ_Start_Date_Time__c;
            if(dt <= DateTime.now()){ //If date time is now or in the past, set it a second ahead so that it runs
                dt = DateTime.now().addSeconds(5);
            }
            cronExpList.add(cronExpGenerator(dt.second(), dt.minute(), dt.hour(), dt.day(), dt.month(), null, dt.year()));
        }
        else if(sch.OSCPQ_Frequency__c == 'HOURLY'){
            for(Integer i = 0 ; i < (60 / Integer.valueOf(sch.OSCPQ_Minutes__c)) ; i++){
                cronExpList.add(cronExpGenerator(0, i * Integer.valueOf(sch.OSCPQ_Minutes__c), null, null, null, null, null));
            }
            
        }
        else if(sch.OSCPQ_Frequency__c == 'DAILY'){
            DateTime dt = sch.OSCPQ_Start_Date_Time__c;
            cronExpList.add(cronExpGenerator(0, dt.minute(), dt.hour(), -1, null, sch.OSCPQ_Days__c.replace(';', ','), null));
        }
        else{ //'MONTHLY'
            DateTime dt =sch.OSCPQ_Start_Date_Time__c;
            cronExpList.add(cronExpGenerator(0, dt.minute(), dt.hour(), dt.day(), null, null, null));
        }
        
        return cronExpList;
    }
    
    /*
     * Helper method that creates new Scheduled Jobs for a list of Schedulers that were inserted or updated
     */
    private static void createNewSchedules(List<OSCPQ_Scheduler__c> newSchedulers){
        Map<String, Set<String>> cronExpMap = new Map<String, Set<String>>(); //Map with key = OSCPQ_Schedule_Type__c value, and values a list of cron expressions
        Map<String, OSCPQ_Scheduler__c> cronNameToSchedulerMap = new Map<String, OSCPQ_Scheduler__c>(); //Used to assign a lookup key to each scheduler record so that individual Jobs can be tied back to them.
        Map<OSCPQ_Scheduler__c, List<Id>> schToCronMap = new Map<OSCPQ_Scheduler__c, List<Id>>();
        
        //Generate full list of cron expressions for each schedule type
        for(OSCPQ_Scheduler__c scheduler : newSchedulers){
            //Fetch existing cron expressions
            Set<String> cronExpList = cronExpMap.containskey(scheduler.OSCPQ_Schedule_Type__c) ? cronExpMap.get(scheduler.OSCPQ_Schedule_Type__c) : new Set<String>();
            
            //Generate list of new cron expressions and add to the existing set
			String[] newCrons = generateChronExpFromSchedulerRecord(scheduler);
            if(!newCrons.isEmpty()){
                cronExpList.addAll(newCrons);
                
                //add each new expression to the map to tied them back to their original schedule
                for(String newCron : newCrons){
                    String jobName = scheduler.OSCPQ_Schedule_Type__c + cronNameDelim + newCron;
                    if(Test.isRunningTest()) { //add "TEST" to the name for test classes
                        jobName = 'TEST' + jobName; 
                    }
                	cronNameToSchedulerMap.put(jobName, scheduler);
                }
            }
            
            cronExpMap.put(scheduler.OSCPQ_Schedule_Type__c, cronExpList);
        }
        
        //With full list generated, schedule relevant jobs
        for(String schType : cronExpMap.keySet()){
            Id jobId;
            OSCPQ_Scheduler__c sch; //Schedule that the inserted scheduled job will tie to
            
            for(String cronExp : cronExpMap.get(schType)){
                String name = schType + cronNameDelim + cronExp;
                if(Test.isRunningTest()) { //add "TEST" to the name for test classes
                    name = 'TEST' + name; 
                }
                
                //schedule the appropriate job baed ont he Schedule Type
                if(schType == 'CPQ_RENEWAL_AUTOMATION'){
	                jobId = System.schedule(name, cronExp, new OSCPQ_ContractRenewal_Schedule());
                }
                else if(schType == 'CPQ_ORDER_AUTOMATION'){
                    jobId = System.schedule(name, cronExp, new OSCPQ_OrderAutomation_Schedule());
                }
                
                if(cronNameToSchedulerMap.containskey(name)){
                    sch = cronNameToSchedulerMap.get(name);
                    
                    List<Id> jobIdList = schToCronMap.containsKey(sch) ? schToCronMap.get(sch) : new List<Id>();
                    jobIdList.add(jobId);
                    schToCronMap.put(sch, jobIdList);
                }
            }
        }
        
        //Populate the OSCPQ_Scheduled_Job_Ids__c with all the shceduled job Ids (comma-delimited)
        for(OSCPQ_Scheduler__c sch : newSchedulers){
            List<Id> jobIdList = schToCronMap.containskey(sch) ? schToCronMap.get(sch) : null;
            if(jobIdList != null){
                sch.OSCPQ_Scheduled_Job_Ids__c = String.join(jobIdList, jobIdListDelim);
            }
        }
    }
}