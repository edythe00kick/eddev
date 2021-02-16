public class  CustomPartnerStdController{

    public Opportunity opprtny {get;set;}  
    public List<Partner> prntrs = new List<Partner>();
    public Account myAcc{get;set;}
    public Map<Id,Account> prtnrAccListMap{ get;set;}
    Set<Id> prtnrSet {get;set;}
    
    public CustomPartnerStdController(ApexPages.StandardController controller) {
        this.opprtny = (Opportunity)controller.getRecord(); 
        Opportunity myOpr = [SELECT Id, AccountId,PartnerAccountId from opportunity Where Id =: this.opprtny.Id limit 1];
        prntrs = [SELECT Id, AccountToId, AccountFromID, role, isprimary FROM Partner Where AccountFromId = :myOpr.AccountId AND OpportunityId =: this.opprtny.Id];
        prtnrSet = new Set<Id>();
        if(prntrs.IsEmpty() == false) {            
            for (Partner tmpPartner : prntrs) {
                prtnrSet.Add(tmpPartner.AccountToId);
                myAcc = [SELECT Id, Name from Account Where Id =: tmpPartner.AccountToId limit 1];
                
            }
            prtnrAccListMap  = new Map<Id,Account>([SELECT Id, Name from Account Where Id in : prtnrSet]);
        }        
    }
    
    public List<Partner> getOpportunityPartners() {        
        return prntrs;
    }    
    public pageReference delPartner()
    {
        try {            
            String cid = ApexPages.currentPage().getParameters().get('cid');            
            List<Partner> rejectedPartners = [SELECT Id from Partner Where OpportunityId =: this.opprtny.Id AND Id = :cid];
            if(rejectedPartners.isEmpty() == false){
                delete rejectedPartners;
            } 
        } catch(Exception ex) {
                ApexPages.addMessages(ex);            
                return null;
        }

        string y = ApexPages.currentPage().getURL();
        PageReference acctPage = new PageReference(y);
        acctPage.setRedirect(true);
        return acctPage;                                          
        
    }
    
     @isTest    
    public static void testCustomCntrl() {
    
        Account tstPartnerAccnt = new Account(Name = 'Partner1', Type = 'Partner');
        insert tstPartnerAccnt;
        Account tstAltryxAccnt = new Account(Name = 'Alteryx1', Type = 'Alteryx');
        insert tstAltryxAccnt;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Amount = 10;
        opp.CloseDate = Date.today();
        opp.Probability = 10;
        opp.StageName = System.label.StageName_B;
        opp.AccountId = tstAltryxAccnt.Id;
        insert opp;
        
        Partner newPartner = new Partner();
        newPartner.isPrimary = true;
        newPartner.OpportunityId = opp.Id;
        newPartner.AccountToId = tstPartnerAccnt.Id ;
        //newPartner.AccountFromId = tstAltryxAccnt.Id ;
        insert newPartner;
        

        PageReference pageRef = Page.CustomPartnerListPage;        
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('oppId',opp.Id);         
        ApexPages.currentPage().getParameters().put('id',opp.Id);         
        ApexPages.currentPage().getParameters().put('cid',newPartner.Id);         

        AttachPartnerController testCntrlr = new AttachPartnerController();
 
        // create the controller instance  

        CustomPartnerStdController  thec = new CustomPartnerStdController(new ApexPages.StandardController(opp));
        thec.getOpportunityPartners();
        thec.delPartner();

             
    
    
    }

    
    
}