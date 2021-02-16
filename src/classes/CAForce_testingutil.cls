public with sharing class CAForce_testingutil {

  public CAForce_testingutil(){
    
  }

  public void addData(){
  
    Customer_Advocacy__c ca = new Customer_Advocacy__c();   
    ca.Willing_to_be_a_Prospect_Reference__c = 'testing';    
    ca.Products__c = 'test';   
    insert ca;
  }

}