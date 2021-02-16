/*
 * Class Name - ScheduleTotalAcvAccount.
 * Test Class Name - ScheduleTotalAcvAccountTest.
 * 
 * %W% %E% Grazitti Team
 * This schedule class execute the "UpdateTotalAcvAccount" batch class.
 */

/**
 * #W-009793
 * Add ACV rollup field to Account Page
 * 
 * This class execute the "UpdateTotalAcvAccount" batch class.
 * 
 * @author Hemendra Singh Rajawat
 * @version 1.0 July 13, 2018
 */

//Name: Chris Salgado Date: 5/13/19 Purpose: Refactored for CPQ
public class ScheduleTotalAcvAccount implements Schedulable {
    public void execute(SchedulableContext ctx) {
        UpdateTotalAcvAccount utaa = new UpdateTotalAcvAccount();
        Database.executeBatch(utaa);
    }
}