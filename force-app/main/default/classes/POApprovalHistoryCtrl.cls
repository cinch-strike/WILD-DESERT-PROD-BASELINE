public with sharing class POApprovalHistoryCtrl {
    public Id POId {get;set;}
    public List<ProcessInstanceHistory> getApprovalSteps() {
        if (POId != null) {
            biz3__Purchase_Order__c po =
                [ SELECT Id, ( SELECT SystemModstamp, StepStatus, OriginalActorId, Id, Comments, ActorId
                               FROM ProcessSteps ORDER BY SystemModstamp DESC)
                  FROM biz3__Purchase_Order__c WHERE Id = :POId ];
            return po.ProcessSteps;
        }

        return new List<ProcessInstanceHistory>();
    } 
}