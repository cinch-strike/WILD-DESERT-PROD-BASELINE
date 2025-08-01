public class InvocableGenerateInvoice {
    @InvocableMethod(label='Generate Invoice')
    public static void genInv(List<InputVariables> inputVariables){
        try{
            GenerateInvoice.generateInvoiceRecord(inputVariables[0].contId, inputVariables[0].siteId);
        }catch(Exception e){
            System.debug('At '+e.getLineNumber()+'. Cause: '+e.getCause()+'. ErrorMessage: '+e.getMessage());
        }
    }
    public class InputVariables{
        @invocableVariable
        public string contId;
        @invocableVariable
        public string siteId;
        
    }
}