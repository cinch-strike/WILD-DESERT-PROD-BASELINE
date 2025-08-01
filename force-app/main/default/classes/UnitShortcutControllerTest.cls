@IsTest
public with sharing class UnitShortcutControllerTest {
    static testmethod void  testUnitShortcut() {
        Account cust = new Account(Name = 'Test');
        insert cust;
        Site__c st = new Site__c(Name = 'Test', Account__c = cust.Id);
        insert st;
        Unit__c unit = new Unit__c(Name = 'Test', Unit_Type__c = 'Transport', Status__c = 'Active', Site__c = st.Id, Unit_Manager__c = UserInfo.getUserId());
        insert unit;
        system.assertEquals(unit.Id, UnitShortcutController.getUnitId());
        system.assertEquals('Test', UnitShortcutController.getUnitName());
        system.assertEquals('0', UnitShortcutController.getActiveOnshiftEmployees());
    }
}