trigger copyEmailToComments on EmailMessage (after insert) {
    // A map of case id and latest comment from email sent to the case
    Map<Id, String> case_id_to_comment = new Map<Id, String>();
    List<CaseComment> comments_to_insert = new List<CaseComment>();
    
    for(EmailMessage mail : Trigger.new) {
        String parent_id = mail.ParentId == null ? '' : mail.ParentId;
        
        
        System.debug('cetc> parent id:' + parent_id);
        System.debug('cetc> incoming:' + mail.Incoming);
        
        // Check for email to case
        if(parent_id.contains('500') && mail.Incoming == true) {
            // Help text to separate latest comment from thread
            String comment_help_text = '##-Please reply above this line-##';
            String comment_help_text1 = '> ##-Please reply above this line-##';
            
            System.debug('cetc> mail body in text:' + mail.textBody);
            
            if(mail.textBody != null 
                    && mail.textBody.contains(comment_help_text1)) {
                String body = mail.textBody;
                // Separate latest comment from email thread
                List<String> splited_body = body.split(comment_help_text1);
                
                System.debug('cetc> size of splited_body:' 
                    + splited_body.size());
                System.debug('cetc> splited email body:' + splited_body);
                
                if(splited_body.size() < 2) { continue; }
                // Store latest comment corresponding to the case
                case_id_to_comment.put(mail.ParentId, splited_body.get(0));
            }
            
            Else if(mail.textBody != null 
                    && mail.textBody.contains(comment_help_text)) {
                String body = mail.textBody;
                // Separate latest comment from email thread
                List<String> splited_body = body.split(comment_help_text);
                
                System.debug('cetc> size of splited_body:' 
                    + splited_body.size());
                System.debug('cetc> splited email body:' + splited_body);
                
                if(splited_body.size() < 2) { continue; }
                // Store latest comment corresponding to the case
                case_id_to_comment.put(mail.ParentId, splited_body.get(0));
            }
        }
    }
    
    System.debug('cetc> case id to comment:' + case_id_to_comment);
    
    for(Id case_id : case_id_to_comment.keySet()) {
        CaseComment cm = new CaseComment();
        cm.CommentBody = case_id_to_comment.get(case_id);
        cm.ParentId =  case_id;
        comments_to_insert.add(cm);
    }
    
    System.debug('cetc> comments to insert:' + comments_to_insert);
    
    if(!comments_to_insert.isEmpty()) {
        insert comments_to_insert;
        System.debug('cetc> comments_to_insert >>>' + comments_to_insert);
    }
}