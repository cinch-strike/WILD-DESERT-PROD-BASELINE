//Test class to test the behaviour of AutoPopulateDevelopmentRecord trigger and AutoPopulateDevelopmentRecordsUtility utility class
@isTest

public class AutoPopulateDevelopmentRecordTest{
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
    //method to create sample data.
    public static void init(){
        pdtList.add(InilitizeTestData.createPersonalDevType('Test PrfessionalDevelopment1',10));
        pdtList.add(InilitizeTestData.createPersonalDevType('Test PrfessionalDevelopment2',20));
        
        database.saveResult[] profDevTypeSaveResultList = database.insert(pdtList);
        
        positionList.add(InilitizeTestData.createPosition('Test Position 1'));
        positionList.add(InilitizeTestData.createPosition('Test Position 2')); 
        
        positionSaveResultList = database.insert(positionList);
        
        devRecList.add(InilitizeTestData.createMandDevRecord(profDevTypeSaveResultList[0].getId(),'Test Mand Pos1',null,positionSaveResultList[0].getId()));
        devRecList.add(InilitizeTestData.createMandDevRecord(profDevTypeSaveResultList[1].getId(),'Test Mand Pos2',null,positionSaveResultList[1].getId()));
        
        positionDevRecSaveResult = database.insert(devRecList);
       
        accountList.add(InilitizeTestData.createAccount('Test Account1'));
        accountList.add(InilitizeTestData.createAccount('Test Account2'));
        
        database.saveResult[] accountSaveResultList = database.insert(accountList);
        
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
    public static testmethod void myUnitTest(){
        init();
        List<Id> empIdsList = new  List<Id>();
        List<Employees__c> empListToUpdate = new List<Employees__c>();
        for(database.saveResult s:employeeSaveResult){
            empIdsList.add(s.getId());    
        }
        for(Employees__c emp:[select id,PositionLookup__c,Assigned_to_Unit__c from Employees__c where id in:empIdsList]){
            		System.debug('-------Loop -----------------------------'+emp); 
            if(emp.PositionLookup__c==positionSaveResultList[0].getId()){
                emp.PositionLookup__c = positionSaveResultList[1].getId();
                emp.Assigned_to_Unit__c  = unitSaveResult[1].getId(); 
                //emp.Assigned_to_Unit__r.site__c=siteSaveResultList[0].getId();  
                //emp.Assigned_to_Unit__r.site__r.Name='test site Name';  
			   System.debug('------------------------------------'+emp);                
            }
            else{
                emp.PositionLookup__c = positionSaveResultList[0].getId();
                emp.Assigned_to_Unit__c  = unitSaveResult[1].getId(); 
               // emp.Assigned_to_Unit__r.site__c=siteSaveResultList[0].getId();  
               // emp.Assigned_to_Unit__r.site__r.Name='test site Name';  
			   System.debug('------------------------------------'+emp);
            }
            empListToUpdate.add(emp);    
        } 
        database.update(empListToUpdate);  
        
          
    }

}