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
         Ext.onReady(function() {
            Ext.create('Ext.Panel', {
               renderTo: 'helloWorldPanel',
               height: 200,
               width: 600,
               title: 'Hello world',
               html: 'First Ext JS Hello World Program'
            });
         });
      </script>
  <div id="helloWorldPanel"></div>



    </body>
	
</html>
