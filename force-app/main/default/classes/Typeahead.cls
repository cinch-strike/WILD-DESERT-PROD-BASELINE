// Controller class for the Force.com Typeahead component
public with sharing class Typeahead {

  @RemoteAction
  public static list<sObject> searchRecords( String queryString, String objectName, 
    list<String> fieldNames, String fieldsToSearch, String filterClause, String orderBy, Integer recordLimit ) {

    if (queryString == null) return null;

    String sQuery = String.escapeSingleQuotes( queryString );
    if (sQuery.length() == 0) return null;

    String sObjectName = (objectName == null) ? 'Contact' : String.escapeSingleQuotes( objectName );

    String sInFields = 
      (fieldsToSearch == null || fieldsToSearch == '' || fieldsToSearch.toUpperCase() == 'ALL') ? '' : ( ' IN ' + String.escapeSingleQuotes(fieldsToSearch) + ' FIELDS' );
    
    if(sObjectName == 'Contract_Item__c'){
        fieldNames.add('Service_Type__c');fieldNames.add('WD_Asset_Name__c');fieldNames.add('WD_Asset__c');}            
    
    
    String sFields = (fieldNames == null || fieldNames.isEmpty()) ? 'Id, Name' : String.escapeSingleQuotes( String.join( fieldNames, ', ' ) );  
    
    String sOrder = ' ORDER BY ' + ( (orderBy == null || orderBy == '') ? 'Name' : String.escapeSingleQuotes(orderBy) ); 
    
    String sLimit = (recordLimit == null || recordLimit == 0 || recordLimit >= 2000) ? '' : ( ' LIMIT ' + String.valueOf(recordLimit));
    
    // can't escape the filter clause
    String sWhere = (filterClause == null || filterClause == '') ? '' : ( ' WHERE ' + filterClause );
    string query = 'FIND \'' + sQuery + '*\'' + sInFields + ' RETURNING ' + sObjectName + '( ' + sFields + sWhere + sOrder + sLimit + ' )';   
        system.debug('query: ' + query);
    list<list<sObject>> results = Search.query(
      'FIND \'' + sQuery + '*\'' + sInFields + 
        ' RETURNING ' + sObjectName + '( ' + sFields + sWhere + sOrder + sLimit + ' )'
    );
    
    return results[0];
  }  

}