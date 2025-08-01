@isTest(seeAllData=true)
public class LinkPDToPositionAndAccountTest{
    public static List<Professional_Development__c> profDevList;
    public static List<Professional_Development__c> profDevListUpdated;
    public static account acc;
    public static account acc1;
    public database.saveresult lsr;
    public static database.saveresult[] lsrArray;
    public static List<Id> recordsIds;
    public static Id accountId;
    public static List<Position__c> listPosition;
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
    public static void init(){
    pdtList.add(InilitizeTestData.createPersonalDevType('Test PrfessionalDevelopment1',10));
        pdtList.add(InilitizeTestData.createPersonalDevType('Test PrfessionalDevelopment2',20));
        
        database.saveResult[] profDevTypeSaveResultList = database.insert(pdtList);
        
        positionList.add(InilitizeTestData.createPosition('Test Position 1'));
        positionList.add(InilitizeTestData.createPosition('Test Position 2')); 
        
        positionSaveResultList = database.insert(positionList);
        System.debug('positionSaveResultList-----------:'+positionSaveResultList);
        
        devRecList.add(InilitizeTestData.createMandDevRecord(profDevTypeSaveResultList[0].getId(),'Test Mand Pos1',null,positionSaveResultList[0].getId()));
        devRecList.add(InilitizeTestData.createMandDevRecord(profDevTypeSaveResultList[1].getId(),'Test Mand Pos2',null,positionSaveResultList[1].getId()));
        
        positionDevRecSaveResult = database.insert(devRecList);
       
        accountList.add(InilitizeTestData.createAccount('Test Account1'));
        accountList.add(InilitizeTestData.createAccount('Test Account2'));
        
        database.saveResult[] accountSaveResultList = database.insert(accountList);
        

        
        siteList.add(InilitizeTestData.createSite('Test Site1',accountSaveResultList[0].getId()));
        siteList.add(InilitizeTestData.createSite('Test Site2',accountSaveResultList[1].getId()));
        
        //database.saveResult[] 
        siteSaveResultList = database.insert(siteList);
        
        unitList.add(InilitizeTestData.createUnit('Test Unit1',siteSaveResultList[0].getId()));
        unitList.add(InilitizeTestData.createUnit('Test Unit2',siteSaveResultList[1].getId()));
        
         unitSaveResult = database.insert(unitList);
        
 
        for(Integer i=0;i<=5;i++){
            employeeList.add(InilitizeTestData.createEmployee(positionSaveResultList[1].getId(),unitSaveResult[1].getId(),'Employee'+i));
        }
        
        
       employeeSaveResult = database.insert(employeeList); 
       
        profDevList = new List<Professional_Development__c>();
        listPosition = new List<Position__c>();
        for(Integer i=0;i<10;i++){
            listPosition.add(InilitizeTestData.createPosition('Test Position'+i));  
        }
        database.insert(listPosition);
        //acc = InilitizeTestData.createAccount('Test Account');
        //database.saveresult lsr =database.insert(acc);
        accountId =accountSaveResultList[0].getId(); 
        for(Integer i=0;i<10;i++){
            profDevList.add(InilitizeTestData.createProfDevRecord('Test Prof Dev'+i,null));    
        }  
        lsrArray =database.insert(profDevList);
       
    }
    
    public static testmethod void myUnitTest1(){
        init(); 
        acc1 = InilitizeTestData.createAccount('Test Account1');
        database.saveresult la = database.insert(acc1);
        //system.assertEquals(lsrArray,null);
        recordsIds = new List<Id>();
        for(database.saveresult d:lsrArray){
            recordsIds.add(d.getId());
        }
        profDevListUpdated = new List<Professional_Development__c>();
        for(Professional_Development__c pd:[select id,Required_By__c from Professional_Development__c where id in:recordsIds]){
            pd.Required_By__c =null;
            pd.Requirement_Type__c = null;
            profDevListUpdated.add(pd);
        }
        database.update(profDevListUpdated);
        profDevListUpdated.clear();
        for(Professional_Development__c pd:[select id,Required_By__c from Professional_Development__c where id in:recordsIds]){
            pd.Requirement_Type__c ='Compulsory - All';
            profDevListUpdated.add(pd); 
        }
        database.update(profDevListUpdated);
      
       
    }
    public static testmethod void myUnitTest2(){
        List<Employees__c> empList = new List<Employees__c>();
       // Position__c position = InilitizeTestData.createPosition('Test Position 2');
        //database.insert(position);
        positionList.add(InilitizeTestData.createPosition('Test Position 1'));
        positionList.add(InilitizeTestData.createPosition('Test Position 2')); 
        
        positionSaveResultList = database.insert(positionList);
        System.debug('positionSaveResultList-----------:'+positionSaveResultList);
                accountList.add(InilitizeTestData.createAccount('Test Account1'));
        accountList.add(InilitizeTestData.createAccount('Test Account2'));
        
        database.saveResult[] accountSaveResultList = database.insert(accountList);
        
        /*accDevRecList.add(InilitizeTestData.createMandDevRecord(profDevTypeSaveResultList[0].getId(),'Test Mand Acc1',accountSaveResultList[0].getId(),null));
        accDevRecList.add(InilitizeTestData.createMandDevRecord(profDevTypeSaveResultList[1].getId(),'Test Mand Acc 2',accountSaveResultList[1].getId(),null));
        
        database.saveResult[] acctDevResultList = database.insert(accDevRecList); */
        
        siteList.add(InilitizeTestData.createSite('Test Site1',accountSaveResultList[0].getId()));
        siteList.add(InilitizeTestData.createSite('Test Site2',accountSaveResultList[1].getId()));
        
        //database.saveResult[] 
        siteSaveResultList = database.insert(siteList);
        
        unitList.add(InilitizeTestData.createUnit('Test Unit1',siteSaveResultList[0].getId()));
        unitList.add(InilitizeTestData.createUnit('Test Unit2',siteSaveResultList[1].getId()));
        
         unitSaveResult = database.insert(unitList);
        for(Integer i=0;i<5;i++){
           // empList.add(InilitizeTestData.createEmployeeForNewTest(position.id,'testEmp'+i));    
       // }
            Employees__c emp= new Employees__c();
            emp.PositionLookup__c = positionSaveResultList[0].getId();
            emp.Assigned_to_Unit__c  = unitSaveResult[0].getId(); 
            emp.First_Name__c='first name';
            emp.Last_Name__c='last name';    
            System.debug('---------------------list to check'+emp);
            empList.add(emp);
          }  
        System.debug('---------------------list to before check'+empList);
        database.insert(empList);
        System.debug('---------------------list to after check'+empList );
        
        PageReference pageRef = Page.deleteWarningPage;
        pageRef.getParameters().put('id',positionSaveResultList[0].id);
        Test.setCurrentPage(pageRef);    
         
        posController pos = new posController();
        system.assertNotEquals(pos.deletePosition(),null);
        system.assertNotEquals(pos.cancelPosition(),null);
        //system.assertEquals(pos.autoDelete(),null);
        
    }
    

}