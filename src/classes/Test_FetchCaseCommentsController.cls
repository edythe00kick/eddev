@isTest
public class Test_FetchCaseCommentsController{
    static testMethod void TestComments() {
       Test.startTest() ;
           Case c = new Case();
           c.status = 'Submitted';
           c.recordtypeid=System.Label.SalesOpsCaseRecordTypeid;
           insert c;
           CaseComment cm = new CaseComment();
           cm.CommentBody = 'test';
           cm.ParentId =  c.Id;    
           insert cm;    
           
           FetchCaseCommentsController fc= new FetchCaseCommentsController();
           fc.CaseId = c.id;
           fc.getComment();
       Test.stopTest();
    }
 }