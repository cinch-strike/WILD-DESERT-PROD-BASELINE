public class DailySummaryReportAttachment {
    
    @InvocableMethod
    public static void createDailySummaryReportAttachment(List<Id> dailySiteJobSummaryIds){
        
        try{
            List<Attachment> attachmentToBeInserted = new List<Attachment>();
            Map<Id,Daily_Summary_Report__c> dailySummaryReportList = new Map<Id,Daily_Summary_Report__c>([Select Id,Name,Summary_Report_Date__c from Daily_Summary_Report__c where Id IN : dailySiteJobSummaryIds]);
            for(Id recordId: dailySiteJobSummaryIds){
                PageReference pgRef = Page.DailySummaryReport_Pdf;
                pgRef.getParameters().put('id',recordId);
                Blob pdfBody;
                if(Test.isRunningTest()){
                    pdfBody = Blob.valueOf('UnitTest for DailySummaryRepot Attachment');
                }
                else{ pdfBody = pgRef.getContentAsPDF(); }
                
                if(pdfBody != null){
                    Attachment att = new Attachment();
                    att.isPrivate = false;
                    att.Body = pdfBody;
                    att.ParentId = recordId;
                    Date dt = dailySummaryReportList.get(recordId).Summary_Report_Date__c;
                    att.Name = 'DSJ Summary Report--' + dailySummaryReportList.get(recordId).Name + '--' + dt.day() + '-' + dt.month() + '-' + dt.year() + '.pdf';
                    attachmentToBeInserted.add(att);
                }
            }
            
            if(!attachmentToBeInserted.isEmpty()){
                insert attachmentToBeInserted;
            }    
        }   
        catch(Exception e){ System.debug('In class: DailySummaryReportAttachment. At line'+e.getLineNumber()+'. Cause: '+e.getCause()+'. ErrorMessage: '+e.getMessage()); }
        
        
        
    }
    
}