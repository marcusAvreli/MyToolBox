/**
*
*  Base64 encode / decode
*  http://www.webtoolkit.info/
*
**/

var Base64 = (function() {

    // private property
    var keyStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

    // private method for UTF-8 encoding
    function utf8Encode(string) {
        string = string.replace(/\r\n/g,"\n");
        var utftext = "";
        for (var n = 0; n < string.length; n++) {
            var c = string.charCodeAt(n);
            if (c < 128) {
                utftext += String.fromCharCode(c);
            }
            else if((c > 127) && (c < 2048)) {
                utftext += String.fromCharCode((c >> 6) | 192);
                utftext += String.fromCharCode((c & 63) | 128);
            }
            else {
                utftext += String.fromCharCode((c >> 12) | 224);
                utftext += String.fromCharCode(((c >> 6) & 63) | 128);
                utftext += String.fromCharCode((c & 63) | 128);
            }
        }
        return utftext;
    }

    // public method for encoding
    return {
        encode : (typeof btoa == 'function') ? function(input) { return btoa(utf8Encode(input)); } : function (input) {
            var output = "";
            var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
            var i = 0;
            input = utf8Encode(input);
            while (i < input.length) {
                chr1 = input.charCodeAt(i++);
                chr2 = input.charCodeAt(i++);
                chr3 = input.charCodeAt(i++);
                enc1 = chr1 >> 2;
                enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
                enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
                enc4 = chr3 & 63;
                if (isNaN(chr2)) {
                    enc3 = enc4 = 64;
                } else if (isNaN(chr3)) {
                    enc4 = 64;
                }
                output = output +
                keyStr.charAt(enc1) + keyStr.charAt(enc2) +
                keyStr.charAt(enc3) + keyStr.charAt(enc4);
            }
            return output;
        }
    };
})();

Ext.LinkButton = Ext.extend(Ext.Button, {
    template: new Ext.Template(
        '<table border="0" cellpadding="0" cellspacing="0" class="x-btn-wrap"><tbody><tr>',
        '<td class="x-btn-left"><i> </i></td><td class="x-btn-center"><a class="x-btn-text" href="{1}" target="{2}">{0}</a></td><td class="x-btn-right"><i> </i></td>',
        "</tr></tbody></table>"),
    
    onRender:   function(ct, position){
        var btn, targs = [this.text || ' ', this.href, this.target || "_self"];
        if(position){
            btn = this.template.insertBefore(position, targs, true);
        }else{
            btn = this.template.append(ct, targs, true);
        }
        var btnEl = btn.child("a:first");
        btnEl.on('focus', this.onFocus, this);
        btnEl.on('blur', this.onBlur, this);

        this.initButtonEl(btn, btnEl);
        Ext.ButtonToggleMgr.register(this);
    },

    onClick : function(e){
        if(e.button != 0){
            return;
        }
        if(!this.disabled){
            this.fireEvent("click", this, e);
            if(this.handler){
                this.handler.call(this.scope || this, this, e);
            }
        }
    }

});


