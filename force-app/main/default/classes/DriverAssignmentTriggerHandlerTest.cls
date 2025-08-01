@IsTest 

public class DriverAssignmentTriggerHandlerTest {
    static testmethod void testUpdateStartTime(){
        Transport_Job__c tj = new Transport_Job__c(Types__c = 'Maintenance');
        insert tj;
        Account cust = new Account(Name = 'Test');
        insert cust;
        Site__c st = new Site__c(Name = 'Test', Account__c = cust.Id);
        insert st;
        Unit__c unit = new Unit__c(Name = 'Test', Unit_Type__c = 'Transport', Status__c = 'Active', Site__c = st.Id);
        insert unit;
        Position__c pos = new Position__c(Name = 'Test');
        insert pos;
        Employees__c emp = new Employees__c(Name = 'Test', Status__c = 'Active', First_Name__c ='Test', Last_Name__c = 'Test', 
        Assigned_to_Unit__c = unit.Id, PositionLookup__c = pos.Id);
        insert emp;
        Driver_Assignment__c da = new Driver_Assignment__c(Transport_Job__c = tj.Id, Driver__c = emp.Id, Maintenance_Category__c = 'Training');
        insert da;
        da.Start_Date_Time__c = system.now();
        da.End_Date_Time__c = system.now() + 1;
        update da;
        da = [select Id, Start_Date_Time__c, End_Date_Time__c, Start_Time__c, End_Time__c from Driver_Assignment__c where Id = :da.Id limit 1];
        system.assertEquals(da.Start_Date_Time__c.format('hh:mm a'), da.Start_Time__c);
        system.assertEquals(da.End_Date_Time__c.format('hh:mm a'), da.End_Time__c);
        
    }
}