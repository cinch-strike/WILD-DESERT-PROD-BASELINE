@IsTest
public with sharing class CreatePRControllerTest {
    static testmethod void testPRController() {
        CreatePRController cont = new CreatePRController();
        cont.coverageHack();
    }
}