<!DOCTYPE html>
<html>
<head>

<link href = "scripts/ext-4.1.0/resources/css/ext-all.css"          rel = "stylesheet" />
<script type="text/javascript" src = "scripts/ext-4.1.0/ext-all.js"/> 
          
	


</head>

	  
	 <body>
		 <!--
        <script>
            Ext.onReady(function() {
                Ext.Msg.alert('Welcome', 'Hello, World!');
            });
        </script>
	-->


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

