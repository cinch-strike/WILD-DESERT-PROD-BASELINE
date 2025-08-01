/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class  UpdateMPDEmployeePositionTest {
	
	private static List<Professional_Development__c>  pdtList = new List<Professional_Development__c>();
    private static List<Position__c> positionList = new List<Position__c>();
    private static List<Mandatory_Professional_Development__c > devRecList = new List<Mandatory_Professional_Development__c>();
    
    
    private static List<Account> accountList = new List<Account>();
    private static List<Mandatory_Professional_Development__c> accDevRecList = new List<Mandatory_Professional_Development__c>();
    private static List<Site__c> siteList = new List<Site__c>();
    private static List<Unit__c> unitList = new List<Unit__c>();
    
    private static List<Employees__c> employeeList = new List<Employees__c>();
    public static database.saveResult[] employeeSaveResult;
    public static database.saveResult[] positionDevRecSaveResult;
    public static database.saveResult[] unitSaveResult;
    public static database.saveResult[] positionSaveResultList; 
    public static database.saveResult[] siteSaveResultList;
    public static database.saveResult[] profDevTypeSaveResultList;
    public static database.saveResult[] accountSaveResultList;
    //method to create sample data.
    public static void init(){
        pdtList.add(InilitizeTestData.createPersonalDevType('Test PrfessionalDevelopment1',10));
        pdtList.add(InilitizeTestData.createPersonalDevType('Test PrfessionalDevelopment2',20));
        pdtList.add(InilitizeTestData.createPersonalDevType('Test PrfessionalDevelopment3',30));
        
        profDevTypeSaveResultList = database.insert(pdtList);
        
        positionList.add(InilitizeTestData.createPosition('Test Position 1'));
        positionList.add(InilitizeTestData.createPosition('Test Position 2')); 
        
        positionSaveResultList = database.insert(positionList);
        
        
       
        accountList.add(InilitizeTestData.createAccount('Test Account1'));
        accountList.add(InilitizeTestData.createAccount('Test Account2'));
        
        accountSaveResultList = database.insert(accountList);
        
        accDevRecList.add(InilitizeTestData.createMandDevRecord(profDevTypeSaveResultList[0].getId(),'Test Mand Acc1',accountSaveResultList[0].getId(),null));
        accDevRecList.add(InilitizeTestData.createMandDevRecord(profDevTypeSaveResultList[1].getId(),'Test Mand Acc 2',accountSaveResultList[1].getId(),null));
        
        database.saveResult[] acctDevResultList = database.insert(accDevRecList); 
        
        siteList.add(InilitizeTestData.createSite('Test Site1',accountSaveResultList[0].getId()));
        siteList.add(InilitizeTestData.createSite('Test Site2',accountSaveResultList[1].getId()));
        
        //database.saveResult[] 
        siteSaveResultList = database.insert(siteList);
        
        unitList.add(InilitizeTestData.createUnit('Test Unit1',siteSaveResultList[0].getId()));
        unitList.add(InilitizeTestData.createUnit('Test Unit2',siteSaveResultList[1].getId()));
        
         unitSaveResult = database.insert(unitList);
        
        for(Integer i=0;i<=100;i++){
            employeeList.add(InilitizeTestData.createEmployee(positionSaveResultList[0].getId(),unitSaveResult[0].getId(),'Employee'+i));
        }
        for(Integer i=100;i<=201;i++){
            employeeList.add(InilitizeTestData.createEmployee(positionSaveResultList[1].getId(),unitSaveResult[1].getId(),'Employee'+i));
        }
        
        employeeSaveResult = database.insert(employeeList); 
       
        
       	
            
    }

	 static testMethod void myUnitTest() {
	 	init();
        devRecList.add(InilitizeTestData.createMandDevRecord(profDevTypeSaveResultList[0].getId(),'Test Mand Pos1',null,positionSaveResultList[0].getId()));
        devRecList.add(InilitizeTestData.createMandDevRecord(profDevTypeSaveResultList[1].getId(),'Test Mand Pos2',null,positionSaveResultList[1].getId()));
        positionDevRecSaveResult = database.insert(devRecList);
        
        list<Development_Records__c> listDRs = [select id, Employee__c from Development_Records__c where status__c = 'Incomplete'] ;
        
        system.assert(listDRs.size() > 0);
        
        devRecList[1].Professional_Development__c = profDevTypeSaveResultList[2].getId();
        
        update devRecList[1];
        
        delete devRecList;
        
        listDRs = [select id, Employee__c from Development_Records__c where status__c = 'Incomplete'] ;
        
        system.assert(listDRs.size() ==  0);
        
	 }
}