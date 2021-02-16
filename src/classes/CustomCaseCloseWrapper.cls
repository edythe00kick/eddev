/* Author: Sharma Nemani | W-013090 | Case: 00293335 
 * Date: 09/11/2019
 * Description: This Wrapper Class is used in 'CustomCaseCloseComponent.apxc' Class.
 */

public class CustomCaseCloseWrapper {
    @AuraEnabled
    Public List<String> caseStatus ;
    @AuraEnabled
    Public String accName ;
    @AuraEnabled
    Public Boolean make_Close_Comment_Public;
    @AuraEnabled
    Public List<String> caseType;
    @AuraEnabled
    Public List<String> caseProduct;
    @AuraEnabled
    Public List<String> cc;
    @AuraEnabled
    Public List<String> cr;
    @AuraEnabled
    public List<CaseCategory> lstCaseCategory;
    
    @AuraEnabled
    public List<String> lstCaseCaseCurrency;
    
    @AuraEnabled
    public List<String> lstCaseSeverity;
    @AuraEnabled
    public Case cse;
    
    public CustomCaseCloseWrapper(List<String> caseStatus,String accName,Boolean make_Close_Comment_Public,List<String> caseType,List<String> caseProduct,List<String> cc,List<String> cr,List<CaseCategory> lstCaseCategory,List<String> lstCaseCaseCurrency,List<String> lstCaseSeverity,Case cse){
        this.caseStatus = caseStatus;
        this.accName = accName;
        this.make_Close_Comment_Public = make_Close_Comment_Public;
        this.caseType = caseType;
        this.caseProduct = caseProduct;
        this.cc = cc;
        this.cr = cr;
        this.lstCaseCategory = lstCaseCategory;
        this.lstCaseCaseCurrency = lstCaseCaseCurrency;
        this.lstCaseSeverity = lstCaseSeverity;
        this.cse = cse;
    }
    
}