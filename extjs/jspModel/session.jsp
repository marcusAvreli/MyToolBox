<%@ page trimDirectiveWhitespaces="true" %>
<%@ page language="java" contentType="text/html; charset=utf-8" 	pageEncoding="utf-8"%>
<%@ page import="sailpoint.integration.JsonUtil" %>
<%@ page import="sailpoint.api.SailPointContext" %>
<%@ page import="sailpoint.api.SailPointFactory" %>
<%@ page import="sailpoint.object.Filter" %>
<%@ page import="sailpoint.object.QueryOptions" %>
<%@ page import="sailpoint.object.TaskDefinition" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.lang.String" %>
<%@ page import="java.lang.StringBuffer" %>
<%@ page import="java.util.Date" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>
<html>
<head>

<link href = "../scripts/ext-4.1.0/resources/css/ext-all.css"          rel = "stylesheet" />
<script type="text/javascript" src = "../scripts/ext-4.1.0/ext-all.js"> 
          
	
</script>
	<%
	Map <String,Object> resultRow = new HashMap<String,Object>();
	List<JSONObject> resultList = new ArrayList<JSONObject>();

SailPointContext context = SailPointFactory.getCurrentContext();
List<TaskDefinition> taskDefinitions = context.getObjects(TaskDefinition.class,null);
for(TaskDefinition taskDefinition : taskDefinitions){
	//resultRow = new HashMap<String,Object>();
	String name = taskDefinition.getName();
	String type = taskDefinition.getType().toString();
	Date created = taskDefinition.getCreated();
	resultRow.put("name",name);
	resultRow.put("type",type);
	resultRow.put("created",created);
	JSONObject jsonMap = new JSONObject(resultRow);
	resultList.add(jsonMap);
}
System.out.println("result:"+resultList);
StringBuffer sb = new StringBuffer("abc");
sb.append(resultList.toString());
String parsedJson = JsonUtil.render(resultList.toString());
System.out.println("parsedJson:"+parsedJson);


JSONArray resultJson = new JSONArray(resultList);
   System.out.println("parsedJson:"+resultJson); 
String fromJSP = "test123341234123441234123412341234123412341234123412341234123412341234123412341234123412341234123412341234123412341234123412341234123412341234123412341234123412341234123412341234123412341234123412341234123412341234123412341234";
String chrome ="Hello World1";       


%>
	  <script>
//	var javaScriptVar="<%out.print(chrome);%>"
//	var parsedJson = "<%out.print(parsedJson);%>"
  
      var parsedJson = '<%=(null != resultJson) ? resultJson : ""%>' 
	    //    console.log("parsedJson:"+parsedJson);

      var chrome = "<%out.print(chrome);%>" 
      console.log("chrome:"+chrome);
	    console.log("resultJson:"+parsedJson);
  </script>
  	<!-- exporter js -->
        <script src="exporter.js"></script>

        <!-- Ext JS DataGrid -->
        <script src="export-grid.js"></script>

</head>
	<body>

		test
	  <div id="helloWorldPanel"></div>

 <div id="grid-example"></div>


    </body>
	
</html>



