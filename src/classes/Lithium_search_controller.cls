/*
Class for integrating lithium and salesforce platforms
Test Class:LithiumSearchControllerTest
Developed By:- Grazitti Interactive
*/
public class Lithium_search_controller {
    public Case caseRecord;
    public List<Case> caseSearchResults {get;set;}  
    public List <LData_WrapperMain> ldata{get;set;}
    public String searchtext{get;set;}
    public String channelType{get;set;}
    public String operation='';
    public String temp_endpoint='';
    public String temp_endpoint2='';
    public Boolean showPrev {get;set;}
    public Boolean showNext {get;set;}
    public Boolean showPrevCase {get;set;}
    public Boolean showNextCase {get;set;}    
    public String categ_operation;
    public Boolean Forums{get;set;}
    public Boolean Blogs{get;set;}
    public Boolean Ideas{get;set;}
    public Boolean KnowledgeBase{get;set;}
    public Boolean Contests{get;set;}   
    public Boolean Groups{get;set;}
    public Boolean showCaseResult{get;set;}
    public DateTime dtime;
    public Integer numberOfResults{get;set;}    
    public Integer currentPage{get; set;}
    public Integer totalRecs{get;set;}
    public Integer index {get;set;}
    public Boolean lithiumresults{get;set;}
    public Boolean caseresults{get;set;}
    public String VF_txt{get; set;}
    public String VF_txt2{get; set;}
    public Boolean enableCaseSearch{get;set;}
    public Integer pageSize{get;set;}
    public Integer blockSize=3;
    public String caseId;
    public List<Case> searchCaseSubject;
    public String jsonString;
    public String sessionId;
    public String strEndPoint;
    public String lithium_url;
    public Lithium_Search_Configuration__c searchConfiguration = Lithium_Search_Configuration__c.getinstance();
    
    public Lithium_search_controller(ApexPages.StandardController controller) {
        if(!Test.isRunningTest()){
            controller.addFields(new List<String>{'Subject'});
        }    
        caseRecord = (Case)controller.getRecord();
        caseId = caseRecord.Id;
        searchtext = caseRecord.subject;
        VF_txt = searchConfiguration.Attach_to_Case_Text__c;
        VF_txt2 = searchConfiguration.Email_Body_Text__c;
        channeltype='All';
        showPrev = true;
        showNext =true;
        showPrevCase=false;
        showNextCase=false;
        showCaseResult=false;
        blogs=false;
        forums=false;
        ideas=false;
        knowledgebase=false;
        contests=false;
        groups=false;
        lithiumresults=true;
        index = 0;
        searchKnowledgeRecords();
    }
    public Lithium_search_controller(){
        
    }
    //method handling the modifications from apex-page
    public pagereference searchKnowledgeRecords(){
        
        if(searchConfiguration!=null&&searchConfiguration.Enable_Cases_Search__c!=null){
            if(searchConfiguration.Enable_Cases_Search__c){
                enableCaseSearch=true;
            }else{enableCaseSearch=false;}
        }
        
        if(showCaseResult==false&&blogs==false&&forums==false&&ideas==false&&contests==false&&groups==false&&knowledgebase==false){
            caseresults=true;lithiumresults=true;
        }else{caseresults=false;}
        
        if(showCaseResult==true&&blogs==false&&forums==false&&ideas==false&&contests==false&&groups==false&&knowledgebase==false){
            lithiumresults=false;
        }else{lithiumresults=true;}
        
        if(caseresults&&enableCaseSearch){
            sf_cases(); 
        }
        else if(showCaseResult&&enableCaseSearch){
            sf_cases();
        }
        
        if(lithiumresults){
            currentPage = 1;
            getResult();
        }
        return  null;
    }
    //method for lithium platform search
    public pagereference getResult(){
        
        ldata = new List<LData_WrapperMain>();
        pageSize = searchConfiguration.Lithium_Search_Results_Per_Page__c.intValue();
        
        if(searchtext!=null&&searchtext.trim()!=''){
            operation = searchtext;
            operation = operation.trim();
            operation = operation.replaceAll('[^\\w\\s]',' ');
            operation = operation.replaceAll('\\s+',' ');
            operation = operation.replaceAll('\\s','%20OR%20');
        }else{return null;}
        
        lithium_url = searchConfiguration.Lithium_Endpoint_URL__c;
        
        HttpRequest req = new HttpRequest();
        HTTPResponse res = new HTTPResponse();
        Http h = new Http();
        
        if(searchConfiguration!=null && searchConfiguration.Lithium_Search_Password__c!=null && searchConfiguration.Lithium_Search_Username__c!=null){
            Lithium_authentication lithauthen = new Lithium_authentication();
            sessionId = lithauthen.authenticate();
        }
        if(sessionId==null){sessionId='';}
        
        if(Forums==true){
            temp_endpoint+='&filter=includeForums&include_forums=true';
        }
        if(Blogs==true){
            temp_endpoint+='&filter=includeBlogs&include_blogs=true';
        }
        if(Ideas==true){
            temp_endpoint+='&filter=includeIdeas&include_ideas=true';
        }
        if(KnowledgeBase==true){
            temp_endpoint+='&filter=includeTkbs&include_tkbs=true';
        }
        if(Contests==true){
            temp_endpoint+='&filter=includeContests&include_contests=true';
        }
        if(Groups==true){
            temp_endpoint+='&filter=includeGroups&include_groups=true';
        }
        if(channeltype=='All'){
            temp_endpoint2+='';
        }
        else if(channeltype=='DayAgo'){
            temp_endpoint2+='&rangeTime=1d';
        }
        else if(channeltype=='WeekAgo'){
            temp_endpoint2+='&rangeTime=1w';
        }
        else if(channeltype=='MonthAgo'){
            temp_endpoint2+='&rangeTime=1M';
        }
        else if(channeltype=='YearAgo'){
            temp_endpoint2+='&rangeTime=1y';
        }
        if(sessionId!=null&&sessionId!=''){
            strEndPoint =lithium_url+'/restapi/vc/search/messages?restapi.session_key='+sessionId+'&restapi.response_format=json&restapi.response_style=view&restapi.format_detail=full_list_element&q='+operation+temp_endpoint+temp_endpoint2+'&page_size='+pageSize+'&page='+currentPage;
        }else{strEndPoint =lithium_url+'/restapi/vc/search/messages?restapi.response_format=json&restapi.response_style=view&restapi.format_detail=full_list_element&q='+operation+temp_endpoint+temp_endpoint2+'&page_size='+pageSize+'&page='+currentPage;}
        temp_endpoint='';
        temp_endpoint2='';
        req.setEndpoint(strEndPoint);
        req.setHeader('content-type','application/json');
        req.setMethod('GET');
        if(!Test.isrunningTest()){
            try{ res = h.send(req);}catch(Exception e){System.debug('Exception encountered during messages callout'+e);}
        }else {
            staticresource testStatic = [select id, body from staticresource where name = 'TestBody' limit 1];
            res = new HTTPResponse();
            string tempStr = testStatic.body.tostring();
            res.setBody(tempStr);
        }
        jsonString = res.getBody();
        jsonString = jsonString.replace('"$":', '"a":');
        jsonString = jsonString.replaceAll('<[^>]*>', '');

        getResultHelper(jsonString);
        return null;
    }
    
