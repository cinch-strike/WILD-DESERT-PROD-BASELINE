//This test class is created to test the behaviour of cloneExpiredDevRecords trigger under various conditions.
@isTest

public class cloneExpiredDevRecordsTest{
    private static List<Professional_Development__c>  pdtList = new List<Professional_Development__c>();
    private static List<Position__c> positionList = new List<Position__c>();
    private static List<Mandatory_Professional_Development__c> devRecList = new List<Mandatory_Professional_Development__c>();
    
    
    private static List<Account> accountList = new List<Account>();
    private static List<Development_Records__c> accDevRecList = new List<Development_Records__c>();
    private static List<Site__c> siteList = new List<Site__c>();
    private static List<Unit__c> unitList = new List<Unit__c>();
    
    private static List<Employees__c> employeeList = new List<Employees__c>();
    public static database.saveResult[] employeeSaveResult;
    public static database.saveResult[] positionDevRecSaveResult;
    public static database.saveResult[] unitSaveResult;
    public static database.saveResult[] siteSaveResult;
    public static database.saveResult[] positionSaveResultList; 
    public static database.saveResult[] accountSaveResult;
     public static void init(){
        pdtList.add(InilitizeTestData.createPersonalDevType('Test PrfessionalDevelopment1',10));
        pdtList.add(InilitizeTestData.createPersonalDevType('Test PrfessionalDevelopment2',20));
        
        database.saveResult[] profDevTypeSaveResultList = database.insert(pdtList);
        
        positionList.add(InilitizeTestData.createPosition('Test Position 1'));
        positionList.add(InilitizeTestData.createPosition('Test Position 2')); 
        
        positionSaveResultList = database.insert(positionList);
        
        accountList.add(InilitizeTestData.createAccount('Test Account 1'));
        accountList.add(InilitizeTestData.createAccount('Test Account 2'));
        
        accountSaveResult = database.insert(accountList); 
         
        siteList.add(InilitizeTestData.createSite('Test Site 1',accountSaveResult[0].getId()));
        siteList.add(InilitizeTestData.createSite('Test Site 2',accountSaveResult[1].getId()));
       
        siteSaveResult= database.insert(siteList);
        
        unitList.add(InilitizeTestData.createUnit('Test Unit 1',siteSaveResult[0].getId()));
        unitList.add(InilitizeTestData.createUnit('Test Unit 2',siteSaveResult[1].getId()));
        
        unitSaveResult = database.insert(unitList);
        
        for(Integer i=0;i<10;i++){
             devRecList.add(InilitizeTestData.createMandDevRecord(profDevTypeSaveResultList[0].getId(),'Mand Type 1',null,positionSaveResultList[0].getId()));
        }
        for(Integer i=0;i<10;i++){
             devRecList.add(InilitizeTestData.createMandDevRecord(profDevTypeSaveResultList[1].getId(),'Mand Type 2',accountSaveResult[0].getId(),null));
        }
        
        
        positionDevRecSaveResult = database.insert(devRecList);
        system.debug('------------>>>>>>>>>>>>>>>>>>>>>>>'+positionDevRecSaveResult);
        
        employeeList.add(InilitizeTestData.createEmployee(positionSaveResultList[0].getId(),unitSaveResult[0].getId(),'Test Employee 1'));
        employeeList.add(InilitizeTestData.createEmployee(positionSaveResultList[1].getId(),unitSaveResult[1].getId(),'Test Employee 2')); 
        employeeList[0].Mobile__c = '61429786541';
        employeeList[1].Mobile__c = '61429786542';

        employeeSaveResult = database.insert(employeeList);      
    }
    
    public static testmethod void myUnitTest(){
        init();
        List<Id> devIds = new List<Id>();
        for(database.saveResult s:employeeSaveResult){
            devIds.add(s.getId());
        }
        List<Development_Records__c> devRecordsList = new List<Development_Records__c>();
        List<Development_Records__c> toUpdateDevRecordsList = new List<Development_Records__c>();
        for(Employees__c emp:[select id,(select id,Expired__c from Training_Records__r ) from Employees__c where id in:devIds]){
            for(Development_Records__c dev:emp.Training_Records__r){
                devRecordsList.add(dev);
            }
        }
       // system.assertEquals(devRecordsList,null);
        for(Development_Records__c  dev:devRecordsList){
            dev.Expired__c=true;
            toUpdateDevRecordsList.add(dev);       
        }
        database.saveResult[] ur =database.update(toUpdateDevRecordsList);
        system.debug('------------>>>>>>>>>>>>>>>>>>>>>>>'+ur);
    }
   

}