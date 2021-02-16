public with sharing class FetchCaseCommentsController{
        public list <CaseComment> caseCommentlist {get;set;}
        public List<WrapperClass> comms {get;set;}
        public String CaseId {get; set;}
        
        public FetchCaseCommentsController(){
           // caseCommentlist = new List<CaseComment>();
           // comms = new List<WrapperClass>();
           // caseId = ApexPages.currentPage().getParameters().get('id');
           // getComment();
           // system.debug('CaseId=======================>' +CaseId );
           // caseCommentlist= [select id, commentbody,creatorname,parentid,isdeleted from CaseComment where parentid = :CaseId AND isdeleted = FALSE ORDER BY createddate Desc ];
           // system.debug('caseCommentlist=======================>' +caseCommentlist );
        }   
        
     /*commented by Paramvir 12June,2015 for displaying comments correctly
       public List<CaseComment> getComments() {
        caseCommentlist = new List<CaseComment>();
        caseCommentlist= [select id,CreatedBy.name,lastmodifieddate,commentbody,creatorname,parentid,isdeleted from CaseComment where parentid = :CaseId AND isdeleted = FALSE ORDER BY createddate Desc LIMIT 10];
        
        return caseCommentlist;
       }*/
       
       public List<WrapperClass> getComment() {
        caseCommentlist = new List<CaseComment>();
        comms = new List<WrapperClass>();
        caseCommentlist= [select id,CreatedBy.name,lastmodifieddate,commentbody,creatorname,parentid,isdeleted from CaseComment where parentid = :CaseId AND isdeleted = FALSE ORDER BY createddate Desc LIMIT 10];
        for(Casecomment c : casecommentList){
            String body = c.commentbody.replace('\r\n','<br>');
            body = body.replace('\n','<br>');
            comms.add(new wrapperClass(body,c.createdby.name,c.lastmodifieddate,c.parentid));
        }
        return comms;
       }
       
       public class WrapperClass{
           public String commentBody {get;set;}
           public String createdbyName {get;set;}
           public DateTime lastmodifieddate{get;set;}
           public Id ParentId{get;set;}
           public wrapperclass(String commentBody,String createdbyName,DateTime lastmodifieddate,Id ParentId){
               this.commentBody = commentBody;
               this.createdbyName = createdbyName;
               this.lastmodifieddate= lastmodifieddate;
               this.ParentId= ParentId;
               
           }
       }
}