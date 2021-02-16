/*
 * Class Name - ScheduleStampValue.
 * Test Class Name - ScheduleStampValueTest.
 * 
 * %W% %E% Grazitti Team
 * This schedule class execute the "StampValueFromLeadContact" batch class.
 */

/**
 * #W-009852
 * UTM Source
 * 
 * This class execute the "StampValueFromLeadContact" batch class.
 * 
 * @author Hemendra Singh Rajawat
 * @version 1.0 July 06, 2018
 */

public class ScheduleStampValue implements Schedulable {
    public void execute(SchedulableContext ctx) {
        StampValueFromLeadContact svflc = new StampValueFromLeadContact();
        Database.executeBatch(svflc);
    }
}