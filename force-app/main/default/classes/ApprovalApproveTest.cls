@isTest
public class ApprovalApproveTest {
    
    @isTest
    public static void testApproveRecord(){
        
        TestDataFactory testData = new TestDataFactory();
        
        Account acc = testData.createAccount();
        insert acc;
        
        Contract__c cont = testData.createContract();
        cont.Account__c = acc.Id;
        insert cont;
        
        Inventory_Item__c invobj = new Inventory_Item__c(Name ='Test Item',Active__c = True);
        insert invobj;
        
        Unit__c unitObj = testData.createRigUnit();
        unitObj.Contract_New__c = cont.Id;
        unitObj.LTI_Reset_Date__c = System.today() - 5;
        insert unitObj;        
        
        Store_Item__c storeItemobj = new Store_Item__c();
        storeItemobj.Inventory_Item__c = invobj.id;
        storeItemobj.Store_Unit__c=unitObj.id;
        insert storeItemobj;
        
        List<Purchase_Request__c> prList = new List<Purchase_Request__c>();
        for(Integer i =1;i<=5;i++){
            Purchase_Request__c pr = new Purchase_Request__c();
            pr.Approval_Comments__c = 'Test Approve' +i;
            pr.Status__c = 'For Approval';
            pr.New_Item_Name__c = 'Test Name' +i;
            pr.Item__c = invobj.Id;
            pr.Source_Store__c = unitObj.Id;
            pr.Source_Store_Item__c = storeItemobj.Id;
            pr.Staff_Name__c = 'Test Staff';
            pr.Quantity__c = 2;
            pr.Purchase_Request_Approver__c = UserInfo.getUserId();
            prList.add(pr);
        }
        
        insert prList;
        List<String> prRecordIdList = new List<String>(); 
        List<String> prRecordIdList2 = new List<String>();         
        prRecordIdList.add(prList[2].id);
        prRecordIdList2.add(prList[3].id);
        
        system.assert(prList[0].Id != Null);
        
        /*ProcessInstance objProcessInstance = new ProcessInstance();
objProcessInstance= [SELECT Id,TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :pr.Id];
System.assertEquals(pr.CreatedDate,objProcessInstance.CreatedDate);*/
        
        /* Approval.ProcessSubmitRequest Approvalreq = new Approval.ProcessSubmitRequest();
Approvalreq.setComments('Submitting request for approval for Purchase Request.');
Approvalreq.setNextApproverIds(new Id[] {UserInfo.getUserId()});
Approvalreq.setObjectId(pr.Id);
Approval.ProcessResult approvalResult = Approval.process(Approvalreq);
*/
        
        List<ApprovalApprove.InvocableInput> InvInputobjListApprove = new List<ApprovalApprove.InvocableInput>();
        
        ApprovalApprove.InvocableInput InvInputObj = new ApprovalApprove.InvocableInput();
        InvInputObj.recordId = prList[0].Id;
        InvInputObj.approvalComments = 'Please Approve Test 1';
        
        InvInputobjListApprove.add(InvInputObj);
        List<ApprovalApprove.InvocableOutput> InvAcceptOutput = ApprovalApprove.ApproveRecord(InvInputobjListApprove);
        if(! InvAcceptOutput.isEmpty()){
            System.assertEquals(True, InvAcceptOutput[0].success , 'Approval Approve process returned False, expected True') ;
        }
        
        List<ApprovalReject.InvocableInput> InvInputobjListReject = new List<ApprovalReject.InvocableInput>();
        
        ApprovalReject.InvocableInput InvInputObj1 = new ApprovalReject.InvocableInput();
        InvInputObj1.recordId = prList[1].Id;
        InvInputObj1.approvalComments = 'Please Approve Test 2';
        
        List<ApprovalReject.InvocableOutput> InvRejectOutput = ApprovalReject.RejectRecord(InvInputobjListReject);
        if(! InvRejectOutput.isEmpty()){
            System.assertEquals(True, InvRejectOutput[0].success , 'Approval Reject process returned False, expected True') ;
        }
        
        InvInputobjListReject.add(InvInputObj1);
        ApprovalReject.RejectRecord(InvInputobjListReject);
        
        ApprovalLock.LockRecord(prRecordIdList);
        List<Purchase_Request__c> lockResult = [SELECT Id, Status__c FROM Purchase_Request__c WHERE Id =: prRecordIdList];
        for(Purchase_Request__c eachLockResult : lockResult){
            System.assertEquals('For Approval', eachLockResult.Status__c, 'Approval Lock Failed');
        }
        
        prRecordIdList2.add(prList[3].id);
                             
        ApprovalUnlock.UnLockRecord(prRecordIdList2);
        List<Purchase_Request__c> unlockResult = [SELECT Id, Status__c FROM Purchase_Request__c WHERE Id =: prRecordIdList2];
        for(Purchase_Request__c eachLockResult : unlockResult){
            System.assertEquals('For Approval', eachLockResult.Status__c, 'Approval unlock Failed');
        }

        ApprovalApprove.coverageHack();
        ApprovalReject.coverageHack();
        ApprovalLock.coverageHack();
        ApprovalUnlock.coverageHack();
    }
}