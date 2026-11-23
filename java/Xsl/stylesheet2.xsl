<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xalan="http://xml.apache.org/xslt">

    <!-- Same 2-space formatting and key ordering as WellAligned.txt. -->
    <xsl:output method="xml" encoding="UTF-8" indent="yes"
                omit-xml-declaration="no" xalan:indent-amount="2"
                doctype-public="sailpoint.dtd" doctype-system="sailpoint.dtd"/>
    <xsl:strip-space elements="*"/>

    <!-- Sorting only: Java's default text collation is case-insensitive.
         These two sort keys enforce the source's case-sensitive ASCII order.
         The ordinal characters below are used ONLY for comparing keys;
         they never appear in the output XML. -->
    <xsl:variable name="ascii" select="'-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="asciiOrdinal" select="'&#xE000;&#xE001;&#xE002;&#xE003;&#xE004;&#xE005;&#xE006;&#xE007;&#xE008;&#xE009;&#xE00A;&#xE00B;&#xE00C;&#xE00D;&#xE00E;&#xE00F;&#xE010;&#xE011;&#xE012;&#xE013;&#xE014;&#xE015;&#xE016;&#xE017;&#xE018;&#xE019;&#xE01A;&#xE01B;&#xE01C;&#xE01D;&#xE01E;&#xE01F;&#xE020;&#xE021;&#xE022;&#xE023;&#xE024;&#xE025;&#xE026;&#xE027;&#xE028;&#xE029;&#xE02A;&#xE02B;&#xE02C;&#xE02D;&#xE02E;&#xE02F;&#xE030;&#xE031;&#xE032;&#xE033;&#xE034;&#xE035;&#xE036;&#xE037;&#xE038;&#xE039;&#xE03A;&#xE03B;&#xE03C;&#xE03D;&#xE03E;&#xE03F;&#xE040;'"/>

    <!-- Copy every element, attribute, value and %% token verbatim. -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Apply key ordering recursively to each SailPoint Map. -->
    <xsl:template match="Map">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each select="entry">
                <!-- ASCII keys before non-ASCII keys, as in the reference. -->
                <xsl:sort select="string-length(translate(substring(@key, 1, 1), $ascii, ''))"
                          data-type="number" order="ascending"/>
                <xsl:sort select="translate(@key, $ascii, $asciiOrdinal)"
                          data-type="text" order="ascending"/>
                <!-- Preserve comments immediately preceding their entry. -->
                <xsl:apply-templates select="preceding-sibling::node()[1][self::comment()]"/>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
            <xsl:apply-templates select="*[not(self::entry)]|text()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
