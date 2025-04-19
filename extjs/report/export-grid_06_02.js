Ext.Loader.setConfig({
    enabled: true
});
Ext.onReady(function(){

	Ext.Loader.setConfig({
    enabled: true
	});
Ext.create('Ext.container.Viewport', {
	 requires: [
        'Ext.rtl.*'
    ],
                rtl: true
}
)
	console.log("updated_1");
var decodedString = Ext.decode(parsedJson);
  var PAGE_SIZE = 25;
  //array with data - dummy data
       	 Ext.define('TranslationServiceModel', {
        extend: 'Ext.data.Model',
        fields: [
		{name: 'id'}
            ,{name: 'name'}
		,{name:"type"}
		,{name:"created" ,type: 'date' ,convert : function(value){
			
			//var formatted = new Date(value);
			var formatted = Ext.Date.format(value, 'd-M-Y');
			

			return new Date(value);
		}
		}

           
        ]
    });
var translationServiceStore = Ext.create('Ext.data.ArrayStore', {
        model: 'TranslationServiceModel'
	,	 data: decodedString 
	,storeId: "Translation"
	, pageSize:PAGE_SIZE
    });


  translationServiceStore.on('load', function(store, records, successful, operation) {
        this.loadData(decodedString.slice((this.currentPage-1)*PAGE_SIZE, (this.currentPage)*PAGE_SIZE));
    },translationServiceStore);

translationServiceStore.load(decodedString);
//translationServiceStore.loadData(decodedString);



   

    //data store - description of fields

	 var exportButton = new Ext.Button ({
        text:'Export to Excel',
        listeners: {
            click: function () {
                window.location = 'data:application/vnd.ms-excel;base64,' +
                    Base64.encode(grid.getExcelXml());
            }
        }
    });
	    var linkButton = new Ext.LinkButton({
        id: 'grid-excel-button',
        text: 'Export to Excel'
    });
//the page navigation for the users in a group
var pageNavigation = new Ext.PagingToolbar({
            pageSize: PAGE_SIZE
           ,store: translationServiceStore
           ,displayInfo: true 

            
           
           , emptyMsg: "No Users to display"
            
        });

    // create the Grid
console.log("update4");
var selectionColumn =  new SailPoint.grid.CheckboxSelectionModel(); 
    var grid = new SailPoint.grid.PagingCheckboxGrid({
        id: 'static-grid',
        store: translationServiceStore,
        columns: [
		{header: 'Id', width: 170, sortable: true, dataIndex: 'id'}
                 , {header: 'NAME', width: 170, sortable: true, dataIndex: 'name'}
		,{header:'TYPE',width: 170, sortable: true, dataIndex: 'type'}
		,{header:'תאריך יצירה' , width:170, sortable:true,dataIndex:'created', renderer: function(d) {
                        return Ext.Date.format(d, 'Y-m-d H:m:s');
                    }   }
                     ],
        stripeRows: true,
       
        width: 580,
	    height: 300,
        title:'My Contacts'
	   , selModel : selectionColumn
,columnLines: true
	    , autoScroll: true
	 ,    viewConfig:{
            autoFill:true,
            stripeRows:true
        }
      	,bbar: new Ext.Toolbar({
            items: [
		    exportButton,pageNavigation
	    ]
		    
	})	
       
	  
	  
    });
//:grid.selectAll();

    grid.render('grid-example');
	// var btn, targs = linkButton.getTemplateArgs();
   //linkButton.getEl().child('a', true).href = 'data:application/vnd.ms-excel;base64,' +
     //   Base64.encode(grid.getExcelXml());

});
