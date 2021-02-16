/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class AlteryxForgotPasswordController {
    public String username {get; set;}   
       
    public  AlteryxForgotPasswordController() {}
  
    public PageReference forgotPassword() {
        boolean success = Site.forgotPassword(username);
        PageReference pr = Page.AlteryxForgotPasswordConfirm;
        pr.setRedirect(true);      
        if (success) {        
            return pr;
        }
      
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Recover Password Error: Please check your email Id.'));      
        return null;
    }
    
    @IsTest(SeeAllData=true) 
    public static void testAlteryxForgotPasswordController() {
        // Instantiate a new controller with all parameters in the page
        AlteryxForgotPasswordController controller = new AlteryxForgotPasswordController();
        controller.username = 'test@salesforce.com';           
        System.assertEquals(controller.forgotPassword(),null); 
    }
}