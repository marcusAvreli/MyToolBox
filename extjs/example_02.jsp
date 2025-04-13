<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<html>
<head>

<link href = "scripts/ext-4.1.0/resources/css/ext-all.css"          rel = "stylesheet" />
<script type="text/javascript" src = "scripts/ext-4.1.0/ext-all.js"> 
          
	
</script>
	
</head>
	<body>

        <script type = "text/javascript">
Ext.define('MyApp.SearchCombo', {
    override: 'Ext.form.field.ComboBox',


    doLocalQuery: function(queryPlan) {
        var me = this,
            queryString = queryPlan.query,
            store = me.getStore(),
            filter = me.queryFilter;

        me.queryFilter = null;

        // Must set changingFilters flag for this.checkValueOnChange.
        // the suppressEvents flag does not affect the filterchange event
        me.changingFilters = true;
        if (filter) {
            store.removeFilter(filter, true);
        }

        // Querying by a string...
        if (queryString) {
            filter = me.queryFilter = new Ext.util.Filter({
                id: me.id + '-filter',
                anyMatch: me.anyMatch,
                caseSensitive: me.caseSensitive,
                root: 'data',
                property: me.searchField || me.displayField,
                value: me.enableRegEx ? new RegExp(queryString) : queryString
            });
            store.addFilter(filter, true);
        }
        me.changingFilters = false;

        // Expand after adjusting the filter if there are records or if emptyText is configured.
        if (me.store.getCount() || me.getPicker().emptyText) {
            // The filter changing was done with events suppressed, so
            // refresh the picker DOM while hidden and it will layout on show.
            me.getPicker().refresh();
            me.expand();
        } else {
            me.collapse();
        }

        me.afterQuery(queryPlan);
    }
});


var states = Ext.create('Ext.data.Store', {
    fields: ['id', 'name', 'description'],
    data : [
        {"id":"1", "name":"AL", "description":"Alabama"},
        {"id":"2", "name":"BK", "description":"Claska"},
        {"id":"3", "name":"CZ", "description":"Zrizona"}
    ]
});


Ext.create('Ext.form.ComboBox', {
    id: 'combo01',
    fieldLabel: 'Choose State',
    queryMode: 'local',
    triggerAction: 'all',
    forceSelection: false,
    enableKeyEvents: true,
    editable: true,
    anyMatch: true,
    valueField: 'id',
    margin: 20,
    displayField: 'name',
    searchField: 'description',
    listConfig: {
        itemTpl: '{description}'
    },
    store: states,
    renderTo: Ext.getBody()
});
	              </script>
  <div id="helloWorldPanel"></div>



    </body>
	
</html>



