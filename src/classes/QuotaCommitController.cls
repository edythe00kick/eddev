public class QuotaCommitController{

public String oppType{get; set;}
public string str{get;set;}
public String LoggedInUserID{get;set;} 
public String LoggedinUserusername{get;set;}
public String profileName{get;set;}
public String roleName{get;set;}
public List<Sales_Numbers__c> salesNumbersList{get; set;}
public List<Sales_Numbers__c> updatedSalesNumberList{get; set;}
public Map<Integer,String> currentMonthMap;
public Map<String,String> quarterMap;
public string currMonthName {get;set;}
public String month1 {get;set;}
public String month2 {get;set;}
public String month3 {get;set;}
public integer currYear {get; set;}
public Map<String,Integer> monthnametonumber ;
public String errStr {get;set;}
public String FirstMonthName {get;set;}
public String SecondMonthName {get;set;}
public String ThirdMonthName {get;set;}
public Map<String,String> quarter2Month;
public Map<String,String> quarter2Month2;
public Map<String,String> quarter2Month3 ;
public boolean displayPopup {get; set;}
public String currMonth {get ;set;}
public String currMonth1 {get; set;}

public QuotaCommitController(ApexPages.StandardController controller){
    str ='a'; 
    quarter2Month = new Map<String,String>();
    quarter2Month2= new Map<String,String>();
    quarter2Month3 = new Map<String,String>();
    
    oppType = 'All';
    system.debug('opptype old is '+opptype);
    LoggedInUserID= Userinfo.getUserId();
    system.debug('loggedinuserid is ============================>'+LoggedInUserID);
    LoggedinUserusername= Userinfo.getName();
    profileName= [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
    roleName=[select u.UserRole.Name from User u where u.id = :Userinfo.getUserId()].UserRole.Name;
    currentMonthMap = new Map<Integer,String>();
    quarterMap = new Map<String,String>();
    currentMonthMap.put(1,'January');
    currentMonthMap.put(2,'February');
    currentMonthMap.put(3,'March');
    currentMonthMap.put(4,'April');
    currentMonthMap.put(5,'May');
    currentMonthMap.put(6,'June');
    currentMonthMap.put(7,'July');
    currentMonthMap.put(8,'August');
    currentMonthMap.put(9,'September');
    currentMonthMap.put(10,'October');
    currentMonthMap.put(11,'November');
    currentMonthMap.put(12,'December');
    currMonthName = currentMonthMap.get(Date.today().month());  
    
    currYear = Date.today().year();
 
    quarter2Month.put('Q1','January');
    quarter2Month.put('Q2','April');
    quarter2Month.put('Q3','July');
    quarter2Month.put('Q4','October');
        
    quarter2Month2.put('Q1','March');
    quarter2Month2.put('Q2','June');
    quarter2Month2.put('Q3','September');
    quarter2Month2.put('Q4','December');
     
    quarter2Month3.put('Q1','February');
    quarter2Month3.put('Q2','May');
    quarter2Month3.put('Q3','August');
    quarter2Month3.put('Q4','November'); 
     
    month1 = currentMonthMap.get(Date.today().month());
    month2='';
    month3='';
    quarterMap.put('January','Q1');
    quarterMap.put('February','Q1');
    quarterMap.put('March','Q1');
    quarterMap.put('April','Q2');
    quarterMap.put('May','Q2');
    quarterMap.put('June','Q2');
    quarterMap.put('July','Q3');
    quarterMap.put('August','Q3');
    quarterMap.put('September','Q3');
    quarterMap.put('October','Q4');
    quarterMap.put('November','Q4');
    quarterMap.put('December','Q4');
    currMonthName = quarterMap.get(currMonthName);
    
    String q1 =currentMonthMap.get(Date.today().month());
    String m1 = quarterMap.get(q1);
    FirstMonthName = quarter2Month.get(m1);
    SecondMonthName = quarter2Month3.get(m1 );
    ThirdMonthName= quarter2Month2.get(m1 );

   if(LoggedInUserID != NULL){
        salesNumbersList = new List<Sales_Numbers__c>();
        for(Sales_Numbers__c s : [select id,ownerid,Manager_Id__c,Owner_Name__c,APR_ECR_Commit__c, APR_ECR_QUOTA__c, APR_ECUR_Commit__c, APR_ECUR_QUOTA__c,
                                  APR_OEM_Commit__c, APR_OEM_QUOTA__c, AUG_ECR_Commit__c, AUG_ECR_QUOTA__c, AUG_ECUR_Commit__c, AUG_ECUR_QUOTA__c,
                                  AUG_OEM_Commit__c, AUG_OEM_QUOTA__c, Apr_Commit__c, Apr_NBEC_Commit__c, Apr_NBEC_Quota__c, Apr_NB_Commit__c, Apr_NB_Quota__c,
                                  Apr_Quota__c, Aug_Commit__c, Aug_NBEC_Commit__c, Aug_NBEC_Quota__c, Aug_NB_Commit__c, Aug_NB_Quota__c, Aug_Quota__c, Current_Month_Commit__c,
                                  Current_Month_Quota__c, DEC_ECR_Commit__c, DEC_ECR_QUOTA__c, DEC_ECUR_Commit__c, DEC_ECUR_QUOTA__c, DEC_OEM_Commit__c, 
                                  DEC_OEM_QUOTA__c, Dec_Commit__c, Dec_NBEC_Commit__c, Dec_NBEC_Quota__c, Dec_NB_Commit__c, Dec_NB_Quota__c, Dec_Quota__c,
                                  FEB_ECR_Commit__c, FEB_ECR_QUOTA__c, FEB_ECUR_Commit__c, FEB_ECUR_QUOTA__c, FEB_OEM_Commit__c, FEB_OEM_QUOTA__c,
                                  FY_ECR_Commit__c, FY_ECR_Quota__c, FY_ECUR_Commit__c, FY_ECUR_Quota__c, FY_NBEC_Commit__c, FY_NBEC_Quota__c, FY_NB_Commit__c,
                                  FY_NB_Quota__c, FY_OEM_Commit__c, FY_OEM_Quota__c, FY_Total_Commit__c, FY_Total_Quota__c, Feb_Commit__c, Feb_NBEC_Commit__c, 
                                  Feb_NBEC_Quota__c, Feb_NB_Commit__c, Feb_NB_Quota__c, Feb_Quota__c, JAN_ECR_Commit__c, JAN_ECR_QUOTA__c, JAN_ECUR_Commit__c, JAN_ECUR_QUOTA__c,
                                  JAN_OEM_Commit__c, JAN_OEM_QUOTA__c, JUL_ECR_Commit__c, JUL_ECR_QUOTA__c, JUL_ECUR_Commit__c, JUL_ECUR_QUOTA__c, JUL_OEM_Commit__c, JUL_OEM_QUOTA__c,
                                  JUN_ECR_Commit__c, JUN_ECR_QUOTA__c, JUN_ECUR_Commit__c, JUN_ECUR_QUOTA__c, JUN_OEM_Commit__c, JUN_OEM_QUOTA__c, Jan_Commit__c, Jan_NBEC_Commit__c,
                                  Jan_NBEC_Quota__c, Jan_NB_Commit__c, Jan_NB_Quota__c, Jan_Quota__c, Jul_Commit__c, Jul_NBEC_Commit__c, Jul_NBEC_Quota__c, Jul_NB_Commit__c,
                                  Jul_NB_Quota__c, Jul_Quota__c, Jun_Commit__c, Jun_NBEC_Commit__c, Jun_NBEC_Quota__c, Jun_NB_Commit__c, Jun_NB_Quota__c, Jun_Quota__c, MAR_ECR_Commit__c,
                                  MAR_ECR_QUOTA__c, MAR_ECUR_Commit__c, MAR_ECUR_QUOTA__c, MAR_OEM_Commit__c, MAR_OEM_QUOTA__c, MAY_ECR_Commit__c, MAY_ECR_QUOTA__c, MAY_ECUR_Commit__c, MAY_ECUR_QUOTA__c, 
                                  MAY_OEM_Commit__c, MAY_OEM_QUOTA__c, Mar_Commit__c, Mar_NBEC_Commit__c, Mar_NBEC_Quota__c, Mar_NB_Commit__c, Mar_NB_Quota__c, Mar_Quota__c, May_Commit__c, May_NBEC_Commit__c,
                                  May_NBEC_Quota__c, May_NB_Commit__c, May_NB_Quota__c, May_Quota__c, Month_NBEC_Commit__c, Month_NBEC_Quota__c, Month_NB_Commit__c, Month_NB_Quota__c, NOV_ECR_Commit__c, NOV_ECR_QUOTA__c,
                                  NOV_ECUR_Commit__c, NOV_ECUR_QUOTA__c, NOV_OEM_Commit__c, NOV_OEM_QUOTA__c, Nov_Commit__c, Nov_NBEC_Commit__c, Nov_NBEC_Quota__c, Nov_NB_Commit__c, Nov_NB_Quota__c, Nov_Quota__c, OCT_ECR_Commit__c,
                                  OCT_ECR_QUOTA__c, OCT_ECUR_Commit__c, OCT_ECUR_QUOTA__c, OCT_OEM_Commit__c, OCT_OEM_QUOTA__c, OEM_Amount__c, Oct_Commit__c, Oct_NBEC_Commit__c, Oct_NBEC_Quota__c,
                                  Oct_NB_Commit__c, Oct_NB_Quota__c, Oct_Quota__c, Opportunity_Name__c, Q1_Commit__c, Q1_ECR_Commit__c, Q1_ECR_Quota__c, Q1_ECUR_Commit__c, Q1_ECUR_Quota__c, Q1_NBEC_Commit__c, Q1_NBEC_Quota__c,
                                  Q1_NB_Commit__c, Q1_NB_Quota__c, Q1_OEM_Commit__c, Q1_OEM_Quota__c, Q1_Quota__c, Q2_Commit__c, Q2_ECR_Commit__c, Q2_ECR_Quota__c, Q2_ECUR_Commit__c, Q2_ECUR_Quota__c, Q2_NBEC_Commit__c, Q2_NBEC_Quota__c,
                                  Q2_NB_Commit__c, Q2_NB_Quota__c, Q2_OEM_Commit__c, Q2_OEM_Quota__c, Q2_Quota__c, Q3_Commit__c, Q3_ECR_Commit__c, Q3_ECR_Quota__c, Q3_ECUR_Commit__c, Q3_ECUR_Quota__c, Q3_NBEC_Commit__c, Q3_NBEC_Quota__c,
                                  Q3_NB_Commit__c, Q3_NB_Quota__c, Q3_OEM_Commit__c, Q3_OEM_Quota__c, Q3_Quota__c, Q4_Commit__c, Q4_ECR_Commit__c, Q4_ECR_Quota__c, Q4_ECUR_Commit__c, Q4_ECUR_Quota__c, Q4_Inside_Quota__c, Q4_NBEC_Commit__c,
                                  Q4_NBEC_Quota__c, Q4_NB_Commit__c, Q4_NB_Quota__c, Q4_OEM_Commit__c, Q4_OEM_Quota__c, Q4_Quota__c, Quarter_NBEC_Commit__c, Quarter_NB_Commit__c, Quarters_Commit__c, SEP_ECR_Commit__c, SEP_ECR_QUOTA__c, SEP_ECUR_Commit__c,
                                  SEP_ECUR_QUOTA__c, SEP_OEM_Commit__c, SEP_OEM_QUOTA__c, Sep_Commit__c, Sep_NBEC_Commit__c, Sep_NBEC_Quota__c, Sep_NB_Commit__c, Sep_NB_Quota__c, Sep_Quota__c
                                   from Sales_Numbers__c where (Manager_Id__c=: LoggedInUserID.substring(0,15) OR ownerid=: LoggedInUserID.substring(0,15)) AND createddate= THIS_YEAR ]){
            salesNumbersList.add(s);
        }
               system.debug('salesnumberlist is----------------------------------->'+salesNumbersList );
               system.debug('LoggedinUserusername is----------------------------------->'+LoggedinUserusername);
               system.debug('LoggedinUserusername is----------------------------------->'+LoggedInUserID.substring(0,15));
               
     }
     monthnametonumber = new Map<String,Integer>();
     monthnametonumber.put('January',1);
     monthnametonumber.put('February',2);
     monthnametonumber.put('March',3);
     monthnametonumber.put('April',4);
     monthnametonumber.put('May',5);
     monthnametonumber.put('June',6);
     monthnametonumber.put('July',7);
     monthnametonumber.put('August',8);
     monthnametonumber.put('September',9);
     monthnametonumber.put('October',10);
     monthnametonumber.put('November',11);
     monthnametonumber.put('December',12);

     String cmonth = quarter2Month.get(currMonthName);
     currMonth = cmonth+' '+'FY'+' '+currYear;
     currMonth1 = quarter2Month2.get(currMonthName)+' '+'FY'+' '+currYear;
     system.debug('currentmonthis---------------------------------------->'+ currMonth);
     system.debug('currentmonth1is---------------------------------------->'+currMonth1 );
   
}
       
       public List<SelectOption> getclassOfBusiness() {
            List<SelectOption> oppTypes = new List<SelectOption>();
            oppTypes.add(new SelectOption('All','All'));
            oppTypes.add(new SelectOption('NB','NB'));
            oppTypes.add(new SelectOption('NBEC','NBEC'));
            oppTypes.add(new SelectOption('ECR','ECR'));
            oppTypes.add(new SelectOption('ECUR','ECUR'));
            oppTypes.add(new SelectOption('OEM','OEM'));
            return oppTypes;
       }
       
    
 
    public PageReference closePopup() {
          errStr = '';
          Integer beginmonth = monthnametonumber.get(currmonth.split(' ', 2)[0]);
          Integer endmonth = monthnametonumber.get(currmonth1.split(' ', 2)[0]);
          Integer currentYear = Integer.valueOf(currmonth.split(' ', 2)[1].split(' ',2)[1]);
          System.debug('first split is '+currmonth.split(' ', 2)[0]);
          System.debug('secondsplit is '+currmonth.split(' ', 2)[1].split(' ',2)[1]);
          System.debug('end first split is '+currmonth1.split(' ', 2)[0]);
          System.debug('end secondsplit is '+currmonth1.split(' ', 2)[1].split(' ',2)[1]);          

         DateTime myDate = DateTime.NewInstance(currentYear,1,1,00,00,00);
         DateTime myDate1 = DateTime.NewInstance(currentYear,12,31,23,59,00);
         system.debug('date is===============================>'+myDate);
         system.debug('date1 is===============================>'+myDate1);
         if((Integer.valueOf(currmonth1.split(' ', 2)[1].split(' ',2)[1]) - Integer.valueOf(currmonth.split(' ', 2)[1].split(' ',2)[1]) == 0) && (monthnametonumber.get(currmonth1.split(' ', 2)[0]) - monthnametonumber.get(currmonth.split(' ', 2)[0]) == 2)){
              system.debug('---------------------->correct value');
              salesNumbersList.clear();
              FirstMonthName=  currmonth.split(' ', 2)[0];
              SecondMonthName = currentMonthMap.get(beginmonth+1);
              ThirdMonthName = currentMonthMap.get(beginmonth+2);
              //opptype='ECUR';
              currMonthName = quarterMap.get(currmonth.split(' ', 2)[0]);
              for(Sales_Numbers__c sn : [select id,ownerid,Manager_Id__c,Owner_Name__c,createddate,APR_ECR_Commit__c, APR_ECR_QUOTA__c, APR_ECUR_Commit__c, APR_ECUR_QUOTA__c,
                                          APR_OEM_Commit__c, APR_OEM_QUOTA__c, AUG_ECR_Commit__c, AUG_ECR_QUOTA__c, AUG_ECUR_Commit__c, AUG_ECUR_QUOTA__c,
                                          AUG_OEM_Commit__c, AUG_OEM_QUOTA__c, Apr_Commit__c, Apr_NBEC_Commit__c, Apr_NBEC_Quota__c, Apr_NB_Commit__c, Apr_NB_Quota__c,
                                          Apr_Quota__c, Aug_Commit__c, Aug_NBEC_Commit__c, Aug_NBEC_Quota__c, Aug_NB_Commit__c, Aug_NB_Quota__c, Aug_Quota__c, Current_Month_Commit__c,
                                          Current_Month_Quota__c, DEC_ECR_Commit__c, DEC_ECR_QUOTA__c, DEC_ECUR_Commit__c, DEC_ECUR_QUOTA__c, DEC_OEM_Commit__c, 
                                          DEC_OEM_QUOTA__c, Dec_Commit__c, Dec_NBEC_Commit__c, Dec_NBEC_Quota__c, Dec_NB_Commit__c, Dec_NB_Quota__c, Dec_Quota__c,
                                          FEB_ECR_Commit__c, FEB_ECR_QUOTA__c, FEB_ECUR_Commit__c, FEB_ECUR_QUOTA__c, FEB_OEM_Commit__c, FEB_OEM_QUOTA__c,
                                          FY_ECR_Commit__c, FY_ECR_Quota__c, FY_ECUR_Commit__c, FY_ECUR_Quota__c, FY_NBEC_Commit__c, FY_NBEC_Quota__c, FY_NB_Commit__c,
                                          FY_NB_Quota__c, FY_OEM_Commit__c, FY_OEM_Quota__c, FY_Total_Commit__c, FY_Total_Quota__c, Feb_Commit__c, Feb_NBEC_Commit__c, 
                                          Feb_NBEC_Quota__c, Feb_NB_Commit__c, Feb_NB_Quota__c, Feb_Quota__c, JAN_ECR_Commit__c, JAN_ECR_QUOTA__c, JAN_ECUR_Commit__c, JAN_ECUR_QUOTA__c,
                                          JAN_OEM_Commit__c, JAN_OEM_QUOTA__c, JUL_ECR_Commit__c, JUL_ECR_QUOTA__c, JUL_ECUR_Commit__c, JUL_ECUR_QUOTA__c, JUL_OEM_Commit__c, JUL_OEM_QUOTA__c,
                                          JUN_ECR_Commit__c, JUN_ECR_QUOTA__c, JUN_ECUR_Commit__c, JUN_ECUR_QUOTA__c, JUN_OEM_Commit__c, JUN_OEM_QUOTA__c, Jan_Commit__c, Jan_NBEC_Commit__c,
                                          Jan_NBEC_Quota__c, Jan_NB_Commit__c, Jan_NB_Quota__c, Jan_Quota__c, Jul_Commit__c, Jul_NBEC_Commit__c, Jul_NBEC_Quota__c, Jul_NB_Commit__c,
                                          Jul_NB_Quota__c, Jul_Quota__c, Jun_Commit__c, Jun_NBEC_Commit__c, Jun_NBEC_Quota__c, Jun_NB_Commit__c, Jun_NB_Quota__c, Jun_Quota__c, MAR_ECR_Commit__c,
                                          MAR_ECR_QUOTA__c, MAR_ECUR_Commit__c, MAR_ECUR_QUOTA__c, MAR_OEM_Commit__c, MAR_OEM_QUOTA__c, MAY_ECR_Commit__c, MAY_ECR_QUOTA__c, MAY_ECUR_Commit__c, MAY_ECUR_QUOTA__c, 
                                          MAY_OEM_Commit__c, MAY_OEM_QUOTA__c, Mar_Commit__c, Mar_NBEC_Commit__c, Mar_NBEC_Quota__c, Mar_NB_Commit__c, Mar_NB_Quota__c, Mar_Quota__c, May_Commit__c, May_NBEC_Commit__c,
                                          May_NBEC_Quota__c, May_NB_Commit__c, May_NB_Quota__c, May_Quota__c, Month_NBEC_Commit__c, Month_NBEC_Quota__c, Month_NB_Commit__c, Month_NB_Quota__c, NOV_ECR_Commit__c, NOV_ECR_QUOTA__c,
                                          NOV_ECUR_Commit__c, NOV_ECUR_QUOTA__c, NOV_OEM_Commit__c, NOV_OEM_QUOTA__c, Nov_Commit__c, Nov_NBEC_Commit__c, Nov_NBEC_Quota__c, Nov_NB_Commit__c, Nov_NB_Quota__c, Nov_Quota__c, OCT_ECR_Commit__c,
                                          OCT_ECR_QUOTA__c, OCT_ECUR_Commit__c, OCT_ECUR_QUOTA__c, OCT_OEM_Commit__c, OCT_OEM_QUOTA__c, OEM_Amount__c, Oct_Commit__c, Oct_NBEC_Commit__c, Oct_NBEC_Quota__c,
                                          Oct_NB_Commit__c, Oct_NB_Quota__c, Oct_Quota__c, Opportunity_Name__c, Q1_Commit__c, Q1_ECR_Commit__c, Q1_ECR_Quota__c, Q1_ECUR_Commit__c, Q1_ECUR_Quota__c, Q1_NBEC_Commit__c, Q1_NBEC_Quota__c,
                                          Q1_NB_Commit__c, Q1_NB_Quota__c, Q1_OEM_Commit__c, Q1_OEM_Quota__c, Q1_Quota__c, Q2_Commit__c, Q2_ECR_Commit__c, Q2_ECR_Quota__c, Q2_ECUR_Commit__c, Q2_ECUR_Quota__c, Q2_NBEC_Commit__c, Q2_NBEC_Quota__c,
                                          Q2_NB_Commit__c, Q2_NB_Quota__c, Q2_OEM_Commit__c, Q2_OEM_Quota__c, Q2_Quota__c, Q3_Commit__c, Q3_ECR_Commit__c, Q3_ECR_Quota__c, Q3_ECUR_Commit__c, Q3_ECUR_Quota__c, Q3_NBEC_Commit__c, Q3_NBEC_Quota__c,
                                          Q3_NB_Commit__c, Q3_NB_Quota__c, Q3_OEM_Commit__c, Q3_OEM_Quota__c, Q3_Quota__c, Q4_Commit__c, Q4_ECR_Commit__c, Q4_ECR_Quota__c, Q4_ECUR_Commit__c, Q4_ECUR_Quota__c, Q4_Inside_Quota__c, Q4_NBEC_Commit__c,
                                          Q4_NBEC_Quota__c, Q4_NB_Commit__c, Q4_NB_Quota__c, Q4_OEM_Commit__c, Q4_OEM_Quota__c, Q4_Quota__c, Quarter_NBEC_Commit__c, Quarter_NB_Commit__c, Quarters_Commit__c, SEP_ECR_Commit__c, SEP_ECR_QUOTA__c, SEP_ECUR_Commit__c,
                                          SEP_ECUR_QUOTA__c, SEP_OEM_Commit__c, SEP_OEM_QUOTA__c, Sep_Commit__c, Sep_NBEC_Commit__c, Sep_NBEC_Quota__c, Sep_NB_Commit__c, Sep_NB_Quota__c, Sep_Quota__c
                                           from Sales_Numbers__c where  (Manager_Id__c=: LoggedInUserID.substring(0,15) OR ownerid=: LoggedInUserID.substring(0,15)) AND createddate >=: myDate and  createddate <=: myDate1 ]){   
                    salesNumbersList.add(sn);
            }
            displayPopup = false;
           
          }
          else{
              
              errStr = 'The Time Frame should be a quarter only.';
              return null;
              system.debug('---------------------->invalid value');
          }
        
        return null;
    }
 
   public void cancelPopup(){
       errStr ='';
       String mon = currentMonthMap.get(Date.today().month());
       Integer currYear = Date.today().year();
       String quar = quarterMap.get(mon);
       String cmonth = quarter2Month.get(quar);
       currMonth = cmonth+' '+'FY'+' '+currYear;
       currMonth1 = quarter2Month2.get(quar)+' '+'FY'+' '+currYear;
       
       displayPopup = false;
   }
 
    public void showPopup() {
        displayPopup = true;
    }
    
    public List<SelectOption> getstartmonth() {
        List<SelectOption> months = new List<SelectOption>();
        months.add(new SelectOption('January FY '+(currYear-1),'January FY '+(currYear-1)));
        months.add(new SelectOption('April FY '+(currYear-1),'April FY '+(currYear-1)));
        months.add(new SelectOption('July FY '+(currYear-1),'July FY '+(currYear-1)));
        months.add(new SelectOption('October FY '+(currYear-1),'October FY '+(currYear-1)));
        months.add(new SelectOption('January FY '+currYear,'January FY '+currYear));
        months.add(new SelectOption('April FY '+currYear,'April FY '+currYear));
        months.add(new SelectOption('July FY '+currYear,'July FY '+currYear));
        months.add(new SelectOption('October FY '+currYear,'October FY '+currYear));
        months.add(new SelectOption('January FY '+(currYear+1),'January FY '+(currYear+1)));
        months.add(new SelectOption('April FY '+(currYear+1),'April FY '+(currYear+1)));
        months.add(new SelectOption('July FY '+(currYear+1),'July FY '+(currYear+1)));
        months.add(new SelectOption('October FY '+(currYear+1),'October FY '+(currYear+1)));
        return months;

    }
    public List<SelectOption> getendmonth() {
        List<SelectOption> months = new List<SelectOption>();
        months.add(new SelectOption('March FY '+(currYear-1),'March FY '+(currYear-1)));
        months.add(new SelectOption('June FY '+(currYear-1),'June FY '+(currYear-1)));
        months.add(new SelectOption('September FY '+(currYear-1),'September FY '+(currYear-1)));
        months.add(new SelectOption('December FY '+(currYear-1),'December FY '+(currYear-1)));
        months.add(new SelectOption('March FY '+currYear,'March FY '+currYear));
        months.add(new SelectOption('June FY '+currYear,'June FY '+currYear));
        months.add(new SelectOption('September FY '+currYear,'September FY '+currYear));
        months.add(new SelectOption('December FY '+currYear,'December FY '+currYear));
        months.add(new SelectOption('March FY '+(currYear+1),'March FY '+(currYear+1)));
        months.add(new SelectOption('June FY '+(currYear+1),'June FY '+(currYear+1)));
        months.add(new SelectOption('September FY '+(currYear+1),'September FY '+(currYear+1)));
        months.add(new SelectOption('December FY '+(currYear+1),'December FY '+(currYear+1)));        
        return months;
    }    

   /* public List<Sales_Numbers__c >getSalesNumberRecords(){
        if(LoggedInUserID != NULL){
        salesNumbersList = new List<Sales_Numbers__c>();
        salesNumbersList = [select id,Manager_Id__c,Owner_Name__c,APR_ECR_Commit__c, APR_ECR_QUOTA__c, APR_ECUR_Commit__c, APR_ECUR_QUOTA__c,
              APR_OEM_Commit__c, APR_OEM_QUOTA__c, AUG_ECR_Commit__c, AUG_ECR_QUOTA__c, AUG_ECUR_Commit__c, AUG_ECUR_QUOTA__c,
              AUG_OEM_Commit__c, AUG_OEM_QUOTA__c, Apr_Commit__c, Apr_NBEC_Commit__c, Apr_NBEC_Quota__c, Apr_NB_Commit__c, Apr_NB_Quota__c,
              Apr_Quota__c, Aug_Commit__c, Aug_NBEC_Commit__c, Aug_NBEC_Quota__c, Aug_NB_Commit__c, Aug_NB_Quota__c, Aug_Quota__c, Current_Month_Commit__c,
              Current_Month_Quota__c, DEC_ECR_Commit__c, DEC_ECR_QUOTA__c, DEC_ECUR_Commit__c, DEC_ECUR_QUOTA__c, DEC_OEM_Commit__c, 
              DEC_OEM_QUOTA__c, Dec_Commit__c, Dec_NBEC_Commit__c, Dec_NBEC_Quota__c, Dec_NB_Commit__c, Dec_NB_Quota__c, Dec_Quota__c,
              FEB_ECR_Commit__c, FEB_ECR_QUOTA__c, FEB_ECUR_Commit__c, FEB_ECUR_QUOTA__c, FEB_OEM_Commit__c, FEB_OEM_QUOTA__c,
              FY_ECR_Commit__c, FY_ECR_Quota__c, FY_ECUR_Commit__c, FY_ECUR_Quota__c, FY_NBEC_Commit__c, FY_NBEC_Quota__c, FY_NB_Commit__c,
              FY_NB_Quota__c, FY_OEM_Commit__c, FY_OEM_Quota__c, FY_Total_Commit__c, FY_Total_Quota__c, Feb_Commit__c, Feb_NBEC_Commit__c, 
              Feb_NBEC_Quota__c, Feb_NB_Commit__c, Feb_NB_Quota__c, Feb_Quota__c, JAN_ECR_Commit__c, JAN_ECR_QUOTA__c, JAN_ECUR_Commit__c, JAN_ECUR_QUOTA__c,
              JAN_OEM_Commit__c, JAN_OEM_QUOTA__c, JUL_ECR_Commit__c, JUL_ECR_QUOTA__c, JUL_ECUR_Commit__c, JUL_ECUR_QUOTA__c, JUL_OEM_Commit__c, JUL_OEM_QUOTA__c,
              JUN_ECR_Commit__c, JUN_ECR_QUOTA__c, JUN_ECUR_Commit__c, JUN_ECUR_QUOTA__c, JUN_OEM_Commit__c, JUN_OEM_QUOTA__c, Jan_Commit__c, Jan_NBEC_Commit__c,
              Jan_NBEC_Quota__c, Jan_NB_Commit__c, Jan_NB_Quota__c, Jan_Quota__c, Jul_Commit__c, Jul_NBEC_Commit__c, Jul_NBEC_Quota__c, Jul_NB_Commit__c,
              Jul_NB_Quota__c, Jul_Quota__c, Jun_Commit__c, Jun_NBEC_Commit__c, Jun_NBEC_Quota__c, Jun_NB_Commit__c, Jun_NB_Quota__c, Jun_Quota__c, MAR_ECR_Commit__c,
              MAR_ECR_QUOTA__c, MAR_ECUR_Commit__c, MAR_ECUR_QUOTA__c, MAR_OEM_Commit__c, MAR_OEM_QUOTA__c, MAY_ECR_Commit__c, MAY_ECR_QUOTA__c, MAY_ECUR_Commit__c, MAY_ECUR_QUOTA__c, 
              MAY_OEM_Commit__c, MAY_OEM_QUOTA__c, Mar_Commit__c, Mar_NBEC_Commit__c, Mar_NBEC_Quota__c, Mar_NB_Commit__c, Mar_NB_Quota__c, Mar_Quota__c, May_Commit__c, May_NBEC_Commit__c,
              May_NBEC_Quota__c, May_NB_Commit__c, May_NB_Quota__c, May_Quota__c, Month_NBEC_Commit__c, Month_NBEC_Quota__c, Month_NB_Commit__c, Month_NB_Quota__c, NOV_ECR_Commit__c, NOV_ECR_QUOTA__c,
              NOV_ECUR_Commit__c, NOV_ECUR_QUOTA__c, NOV_OEM_Commit__c, NOV_OEM_QUOTA__c, Nov_Commit__c, Nov_NBEC_Commit__c, Nov_NBEC_Quota__c, Nov_NB_Commit__c, Nov_NB_Quota__c, Nov_Quota__c, OCT_ECR_Commit__c,
              OCT_ECR_QUOTA__c, OCT_ECUR_Commit__c, OCT_ECUR_QUOTA__c, OCT_OEM_Commit__c, OCT_OEM_QUOTA__c, OEM_Amount__c, Oct_Commit__c, Oct_NBEC_Commit__c, Oct_NBEC_Quota__c,
              Oct_NB_Commit__c, Oct_NB_Quota__c, Oct_Quota__c, Opportunity_Name__c, Q1_Commit__c, Q1_ECR_Commit__c, Q1_ECR_Quota__c, Q1_ECUR_Commit__c, Q1_ECUR_Quota__c, Q1_NBEC_Commit__c, Q1_NBEC_Quota__c,
              Q1_NB_Commit__c, Q1_NB_Quota__c, Q1_OEM_Commit__c, Q1_OEM_Quota__c, Q1_Quota__c, Q2_Commit__c, Q2_ECR_Commit__c, Q2_ECR_Quota__c, Q2_ECUR_Commit__c, Q2_ECUR_Quota__c, Q2_NBEC_Commit__c, Q2_NBEC_Quota__c,
              Q2_NB_Commit__c, Q2_NB_Quota__c, Q2_OEM_Commit__c, Q2_OEM_Quota__c, Q2_Quota__c, Q3_Commit__c, Q3_ECR_Commit__c, Q3_ECR_Quota__c, Q3_ECUR_Commit__c, Q3_ECUR_Quota__c, Q3_NBEC_Commit__c, Q3_NBEC_Quota__c,
              Q3_NB_Commit__c, Q3_NB_Quota__c, Q3_OEM_Commit__c, Q3_OEM_Quota__c, Q3_Quota__c, Q4_Commit__c, Q4_ECR_Commit__c, Q4_ECR_Quota__c, Q4_ECUR_Commit__c, Q4_ECUR_Quota__c, Q4_Inside_Quota__c, Q4_NBEC_Commit__c,
              Q4_NBEC_Quota__c, Q4_NB_Commit__c, Q4_NB_Quota__c, Q4_OEM_Commit__c, Q4_OEM_Quota__c, Q4_Quota__c, Quarter_NBEC_Commit__c, Quarter_NB_Commit__c, Quarters_Commit__c, SEP_ECR_Commit__c, SEP_ECR_QUOTA__c, SEP_ECUR_Commit__c,
              SEP_ECUR_QUOTA__c, SEP_OEM_Commit__c, SEP_OEM_QUOTA__c, Sep_Commit__c, Sep_NBEC_Commit__c, Sep_NBEC_Quota__c, Sep_NB_Commit__c, Sep_NB_Quota__c, Sep_Quota__c
               from Sales_Numbers__c where Manager_Id__c=: LoggedInUserID.substring(0,15) ];
        return salesNumbersList ;
        system.debug('salesnumberlist----------------------------------->'+salesNumbersList );
        }
        return null;
    }  */
       
       public PageReference fetchRecords(){
          Integer beginmonth = monthnametonumber.get(currmonth.split(' ', 2)[0]);
          Integer endmonth = monthnametonumber.get(currmonth1.split(' ', 2)[0]);
          Integer currentYear = Integer.valueOf(currmonth.split(' ', 2)[1].split(' ',2)[1]);
          System.debug('first split is '+currmonth.split(' ', 2)[0]);
          System.debug('secondsplit is '+currmonth.split(' ', 2)[1].split(' ',2)[1]);
          System.debug('end first split is '+currmonth1.split(' ', 2)[0]);
          System.debug('end secondsplit is '+currmonth1.split(' ', 2)[1].split(' ',2)[1]);          

         DateTime myDate = DateTime.NewInstance(currentYear,1,1,00,00,00);
         DateTime myDate1 = DateTime.NewInstance(currentYear,12,31,23,59,00);
         system.debug('date is===============================>'+myDate);
         system.debug('date1 is===============================>'+myDate1);
         if((Integer.valueOf(currmonth1.split(' ', 2)[1].split(' ',2)[1]) - Integer.valueOf(currmonth.split(' ', 2)[1].split(' ',2)[1]) == 0) && (monthnametonumber.get(currmonth1.split(' ', 2)[0]) - monthnametonumber.get(currmonth.split(' ', 2)[0]) == 2)){
              system.debug('---------------------->correct value');
              salesNumbersList.clear();
              //FirstMonthName=  currmonth.split(' ', 2)[0];
              //SecondMonthName = currentMonthMap.get(beginmonth+1);
              //ThirdMonthName = currentMonthMap.get(beginmonth+2);
              //opptype='ECUR';
              currMonthName = quarterMap.get(currmonth.split(' ', 2)[0]);
              for(Sales_Numbers__c sn : [select id,ownerid,Manager_Id__c,Owner_Name__c,createddate,APR_ECR_Commit__c, APR_ECR_QUOTA__c, APR_ECUR_Commit__c, APR_ECUR_QUOTA__c,
                                          APR_OEM_Commit__c, APR_OEM_QUOTA__c, AUG_ECR_Commit__c, AUG_ECR_QUOTA__c, AUG_ECUR_Commit__c, AUG_ECUR_QUOTA__c,
                                          AUG_OEM_Commit__c, AUG_OEM_QUOTA__c, Apr_Commit__c, Apr_NBEC_Commit__c, Apr_NBEC_Quota__c, Apr_NB_Commit__c, Apr_NB_Quota__c,
                                          Apr_Quota__c, Aug_Commit__c, Aug_NBEC_Commit__c, Aug_NBEC_Quota__c, Aug_NB_Commit__c, Aug_NB_Quota__c, Aug_Quota__c, Current_Month_Commit__c,
                                          Current_Month_Quota__c, DEC_ECR_Commit__c, DEC_ECR_QUOTA__c, DEC_ECUR_Commit__c, DEC_ECUR_QUOTA__c, DEC_OEM_Commit__c, 
                                          DEC_OEM_QUOTA__c, Dec_Commit__c, Dec_NBEC_Commit__c, Dec_NBEC_Quota__c, Dec_NB_Commit__c, Dec_NB_Quota__c, Dec_Quota__c,
                                          FEB_ECR_Commit__c, FEB_ECR_QUOTA__c, FEB_ECUR_Commit__c, FEB_ECUR_QUOTA__c, FEB_OEM_Commit__c, FEB_OEM_QUOTA__c,
                                          FY_ECR_Commit__c, FY_ECR_Quota__c, FY_ECUR_Commit__c, FY_ECUR_Quota__c, FY_NBEC_Commit__c, FY_NBEC_Quota__c, FY_NB_Commit__c,
                                          FY_NB_Quota__c, FY_OEM_Commit__c, FY_OEM_Quota__c, FY_Total_Commit__c, FY_Total_Quota__c, Feb_Commit__c, Feb_NBEC_Commit__c, 
                                          Feb_NBEC_Quota__c, Feb_NB_Commit__c, Feb_NB_Quota__c, Feb_Quota__c, JAN_ECR_Commit__c, JAN_ECR_QUOTA__c, JAN_ECUR_Commit__c, JAN_ECUR_QUOTA__c,
                                          JAN_OEM_Commit__c, JAN_OEM_QUOTA__c, JUL_ECR_Commit__c, JUL_ECR_QUOTA__c, JUL_ECUR_Commit__c, JUL_ECUR_QUOTA__c, JUL_OEM_Commit__c, JUL_OEM_QUOTA__c,
                                          JUN_ECR_Commit__c, JUN_ECR_QUOTA__c, JUN_ECUR_Commit__c, JUN_ECUR_QUOTA__c, JUN_OEM_Commit__c, JUN_OEM_QUOTA__c, Jan_Commit__c, Jan_NBEC_Commit__c,
                                          Jan_NBEC_Quota__c, Jan_NB_Commit__c, Jan_NB_Quota__c, Jan_Quota__c, Jul_Commit__c, Jul_NBEC_Commit__c, Jul_NBEC_Quota__c, Jul_NB_Commit__c,
                                          Jul_NB_Quota__c, Jul_Quota__c, Jun_Commit__c, Jun_NBEC_Commit__c, Jun_NBEC_Quota__c, Jun_NB_Commit__c, Jun_NB_Quota__c, Jun_Quota__c, MAR_ECR_Commit__c,
                                          MAR_ECR_QUOTA__c, MAR_ECUR_Commit__c, MAR_ECUR_QUOTA__c, MAR_OEM_Commit__c, MAR_OEM_QUOTA__c, MAY_ECR_Commit__c, MAY_ECR_QUOTA__c, MAY_ECUR_Commit__c, MAY_ECUR_QUOTA__c, 
                                          MAY_OEM_Commit__c, MAY_OEM_QUOTA__c, Mar_Commit__c, Mar_NBEC_Commit__c, Mar_NBEC_Quota__c, Mar_NB_Commit__c, Mar_NB_Quota__c, Mar_Quota__c, May_Commit__c, May_NBEC_Commit__c,
                                          May_NBEC_Quota__c, May_NB_Commit__c, May_NB_Quota__c, May_Quota__c, Month_NBEC_Commit__c, Month_NBEC_Quota__c, Month_NB_Commit__c, Month_NB_Quota__c, NOV_ECR_Commit__c, NOV_ECR_QUOTA__c,
                                          NOV_ECUR_Commit__c, NOV_ECUR_QUOTA__c, NOV_OEM_Commit__c, NOV_OEM_QUOTA__c, Nov_Commit__c, Nov_NBEC_Commit__c, Nov_NBEC_Quota__c, Nov_NB_Commit__c, Nov_NB_Quota__c, Nov_Quota__c, OCT_ECR_Commit__c,
                                          OCT_ECR_QUOTA__c, OCT_ECUR_Commit__c, OCT_ECUR_QUOTA__c, OCT_OEM_Commit__c, OCT_OEM_QUOTA__c, OEM_Amount__c, Oct_Commit__c, Oct_NBEC_Commit__c, Oct_NBEC_Quota__c,
                                          Oct_NB_Commit__c, Oct_NB_Quota__c, Oct_Quota__c, Opportunity_Name__c, Q1_Commit__c, Q1_ECR_Commit__c, Q1_ECR_Quota__c, Q1_ECUR_Commit__c, Q1_ECUR_Quota__c, Q1_NBEC_Commit__c, Q1_NBEC_Quota__c,
                                          Q1_NB_Commit__c, Q1_NB_Quota__c, Q1_OEM_Commit__c, Q1_OEM_Quota__c, Q1_Quota__c, Q2_Commit__c, Q2_ECR_Commit__c, Q2_ECR_Quota__c, Q2_ECUR_Commit__c, Q2_ECUR_Quota__c, Q2_NBEC_Commit__c, Q2_NBEC_Quota__c,
                                          Q2_NB_Commit__c, Q2_NB_Quota__c, Q2_OEM_Commit__c, Q2_OEM_Quota__c, Q2_Quota__c, Q3_Commit__c, Q3_ECR_Commit__c, Q3_ECR_Quota__c, Q3_ECUR_Commit__c, Q3_ECUR_Quota__c, Q3_NBEC_Commit__c, Q3_NBEC_Quota__c,
                                          Q3_NB_Commit__c, Q3_NB_Quota__c, Q3_OEM_Commit__c, Q3_OEM_Quota__c, Q3_Quota__c, Q4_Commit__c, Q4_ECR_Commit__c, Q4_ECR_Quota__c, Q4_ECUR_Commit__c, Q4_ECUR_Quota__c, Q4_Inside_Quota__c, Q4_NBEC_Commit__c,
                                          Q4_NBEC_Quota__c, Q4_NB_Commit__c, Q4_NB_Quota__c, Q4_OEM_Commit__c, Q4_OEM_Quota__c, Q4_Quota__c, Quarter_NBEC_Commit__c, Quarter_NB_Commit__c, Quarters_Commit__c, SEP_ECR_Commit__c, SEP_ECR_QUOTA__c, SEP_ECUR_Commit__c,
                                          SEP_ECUR_QUOTA__c, SEP_OEM_Commit__c, SEP_OEM_QUOTA__c, Sep_Commit__c, Sep_NBEC_Commit__c, Sep_NBEC_Quota__c, Sep_NB_Commit__c, Sep_NB_Quota__c, Sep_Quota__c
                                           from Sales_Numbers__c where  (Manager_Id__c=: LoggedInUserID.substring(0,15) OR ownerid=: LoggedInUserID.substring(0,15)) AND createddate >=: myDate and  createddate <=: myDate1 ]){   
                    salesNumbersList.add(sn);
            }
          }
       
           return null;
       }
       public Pagereference updatesalesRecords(){
          if(salesNumbersList != NULL && salesNumbersList.size() > 0){
              updatedSalesNumberList = new List<Sales_Numbers__c>();
              for(Sales_Numbers__c sp : salesNumbersList){
                   updatedSalesNumberList.add(sp);
              }  
              if(updatedSalesNumberList != NULL && updatedSalesNumberList.size() > 0){
                   update updatedSalesNumberList;
                   salesNumbersList = updatedSalesNumberList;
              }         
           }
           return null;
       }

       public PageReference doCancel() {
            PageReference reference = new PageReference('/apex/QuotaCommitPage');
            reference.setRedirect(true);
            return reference;
       }
}