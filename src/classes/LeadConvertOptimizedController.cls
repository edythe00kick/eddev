/*
 * Class Name - LeadConvertOptimizedController.
 * Test Class Name -LeadConvertOptimizedControllerTest.
 * 
 * %W% %E% Grazitti Team
 * This class is the controller of "LeadConvertOptimized" VF Page.
 */

/**
 * This class contains different methods to handle the page functionality.
 * 
 * @author Grazitti Team
 * @version 1.0 March 15, 2018
 */
public class LeadConvertOptimizedController {
    public Lead lead {get;set;}
    public Lead dummyLead {get;set;}
    public Contact dummyContact {get;set;}
    public Opportunity dummyOpp {get;set;}
    public Account dummyAccount {get;set;} 
    public String selectedAccount {get;set;}
    public String selectedContact {get;set;}
    public String oppName {get;set;}
    public String OppType {get;set;}
    public Boolean createOpp {get;set;}
    public Boolean hascontact {get;set;}
    public Boolean sendnotification {get;set;}
    public List<SelectOption> accountList {get;set;}
    public List<SelectOption> ContactList {get;set;}
    public String existing = 'Attach to existing: ';
    public Boolean isPartner {get;set;}
    
    /**
     * This is the constructor of "LeadConvertOptimizedController" class.
     */
    public LeadConvertOptimizedController() {
        createopp = false;
        isPartner = false;
        sendnotification = false;
        lead = [SELECT Id, Name, FirstName, LastName, OwnerId, Company, Email 
                FROM Lead 
                WHERE Id = :ApexPages.currentPage().getParameters().get('id')];

        hascontact = false;
        dummyContact = new Contact();
        dummyOpp = new Opportunity();
        dummyAccount = new Account(ownerId = lead.OwnerId);
        selectedAccount = 'NONE';
        selectedContact = 'NONE';
        dummyLead = new Lead(Status = leadStatus());
        AccountForLead();
    }

    /**
     * Display the list for class of business to be assign to opportunity
     * 
     * @return the list of SelectOption - 'oppCoblist' consist of available 
     * values for class of business
     */
    public List<SelectOption> getClassOfBusiness() {
        List<SelectOption> oppCoblist = new List<SelectOption>();
        oppCoblist.add(new SelectOption('NB', 'NB'));
        oppCoblist.add(new SelectOption('NBEC', 'NBEC'));

        return oppCoblist;
    }

    /**
     * Displays the available status for the converted leads from  LeadStatus 
     * 
     * @return the list of SelectOption - 'leadStatusOption' consist of 
     * available status
     */
    public String leadStatus() {
        LeadStatus ls = [SELECT MasterLabel 
                         FROM LeadStatus 
                         WHERE IsConverted = true 
                         ORDER BY SortOrder];

        return ls.MasterLabel;
    }

    /**
     * Get the list of all the similar account matched with lead company and 
     * put them in accountList
     */
    public void AccountForLead() {
        String company = '%' + lead.Company + '%';
        accountList = new List<SelectOption>();
        SearchHelper Searchhelper = new SearchHelper();
        List<Account> accountFound = Searchhelper.SearchAccount(company);

        accountList.add(new SelectOption('NONE', '-None-'));
        accountList.add(new SelectOption('NEW',
                                         'Create New Account: '+lead.Company));

        for (Account a: accountFound) {
            accountList.add(new SelectOption(a.Id, existing + a.Name));
        }
        oppName = lead.Company + '-';
    }

    /**
     * A function to fetch the detail of selected account through lookup and
     * add it to accountList.
     * 
     */
    public void AccountLookedUp() {
        Account a = [SELECT Id, Name 
                     FROM Account 
                     WHERE Id = :dummyContact.AccountId];

        if (a != null) {
            accountList.add(new SelectOption(a.Id, existing + a.Name));
            selectedAccount = a.Id;
            oppName = a.Name + '-';
            hascontact = false;
            populateContacts();
        }
    }

    /*
     * A function to fetch the detail of selected contact through lookup and
     * add it to contactlist.
     * Functionality is commented for future use
     */
    /*public PageReference ContactLookedUp() {
        Contact c = [SELECT Id, Name 
                     FROM Contact 
                     WHERE Id = :dummyOpp.Primary_Contact__c];

        if (c != null) {
            ContactList.add(new SelectOption(c.Id, existing + c.Name));
        }
        return null;
    }*/