    public void getResultHelper(String jsonData){
        
        HttpRequest req = new HttpRequest();
        HTTPResponse res = new HTTPResponse();
        Http h = new Http();
        String board_var;
        Lithium_Parser lp=new Lithium_Parser();
        lp = (Lithium_Parser)Lithium_Parser.parse(jsonData);
        Lithium_Parser.cls_response lvl1 = lp.response;
        if(lvl1.status!=null && lvl1.status.equalsIgnoreCase('success')){
            Lithium_Parser.cls_messages val = lp.response.messages;
            if(val!=null){
                for(Lithium_Parser.cls_message clsmsgs : val.message) {             
                    LData_WrapperMain temp1 = new LData_WrapperMain();
                    Lithium_Parser.cls_root val3=clsmsgs.root;
                    temp1.art_endpoint=val3.view_href;
                    Lithium_Parser.cls_subject sub=clsmsgs.subject;
                    temp1.title = sub.a;
                    Lithium_Parser.cls_post_time pst=clsmsgs.post_time;
                    temp1.created_date=pst.view_date;
                    Lithium_Parser.cls_author log=clsmsgs.author;
                    temp1.view_author=log.view_href;
                    Lithium_Parser.cls_login log1=log.login;
                    temp1.author=log1.a;
                    if(clsmsgs.body!=null){
                        Lithium_Parser.cls_body content=clsmsgs.body;
                        temp1.description = content.a;
                    }
                    else if(clsmsgs.seo_description!=null){
                        Lithium_Parser.cls_seo_description seo_content = clsmsgs.seo_description;
                        temp1.description=seo_content.a;}
                    else{temp1.description='';}
                    
                    Lithium_Parser.cls_board brd=clsmsgs.board;
                    temp1.board_endpoint=brd.view_href;
                    board_var=brd.href.replace('/boards/id/','');
                    board_var=board_var.replace('/blogs/id/','');
                    if(sessionId!=null&&sessionId!=''){    
                        strEndPoint =lithium_url+'/restapi/vc/boards/id/'+board_var+'?restapi.session_key='+sessionId+'&restapi.response_format=json';
                    }else{strEndPoint =lithium_url+'/restapi/vc/boards/id/'+board_var+'?restapi.response_format=json';}
                    req.setEndpoint(strEndPoint );
                    req.setHeader('content-type','application/json');
                    req.setMethod('GET');
                    if(!Test.isrunningTest()){
                        try{ res = h.send(req);}catch(Exception e){System.debug('Exception during board callout'+e);}    }
                    else {
                        staticresource testStatic = [select id, body from staticresource where name = 'SecondCall' limit 1];
                        res = new HTTPResponse();
                        string tempStr = testStatic.body.tostring();
                        res.setBody(tempStr);
                    }        
                    jsonString=res.getBody();
                    jsonString = jsonString.replace('"$":', '"a":');
                    Board_Parser bp=new Board_Parser();
                    bp = (Board_Parser)Board_Parser.parse(jsonString);
                    Board_Parser.cls_board bd = bp.response.board;
                    Board_Parser.cls_interaction_style bd1 = bd.interaction_style;
                    categ_operation = bd1.a;
                    if(categ_operation=='tkb'){categ_operation=categ_operation.replace('tkb','Knowledge Base');}
                    else if(categ_operation=='Board'){categ_operation=categ_operation.replace('board','Forums');}
                    temp1.category = categ_operation;
                    Board_Parser.cls_title bd2 = bd.title;
                    temp1.board_id = bd2.a;
                    ldata.add(temp1);
                }
            }
        }else{
            System.debug('Invalid Response');
        }
    }
    
