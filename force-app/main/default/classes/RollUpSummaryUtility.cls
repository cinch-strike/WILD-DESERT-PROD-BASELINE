public class RollUpSummaryUtility {
    public class fieldDefinition {
        public String operation {get;set;}
        public String childField {get;set;}
        public String parentField {get;set;}
         
        public fieldDefinition (String o, String c, String p) {
            operation = o;
            childField = c;
            parentField = p;
        }
    }
    public static void rollUpTrigger(list<fieldDefinition> fieldDefinitions,
    list<sObject> records, String childObject, String childParentLookupField, 
    String parentObject, String queryFilter) {
        set<Id> parentIds = new set<Id>();
        for(sObject s : records) {
            parentIds.add((Id)s.get(childParentLookupField));
        }
        String fieldsToAggregate = '';
        String parentFields = '';
        for(fieldDefinition d : fieldDefinitions) {
            fieldsToAggregate += d.operation + '(' + d.childField + ') ' + 
            ', ';
            parentFields += d.parentField + ', ';
        }
        String aggregateQuery = 'Select ' + fieldsToAggregate + 
        childParentLookupField + ' from ' + childObject + ' where  ' + 
        childParentLookupField + ' IN :parentIds ' + queryFilter + ' ' +
        ' group by ' + childParentLookupField;
        map<Id, AggregateResult> parentValueMap = 
        new map <Id, AggregateResult>();
         
        for(AggregateResult q : Database.query(aggregateQuery)){
            parentValueMap.put((Id)q.get(childParentLookupField), q);
        }
        list<sObject> parentsToUpdate = new list<sObject>();
        String parentQuery = 'select ' + parentFields + ' Id ' +
         ' from ' + parentObject + ' where Id IN :parentIds';
        
        for(sObject s : Database.query(parentQuery)) {
            Integer row = 0; 
            for(fieldDefinition d : fieldDefinitions) {
                String field = 'expr' + row.format();
                AggregateResult r = parentValueMap.get(s.Id);
                if(r != null) { 
                    Decimal value = ((Decimal)r.get(field) == null ) ? 0 : 
                        (Decimal)r.get(field);
                    s.put(d.parentField, value);
                } else {
                    s.put(d.parentField, 0);
                }
                row += 1; 
            }
            parentsToUpdate.add(s);
        }
        if(parentsToUpdate.Size() > 0) {
            update parentsToUpdate;
        }
    }
}