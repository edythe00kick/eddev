/*
Parser Class for parsing lithium's messeges response
Developed By:- Grazitti Interactive
*/
public class Lithium_Parser{
  public cls_response response;
  public class cls_response {
    public String status;  //success
    public cls_messages messages;
  }
  public class cls_messages {
    public cls_message[] message;
  }
  public class cls_message {
    public String type;  //message
    public String href;  ///messages/id/83
    public String view_href;
    public cls_message_rating message_rating;
    public cls_last_edit_author last_edit_author;
    public cls_labels labels;
    public cls_seo_title seo_title;
    public cls_seo_description seo_description;
    public cls_kudos kudos;
    public cls_canonical_url canonical_url;
    public cls_board_id board_id;
    public cls_root root;
    public cls_post_time post_time;
    public cls_last_edit_time last_edit_time;
    public cls_teaser teaser;
    public cls_views views;
    public cls_parent parent;
    public cls_body body;
    public cls_thread thread;
    public cls_board board;
    public cls_subject subject;
    public cls_id id;
    public cls_read_only read_only;
    public cls_deleted deleted;
    public cls_author author;
  }
  class cls_message_rating {
    public String type;  //float
    public Double a;  //0
  }
  class cls_last_edit_author {
    public String type;  //user
    public String href;  ///users/id/11
    public String view_href;
    public cls_login login;
  }
  public class cls_login {
    public String type;  //string
    public String a;  //Mudit_Garg
  }
  class cls_labels {
    public cls_label[] label;
  }
  class cls_label {
    public String type;  //label
    public String href;  ///labels/id/8
    public cls_id id;
    public cls_text text;
  }
  class cls_id {
    public String type;  //int
    public Integer a;  //83
  }
  class cls_text {
    public String type;  //string
    public String a;  //API
  }
  class cls_seo_title {
    public String type;  //string
    
    public String a;
  }
  public class cls_seo_description {
    public String type;  //string
    
    public String a;
  }
  class cls_kudos {
    public cls_count count;
  }
  class cls_count {
    public String type;  //int
    public Integer a;  //15
  }
  class cls_canonical_url {
    public String type;  //string
    
    public String a;
  }
  class cls_board_id {
    public String type;  //int
    public Integer a;  //27
  }
  public class cls_root {
    public String type;  //message
    public String href;  ///messages/id/83
    public String view_href;  //https://communitystage.alteryx.com/t5/Setup-Configuration/Test-automatic-escalation-before-call-with-alteryx-community/m-p/83#M27
  }
  public class cls_post_time {
    public String type;  //date_time
    public String view_date;  //01-05-2016
    public String view_time;  //09:17 PM
    public String view_friendly_date;  //
    public DateTime a;  //2016-01-05T15:47:28+00:00
  }
  class cls_last_edit_time {
    public String type;  //date_time
    public String view_date;  //01-05-2016
    public String view_time;  //09:17 PM
    public String view_friendly_date;  //
    public String a;  //2016-01-05T15:47:28+00:00
  }
  class cls_teaser {
    public String type;  //string
    public String a;  //
  }
  class cls_views {
    public cls_count count;
  }
  class cls_parent {
    public String type;  //message
    
    public String a;
  }
  public class cls_body {
    public String type;  //string
    public String a;  //<P>Testing</P>
  }
  class cls_thread {
    public String type;  //thread
    public String href;  ///threads/id/83
    public String view_href;  //https://communitystage.alteryx.com/t5/Setup-Configuration/Test-automatic-escalation-before-call-with-alteryx-community/td-p/83
  }
  public class cls_board {
    public String type;  //board
    public String href;  ///boards/id/setup-configuration
    public String view_href;  //https://communitystage.alteryx.com/t5/Setup-Configuration/bd-p/setup-configuration
  }
  public class cls_subject {
    public String type;  //string
    public String a;  //Test automatic escalation before call with alteryx community
  }
  class cls_read_only {
    public String type;  //boolean
    public boolean a;
  }
  class cls_deleted {
    public String type;  //boolean
    public boolean a;
  }
  public class cls_author {
    public String type;  //user
    public String href;  ///users/id/11
    public String view_href;  //https://communitystage.alteryx.com/t5/user/viewprofilepage/user-id/11
    public cls_login login;
  }
  public static Lithium_Parser parse(String json){
    return (Lithium_Parser) System.JSON.deserialize(json, Lithium_Parser.class);
  }

}