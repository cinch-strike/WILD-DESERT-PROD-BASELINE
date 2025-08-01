@isTest(SeeAllData = true)
public class TestDevRecordReminder {
    static testMethod void testMe(){
    	DevRecordReminder reminder = new DevRecordReminder();
    	reminder.testSendMail();
    }
}