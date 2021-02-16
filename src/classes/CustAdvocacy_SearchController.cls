public with sharing class CustAdvocacy_SearchController {

  public List <Customer_Advocacy__c> CustAdvocacies {get; set;}
  public Customer_Advocacy__c caSearch                  {get; set;}
  public List <CustAdvocacy_SearchHelper > caHelperList   {get; set;}
  public String tSearch                             {get; set;}
  public list <Selectoption>  productsSelect        {get; set;}
  public String productSelected                     {get; set;}
  public list <Selectoption>  competitorsSelect     {get; set;} 
  public String competitorSelected                  {get; set;}
  public String  listLink                           {get; set;}
  public String  industrySelected                   {get; set;}
   
  public Id shareRecordId {get; set{shareRecordId= value;}}                         
  //Added by Nishtha
  public list <Selectoption>  datasourcesSelect       {get; set;}
  public String datasourceSelected                    {get; set;}
  //public list <Selectoption>  capabilitiesSelect      {get; set;}
  public list <Selectoption>  industriesSelect        {get; set;}
  public list <Selectoption>  ARPRActivitiesSelect    {get; set;}
  public list <Selectoption>  eventsSelect                         {get; set;}
  public list <Selectoption>  CreativeAndWebActivitiesSelect        {get; set;}
  public list <Selectoption>  AdvocacyToolsSelect                  {get; set;}
  public list <Selectoption>  WillingToBeAProspectReferenceSelect        {get; set;}
  
  public String capabilitySelected                    {get; set;}
  public String eventsSelected                         {get; set;}
  
  public String advocacyToolsSelected                 {get; set;}
  public String ARPRActivitiesSelected                {get; set;}
  public String CreativeAndWebActivitiesSelected      {get; set;}
  public string WillingToBeAProspectReferenceSelected   {get; set;}
  //setup in constructor. Used if 'All' is selected
  
  private String allNPSTypes;
  private String allIndustries;
  private String allProducts;
  private String allARPRActivities;
  private String allAdvocacyTools;
  private String creativeAndWebActivities ;
  private string WillingToBeAProspectReferences;
  
  //Added by nishtha
  private String allEvents;
  private String allCreativeAndWebActivities;
   private String allWillingToBeAProspectReferences;
  private String participateInWebinars;
  private String advocacyTools;
  //private String willingToBeAProspectReferences
  
  //search values
  private String NPSType;
  private String industry;
  private String product;
  private String ARPRActivity;  
  private String event;
  private String creativeAndWebActivity;
  private String role;
  //Added by Nishtha
  private String participateInWebinar;
  private String AdvocacyTool;
  private String willingToBeAProspectReference;
  
  public pagereference getShare(){
      FeedItem fitem = new FeedItem();
      system.debug('shareRecordId==>'+shareRecordId);
      fItem.parentId = '0F9E00000000G4nKAE';      
      fItem.body = ' Testing..Pls Ignore ' ;
      fitem.Title = 'Customer Advocacy Record';
      fItem.linkUrl = 'https://' +System.Label.instance+ '.salesforce.com/' +shareRecordId;
      insert fItem;
      return null;
  }
  
  public CustAdvocacy_SearchController (){
    setupListLink();
    caSearch = new Customer_Advocacy__c();
    setProductsFieldInfo();
    setIndustriesFieldInfo();
    //Added by Nishtha
    setEventsFieldInfo();
    setCreativeAndWebActivitiesFieldInfo();
    setAdvocacyToolsFieldInfo();
    setARPRActivitiesFieldInfo();
    
  }

  private void setupListlink(){
    Schema.Describesobjectresult r = Customer_Advocacy__c.sObjectType.getDescribe();
    String keyPref = r.getKeyPrefix();
    listLink = '/'+keyPref+'/o';
  }
  
  private void setProductsFieldInfo(){
    Schema.DescribeFieldResult F = Customer_Advocacy__c.Products__c.getDescribe();
    list <Schema.PicklistEntry> plSchemaList = F.getPicklistValues();
    
    productsSelect = new list<Selectoption>();
    productsSelect.add(new Selectoption('All', 'All'));
    allProducts = '';
    
    for (Schema.Picklistentry ple : plSchemaList){
        productsSelect.add(new Selectoption(ple.getValue(), ple.getValue()));
        allProducts += ple.getValue()+';';
    }
  }

  private void setEventsFieldInfo(){
    Schema.DescribeFieldResult F = Customer_Advocacy__c.Events__c.getDescribe();
    list <Schema.PicklistEntry> plSchemaList = F.getPicklistValues();
    
    eventsSelect = new list<Selectoption>();
    eventsSelect.add(new Selectoption('All', 'All'));
    allEvents = '';
    
    for (Schema.Picklistentry ple : plSchemaList){
      eventsSelect.add(new Selectoption(ple.getValue(), ple.getValue()));
      allEvents += ple.getValue()+';';
    }
  }
  
  
  private void setCreativeAndWebActivitiesFieldInfo(){
      
    Schema.DescribeFieldResult F = Customer_Advocacy__c.Creative_and_Web_Activities__c.getDescribe();
    list <Schema.PicklistEntry> plSchemaList = F.getPicklistValues();
    
    CreativeAndWebActivitiesSelect = new list<Selectoption>();
    CreativeAndWebActivitiesSelect.add(new Selectoption('All', 'All'));
    allCreativeAndWebActivities = '';
    
    for (Schema.Picklistentry ple : plSchemaList){
      CreativeAndWebActivitiesSelect.add(new Selectoption(ple.getValue(), ple.getValue()));
      allCreativeAndWebActivities += ple.getValue()+';';
    }
  }
  
  private void setAdvocacyToolsFieldInfo(){
    Schema.DescribeFieldResult F = Customer_Advocacy__c.Advocacy_Tools__c.getDescribe();
    list <Schema.PicklistEntry> plSchemaList = F.getPicklistValues();
    
    AdvocacyToolsSelect = new list<Selectoption>();
    AdvocacyToolsSelect.add(new Selectoption('All', 'All'));
    allAdvocacyTools = '';
    
    for (Schema.Picklistentry ple : plSchemaList){
      AdvocacyToolsSelect.add(new Selectoption(ple.getValue(), ple.getValue()));
      allAdvocacyTools += ple.getValue()+';';
    }
  }
  
    //Added by Nishtha
    private void setARPRActivitiesFieldInfo(){
        Schema.DescribeFieldResult F = Customer_Advocacy__c.AR_PR_Activities__c.getDescribe();
        list <Schema.PicklistEntry> plSchemaList = F.getPicklistValues();
        
        ARPRActivitiesSelect = new list<Selectoption>();
        ARPRActivitiesSelect.add(new Selectoption('All', 'All'));
        allARPRActivities = '';
        
        for (Schema.Picklistentry ple : plSchemaList){
          ARPRActivitiesSelect.add(new Selectoption(ple.getValue(), ple.getValue()));
          allARPRActivities += ple.getValue()+';';
        }
   }
    
    //Added by Nishtha
    
    private void setIndustriesFieldInfo(){
        Schema.DescribeFieldResult F = Account.Industry.getDescribe();
        list <Schema.PicklistEntry> plSchemaList = F.getPicklistValues();
        
        industriesSelect = new list<Selectoption>();
        industriesSelect.add(new Selectoption('All', 'All'));
        allIndustries = '';
        
        for (Schema.Picklistentry ple : plSchemaList){
          industriesSelect.add(new Selectoption(ple.getValue(), ple.getValue()));
          allIndustries += ple.getValue()+';';
        }
   }
 
 
  
  public void doSearch(){
    setupSearchFields();
    //if(tSearch != null && tSearch.length()>2)    
      //soslSearch();
   // else
      soqlSearch();
    
    caHelperList = new List<CustAdvocacy_SearchHelper>();
    if(CustAdvocacies != null){
        for(Customer_Advocacy__c ca : CustAdvocacies){
        caHelperList.add(new CustAdvocacy_SearchHelper (ca));
      }
    }
  }
  
 /* private void soslSearch(){
    String searchString;
    
    searchString = 'Find :tSearch IN ALL Fields ';
    searchString += 'RETURNING Customer_Advocacy__c ';
    searchString += '(Id, AR_PR_Activities__c, NPS_Type__c, Products__c,Industry__c,Account__r.Name,Account__c, ';
    searchString += 'Role__c, Events__c, Contact__r.Name, Creative_and_Web_Activities__c,Participate_in_Webinars__c,Willing_to_be_a_Prospect_Reference__c, ';
    searchString += 'Advocacy_Tools__c';
    searchString += ' WHERE ';
    if(NPSType == '%')    
        searchString +=  ' (NPS_Type__c Like :NPSType OR NPS_Type__c = null) ';
    else
        searchString +=  ' NPS_Type__c Like :NPSType '; 
   
    //searchString +=  ' AND Status__c Like :status ';   //\'Available\' ';
    
   
    
    if(industry == '%')    
        searchString +=  ' AND (Industry__c Like :industry OR Industry__c = null) ';
    else
        searchString +=  ' AND Industry__c Like :industry';
   
    if(product != null)
     searchString += ' AND Products__c INCLUDES (:product)';
    if(ARPRActivity != null)
     searchString += ' AND AR_PR_Activities__c INCLUDES (:ARPRActivity)';
  
  
    searchString += ') limit 150';
    system.debug('====>searchStringSOSL'+searchString); 
    LIST<LIST<SObject>> soList = search.query(searchString);
   
    CustAdvocacies = soList[0];
     system.debug('====>CustAdvocacies '+CustAdvocacies );
  }*/
  
  private void soqlSearch(){
    
   //  if (capability == 'All')
   //  capability = null;
    String searchString = 'select Id, Name, NPS_Type__c, Products__c,Industry__c,Account__r.Name,Account__c, ';
    searchString += 'Role__c, Events__c, Contact__r.Name, Creative_and_Web_Activities__c,Participate_in_Webinars__c,Willing_to_be_a_Prospect_Reference__c, ';
    searchString += 'Advocacy_Tools__c ';
    searchString += 'from Customer_Advocacy__c';
    searchString += ' WHERE ';
    
    if(NPSType == '%')    
        searchString +=  ' (NPS_Type__c Like :NPSType OR NPS_Type__c = null) ';
    else
        searchString +=  ' NPS_Type__c Like :NPSType ';  
   
       
    if(industry == '%')    
        searchString +=  ' AND (Industry__c Like :industry OR Industry__c = null) ';
    else
        searchString +=  ' AND Industry__c Like :industry';
     if(participateInWebinars == '%')    
        searchString +=  ' AND (Participate_in_Webinars__c Like :participateInWebinars OR Participate_in_Webinars__c = null) ';
    else
        searchString +=  ' AND Participate_in_Webinars__c Like :participateInWebinars';    
    if(willingToBeAProspectReference == '%')    
        searchString +=  ' AND (Willing_to_be_a_Prospect_Reference__c Like :willingToBeAProspectReference OR Willing_to_be_a_Prospect_Reference__c = null) ';
    else
        searchString +=  ' AND Willing_to_be_a_Prospect_Reference__c Like :willingToBeAProspectReference';
        
    if(product != null)
     searchString += ' AND Products__c INCLUDES (:product) ';     
    if(ARPRActivity != null)
     searchString += ' AND AR_PR_Activities__c INCLUDES (:ARPRActivity)';     
    if(advocacyTool != null)
     searchString += ' AND Advocacy_Tools__c INCLUDES (:advocacyTool)';     
    if(creativeAndWebActivities != null)
     searchString += ' AND Creative_and_Web_Activities__c INCLUDES (:creativeAndWebActivities)';    
    if(event != null)
     searchString += ' AND Events__c INCLUDES (:event)';     
     searchString += ' limit 150'; 
    
    system.debug('====>searchStringSOQL'+searchString);
    CustAdvocacies = Database.query(searchString);
    system.debug('====>CustAdvocacies '+CustAdvocacies );
  }
  
  private void setupSearchFields(){
    
    if(caSearch.NPS_Type__c != null){
     NPSType = caSearch.NPS_Type__c;
    }
    else{
     NPSType  = '%';
    }
    
    if(caSearch.Willing_to_be_a_Prospect_Reference__c != null){
      willingToBeAProspectReference = caSearch.Willing_to_be_a_Prospect_Reference__c;
            }
    else{
      willingToBeAProspectReference = '%';           
     } 
    System.debug('Willing_to_be_a_Prospect_Reference__c ====>'+willingToBeAProspectReference ); 
     
   
    if(caSearch.Participate_in_Webinars__c != null){
        participateInWebinars = caSearch.Participate_in_Webinars__c;        
    }
    else{ 
        participateInWebinars = '%';
    }
    System.debug('Participate_in_Webinars__c ====>'+participateInWebinars ); 
     
     
    if(productSelected == 'All'){
        product = null;
    }
    else{    
      product = productSelected+';';
    }
    System.debug('product ====>'+product); 
       
    if(eventsSelected == 'All'){
        event = null;
    }
    else{    
      event = eventsSelected+';';
    } 
    System.debug('event ====>'+event ); 
    
    System.debug('Events__c ====>'+event ); 
        
    if(advocacyToolsSelected =='All'){
      advocacyTool = null;
    }
    else {
      advocacyTool = advocacyToolsSelected +';';
    }
    System.debug('advocacyTool ====>'+advocacyTool );   
      
    //Added by Nishtha  
    if(ARPRActivitiesSelected =='All'){
      ARPRActivity = null;      
      }
    else{       
      ARPRActivity = ARPRActivitiesSelected+';';
    } 
    system.debug('====>ARPRActivitysetSearchField '+ARPRActivity ); 
      
    if(industrySelected == 'All'){
     industry = '%';
     }
    else{
     industry = industrySelected; 
    }
    system.debug('====>Industry__c '+industry);
    
    if(CreativeAndWebActivitiesSelected == 'All'){
     creativeAndWebActivities = null;
     }
    else{
     creativeAndWebActivities = CreativeAndWebActivitiesSelected+';'; 
    }
         
    System.debug('Creative_and_Web_Activities__c ====>'+creativeAndWebActivities ); 
  }
  
  static testmethod void testSearch(){
    
    CAForce_testingutil tu = new CAForce_testingutil();
    tu.addData();
    CustAdvocacy_SearchController  sc = new CustAdvocacy_SearchController();
    sc.productSelected = 'All';
    sc.eventsSelected  = 'All';
    sc.advocacyToolsSelected = 'All';
    sc.ARPRActivitiesSelected = 'All';
    sc.CreativeAndWebActivitiesSelected   = 'All' ;
    sc.WillingToBeAProspectReferenceSelected = 'All';  
    sc.doSearch();
  
    
    sc.productSelected = 'test';
    sc.eventsSelected  = 'test';
    sc.advocacyToolsSelected = 'test';
    sc.ARPRActivitiesSelected = 'test';
    sc.CreativeAndWebActivitiesSelected   = 'test' ;
    sc.WillingToBeAProspectReferenceSelected = 'test'; 
    sc.caSearch.Products__c = 'test';
    sc.caSearch.Events__c = 'test';
    sc.caSearch.Willing_to_be_a_Prospect_Reference__c = 'test';
    sc.caSearch.Participate_in_Webinars__c = 'test';
    sc.caSearch.Creative_and_Web_Activities__c = 'test';
   
    sc.doSearch();
 
  } 
}