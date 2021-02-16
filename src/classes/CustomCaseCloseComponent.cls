/* Author: Sharma Nemani | W-013090 | Case: 00293335 
 * Date: 09/11/2019
 * Description: This Class is used in 'CustomCaseCloseComponent.cmp'
 */
public class CustomCaseCloseComponent {
    
   @AuraEnabled
    public static Boolean isValidUser(){
        Set<String> lstStr = new Set<String>{'Trevor Swatek','Dan Menke','Jeff Stroud'};
        List<User> lstUser = [select id,Name,profile.name from user where Id =: userInfo.getUserId()];
        Boolean isValidUser = false;
        
        for(user usr : lstUser){
            if(lstStr.contains(usr.Name) || usr.profile.name.equalsIgnoreCase('System Administrator')){
                isValidUser = true;
            }
        }
        return isValidUser;
    }
    
    @AuraEnabled
    public static CustomCaseCloseWrapper caseInfoToShow(String caseId){
        Case cse = [select id,status, Case_Category__c ,Case_Detail__c,Account.Name,AccountId,Make_Close_Comment_Public__c,Case_Escalation_Summary__c,Type,CurrencyIsoCode, Products__c,Severity__c from case where Id=:caseId];  
        
        List<String> lstCaseStatus = returnCasePlTypeValues('Status');
        system.debug('lstCaseStatus :: '+lstCaseStatus);
        List<String> lstCaseProducts = returnCasePlTypeValues('Products__c');
        system.debug('lstCaseProduct s :: '+lstCaseProducts);
        
        List<String> lstCaseType = returnCasePlTypeValues('Type');
        system.debug('lstCaseType :: '+lstCaseType);
        
		List<String> lstCurrencyIsoCode = returnCasePlTypeValues('CurrencyIsoCode');

		List<String> lstCaseSeverity = returnCasePlTypeValues('Severity__c');        
        
        List<CaseCategory> lstCaseCategory = returnCaseCategory();
        
        CustomCaseCloseWrapper ccw = new CustomCaseCloseWrapper(lstCaseStatus,cse.Account.Name,cse.Make_Close_Comment_Public__c,lstCaseType, lstCaseProducts,new List<String>(),new List<String>(),lstCaseCategory,lstCurrencyIsoCode,lstCaseSeverity,cse);
        system.debug('ccw :: '+JSON.serialize(ccw));
        return ccw;
    }
    public static List<String> returnCasePlTypeValues(String FieldApiName){
        List<String> pickListValuesList= new List<String>();
        
        
        SObjectType accountType = Schema.getGlobalDescribe().get('Case');
		Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        
		Schema.DescribeFieldResult fieldResult = mfields.get(FieldApiName).getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getValue());
		}     
		return pickListValuesList;
    }
    public static List<CaseCategory> returnCaseCategory(){
        List<CaseCategory> lst = new List<CaseCategory>();
        Map<String,List<String>> mapCC = new Map<String,List<String>>{
            'Access Management' => new List<String>{'New Associate', 'Partner', 'Data Products', 'Blogger', 'TKB Writer', 'Beta Testing', 'Idea Management', 'Analytics', 'User Groups', 'Departmental', 'Offboarding', 'Case Portal'},
                'Profile changes' => new List<String>{'Recover Deleted Account', 'Recover Terminated Account', 'Change Email Address'},
                    'Content' => new List<String>{'Labels', 'Blogs', 'Knowledge Bases', 'Guest Blog'},
                        'How-To' => new List<String>{'Delete Account', 'Login', 'Register', 'Posting', 'Editing Content', 'Report/Data/Seo/Cookies'},
                            'Bugs & Issues' => new List<String>{'Authentication', 'Performance', 'Forum Threads', 'Error Message', 'Broken URL', 'User Interface', 'Navigation', 'Banners', 'Case Portal', 'Video', 'Images', 'Subscriptions', 'Notifications', 'Attachment', 'Blogs', 'Knowledge Base', 'Labels', 'Rich Text Editor', 'Avatar', 'Spam', 'Badges', 'User Settings', 'Search'},
            'Localization' => new List<String>{'Missing', 'User Settings', 'Browser', 'Translation'},
            'Training' => new List<String>{'Content Error', 'Live Training', 'Interactive Lessons', 'Badge', 'Weekly Challenge', 'Progress'},
            'Certification' => new List<String>{'Badge', 'Schedule', 'General', 'Partner Certification'},
            'Improvement Request' => new List<String>{'New Area', 'Reporting', 'New Feature', 'User Interface', 'Other'},
            'No Response' => new List<String>{'SPAM', 'Duplicate', 'Non-Ticket Items'}
        };
            for(String str : mapCC.keyset()){
                lst.add(new CaseCategory(str,mapCC.get(str)));
            }
		return lst;
    }
    @AuraEnabled
    public static String saveCase(Case cse){
        try{ 
            update cse;
            return 'success';
        }catch(Exception ee){
            return ee.getStackTraceString()+' :: '+ee.getMessage();
        }
    }
    @AuraEnabled
    public static List<Account> searchAcc(String accName){
        String accNameToSearch = '%'+accName+'%';
        List<Account> lstAcc = [select id , name from Account where Name like : accNameToSearch limit 10];
        return lstAcc;
    }
    
    
}