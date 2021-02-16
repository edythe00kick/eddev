/* Author: Sharma Nemani | W-012584 & W-012585
 * Date: 07/16/2019
 * Description: This class prevents the Opportunity Trigger from falling into recursion.
*/
public class RunOnceTrigger {
    public static Boolean runOnce = true;
    public static void setRunOnceFalse(){
        runOnce = false;
    }
}