    public void gotoPrevious(){
        currentPage = currentPage - 1;
        getResult();
    }
    public void gotoNext(){
        currentPage = currentPage + 1;
        getResult();
        if(ldata==null || ldata.isEmpty()){
            showprev=true;
        }    
    }
    //code for salesforce cases search
    public void sf_cases(){
        totalRecs = 0;
        DateTime LastDay    = System.now().addDays(-1);
        DateTime LastWeek   = System.now().addDays(-7);
        DateTime LastMonth  = System.now().addMonths(-1);
        DateTime LastYear   = System.now().addYears(-1);            
        String LastDayStr   = System.now().addDays(-1).format('MM-dd-yyyy');
        String LastWeekStr  = System.now().addDays(-7).format('MM-dd-yyyy');
        String LastMonthStr = System.now().addMonths(-1).format('MM-dd-yyyy');
        String LastYearStr  = System.now().addYears(-1).format('MM-dd-yyyy');
        //Date filter Ends...
        
        //Date string to be used in Callout URL
        String dateString;
        dtime = System.now().addYears(-25);
        if(channelType =='DayAgo') {
            dateString = LastDayStr+'T11:00:00.000+0000)';
            dtime = LastDay;
        }else if(channelType =='WeekAgo') {
            dateString = LastWeekStr+'T11:00:00.000+0000)';
            dtime = LastWeek;
        }else if(channelType =='MonthAgo') {
            dateString = LastMonthStr+'T11:00:00.000+0000)';
            dtime = LastMonth;
        }else if(channelType =='YearAgo') {
            dateString = LastYearStr+'T11:00:00.000+0000)';
            dtime= LastYear;
        }
        search(dtime);  
    }
    //method implementing the salesforce case result search
    public void search(DateTime dtime){
        caseSearchResults = new List<Case>();
        String tempInput;  
        if(searchText!=null&&searchText.trim()!=''){
            operation = searchtext;
            operation = operation.trim();
            operation = operation.replaceAll('\\s+',' ');
            searchtext = operation;
        }else{return;}
        tempInput = '%'+searchText+'%';
        totalRecs = [select count() from case where Subject like :tempInput AND createddate > :dtime AND Id !=: caseId limit 49000];    
        caseSearchResults = Database.query('SELECT id, CaseNumber, Subject, Description, LastModifiedDate FROM Case WHERE (Subject LIKE :tempInput AND Createddate > :dtime AND Id !=: caseId) Limit :blockSize OFFSET :index');  
        
        if(totalRecs>3){
            showNextCase=true;
        }else{showNextCase=false;}
    }
    
    public void previous(){
        index = index - blockSize;
        sf_cases();
        showPrevCase = prev();
        showNextCase = nxt();
    }
    
    public void next(){
        index = index + blockSize;
        sf_cases();
        showPrevCase = prev();
        showNextCase = nxt();
    }
    
    public boolean prev(){
        if(index == 0)
        {return false;}
        else{return true;}
    }
    
    public boolean nxt(){
        if((index + blockSize) >= totalRecs)
        {return false;}
        else{return true;}
    }  
    
}