Ext.override(Ext.grid.GridPanel, {
    getExcelXml: function(includeHidden) {
	    console.log("get_excel_xml_started");
        var worksheet = this.createWorksheet(includeHidden);
        var totalWidth = this.getView().getHeaderCt().getFullWidth();
        return '<?xml version="1.0" encoding="utf-8"?>' +
            '<ss:Workbook xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:o="urn:schemas-microsoft-com:office:office">' +
            '<o:DocumentProperties><o:Title>' + this.title + '</o:Title></o:DocumentProperties>' +
            '<ss:ExcelWorkbook>' +
                '<ss:WindowHeight>' + worksheet.height + '</ss:WindowHeight>' +
                '<ss:WindowWidth>' + worksheet.width + '</ss:WindowWidth>' +
                '<ss:ProtectStructure>False</ss:ProtectStructure>' +
                '<ss:ProtectWindows>False</ss:ProtectWindows>' +
            '</ss:ExcelWorkbook>' +
            '<ss:Styles>' +
                '<ss:Style ss:ID="Default">' +
                    '<ss:Alignment ss:Vertical="Top" ss:WrapText="1" />' +
                    '<ss:Font ss:FontName="arial" ss:Size="10" />' +
                    '<ss:Borders>' +
                        '<ss:Border ss:Color="#e4e4e4" ss:Weight="1" ss:LineStyle="Continuous" ss:Position="Top" />' +
                        '<ss:Border ss:Color="#e4e4e4" ss:Weight="1" ss:LineStyle="Continuous" ss:Position="Bottom" />' +
                        '<ss:Border ss:Color="#e4e4e4" ss:Weight="1" ss:LineStyle="Continuous" ss:Position="Left" />' +
                        '<ss:Border ss:Color="#e4e4e4" ss:Weight="1" ss:LineStyle="Continuous" ss:Position="Right" />' +
                    '</ss:Borders>' +
                    '<ss:Interior />' +
                    '<ss:NumberFormat />' +
                    '<ss:Protection />' +
                '</ss:Style>' +
                '<ss:Style ss:ID="title">' +
                    '<ss:Borders />' +
                    '<ss:Font />' +
                    '<ss:Alignment ss:WrapText="1" ss:Vertical="Center" ss:Horizontal="Center" />' +
                    '<ss:NumberFormat ss:Format="@" />' +
                '</ss:Style>' +
                '<ss:Style ss:ID="headercell">' +
                    '<ss:Font ss:Bold="1" ss:Size="10" />' +
                    '<ss:Alignment ss:WrapText="1" ss:Horizontal="Center" />' +
                    '<ss:Interior ss:Pattern="Solid" ss:Color="#A3C9F1" />' +
                '</ss:Style>' +
                '<ss:Style ss:ID="even">' +
                    '<ss:Interior ss:Pattern="Solid" ss:Color="#CCFFFF" />' +
                '</ss:Style>' +
                '<ss:Style ss:Parent="even" ss:ID="evendate">' +
                    '<ss:NumberFormat ss:Format="[ENG][$-409]dd\-mmm\-yyyy;@" />' +
                '</ss:Style>' +
                '<ss:Style ss:Parent="even" ss:ID="evenint">' +
                    '<ss:NumberFormat ss:Format="0" />' +
                '</ss:Style>' +
                '<ss:Style ss:Parent="even" ss:ID="evenfloat">' +
                    '<ss:NumberFormat ss:Format="0.00" />' +
                '</ss:Style>' +
                '<ss:Style ss:ID="odd">' +
                    '<ss:Interior ss:Pattern="Solid" ss:Color="#CCCCFF" />' +
                '</ss:Style>' +
                '<ss:Style ss:Parent="odd" ss:ID="odddate">' +
                    '<ss:NumberFormat ss:Format="[ENG][$-409]dd\-mmm\-yyyy;@" />' +
                '</ss:Style>' +
                '<ss:Style ss:Parent="odd" ss:ID="oddint">' +
                    '<ss:NumberFormat ss:Format="0" />' +
                '</ss:Style>' +
                '<ss:Style ss:Parent="odd" ss:ID="oddfloat">' +
                    '<ss:NumberFormat ss:Format="0.00" />' +
                '</ss:Style>' +
            '</ss:Styles>' +
            worksheet.xml +
            '</ss:Workbook>';
    },

    createWorksheet: function(includeHidden) {

//      Calculate cell data types and extra class names which affect formatting
        var cellType = [];
        var cellTypeClass = []  ;
	    var records = [];
	    console.log("create_wrok_sheet_started_1");
        var cm = this.getView().headerCt.getGridColumns();
	var cm2 = this.getSelectedIds();
	    if(cm && cm.length>0){
		var thisStore =    this.getStore();
		var thisProxy = thisStore.getProxy();
		console.log("proxy:"+thisProxy);
		console.log(thisProxy.getReader().rawData);
		  records   = this.getView().getSelectionModel( ).getSelection();
		console.log("selection:"+records);
		var pageSize = thisStore.pageSize;
		var totalCount = thisStore.totalCount;
for (var thisPageNumber=0; thisPageNumber<(totalCount/pageSize)+1;thisPageNumber++) {
//	var thisPage = thisStore.slice((thisPageNumber - 1) * pageSize, thisPageNumber  * pageSize);i
	 var start = 0;
	var end = Math.min(start + pageSize - 1, totalCount);
//	console.log("start:"+start+ " end: "+end);
//	var loadedRange = Ext.getStore('Translation').getResultSet();
//	console.log("loadedRange:"+JSON.stringify(loadedRange[0]));
//	var thisPage = thisStore.getRange(thisPageNumber*pageSize,thisPageNumber*pageSize+pageSize-1);
//	console.log("thisPage:"+thisPage);
//	var newArray = thisPage.filter(function (el) {

//		return el;
//	});
//	console.log("filteredArray:"+newArray);

}
//		    console.log("translation:"+translation);
//		    console.log("translation:"+translation.data.length);
//		    console.log("translation:"+translation.totalCount);
//		    console.log("translation:"+translation.getRange());
		    /*
		    var newArray = cm2.filter(function (el) {
  return el.price <= 1000 &&
         el.sqft >= 500 &&
         el.num_of_beds >=2 &&
         el.num_of_baths >= 2.5;
});
		    */
	    }
	    console.log("selected_columns:"+cm2[0]);
console.log("selected_columns:"+cm.length);
        var totalWidthInPixels = 0;
        var colXml = '';
        var headerXml = '';
	        for (var i = 1; i < cm.length+1; i++) {
            
                var w =15; 
		  var headerC = this.getView().getHeaderCt().items.length;
		     var header = this.getView().getHeaderCt().getHeaderAtIndex(i);
		    //var records = selection;
if(this.getSelectionModel( ).isSelected(1000)){
		    console.log("records_1:"+JSON.stringify(this.getSelectionModel( ).isSelected(120)));
}
  var myrecord = this.store.getAt(1);

console.log("myrecord:"+myrecord);
console.log("myrecord:"+JSON.stringify(typeof(myrecord)));
console.log("myrecord_selected:"+this.getView().getSelectionModel().isSelected(myrecord));
console.log("myrecord:"+myrecord.getId());


		    console.log("records_2:"+records.length);
		    console.log("headerC:"+headerC);
		    console.log("headerC:"+header);
		    
if(header && header.text){
                totalWidthInPixels += w;
                colXml += '<ss:Column ss:AutoFitWidth="1" ss:Width="' + w + '" />';
                headerXml += '<ss:Cell ss:StyleID="headercell">' +
                    '<ss:Data ss:Type="String">' + header.text + '</ss:Data>' +
                    '<ss:NamedCell ss:Name="Print_Titles" /></ss:Cell>';
		     var record = records[0];
		    
			console.log("record:"+(record.type));
		    console.log("column_name:"+cm[i].dataIndex);
		     var fld2 = this.store.model.prototype.fields.map[cm[1].dataIndex];
		    console.log("fld:"+fld2);
		   
		    console.log("fld_type:"+fld2.type);
		    console.log("fld_type_type:"+fld2.type.type);
                //var fld = this.store.recordType.prototype.fields.get(cm.getDataIndex(i));
                switch(fld2.type.type) {
                    case "int":
                        cellType.push("Number");
                        cellTypeClass.push("int");
                        break;
                    case "float":
                        cellType.push("Number");
                        cellTypeClass.push("float");
                        break;
                    case "bool":
                    case "boolean":
                        cellType.push("String");
                        cellTypeClass.push("");
                        break;
                    case "date":
                        cellType.push("String");
                        cellTypeClass.push("");
                        break;
                    default:
                        cellType.push("String");
                        cellTypeClass.push("");
                        break;
                }
} 
        }
        var visibleColumnCount = cellType.length;

        var result = {
            height: 9000,
            width: Math.floor(totalWidthInPixels * 30) + 50
        };

//      Generate worksheet header details.
        var t = '<ss:Worksheet ss:Name="' + this.title + '">' +
            '<ss:Names>' +
                '<ss:NamedRange ss:Name="Print_Titles" ss:RefersTo="=\'' + this.title + '\'!R1:R2" />' +
            '</ss:Names>' +
            '<ss:Table x:FullRows="1" x:FullColumns="1"' +
                ' ss:ExpandedColumnCount="' + visibleColumnCount +
                '" ss:ExpandedRowCount="' + (this.store.getCount() + 2) + '">' +
                colXml +
                '<ss:Row ss:Height="38">' +
                    '<ss:Cell ss:StyleID="title" ss:MergeAcross="' + (visibleColumnCount - 1) + '">' +
                      '<ss:Data xmlns:html="http://www.w3.org/TR/REC-html40" ss:Type="String">' +
                        '<html:B><html:U><html:Font html:Size="15">' + this.title +
                        '</html:Font></html:U></html:B></ss:Data><ss:NamedCell ss:Name="Print_Titles" />' +
                    '</ss:Cell>' +
                '</ss:Row>' +
                '<ss:Row ss:AutoFitHeight="1">' +
                headerXml + 
                '</ss:Row>';

//      Generate the data rows from the data in the Stor
	    console.log("cm:"+cm);
	    console.log("cm_items_object:"+cm[0]);
        for (var i = 0, it = records, l = records.length; i < l; i++) {
            t += '<ss:Row>';
            var cellClass = (i & 1) ? 'odd' : 'even';
            r = it[i].data;
		console.log("row_initialized:"+r);
		console.log("row_initialized:"+it[i].itemi);
            var k = 0;
            for (var j = 0; j < cm.length; j++) {
		    console.log("checkPost_2");
		     console.log("cm_items_object_2:"+cm[0].dataIndex);
                if (includeHidden || !cm[j].isHidden()) {
			console.log("checkPost_3:"+cm);
			console.log("checkPost_row_as_object:"+r);
			console.log("row_as_string_1:"+JSON.stringify(r));
                   var  col = cm[j];
			console.log("cm[j]index:"+j);
console.log("cm_value_of_j:"+col.dataIndex);
                       var  v = r[col.dataIndex];

			console.log("checkPost_table_1_v:"+v);
console.log("checkPost_table_1_cellClass:"+cellClass);
			console.log("checkPost_table_1_cellTypeClass:"+cellTypeClass[k]);
			 console.log("checkPost_table_1_cellType:"+cellType[k]);
                    t += '<ss:Cell ss:StyleID="' + cellClass + cellTypeClass[k] + '"><ss:Data ss:Type="' + cellType[k] + '">';
			
                        if (cellType[k] == 'DateTime') {
				console.log("setting_dateTime:"+v);

				console.log("setting_dateTime:"+Ext.Date.format(v,'Y-m-d'));
                    //       t += Ext.Date.format(v,'Y-m-d');
					v = new Date(v);
                            t += v.format('Y-m-d\\TH:i:s');
				console.log("setting_dateTime_1:"+t);
		//	  t += v.format('Y-m-d');
                        } else {
				console.log("setting_other_type");
                            t += Ext.htmlEncode(v);
                        }
                    t +='</ss:Data></ss:Cell>';
                    k++;
                }
            }
            t += '</ss:Row>';
        }

        result.xml = t + '</ss:Table>' +
            '<x:WorksheetOptions>' +
                '<x:PageSetup>' +
                    '<x:Layout x:CenterHorizontal="1" x:Orientation="Landscape" />' +
                    '<x:Footer x:Data="Page &amp;P of &amp;N" x:Margin="0.5" />' +
                    '<x:PageMargins x:Top="0.5" x:Right="0.5" x:Left="0.5" x:Bottom="0.8" />' +
                '</x:PageSetup>' +
                '<x:FitToPage />' +
                '<x:Print>' +
                    '<x:PrintErrors>Blank</x:PrintErrors>' +
                    '<x:FitWidth>1</x:FitWidth>' +
                    '<x:FitHeight>32767</x:FitHeight>' +
                    '<x:ValidPrinterInfo />' +
                    '<x:VerticalResolution>600</x:VerticalResolution>' +
                '</x:Print>' +
                '<x:Selected />' +
                '<x:DoNotDisplayGridlines />' +
                '<x:ProtectObjects>False</x:ProtectObjects>' +
                '<x:ProtectScenarios>False</x:ProtectScenarios>' +
            '</x:WorksheetOptions>' +
        '</ss:Worksheet>';
        return result;
    }
});

