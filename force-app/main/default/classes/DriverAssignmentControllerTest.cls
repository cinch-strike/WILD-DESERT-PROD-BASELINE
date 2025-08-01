/****
 * Apex Class for DriverAssignmentController
 * Author: D Banez
 * Date: Nov 2020 
 * Test Class: DriverAssignmentControllerTest
*/
@isTest
public without sharing class DriverAssignmentControllerTest {

    static testmethod void testMethodLookup() {
        
            
        Test.startTest();
        DriverAssignmentController.getDriverAssignmentList('a3W0o000000p6QaEAI');
        DriverAssignmentController.ConfigurationLookUp('a3W0o000000p6QaEAI');
        DriverAssignmentController.fetchLookUpValues('test', 'name', 'Transport_Job__c', 'Id');
        DriverAssignmentController.DriverNameLookUp();
        DriverAssignmentController.getDriverAssignNoContactJobItem('a3W0o000000p6QaEAI');
        DriverAssignmentController.getDriverAssignNoConfiguration('a3W0o000000p6QaEAI');
		DriverAssignmentController.TruckLookUp('a3W0o000000p6QaEAI');
        
        Test.stopTest();  
        
    }

}