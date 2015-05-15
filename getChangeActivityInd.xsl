<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" omit-xml-declaration="yes" indent="no"/>
<xsl:strip-space elements="*"/>
<xsl:template match="/">

<AgencySynchronizationFile>
<xsl:text>&#xa;</xsl:text>
<RecordCount><xsl:value-of select="count(/AgencySynchronizationFile/AgencySynchronization[Producer/GeneralPartyInfo/ProducerInfo/ChangeActivityInd = 'Y'])"/></RecordCount>
<xsl:text>&#xa;</xsl:text>
<xsl:for-each select="/AgencySynchronizationFile/AgencySynchronization[Producer/GeneralPartyInfo/ProducerInfo/ChangeActivityInd = 'Y']">
<xsl:copy>
<xsl:copy-of select="@*|node()"/>
</xsl:copy>
<xsl:text>&#xa;</xsl:text>
</xsl:for-each>
</AgencySynchronizationFile>
</xsl:template>
</xsl:stylesheet>
