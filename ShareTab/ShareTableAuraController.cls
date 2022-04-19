public class ShareTableAuraController {
    @AuraEnabled
    public static String doTablePrepare(String recordId, String objApiName, String pageFieldApiName,String orderByField, String orderByDirection, String pageFieldValue, String tableFields, String searchFieldMap, Boolean isSearch, Boolean isRelationShip, String relateFieldApiName, Decimal page, Integer recordToDisply) {
            List<SelectOption> pagePickList = getPaginateLabel(objApiName, pageFieldApiName);
            PageWrapper pageData = new PageWrapper();
            pageData.pageList =  pagePickList;
            System.debug(LoggingLevel.INFO, '*** : QueryString' + getQueryString(recordId,objApiName,pageFieldApiName,null, null,pageFieldValue,tableFields, null, isSearch, isRelationShip, relateFieldApiName, page, recordToDisply,false));
         //   pageData.objData = Database.query(getQueryString(objApiName,pageFieldApiName,null, null,pageFieldValue,tableFields, null, isSearch, page, recordToDisply,false));
            pageData.total = Database.countQuery(getQueryString(recordId,objApiName,pageFieldApiName,null, null,pageFieldValue,tableFields, null, isSearch, isRelationShip, relateFieldApiName, page, recordToDisply,true));       
            pageData.columnList = getColumns(objApiName, tableFields);
            List<SObject> objects = Database.query(getQueryString(recordId,objApiName,pageFieldApiName,null, null,pageFieldValue,tableFields, null, isSearch, isRelationShip, relateFieldApiName, page, recordToDisply,false));
            
            pageData.objData = reBuildData(objects, tableFields);
            System.debug(LoggingLevel.INFO, '*** pageData: ' + pageData);
            return JSON.serialize(pageData);
    }

    @AuraEnabled
    public static String doTableSearch(String recordId, String objApiName, String pageFieldApiName,String orderByField, String orderByDirection, String pageFieldValue, String tableFields, String searchFieldMap, Boolean isSearch, Boolean isRelationShip, String relateFieldApiName, Decimal page, Integer recordToDisply){
        PageWrapper pageData = new PageWrapper();

        Map<String,Object> searchMap = new Map<String, Object>();
        System.debug(LoggingLevel.INFO, '*** : searchFieldMap' + searchFieldMap);
        if(searchFieldMap != null){
            searchMap = (Map<String,Object>)JSON.deserializeUntyped(searchFieldMap);
        }
        List<SObject> objects = Database.query(getQueryString(recordId,objApiName,pageFieldApiName,null, null,pageFieldValue,tableFields, searchMap, isSearch, isRelationShip, relateFieldApiName, page, recordToDisply,false));
         pageData.total = Database.countQuery(getQueryString(recordId,objApiName,pageFieldApiName,null, null,pageFieldValue,tableFields, searchMap, isSearch, isRelationShip, relateFieldApiName, page, recordToDisply,true));       
        pageData.objData = reBuildData(objects, tableFields);
        return JSON.serialize(pageData);
    }
    @testvisible private static List<Map<String,Object>> reBuildData( List<SObject> objects, String tableFields) {
        List<String> splitStrList = tableFields.split(',');
        List<Map<String, Object>> dataMapList = new List<Map<String, Object>>(); 
        for(SObject objectItem : objects) {
            Map<String, Object> dataMap = new Map<String, Object>();
            System.debug(LoggingLevel.INFO, '*** objectItem: ' + objectItem);
            for(String key : splitStrList) {
                dataMap.put(key, objectItem.get(key));
                try {
                        Id keyId = Id.valueOf(String.valueOf(objectItem.get(key)));
                        String objectName = keyId.getSobjectType().getDescribe().getName();
                        String url='/lightning/r/'+ objectName + '/' + keyId +'/view';
                        dataMap.put(key+'Url', url);
                        System.debug(LoggingLevel.INFO, '*** objectName: ' + objectName);
                    } catch(Exception e) {
                        System.debug(LoggingLevel.INFO, '*** e.getMessage: ' + e.getMessage());
                        continue;
                    }
                }
                dataMapList.add(dataMap);
            }
        return dataMapList;
    }

    @testvisible private static List<SelectOption> getPaginateLabel(String apiName, String apiFieldName) {
        SObjectType objectType = Schema.getGlobalDescribe().get(apiName);
        //objectType.getDescribe().
        List<SelectOption> pickListValuesList = new List<SelectOption>();
        Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
        if (String.isBlank(apiFieldName)) {
            return null;
        }
        Schema.SObjectField grade = mfields.get(apiFieldName);
        System.debug(LoggingLevel.INFO, '*** grade: ' + grade.getDescribe().getType());
        /*获取picklist*/
        //List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = grade.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(LoggingLevel.INFO, '*** : ' + pickListVal.getLabel());
           pickListValuesList.add(new SelectOption(pickListVal.getLabel(),pickListVal.getLabel()));
        }
        return pickListValuesList;     
    }

    @testvisible private static List<Columns> getColumns(String apiName, String tableFields) {
        //String tableFields = 'Id,Name,Grade__c';
        List<String> splitStrList = tableFields.split(',');
        SObjectType objectType = Schema.getGlobalDescribe().get(apiName);
        Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
        for(String key : mfields.keySet()){
            Schema.SObjectField field = mfields.get(key);
             System.debug(LoggingLevel.INFO, '*** : ' + field.getDescribe().getLabel() + '==type==' + field.getDescribe().getType());
        }
        List<Columns> columnList = new List<Columns>();

        for(String key : splitStrList ){
            Schema.SObjectField field = mfields.get(key);
            Columns column = new Columns();

            if (field == null) {
              continue;  
            }
            Schema.DisplayType fieldType = field.getDescribe().getType();

            column.label = field.getDescribe().getLabel();
            column.fieldName = key;
            column.sortable = true;
            if (fieldType == Schema.DisplayType.ID) {
                column.type = 'url';
              // column.fieldName = 'attributes';
                if (tableFields.contains('Name')||tableFields.contains('name')) {
                    TypeAttributes attribute = new TypeAttributes();
                    Label label = new Label();
                    column.fieldName = key+'Url';
                    label.fieldName = 'Name';
                    attribute.label = label;
                    attribute.target = '_self';
                    column.typeAttributes = attribute;
                }
            } else if (fieldType == Schema.DisplayType.DATETIME) {
                column.type = 'datetime';
            } else if(fieldType == Schema.DisplayType.DATE){
                column.type = 'date';
            } else if(fieldType == Schema.DisplayType.URL) {
                column.type = 'url';
            } else if(fieldType == Schema.DisplayType.REFERENCE) {
                column.type = 'url';
                TypeAttributes attribute = new TypeAttributes();
                System.debug(LoggingLevel.INFO, '*** key: ' + key);
                    Label label = new Label();
                    column.fieldName = key+'Url';
                    label.fieldName = key;
                    attribute.label = label;
                    attribute.target = '_self';
                    column.typeAttributes = attribute;
            } else {
                 if (fieldType == Schema.DisplayType.BOOLEAN) {
                    column.sortable = false;
                 }
                 column.type = 'text';
            }
            columnList.add(column);
            //System.debug(LoggingLevel.INFO, '*** : ' + field.getDescribe().getLabel() + '==type==' + field.getDescribe().getType());
        }
        return columnList;

    }

    @testvisible private static String getQueryString(String recordId, String objApiName, String pageFieldApiName,String orderByField, String orderByDirection, String pageFieldValue, String tableFields, Map<String, Object> searchFieldMap, Boolean isSearch, Boolean isRelationShip, String relateFieldApiName,Decimal page, Integer recordToDisply, Boolean isGetNumber){
        String query = 'SElECT ' + tableFields + ' FROM ' + objApiName ;
        String getCountQuery = 'SELECT Count() FROM ' + objApiName;
        Boolean isWhereHave = false;
        Integer pageSize = recordToDisply;
        Integer offset = ((Integer)page - 1) * pageSize;
        if (!pageFieldValue.equals('ALL') && !pageFieldValue.equals('全部')) {
            query += ' WHERE ' + pageFieldApiName + '=\'' + pageFieldValue + '\'';
            getCountQuery += ' WHERE ' + pageFieldApiName + '=\'' + pageFieldValue + '\'';
            isWhereHave = true;
        } 

        if (isSearch && searchFieldMap!=null) {
            Boolean isWherehava2 = false;
            if (!isWhereHave) {
                query += ' WHERE ';
                getCountQuery += ' WHERE ';
                isWherehava2 = true;
            } 
            Integer i = 0;
            for(String key : searchFieldMap.keySet()) {
                if (i!=0 ) {
                    query += ' AND ';
                    getCountQuery += ' AND ';
                } else if(isWherehava2) {
                    
                }
                if (searchFieldMap.get(key)==null || searchFieldMap.get(key) == '') {
                    //query = query.replaceAll('WHERE', '');
                    // getCountQuery = getCountQuery.replaceAll('WHERE', '');
                    query += key + '=\'\'';
                    getCountQuery +=  key + '=\'\'';
                    //continue;
                }else{
                    query += key + ' like' + '\'%' + searchFieldMap.get(key) +'%\' ';
                    getCountQuery +=key + ' like' + '\'' + searchFieldMap.get(key) +'\' ';
                }
               // query += key + ' like' + '\'%' + searchFieldMap.get(key) +'%\' ';
                //getCountQuery += key + ' like' + '\'' + searchFieldMap.get(key) +'\' ';
                i++;
            }
        }

        if(isRelationShip) {
            if(String.isNotBlank(recordId) && String.isNotBlank(relateFieldApiName)){
                if (!isWhereHave) {
                    query += ' WHERE ';
                    getCountQuery += ' WHERE ';
                } else {
                    query += ' AND ';
                    getCountQuery += ' AND ';
                }
                query += relateFieldApiName + '=\'' + recordId + '\'';
                getCountQuery += relateFieldApiName + '=\'' + recordId+'\'';
            }
        }
        if (String.isNotBlank(orderByField)) {
            query += ' Order By ' + orderByField +  orderByDirection;
        }
        query += ' LIMIT  ' + pageSize + ' OFFSET ' + offset;
        System.debug(LoggingLevel.INFO, '*** : getCountQuery' + getCountQuery + '===query' + query);
        if (isGetNumber) {
            return getCountQuery;
        }
        return query;
    }


    public class PageWrapper{
        public List<SelectOption> pageList{set;get;}
        public List<Object> objData{set;get;}
        public List<Columns> columnList{set;get;}
        public Integer total{set;get;}
    }

    public class SelectOption{
        public String label{set;get;}
        public String value{set;get;}
        SelectOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public class Columns{
        public String label{set;get;}
        public String fieldName{set;get;}
        public Boolean sortable{ set{this.sortable=true;} get;}
        public String type{set;get;}
        public TypeAttributes typeAttributes{set;get;}
    }

    public class TypeAttributes{
        public Label label{set;get;}
        public String target{set{this.target='_self';} get;}
    }

    public class Label{
        public String fieldName{set; get;}
    }
}