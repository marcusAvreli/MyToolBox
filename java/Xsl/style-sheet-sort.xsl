<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

       version="1.0"

       xmlns:redirect="http://xml.apache.org/xalan/redirect"

       extension-element-prefixes="redirect"

       xmlns:xalan="http://xml.apache.org/xslt">

       <!-- keeps xml looking good :)-->

<xsl:output method="xml" indent="yes" omit-xml-declaration="no" xalan:indent-amount="2" doctype-public="sailpoint.dtd"   doctype-system="sailpoint.dtd"/>

 

 

<!-- removes white spaces -->

<xsl:strip-space elements="*"/> 

<xsl:template match="@*|node()">

       <xsl:copy>         

              <xsl:apply-templates select="@*|node()">

                     <xsl:sort select="@key" data-type="text" order="ascending"/>

              </xsl:apply-templates>

       </xsl:copy>

</xsl:template>

<!--  removes created modified and id -->

<xsl:template match="@created|@modified|@id|@significantModified"/>

<!-- removes tags RoleIndex and RoleScorecard -->

<xsl:template match="RoleIndex|RoleScorecard"/>