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
			<!-- <mods:titleInfo><mods:title> dc.title </mods:title></mods:titleInfo> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
				<mods:titleInfo>
					<mods:title><xsl:value-of select="." /></mods:title>
				</mods:titleInfo>
			</xsl:for-each>

			<!-- <mods:name type="personal"><mods:role><roleTerm type="text" authroity="marcrelator">creator</roleTerm><roleTerm type="code" authority="marcrelator">cre</roleTerm></mods:role><mods:namePart> dc.creator </mods:namePart><mods:role><roleTerm valueURI="ORCID"/></mods:role></mods:name> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element/doc:field[@name='value']">
				<mods:name type="personal">
					<role>
						<roleTerm type="text" authroity="marcrelator">creator</roleTerm>
						<roleTerm type="code" authority="marcrelator">cre</roleTerm>
					</role>
					<xsl:variable name="creator_name"><xsl:value-of select="."/></xsl:variable>
					<mods:namePart><xsl:value-of select="$creator_name"/></mods:namePart>

					<xsl:for-each select="/doc:metadata/doc:element[@name='cg']/doc:element[@name='creator']/doc:element[@name='id']/doc:element/doc:field[@name='value']">
						<xsl:variable name="creatorId" select="."/>
						<xsl:analyze-string select="normalize-space($creatorId)" regex="^(.*):\s(\d{{4}}-\d{{4}}-\d{{4}}-\d{{4}})$">
							<xsl:matching-substring>
								<xsl:if test="$creator_name = regex-group(1)">
									<xsl:variable name="orcid" select="regex-group(2)"/>
									<role>
										<roleTerm>
											<xsl:attribute name="valueURI">
												<xsl:value-of select="$orcid"/>
											</xsl:attribute>
										</roleTerm>
									</role>
								</xsl:if>
							</xsl:matching-substring>
						</xsl:analyze-string>
					</xsl:for-each>
				</mods:name>
			</xsl:for-each>

			<!-- <mods:name type="personal"><mods:role><roleTerm type="text" authority="marcrelator">author</roleTerm><roleTerm type="code" authority="marcrelator">aut</roleTerm></mods:role><mods:namePart> dc.contributor </mods:namePart><mods:role><roleTerm valueURI="ORCID"/></mods:role></mods:name> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element/doc:field[@name='value']">
				<mods:name type="personal">
					<role>
						<roleTerm type="text" authroity="marcrelator">author</roleTerm>
						<roleTerm type="code" authority="marcrelator">aut</roleTerm>
					</role>
					<xsl:variable name="author_name"><xsl:value-of select="."/></xsl:variable>
					<mods:namePart><xsl:value-of select="$author_name"/></mods:namePart>

					<xsl:for-each select="/doc:metadata/doc:element[@name='cg']/doc:element[@name='creator']/doc:element[@name='id']/doc:element/doc:field[@name='value']">
						<xsl:variable name="creatorId" select="."/>
						<xsl:analyze-string select="normalize-space($creatorId)" regex="^(.*):\s(\d{{4}}-\d{{4}}-\d{{4}}-\d{{4}})$">
							<xsl:matching-substring>
								<xsl:if test="$author_name = regex-group(1)">
									<xsl:variable name="orcid" select="regex-group(2)"/>
									<role>
										<roleTerm>
											<xsl:attribute name="valueURI">
												https://orcid.org/<xsl:value-of select="$orcid"/>
											</xsl:attribute>
										</roleTerm>
									</role>
								</xsl:if>
							</xsl:matching-substring>
						</xsl:analyze-string>
					</xsl:for-each>
				</mods:name>
			</xsl:for-each>

			<!-- <mods:name type="personal"><mods:role><roleTerm type="text" authority="marcrelator">Metadata contact</roleTerm><roleTerm type="code" authority="marcrelator">mdc</roleTerm></mods:role><mods:namePart> cg.contact </mods:namePart></mods:name> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='contact']/doc:element/doc:field[@name='value']">
				<mods:name type="personal">
					<role>
						<roleTerm type="text" authority="marcrelator">Metadata contact</roleTerm>
						<roleTerm type="code" authority="marcrelator">mdc</roleTerm>
					</role>
					<mods:namePart><xsl:value-of select="."/></mods:namePart>
				</mods:name>
			</xsl:for-each>

			<!-- <mods:name type="corporate"><mods:role><mods:roleTerm type="text"> * </mods:roleTerm></mods:role><mods:affiliation> cg.contributor.* </mods:affiliation></mods:name> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='contributor']/doc:element/doc:element/doc:field[@name='value']">
				<xsl:variable name="contributor_type"><xsl:value-of select="../../@name"/></xsl:variable>
				<xsl:if test="not($contributor_type = 'project')">
					<mods:name type="corporate">
						<mods:role>
							<mods:roleTerm type="text"><xsl:value-of select="$contributor_type"/></mods:roleTerm>
						</mods:role>
						<affiliation><xsl:value-of select="."/></affiliation>
					</mods:name>
				</xsl:if>
			</xsl:for-each>

			<!-- <mods:subject><mods:topic> cg.subject.agrovoc </mods:topic></mods:subject> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='subject']/doc:element[@name='agrovoc']/doc:element/doc:field[@name='value']">
				<mods:subject>
					<mods:topic><xsl:value-of select="." /></mods:topic>
				</mods:subject>
			</xsl:for-each>

			<!-- <mods:subject><mods:topic> dc.subject </mods:topic></mods:subject> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:field[@name='value']">
				<mods:subject>
					<mods:topic><xsl:value-of select="." /></mods:topic>
				</mods:subject>
			</xsl:for-each>

			<!-- <mods:abstract> dc.description.abstract </mods:abstract> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']">
				<mods:abstract><xsl:value-of select="." /></mods:abstract>
			</xsl:for-each>

			<!-- <mods:originInfo eventType="publisher"><mods:publisher> dc.publisher </mods:publisher></mods:originInfo> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
				<mods:originInfo eventType="publisher">
					<mods:publisher><xsl:value-of select="." /></mods:publisher>
					<!-- <mods:dateIssued encoding="iso8601"> dc.date.issued </mods:dateIssued> -->
					<xsl:if test="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:field[@name='value']">
						<mods:dateIssued encoding="iso8601">
							<xsl:value-of select="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
						</mods:dateIssued>
					</xsl:if>
				</mods:originInfo>
			</xsl:for-each>

			<!-- <mods:originInfo eventType="publication"><mods:dateIssued encoding="iso8601"> dc.date.issued </mods:dateIssued></mods:originInfo> -->
			<xsl:if test="not(doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value'])">
				<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:field[@name='value']">
					<mods:originInfo eventType="publication">
						<mods:dateIssued encoding="iso8601">
							<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
						</mods:dateIssued>
					</mods:originInfo>
				</xsl:if>
			</xsl:if>

			<!-- <mods:genre> dc.type </mods:genre> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']">
				<mods:genre><xsl:value-of select="." /></mods:genre>
			</xsl:for-each>

			<!-- <mods:physicalDescription><mods:form> dc.format </mods:form></mods:physicalDescription> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='format']/doc:element/doc:field[@name='value']">
				<mods:physicalDescription>
					<mods:form><xsl:value-of select="." /></mods:form>
				</mods:physicalDescription>
			</xsl:for-each>

			<!-- <mods:note type="citation"><mods:form> dc.identifier.citation </mods:note> -->
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='citation']/doc:element/doc:field[@name='value']">
				<mods:note type="citation">
					<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='citation']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
				</mods:note>
			</xsl:if>

			<!-- <mods:identifier type="*"> dc.identifier.* </mods:identifier> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element/doc:element/doc:field[@name='value']">
				<xsl:variable name="identifier_type"><xsl:value-of select="../../@name"/></xsl:variable>
				<xsl:if test="(($identifier_type != 'citation') and ($identifier_type != 'status'))">
					<mods:identifier>
						<xsl:attribute name="type"><xsl:value-of select="$identifier_type"/></xsl:attribute>
						<xsl:value-of select="."/>
					</mods:identifier>
				</xsl:if>
			</xsl:for-each>

			<!-- <mods:identifier type="doi"> cg.identifier.doi </mods:identifier> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='identifier']/doc:element[@name='doi']/doc:element/doc:field[@name='value']">
				<mods:identifier>
					<xsl:attribute name="type">
						<xsl:value-of select="../../@name" />
					</xsl:attribute>
					<xsl:value-of select="." />
				</mods:identifier>
			</xsl:for-each>

			<!-- <mods:relatedItem><titleInfo><title> dc.source </title></titleInfo></mods:relatedItem> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element/doc:field[@name='value']">
				<mods:relatedItem>
					<mods:titleInfo>
						<mods:title><xsl:value-of select="." /></mods:title>
					</mods:titleInfo>
				</mods:relatedItem>
			</xsl:for-each>

			<!-- <mods:language><mods:languageTerm type="code" authority="iso639-1"> dc.language </mods:languageTerm></mods:language> -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:field[@name='value']">
				<language>
					<languageTerm type="code" authority="iso639-1"><xsl:value-of select="." /></languageTerm>
				</language>
			</xsl:for-each>

			<!-- <mods:subject><mods:hierarchicalGeographic><mods:region> cg.coverage.region </mods:region></mods:hierarchicalGeographic></mods:subject> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='coverage']/doc:element[@name='region']/doc:element/doc:field[@name='value']">
				<mods:subject>
					<mods:hierarchicalGeographic>
						<mods:region><xsl:value-of select="." /></mods:region>
					</mods:hierarchicalGeographic>
				</mods:subject>
			</xsl:for-each>

			<!-- <mods:subject><mods:hierarchicalGeographic><mods:country> cg.coverage.country </mods:country></mods:hierarchicalGeographic></mods:subject> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='coverage']/doc:element[@name='country']/doc:element/doc:field[@name='value']">
				<mods:subject>
					<mods:hierarchicalGeographic>
						<mods:country><xsl:value-of select="." /></mods:country>
					</mods:hierarchicalGeographic>
				</mods:subject>
			</xsl:for-each>

			<!-- <mods:subject><mods:hierarchicalGeographic><mods:area areaType="administrativeUnit"> cg.coverage.admin-unit </mods:area></mods:hierarchicalGeographic></mods:subject> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='coverage']/doc:element[@name='admin-unit']/doc:element/doc:field[@name='value']">
				<mods:subject>
					<mods:hierarchicalGeographic>
						<mods:area areaType="administrative unit"><xsl:value-of select="." /></mods:area>
					</mods:hierarchicalGeographic>
				</mods:subject>
			</xsl:for-each>

			<!-- <mods:subject><mods:temporal encoding="iso8601" point="start"> cg.coverage.start-date </mods:temporal></mods:subject> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='coverage']/doc:element[@name='start-date']/doc:element/doc:field[@name='value']">
				<mods:subject>
					<mods:temporal encoding="iso8601" point="start"><xsl:value-of select="." /></mods:temporal>
				</mods:subject>
			</xsl:for-each>

			<!-- <mods:subject><mods:temporal encoding="iso8601" point="end"> cg.coverage.end-date </mods:temporal></mods:subject> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='coverage']/doc:element[@name='end-date']/doc:element/doc:field[@name='value']">
				<mods:subject>
					<mods:temporal encoding="iso8601" point="end"><xsl:value-of select="." /></mods:temporal>
				</mods:subject>
			</xsl:for-each>

			<!-- <mods:subject><mods:cartographics><mods:coordinates> cg.coverage.geolocation </mods:coordinates></mods:cartographics></mods:subject> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='coverage']/doc:element[@name='geolocation']/doc:element/doc:field[@name='value']">
				<mods:subject>
					<mods:cartographics>
						<mods:coordinates><xsl:value-of select="." /></mods:coordinates>
					</mods:cartographics>
				</mods:subject>
			</xsl:for-each>

			<!-- <accessCondition type="restriction on access" displayLabel="Access Status"> dc.identifier.status </accessCondition> -->
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='status']/doc:element/doc:field[@name='value']">
				<xsl:variable name="access_status"><xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='status']/doc:element/doc:field[@name='value']/text()"></xsl:value-of></xsl:variable>
				<accessCondition type="restriction on access" displayLabel="Access Status">
					<xsl:choose>
						<xsl:when test="doc:metadata/doc:element[@name='cg']/doc:element[@name='date']/doc:element[@name='embargo-end-date']/doc:element/doc:field[@name='value']">
							<xsl:variable name="embargo_date"> Embargo Date: <xsl:value-of select="doc:metadata/doc:element[@name='cg']/doc:element[@name='date']/doc:element[@name='embargo-end-date']/doc:element/doc:field[@name='value']/text()"></xsl:value-of></xsl:variable>
							<xsl:value-of select="$access_status"/>, <xsl:value-of select="$embargo_date"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$access_status"/>
						</xsl:otherwise>
					</xsl:choose>
				</accessCondition>
			</xsl:if>

			<!-- <mods:accessCondition type="useAndReproduction"> dc.rights </mods:accessCondition> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field[@name='value']">
				<mods:accessCondition type="use and reproduction"><xsl:value-of select="." /></mods:accessCondition>
			</xsl:for-each>
		</mods:mods>
	</xsl:template>
</xsl:stylesheet>

