public with sharing class TaskRedirectController {

    public TaskRedirectController(ApexPages.StandardController controller) {
    
   
    }
     public PageReference taskpageRedirect(){
    //PageReference pageRef = new PageReference('https://' + System.Label.instance +  '.salesforce.com/'+ApexPages.currentPage().getParameters().get('id')); 
    PageReference pageRef = new PageReference('/'+ApexPages.currentPage().getParameters().get('id')); 
    pageRef.setRedirect(true);
    return pageRef;
    }

}