    /**
     * A Function to updated the fields on vfpage according to selected account.
     */
    public void selectedAccountChange() {
        hascontact = false;
        if (selectedAccount == 'NEW' || selectedAccount == 'NONE') {
            oppName = lead.Company + '-';
        } else {
            populateContacts();
        }
    }
    /**
   * Shows up the list of availabe contacts linked with selected account 
   */
    public void populateContacts() {

        List<Contact> Relatedcontact = [SELECT Id, Name, Account.Name 
                                        FROM Contact 
                                        WHERE (AccountId = :selectedAccount 
                                               AND (Name = :Lead.Name OR 
                                                    Email = :lead.email))];
                                          
        if (!Relatedcontact.isEmpty()) {
            oppName = Relatedcontact[0].account.name + '-';
            hascontact = true;
            ContactList = new List < SelectOption > ();
            ContactList.add(new SelectOption('NONE', '-None-'));
            ContactList.add(new SelectOption('NEW', 'Create new contact - ' + 
                            Relatedcontact[0].account.name));
            for (Contact c: Relatedcontact) {
                ContactList.add(new SelectOption(c.Id, existing + c.Name));
            }
        }
    }

    /**
   *  A function to convert the lead 
   * 
   * if not opted for opportunity creation, it 
   * @returns to the contact created from lead conversion
   * else
   * @returns to the Leadconvertredirectpage 
   */
    public PageReference ConvertLead() {
        try {
            User usr = [Select id, profile.name from user
                        where id =:userinfo.getUserId()];

            String profileName = usr.Profile.name;

            if (LeadConvertOptimizedHelper.Validate(selectedAccount, 
                                                    dummyAccount.ownerid,
                                                    oppName, createOpp, 
                                                    OppType, hascontact, 
                                                    selectedContact,
                                                    dummyOpp.CloseDate,
                                                    dummyLead.Lead_Close_Reason__c, 
                                                    isPartner, dummyOpp.Forecast_Amount__c, dummyOpp.Term_in_Months__c
                                                    //dummyOpp.Best_Case_Term__c, dummyOpp.Upside_Forecast_Amount_ACV__c Sergio Flores 02/21/2020 W-004548
                                                    )) {

                return null;
            } else { 
                String mqlValue;
                mqlValue 
                    = ApexPages.currentPage().getParameters().get('AcceptMQL');

                try {
                    LeadConvertOptimizedHelper.UpdateMqlLeadStatus(Lead.id,
                                                                    mqlValue);
                } catch (Exception e) {
                    ApexPages.Message msg =
                        new ApexPages.Message(Apexpages.Severity.ERROR,
                                              e.getMessage());
                    ApexPages.addMessage(msg);
                }

                Database.LeadConvert leadconvert = new Database.LeadConvert();
                leadconvert.LeadId = lead.id;
                leadconvert.ConvertedStatus = dummyLead.Status;
                if (sendnotification) {
                    leadconvert.sendnotificationemail = true;
                }
                if (selectedAccount != 'NEW') {
                    leadconvert.accountId = selectedAccount;
                }
                if (selectedContact != 'NEW' && selectedContact != 'NONE') {
                    leadconvert.contactId = selectedContact;
                }
                if (createOpp) {
                    leadconvert.OpportunityName = oppName;
                } else {
                    leadconvert.DoNotCreateOpportunity = true;
                }

                leadConvert.setOwnerId(
                    LeadConvertOptimizedHelper.SetLeadOwner(profileName,
                                                            dummyAccount.OwnerId));

                leadconvert.OverWriteLeadSource = true;
                Lead ld = new Lead(Id = lead.Id);
                ld.Lead_Close_Reason__c = dummyLead.Lead_Close_Reason__c;
                try {
                    update ld;
                } catch (Exception ex) {
                    ApexPages.Message m 
                        = new ApexPages.Message(Apexpages.Severity.ERROR, ex.getMessage());
                    
                    ApexPages.addMessage(m);
                    return null;
                }
                Database.LeadConvertResult leadConvertResult 
                    = Database.convertLead(leadConvert);

                if (leadConvertResult.success) {
                    Lead Convertedlead = [SELECT Id, ConvertedAccountId, 
                                          ConvertedOpportunityId,
                                          ConvertedContactId, 
                                          Lead_Partner_Role__c, RecordTypeId, 
                                          Partner_Representative__c,
                                          PartnerAccountID__c 
                                          FROM Lead 
                                          WHERE Id = :lead.id];

                    String ConvertedOpp = Convertedlead.ConvertedOpportunityId;
                    String ConvertedContact = Convertedlead.ConvertedContactId;
                    Date closeDate = dummyOpp.CloseDate;
                    Integer termInMonths = (Integer)dummyOpp.Term_in_Months__c;
                    if(termInMonths == null)
                    {
                        termInMonths = 12;
                    }

                    //Sergio Flores
                    //Date: 06/19/2019
                    //W-012297
                    /*Sergio Flores 02/21/2020 W-004548
                    Integer bestTerm = (Integer)dummyOpp.Best_Case_Term__c;
                    if(bestTerm == null)
                    {
                        bestTerm = 12;
                    }*/

                    decimal forecastAmount = dummyOpp.Forecast_Amount__c;
                    //decimal upsideForecastAmount = dummyOpp.Upside_Forecast_Amount_ACV__c; Sergio Flores 02/21/2020 W-004548
                    LeadConvertOptimizedHelper.UpdateOpportunityType(ConvertedOpp,
                                                                     ConvertedContact,
                                                                     OppType, 
                                                                     profileName,
                                                                     closeDate,
                                                                     termInMonths, //Sergio Flores W-011118
                                                                     forecastAmount//Sergio Flores W-012297
                                                                     //bestTerm, Sergio Flores 02/21/2020 W-004548
                                                                     //upsideForecastAmount //Sergio Flores W-013410   Sergio Flores 02/21/2020 W-004548
                                                                     );

                    LeadConvertOptimizedHelper.UpdateContactStatus(ConvertedContact, 
                                                                    createOpp);

                    if (!createOpp) {
                        PageReference pageRef = 
                            new PageReference('/' + Convertedlead.ConvertedContactId);

                        pageRef.setRedirect(true);
                        return pageRef;
                    } else {
                        PageReference pagRef;
                        if(isPartner){
                            
                            pagRef = new PageReference('/apex/Attach_Partner_Page?oppId='+ConvertedOpp);
                        } else {
                            pagRef = new PageReference('/'+ConvertedOpp);
                        }
                        /* In Progress 
                        PageReference pagRef 
                            = new PageReference('/apex/Leadconvertredirectpage');

                        pagRef.getParameters().put('leadid', Convertedlead.id);
                        pagRef.getParameters().
                        put('accid', Convertedlead.ConvertedAccountId);
                        pagRef.getParameters().
                        put('oppid', Convertedlead.ConvertedOpportunityId);
                        pagRef.getParameters().
                        put('rectype', Convertedlead.RecordTypeId);
                        pagRef.getParameters().
                        put('contactid', Convertedlead.ConvertedContactId);
                        pagRef.getParameters().
                        put('OppCreation', 'true');
                        pagRef.getParameters().
                        put('PartnerAccountId', Convertedlead.PartnerAccountID__c);
                        pagRef.getParameters().
                        put('PartnerRep', Convertedlead.Partner_Representative__c);
                        pagRef.getParameters().
                        put('partnerRole', Convertedlead.Lead_Partner_Role__c);
                        */
                        pagRef.setRedirect(true);
                        return pagRef;
                    }
                }
                return null;
            }
        } catch (Exception e) {
            ApexPages.Message msg 
                = new ApexPages.Message(Apexpages.Severity.ERROR, e.getMessage());
            
            ApexPages.addMessage(msg);
            return null;
        } 
    }

    /**
     * function to cancel the lead conversion process
     * 
     * @return the address of lead from which the process started.
     * 
     */
    public PageReference Cancel() {
        PageReference pg = new PageReference('/' + lead.id);
        return pg;
    }
    /**
     * Fetched records according to  user permissions   
     * 
     */
  public with sharing class SearchHelper {
        /**
         * Fetched accounts according to  user permissions 
         * 
         * @param Name used as filter to search accounts.  
         * @return the list of account matching with Name.
         */
        public  List<Account> SearchAccount(String Name){
          return  [SELECT Id, Name, Customer_Since_Date__c, Type 
                   FROM Account 
                   WHERE Name Like: Name limit 800];
        }
    }
}