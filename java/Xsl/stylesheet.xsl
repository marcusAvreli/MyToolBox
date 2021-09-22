<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" omit-xml-declaration="yes"   indent="yes" encoding="UTF-8"/>
<!-- 
<xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
-->

<xsl:template match="/">
       <html>
              <head>
                     <title>Example</title>
                     <link href="./html/style.css" rel="stylesheet" type="text/css"/>
                     <script type="text/javascript" src="./jquery/jquery.min.js"></script>
              <script src="./html/script.js"></script>
              </head>      
              <body>
                     <h1>Bundle Details</h1>
                     <table>
                           <tr>                              
                           <th>RefNo</th>
                           <th>Type</th>
                           <th>Name</th>
                           <th>Display Name</th>
                           <th>Owner</th>                  
                           </tr>
                           <xsl:apply-templates select="sailpoint/Bundle" />
                     </table>
              </body>
       </html>
</xsl:template>
               
   
   
<xsl:template match="*">      
       <!-- <xsl:for-each select="current()">-->
       <xsl:for-each select=".">             
              <xsl:choose>
                     <xsl:when test="@type='it' or @type='business' or @type='organizational'">
                           <tr>
                                  <td>          
                                         <xsl:number/>
                                  </td>
                                  <td>            
                                         <xsl:value-of select = "@type"/>
                                  </td>
                                  <td>            
                                         <xsl:value-of select = "@name"/>
                                  </td>
                                  <td>
                                         <xsl:value-of select = "@displayName"/>
                                  </td>
                                  <td>
                                         <xsl:for-each select = ".//Owner/Reference">
                                                <xsl:value-of select = "@name"/>
                                         </xsl:for-each>
                                  </td>                      
                           </tr>                  
                     </xsl:when>                     
              </xsl:choose>              
       </xsl:for-each>    
</xsl:template>
   
   <!--
   <xsl:template match="Bundle">
      
              <xsl:for-each select="@name[current()/@type='business']">
              <xsl:if test="not(name)">
               <tr>
              <td>
                       
                        <xsl:value-of select="." />
                         
                        
                     </td>
                   
                     </tr>
                        </xsl:if>
               </xsl:for-each>
            
         
      
   </xsl:template> 
    -->
</xsl:stylesheet>
