({
    doInit : function(cmp, evt, helper) {
        var objApiName = cmp.get("v.objApiName");
        var pageFieldApiName = cmp.get("v.objFieldApiName");
        var tableFields = cmp.get('v.objFieldSet');
        var isSearch = cmp.get('v.isSearch');
        var searchApiFields = cmp.get('v.searchApiMap');
        console.log('====searchApiFields====='+searchApiFields.split(','));
        var splitText = searchApiFields.split(',');
        for (var i = splitText.length - 1; i >= 0; i--) {
            console.log("splitText====>" + splitText[i]);
        }
        cmp.set("v.searchFields", splitText);
       /* var searList = searchApiFields.split(',');
        console.log('searList===',searList);*/
        var isRelationShip = cmp.get("v.isRelationShip");
        var relationFieldApiName = cmp.get("v.relatedFieldApiName");
        var recordId = cmp.get('v.recordId');
        var initAction = cmp.get("c.doTablePrepare");


        //Boolean isRelationShip, String relateFieldApiName
        initAction.setParams({
            "objApiName" : objApiName,
            "recordId": recordId,
            "isRelationShip" : isRelationShip,
            "relateFieldApiName" : relationFieldApiName,
            "pageFieldApiName": pageFieldApiName,
            "tableFields": tableFields,
            "isSearch": isSearch,
            "page": 1,
            "recordToDisply": 20,
            "pageFieldValue": "ALL"
        })

        initAction.setCallback(this, function(response){
            var state = response.getState();
            console.log("state====", state);
            if (state === "SUCCESS" ) {
                var result = response.getReturnValue();
                console.log(result);
                var resultObj = JSON.parse(result);
                var options = resultObj.pageList;
                if (!$A.util.isUndefinedOrNull(options)) {
                    options.unshift({'label': 'ALL',
                            'value': 'ALL'
                        });
                }
                
                cmp.set("v.options", options);
                cmp.set("v.columns", resultObj.columnList);
                resultObj.objData.forEach(function(item, index){

                    /*if (!$A.util.isUndefinedOrNull(item.Id)) {
                        item.Id ='/lightning/r/'+ objApiName + '/' +item.Id+'/view';
                    }*/

                    
                });
                cmp.set("v.objList", resultObj.objData);
                cmp.set("v.total", resultObj.total);
                console.log("===result===", result);
            } else if (state === "ERROR") {
                console.log("====error====", response.getError());
            }

        });
        $A.enqueueAction(initAction);  

    },
    testSubmit : function(cmp, evt, helper) {
        console.log("===执行===");
         evt.preventDefault();
        const fields = evt.getParam('fields');

        //var fieldNames = Object.keys(record.fields);
        console.log('=====test===',JSON.stringify(fields));
        var searMap = JSON.stringify(fields);
        cmp.set("v.searchApiMap", searMap);
        var objApiName = cmp.get("v.objApiName");
        var pageFieldApiName = cmp.get("v.objFieldApiName");
        var tableFields = cmp.get('v.objFieldSet');
        var isSearch = cmp.get('v.isSearch');
        var searchApiFields = cmp.get('v.searchApiMap');

        var isRelationShip = cmp.get("v.isRelationShip");
        var relationFieldApiName = cmp.get("v.relatedFieldApiName");
        var recordId = cmp.get('v.recordId');
        var initAction = cmp.get("c.doTableSearch");


        //Boolean isRelationShip, String relateFieldApiName
        initAction.setParams({
            "objApiName" : objApiName,
            "recordId": recordId,
            "isRelationShip" : isRelationShip,
            "relateFieldApiName" : relationFieldApiName,
            "pageFieldApiName": pageFieldApiName,
            "tableFields": tableFields,
            "isSearch": isSearch,
            "searchFieldMap": searMap,
            "page": 1,
            "recordToDisply": 20,
            "pageFieldValue": "ALL"
        })

        initAction.setCallback(this, function(response){
            var state = response.getState();
            console.log("state====", state);
            if (state === "SUCCESS" ) {
                var result = response.getReturnValue();
                var resultObj = JSON.parse(result);
                cmp.set("v.objList", resultObj.objData);
                 cmp.set("v.total", resultObj.total);
                console.log("===result===", result);
            } else if (state === "ERROR") {
                console.log("====error====", response.getError());
            }

        });
        $A.enqueueAction(initAction);  
    },

    doTableChange : function(cmp, evt, helper) {
        var selectedOptionValue = evt.getParam("value");
        console.log('test===>', selectedOptionValue);
        var pageFieldApiName = cmp.get("v.objFieldApiName");
        var searMap = cmp.get("v.searchApiMapAndVar");
        var objApiName = cmp.get("v.objApiName");
        var pageFieldApiName = cmp.get("v.objFieldApiName");
        var tableFields = cmp.get('v.objFieldSet');
        var isSearch = cmp.get('v.isSearch');
        var searchApiFields = cmp.get('v.searchApiMap');

        var isRelationShip = cmp.get("v.isRelationShip");
        var relationFieldApiName = cmp.get("v.relatedFieldApiName");
        var recordId = cmp.get('v.recordId');
        var initAction = cmp.get("c.doTableSearch");


        //Boolean isRelationShip, String relateFieldApiName
        initAction.setParams({
            "objApiName" : objApiName,
            "recordId": recordId,
            "isRelationShip" : isRelationShip,
            "relateFieldApiName" : relationFieldApiName,
            "pageFieldApiName": pageFieldApiName,
            "tableFields": tableFields,
            "isSearch": isSearch,
            "pageFieldValue": selectedOptionValue,
            "searchFieldMap": searMap,
            "page": 1,
            "recordToDisply": 20,
            //"pageFieldValue": "ALL"
        })

        initAction.setCallback(this, function(response){
            var state = response.getState();
            console.log("state====", state);
            if (state === "SUCCESS" ) {
                var result = response.getReturnValue();
                var resultObj = JSON.parse(result);
                cmp.set("v.objList", resultObj.objData);
                 cmp.set("v.total", resultObj.total);
                console.log("===result===", result);
            } else if (state === "ERROR") {
                console.log("====error====", response.getError());
            }

        });
        $A.enqueueAction(initAction);  
    }
})