/** This class is used for 'GenerateQuote_Pdf' to get the Quote details
 * CreatedBy: Cinch + Strike
 * Created Date: 25th NOV 2022
 * 
 * History
 * 25-NOV-2022    Vic Petilla    Initial Creation
**/

public with sharing class GenerateQuote_Controller {

    private final Quote__c quo;
    public String quoteName { get; set; }
    public String supplierName { get; set; }
    public String supplierAddress { get; set; }
    public String supplierPhone { get; set; }
    public String quoteItems { get; set; }
    public String detailsForSupplier { get; set; }


    public GenerateQuote_Controller(ApexPages.StandardController stdController) {

        try {

            quo = (Quote__c) stdController.getRecord();
            List<Quote__c> tempquote = [SELECT Id, Name, Supplier__r.Name, Supplier_Address_formula__c, Supplier_Phone_formula__c, Quote_Item_Table__c, Details_for_Supplier__c
                FROM Quote__c WHERE Id = :quo.Id LIMIT 1];

            for (Quote__c quote : tempquote) {
                quoteName = quote.Name;
                supplierName = quote.Supplier__r.Name;
                supplierAddress = quote.Supplier_Address_formula__c;
                supplierPhone = quote.Supplier_Phone_formula__c;
                quoteItems = quote.Quote_Item_Table__c;
                detailsForSupplier = quote.Details_for_Supplier__c;
            }
            
        } catch (Exception e){
            System.debug('At '+e.getLineNumber()+'. Cause: '+e.getCause()+'. ErrorMessage: '+e.getMessage());
        }
    }
}