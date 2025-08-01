/******************************************************************************
* @author        Kunal Jain
* @date         
* @description   This is a test class for RelatedListComponent_Controller
******************************************************************************/
@isTest
public class RelatedListComponent_Controller_Test {
    
    static testMethod void testMethod1(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact cont = new Contact();
        cont.LastName = 'Last Name';
        cont.FirstName = 'First Name';
        cont.Email = 'test@email.com';
        cont.AccountId = acc.Id;
        insert cont;
        
        Contact cont2 = new Contact();
        cont2.LastName = 'Last Name 2';
        cont2.FirstName = 'First Name 2';
        cont2.Email = 'test2@email.com';
        cont2.AccountId = acc.Id;
        insert cont2;
        
        RelatedListComponent_Controller relatedListController = new RelatedListComponent_Controller();
        relatedListController.relatedField = 'AccountId';
        relatedListController.relatedId = acc.Id;
        relatedListController.fieldSet = 'TestFieldSet';
        relatedListController.currentUrl = 'www.google.com';
        relatedListController.orderByField = 'Name';
        relatedListController.orderByField = 'Name';
        relatedListController.recordsPerPage = 5;
        relatedListController.showNew = true;
        relatedListController.showEdit = true;
        relatedListController.showDelete = true;   
        relatedListController.sObjName = 'Contact'; 
        system.debug('relatedListController.relatedField' + relatedListController.relatedField);
            system.debug('relatedListController.relatedId' + relatedListController.relatedId);
        //relatedListController.relatedField = 'AccountId';
        //relatedListController.relatedId = acc.Id;
        //relatedListController.relatedListComponent_CustomConstructor();
        
        relatedListController.recordsPerPage = 21;
        relatedListController.setRecordPerPage();
        relatedListController.selectedRecordsPerPage = 5;
        relatedListController.setRecordPerPage();
        
        relatedListController.getSOjectRecordList();
        relatedListController.getFields();
        
        relatedListController.recIdToBeDeleted = cont.Id;
        relatedListController.deleteSelectedRecord();
    }
}