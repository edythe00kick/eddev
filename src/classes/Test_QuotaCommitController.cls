@isTest
public class Test_QuotaCommitController {
   static testMethod void TestQuotaController (){ 
        QuotaCommitController atc = new QuotaCommitController(null);
         atc.getclassOfBusiness();
         atc.closePopup();
         atc.cancelPopup();
         atc.showPopup();
         atc.getstartmonth();
         atc.getendmonth();
         atc.fetchRecords();
         atc.doCancel();

     }
}