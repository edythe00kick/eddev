/* Author: Sharma Nemani | W-010390 | Case: 00293335 
 * Date: 09/11/2019
 * Description: This Class is used in 'CustomCaseCloseComponent.cmp'
 */
public class CaseCategory {
    @AuraEnabled
	public String ccName;
    @AuraEnabled
    public List<String> caseReason;
    public CaseCategory(String ccName,List<String> caseReason){
        this.ccName = ccName;
        this.caseReason = caseReason;
    }
}