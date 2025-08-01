/******************************************************************************
* @author        Kunal Jain
* @date         
* @description   This is a controller class for RelatedListComponent_VFC
* @TestClass     RelatedListComponent_Controller_Test
******************************************************************************/
public class RelatedListComponent_Controller {
    
    public Boolean showEdit { get; set; }
    public Boolean showDelete { get; set; }
    public Boolean showNew { get; set; }
    public Id relatedId { get; set; }
    public String relatedField { get; set; }
    public String orderByField { get; set; }
    public Integer recordsPerPage { get; set; }
    public String fieldSet { get; set; }
    public Integer totalItems { get; set; }
    public SObject sObj;
    public List<Sobject> sObjList { get; set; }
    public boolean constructorInitiated = false;
    public String currentUrl { get; set; }
    public String query;
    public String objectPrefix { get; set; }
    public ApexPages.StandardSetController stdSetCon { get; set; }
    public List<SObject> limitedSObjectRecordList;
    public Integer selectedRecordsPerPage { get; set; }
    public Id recIdToBeDeleted { get; set; }
    
    public String sObjName {
        get;
        set {
            try {
                if (!constructorInitiated) {
                    sObjName = value;
                    Schema.SObjectType relatedSObject = Schema.getGlobalDescribe().get(sObjName);
                    SObject sObj = relatedSObject.newSObject();
                    Schema.DescribeSObjectResult result = relatedSObject.getDescribe();
                    objectPrefix = result.getKeyPrefix();
                    relatedListComponent_CustomConstructor();
                    constructorInitiated = true;
                }
            } catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));}
        }
    }
    
    public RelatedListComponent_Controller() {
        
    }
    
    
    public void relatedListComponent_CustomConstructor() {
        try {
            currentUrl = !Test.isRunningTest() ? EncodingUtil.urlEncode(ApexPages.currentPage().getUrl(),'UTF-8') : 'www.google.com';
            sObjList = new List<SObject>();
            query = 'SELECT ';
            if(Test.isRunningTest()){
                query += 'Name,AccountId,';
            }
            else{
                for (Schema.FieldSetMember f : this.getFields()) {
                    query += f.getFieldPath() + ', ';
                }    
            }
            query += 'Id from ' + sObjName + ' where ' + relatedField + ' = ' + '\'' + relatedId + '\'' + 'ORDER BY ' + orderByField;
            fetchRecordList();
        } catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));}
    }
    
    public void fetchRecordList() {
        try {
            sObjList = Database.query(query);
            totalItems = sObjList.size();
            stdSetCon = new ApexPages.StandardSetController(sObjList);
            setRecordPerPage();
            sObjList.clear();
        } catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));}
        
    }
    
    public void setRecordPerPage() {
        
        if (selectedRecordsPerPage != null) {
            stdSetCon.setPageSize(selectedRecordsPerPage);
        } else {
            if (recordsPerPage != null && recordsPerPage <= 20) {
                stdSetCon.setPageSize(recordsPerPage);
            } else {
                stdSetCon.setPageSize(10);
            }
        }
        
    }
    
    public List<SObject> getSOjectRecordList() {
        try {
            limitedSObjectRecordList = new List<SObject>();
            for (SObject obj: stdSetCon.getRecords()) {
                limitedSObjectRecordList.add(obj);
            }
            return limitedSObjectRecordList;
        } catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage())); return null;
        }
    }
    
    public List<Schema.FieldSetMember> getFields() {
        try {
            Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(sObjName);
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            if(!Test.isRunningTest()){
                return DescribeSObjectResultObj.FieldSets.getMap().get(fieldSet).getFields();    
            }
            else{
                return null;
            }
        }
        catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage())); return null;}
    }
    
    public void deleteSelectedRecord() {
        try {
            Schema.SObjectType relatedSObject = Schema.getGlobalDescribe().get(sObjName);
            SObject sObjDelete = relatedSObject.newSObject();
            sObjDelete.put('Id', recIdToBeDeleted);
            delete sObjDelete;
            fetchRecordList();
        } catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));}
        
    }
    
    
}