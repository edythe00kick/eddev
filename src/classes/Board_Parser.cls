/*
Parser Class for parsing boards endpoint response
Developed By:- Grazitti Interactive
*/
public class Board_Parser{
  public cls_response response;
  public class cls_response {
    public String status;  //success
    public cls_board board;
  }
  public class cls_board {
    public String type;  //board
    public String href;  ///boards/id/setup-configuration
    public cls_interaction_style interaction_style;
    public cls_blog blog;
    public cls_user_created user_created;
    public cls_id id;
    public cls_owner owner;
    public cls_short_title short_title;
    public cls_title title;
    public cls_description description;
  }
  public class cls_interaction_style {
    public String type;  //string
    public String a;  //board
  }
  class cls_blog {
    public String type;  //boolean
    public boolean a;
  }
  class cls_user_created {
    public String type;  //boolean
    public boolean a;
  }
  class cls_id {
    public String type;  //string
    public String a;  //setup-configuration
  }
  class cls_owner {
    public String type;  //user
    
    public String a;
  }
  class cls_short_title {
    public String type;  //string
    public String a;  //Setup & Configuration
  }
  public class cls_title {
    public String type;  //string
    public String a;  //Setup & Configuration
  }
  class cls_description {
    public String type;  //string
    public String a;  //Download, install, configure, deploy, and conquer!
  }
  public static Board_Parser parse(String json){
    return (Board_Parser) System.JSON.deserialize(json, Board_Parser.class);
  }
}