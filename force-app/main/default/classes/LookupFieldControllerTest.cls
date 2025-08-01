@isTest
public class LookupFieldControllerTest {
    
    static testMethod void testLookupField() {
        List<String> returnFields = new List<string> {'Name'};
        Account a = new Account(Name = 'Test');
        insert a;
        a = [SELECT Id FROM Account LIMIT 1];
		LookupFieldController.getObjectDetails('Account');
        LookupFieldController.GetRecentRecords('Account', returnFields, 5, null);
        LookupFieldController.SearchRecords('Account', returnFields, returnFields, '', 'Name', 'ASC', 5, 'CreatedDate > 2001-01-01T00:00:01Z');
        LookupFieldController.GetRecord('Account', returnFields, a.Id);
    }
}