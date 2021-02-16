public with sharing class CustAdvocacy_SearchHelper {
/*
  <apex:inputField value="{!csSearch.name}"/>
        <apex:inputField value="{!csSearch.Story_Type__c}"/>
        <apex:inputField value="{!csSearch.Win_Against__c}"/>
        <apex:inputField required="true" value="{!csSearch.Products__c}"/>
        <apex:inputField value="{!csSearch.Sales_Reference__c}"/>
        <apex:inputField value="{!csSearch.Sharing_Restriction__c}"/>
*/

  public String npsType                      {get; set;}
  public String industry                     {get; set;}
  public String contact                      {get; set;}  
  public String role                         {get; set;} 
  public String account                      {get; set;} 
  public String link                         {get; set;}
  public String title                       {get; set;}
  
  public Id Id{get;set;}
  public CustAdvocacy_SearchHelper (Customer_Advocacy__c ca){
    
    npsType = ca.NPS_Type__c;
    role = ca.Role__c;
    contact = ca.Contact__r.Name;
    industry = ca.Industry__c;   
    account = ca.Account__r.Name;  
    id = ca.id;
    title = ca.Name;
    link = '/'+ca.Id;   
  }
  
  private String getImageUrl(String img){
    integer s = img.indexOf('/');
    img = img.substring(s, img.length());
    integer e = img.indexOf('"');
    return img.substring(0,e);
  }

}