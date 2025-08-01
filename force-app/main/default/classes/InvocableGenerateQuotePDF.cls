public with sharing class InvocableGenerateQuotePDF {
    @InvocableMethod(Label='Generate Quote')
    public static List<InvocableOutput> generateQuotePDF(List<InvocableInput> inputList) {

        List<InvocableOutput> outputList = new List<InvocableOutput>();
        InvocableOutput output = new InvocableOutput();
        try{
            //Attach PDF to Quote
            PageReference PDF =  Page.GenerateQuote_Pdf;
            PDF.getParameters().put('Id', inputList[0].quoteId);
            PDF.setRedirect(true);
            Blob pdfGenerated ;
            if(Test.isRunningTest()){
                pdfGenerated = blob.valueOf('Unit.Test');
            } else {
                pdfGenerated = PDF.getContent();
            }
            
            // Upload PDF on Content Document
            ContentVersion ContVerFile = new ContentVersion();
            ContVerFile.VersionData = pdfGenerated;
            ContVerFile.Title = inputList[0].fileName; 
            ContVerFile.ContentLocation = 's';
            ContVerFile.PathOnClient = inputList[0].fileName + '.pdf';
            insert ContVerFile;

            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:ContVerFile.Id].ContentDocumentId;
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            cDe.LinkedEntityId = inputList[0].quoteId;
            cDe.ShareType = 'I';
            cDe.Visibility = 'AllUsers';
            insert cDe;

            output.isSuccess = true;
            
        } catch (Exception e){
            System.debug('At '+e.getLineNumber()+'. Cause: '+e.getCause()+'. ErrorMessage: '+e.getMessage());
            output.errorMessage = 'At '+e.getLineNumber()+'. Cause: '+e.getCause()+'. ErrorMessage: '+e.getMessage();

            output.isSuccess = false;
        }

        outputList.add(output);
        
        return outputList;

    }

    public class InvocableInput {
        public InvocableInput(){}

        @InvocableVariable (label='Quote Id' required=true)
		public String quoteId;

        @InvocableVariable (label='File Name' required=true)
		public String fileName;

    }

    public class InvocableOutput {
        public InvocableOutput(){}
        @InvocableVariable (label='Success Flag')
		public Boolean isSuccess;

        @InvocableVariable (label='Error Message' )
		public String errorMessage;

    }
}