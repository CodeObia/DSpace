<?xml version="1.0" encoding="UTF-8" ?>
<!-- 


    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/
	Developed by DSpace @ Lyncode <dspace@lyncode.com>

 -->
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://www.lyncode.com/xoai"
	version="1.0">
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />

	<xsl:template match="/">
		<mods:mods xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-1.xsd">
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element/doc:field[@name='value']">
				<mods:name>
					<mods:contributor><xsl:value-of select="." /></mods:contributor>
				</mods:name>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element/doc:field[@name='value']">
				<mods:name>
					<mods:creator><xsl:value-of select="." /></mods:creator>
				</mods:name>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element/doc:field[@name='value']">
				<mods:name>
					<mods:creator type="contact"><xsl:value-of select="." /></mods:creator>
				</mods:name>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='contributor']/doc:element/doc:element/doc:field[@name='value']">
				<mods:name>
					<mods:contributor>
						<xsl:attribute name="type">
							<xsl:value-of select="../../@name"/>
						</xsl:attribute>
						<xsl:value-of select="."/>
					</mods:contributor>
				</mods:name>
			</xsl:for-each>
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:field[@name='value']">
				<mods:originInfo>
					<mods:dateOther encoding="iso8601">
						<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
					</mods:dateOther>
				</mods:originInfo>
			</xsl:if>
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='accessioned']/doc:element/doc:field[@name='value']">
			<mods:extension>
				<mods:dateAvailable encoding="iso8601">
					<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='accessioned']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
				</mods:dateAvailable>
			</mods:extension>
			</xsl:if>
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='available']/doc:element/doc:field[@name='value']">
			<mods:extension>
				<mods:dateAccessioned encoding="iso8601">
					<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='available']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
				</mods:dateAccessioned>
			</mods:extension>
			</xsl:if>
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">
			<mods:originInfo>
				<mods:dateIssued encoding="iso8601">
					<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
				</mods:dateIssued>
			</mods:originInfo>
			</xsl:if>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element/doc:element/doc:field[@name='value']">
			<mods:identifier>
				<xsl:attribute name="type">
					<xsl:value-of select="../../@name" />
				</xsl:attribute>
				<xsl:value-of select="." />
			</mods:identifier>
			</xsl:for-each>
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element/doc:field[@name='value']">
                <mods:identifier>
                    <xsl:attribute name="type">url</xsl:attribute>
                    <xsl:value-of select="." />
                </mods:identifier>
            </xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='identifier']/doc:element[@name='doi']/doc:element/doc:field[@name='value']">
				<mods:identifier>
					<xsl:attribute name="type">
						<xsl:value-of select="../../@name" />
					</xsl:attribute>
					<xsl:value-of select="." />
				</mods:identifier>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']">
				<mods:abstract><xsl:value-of select="." /></mods:abstract>
			</xsl:for-each>
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:field[@name='value']">
			<mods:language>
				<mods:languageTerm><xsl:value-of select="." /></mods:languageTerm>
			</mods:language>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:element/doc:field[@name='value']">
			<mods:accessCondition type="useAndReproduction"><xsl:value-of select="." /></mods:accessCondition>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field[@name='value']">
			<mods:accessCondition type="useAndReproduction"><xsl:value-of select="." /></mods:accessCondition>
			</xsl:for-each>
			<xsl:if test="doc:metadata/doc:element[@name='cg']/doc:element[@name='date']/doc:element[@name='embargo-end-date']/doc:element/doc:field[@name='value']">
				<mods:extension>
					<mods:embargoEndDate encoding="iso8601">
						<xsl:value-of select="doc:metadata/doc:element[@name='cg']/doc:element[@name='date']/doc:element[@name='embargo-end-date']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
					</mods:embargoEndDate>
				</mods:extension>
			</xsl:if>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:field[@name='value']">
			<mods:subject>
				<mods:topic><xsl:value-of select="." /></mods:topic>
			</mods:subject>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='subject']/doc:element[@name='agrovoc']/doc:element/doc:field[@name='value']">
				<mods:subject>
					<mods:topic><xsl:value-of select="." /></mods:topic>
				</mods:subject>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
			<mods:titleInfo>
				<mods:title><xsl:value-of select="." /></mods:title>
			</mods:titleInfo>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']">
			<mods:genre><xsl:value-of select="." /></mods:genre>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='coverage']/doc:element/doc:element/doc:field[@name='value']">
				<mods:coverage>
					<xsl:attribute name="type">
						<xsl:value-of select="../../@name" />
					</xsl:attribute>
					<xsl:value-of select="." />
				</mods:coverage>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='format']/doc:element/doc:field[@name='value']">
				<mods:physicalDescription>
					<mods:form><xsl:value-of select="." /></mods:form>
				</mods:physicalDescription>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
				<mods:originInfo>
					<mods:publisher><xsl:value-of select="." /></mods:publisher>
				</mods:originInfo>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element/doc:field[@name='value']">
				<mods:relatedItem type="original"><xsl:value-of select="." /></mods:relatedItem>
			</xsl:for-each>
		</mods:mods>
	</xsl:template>
</xsl:stylesheet>
