global class Alteryxnews implements Messaging.InboundEmailHandler {
      global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
          Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          if(email.subject != NULL && (!email.subject.contains('Undeliverable: Alteryx Daily Industry News'))){
              createNewsItemFeed(email.htmlbody,email.subject); 
          }           
          return result;
      }
      public static void createNewsItemFeed(String emailBody, String subject) {
          News_Item_Feed__c nif = new News_Item_Feed__c(Description__c=emailbody,subject__c=subject);
          insert nif;
      }
  }