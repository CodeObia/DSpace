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
		<mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xlink="http://www.w3.org/1999/xlink" version="3.7" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd">
			<!-- <titleInfo><title> dc.title </title></titleInfo> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
				<titleInfo>
					<title><xsl:value-of select="." /></title>
				</titleInfo>
			</xsl:for-each>

			<!-- <name type="personal"><role><roleTerm type="text" authority="marcrelator">creator</roleTerm><roleTerm type="code" authority="marcrelator">cre</roleTerm></role><namePart> dc.creator </namePart><role><roleTerm valueURI="ORCID"/></role></name> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element/doc:field[@name='value']">
				<name type="personal">
					<role>
						<roleTerm type="text" authority="marcrelator">creator</roleTerm>
						<roleTerm type="code" authority="marcrelator">cre</roleTerm>
					</role>
					<xsl:variable name="creator_name"><xsl:value-of select="."/></xsl:variable>
					<namePart><xsl:value-of select="$creator_name"/></namePart>

					<xsl:for-each select="/doc:metadata/doc:element[@name='cg']/doc:element[@name='creator']/doc:element[@name='id']/doc:element/doc:field[@name='value']">
						<xsl:variable name="creatorId" select="."/>
						<xsl:analyze-string select="normalize-space($creatorId)" regex="^(.*):\s(\d{{4}}-\d{{4}}-\d{{4}}-\d{{4}})$">
							<xsl:matching-substring>
								<xsl:if test="$creator_name = regex-group(1)">
									<nameIdentifier type="ORCID">https://orcid.org/<xsl:value-of select="regex-group(2)"/></nameIdentifier>
								</xsl:if>
							</xsl:matching-substring>
						</xsl:analyze-string>
					</xsl:for-each>
				</name>
			</xsl:for-each>

			<!-- <name type="personal"><role><roleTerm type="text" authority="marcrelator">author</roleTerm><roleTerm type="code" authority="marcrelator">aut</roleTerm></role><namePart> dc.contributor </namePart><role><roleTerm valueURI="ORCID"/></role></name> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element/doc:field[@name='value']">
				<name type="personal">
					<role>
						<roleTerm type="text" authority="marcrelator">author</roleTerm>
						<roleTerm type="code" authority="marcrelator">aut</roleTerm>
					</role>
					<xsl:variable name="author_name"><xsl:value-of select="."/></xsl:variable>
					<namePart><xsl:value-of select="$author_name"/></namePart>

					<xsl:for-each select="/doc:metadata/doc:element[@name='cg']/doc:element[@name='creator']/doc:element[@name='id']/doc:element/doc:field[@name='value']">
						<xsl:variable name="creatorId" select="."/>
						<xsl:analyze-string select="normalize-space($creatorId)" regex="^(.*):\s(\d{{4}}-\d{{4}}-\d{{4}}-\d{{4}})$">
							<xsl:matching-substring>
								<xsl:if test="$author_name = regex-group(1)">
									<nameIdentifier type="ORCID">https://orcid.org/<xsl:value-of select="regex-group(2)"/></nameIdentifier>
								</xsl:if>
							</xsl:matching-substring>
						</xsl:analyze-string>
					</xsl:for-each>
				</name>
			</xsl:for-each>

			<!-- <name type="corporate"><role><roleTerm type="text"> * </roleTerm></role><affiliation> cg.contributor.* </affiliation></name> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='contributor']/doc:element/doc:element/doc:field[@name='value']">
				<xsl:variable name="contributor_type"><xsl:value-of select="../../@name"/></xsl:variable>
				<xsl:if test="not($contributor_type = 'project')">
					<name type="corporate">
						<role>
							<roleTerm type="text"><xsl:value-of select="$contributor_type"/></roleTerm>
						</role>
						<affiliation><xsl:value-of select="."/></affiliation>
					</name>
				</xsl:if>
			</xsl:for-each>

			<!-- <subject><topic> cg.subject.agrovoc </topic></subject> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='subject']/doc:element[@name='agrovoc']/doc:element/doc:field[@name='value']">
				<subject>
					<topic><xsl:value-of select="." /></topic>
				</subject>
			</xsl:for-each>

			<!-- <subject><topic> dc.subject </topic></subject> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:field[@name='value']">
				<subject>
					<topic><xsl:value-of select="." /></topic>
				</subject>
			</xsl:for-each>

			<!-- <abstract> dc.description.abstract </abstract> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']">
				<abstract><xsl:value-of select="." /></abstract>
			</xsl:for-each>

			<!-- <originInfo eventType="publisher"><publisher> dc.publisher </publisher></originInfo> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
				<originInfo eventType="publisher">
					<publisher><xsl:value-of select="." /></publisher>
					<xsl:choose>
						<!-- <dateIssued encoding="iso8601"> dc.date.issued </dateIssued> -->
						<xsl:when test="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">
							<dateIssued encoding="iso8601">
								<xsl:value-of select="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
							</dateIssued>
						</xsl:when>
						<!-- <dateIssued encoding="iso8601"> dc.date </dateIssued> -->
						<xsl:when test="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:field[@name='value']">
							<dateIssued encoding="iso8601">
								<xsl:value-of select="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
							</dateIssued>
						</xsl:when>
						<!-- <dateIssued encoding="iso8601"> dcterms.available </dateIssued> -->
						<xsl:when test="/doc:metadata/doc:element[@name='dcterms']/doc:element[@name='available']/doc:element/doc:field[@name='value']">
							<dateIssued encoding="iso8601">
								<xsl:value-of select="/doc:metadata/doc:element[@name='dcterms']/doc:element[@name='available']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
							</dateIssued>
						</xsl:when>
						<!-- <dateIssued encoding="iso8601"> dcterms.issued </dateIssued> -->
						<xsl:when test="/doc:metadata/doc:element[@name='dcterms']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">
							<dateIssued encoding="iso8601">
								<xsl:value-of select="/doc:metadata/doc:element[@name='dcterms']/doc:element[@name='issued']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
							</dateIssued>
						</xsl:when>
					</xsl:choose>
				</originInfo>
			</xsl:for-each>

			<!-- <originInfo eventType="publication"><dateIssued encoding="iso8601"> dc.date.issued </dateIssued></originInfo> -->
			<xsl:if test="not(doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value'])">
				<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:field[@name='value']">
					<originInfo eventType="publication">
						<xsl:choose>
							<!-- <dateIssued encoding="iso8601"> dc.date.issued </dateIssued> -->
							<xsl:when test="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">
								<dateIssued encoding="iso8601">
									<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
								</dateIssued>
							</xsl:when>
							<!-- <dateIssued encoding="iso8601"> dc.date </dateIssued> -->
							<xsl:when test="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:field[@name='value']">
								<dateIssued encoding="iso8601">
									<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
								</dateIssued>
							</xsl:when>
						</xsl:choose>
					</originInfo>
				</xsl:if>
			</xsl:if>

			<!-- <typeOfResource> dc.type </typeOfResource> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']">
				<typeOfResource><xsl:value-of select="." /></typeOfResource>
			</xsl:for-each>

			<!-- <physicalDescription><form> dc.format </form></physicalDescription> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='format']/doc:element/doc:field[@name='value']">
				<physicalDescription>
					<form><xsl:value-of select="." /></form>
				</physicalDescription>
			</xsl:for-each>

			<!-- <note type="citation"><form> dc.identifier.citation </note> -->
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='citation']/doc:element/doc:field[@name='value']">
				<note type="citation">
					<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='citation']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
				</note>
			</xsl:if>

			<!-- <identifier type="*"> dc.identifier.* </identifier> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element/doc:element/doc:field[@name='value']">
				<xsl:variable name="identifier_type"><xsl:value-of select="../../@name"/></xsl:variable>
				<xsl:if test="(($identifier_type != 'citation') and ($identifier_type != 'status') and ($identifier_type != 'doi') and ($identifier_type != 'issn') and ($identifier_type != 'isbn'))">
					<identifier>
						<xsl:attribute name="type"><xsl:value-of select="$identifier_type"/></xsl:attribute>
						<xsl:value-of select="."/>
					</identifier>
				</xsl:if>
			</xsl:for-each>

			<!-- <identifier type="doi"> cg.identifier.doi </identifier> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='identifier']/doc:element[@name='doi']/doc:element/doc:field[@name='value']">
				<identifier>
					<xsl:attribute name="type">
						<xsl:value-of select="../../@name" />
					</xsl:attribute>
					<xsl:value-of select="." />
				</identifier>
			</xsl:for-each>

			<!-- <identifier type="doi"> dc.identifier.doi </identifier> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='doi']/doc:element/doc:field[@name='value']">
				<identifier>
					<xsl:attribute name="type">
						<xsl:value-of select="../../@name" />
					</xsl:attribute>
					<xsl:value-of select="." />
				</identifier>
			</xsl:for-each>

			<!-- <identifier type="issn"> cg.issn </identifier> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='issn']/doc:element/doc:field[@name='value']">
				<identifier type="issn">
					<xsl:value-of select="." />
				</identifier>
			</xsl:for-each>

			<!-- <identifier type="issn"> dc.identifier.issn </identifier> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='issn']/doc:element/doc:field[@name='value']">
				<identifier type="issn">
					<xsl:value-of select="." />
				</identifier>
			</xsl:for-each>

			<!-- <identifier type="isbn"> cg.isbn </isbn> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='isbn']/doc:element/doc:field[@name='value']">
				<identifier type="isbn">
					<xsl:value-of select="." />
				</identifier>
			</xsl:for-each>

			<!-- <identifier type="issn"> dc.identifier.issn </identifier> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='isbn']/doc:element/doc:field[@name='value']">
				<identifier type="isbn">
					<xsl:value-of select="." />
				</identifier>
			</xsl:for-each>

			<!-- <relatedItem><titleInfo><title> cg.journal </title></titleInfo><part><detail type="issue"> cg.issue </detail></part><part><detail type="volume"> cg.volume </detail></part><part><extent unit="pages"> dcterms.extent </extent></part><part><date> mel.date.year </date></part></relatedItem> -->
			<xsl:if test="doc:metadata/doc:element[@name='cg']/doc:element[@name='journal']/doc:element/doc:field[@name='value']">
				<relatedItem>
					<titleInfo>
						<title>
							<xsl:value-of select="doc:metadata/doc:element[@name='cg']/doc:element[@name='journal']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
						</title>
					</titleInfo>
					<xsl:if test="doc:metadata/doc:element[@name='cg']/doc:element[@name='issue']/doc:element/doc:field[@name='value']">
						<part>
							<detail type="issue">
								<number>
									<xsl:value-of select="doc:metadata/doc:element[@name='cg']/doc:element[@name='issue']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
								</number>
							</detail>
						</part>
					</xsl:if>
					<xsl:if test="doc:metadata/doc:element[@name='cg']/doc:element[@name='volume']/doc:element/doc:field[@name='value']">
						<part>
							<detail type="volume">
								<number>
									<xsl:value-of select="doc:metadata/doc:element[@name='cg']/doc:element[@name='volume']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
								</number>
							</detail>
						</part>
					</xsl:if>
					<xsl:if test="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='extent']/doc:element/doc:field[@name='value']">
						<part>
							<extent unit="pages">
								<xsl:variable name="pages" select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='extent']/doc:element/doc:field[@name='value']/text()"/>
								<xsl:analyze-string select="normalize-space($pages)" regex="^(.*)-(.*)$">
									<xsl:matching-substring>
										<xsl:if test="regex-group(1)">
											<start>
												<xsl:value-of select="regex-group(1)"/>
											</start>
										</xsl:if>
										<xsl:if test="regex-group(2)">
											<end>
												<xsl:value-of select="regex-group(2)"/>
											</end>
										</xsl:if>
									</xsl:matching-substring>
								</xsl:analyze-string>
							</extent>
						</part>
					</xsl:if>
					<xsl:if test="doc:metadata/doc:element[@name='mel']/doc:element[@name='date']/doc:element[@name='year']/doc:element/doc:field[@name='value']">
						<part>
							<date>
								<xsl:value-of select="doc:metadata/doc:element[@name='mel']/doc:element[@name='date']/doc:element[@name='year']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
							</date>
						</part>
					</xsl:if>
					<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">
						<part>
							<date>
								<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
							</date>
						</part>
					</xsl:if>
				</relatedItem>
			</xsl:if>

			<!-- <language><languageTerm type="code" authority="iso639-3"> dc.language </languageTerm></language> -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:field[@name='value']">
				<language>
					<languageTerm type="code" authority="iso639-3"><xsl:value-of select="." /></languageTerm>
				</language>
			</xsl:for-each>

			<!-- <subject><hierarchicalGeographic><region> cg.coverage.region </region></hierarchicalGeographic></subject> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='coverage']/doc:element[@name='region']/doc:element/doc:field[@name='value']">
				<subject>
					<hierarchicalGeographic>
						<region><xsl:value-of select="." /></region>
					</hierarchicalGeographic>
				</subject>
			</xsl:for-each>

			<!-- <subject><hierarchicalGeographic><country> cg.coverage.country </country></hierarchicalGeographic></subject> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='coverage']/doc:element[@name='country']/doc:element/doc:field[@name='value']">
				<subject>
					<hierarchicalGeographic>
						<country><xsl:value-of select="." /></country>
					</hierarchicalGeographic>
				</subject>
			</xsl:for-each>

			<!-- <subject><hierarchicalGeographic><area areaType="administrativeUnit"> cg.coverage.admin-unit </area></hierarchicalGeographic></subject> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='coverage']/doc:element[@name='admin-unit']/doc:element/doc:field[@name='value']">
				<subject>
					<hierarchicalGeographic>
						<area areaType="administrative unit"><xsl:value-of select="." /></area>
					</hierarchicalGeographic>
				</subject>
			</xsl:for-each>

			<!-- <subject><temporal encoding="iso8601" point="start"> cg.coverage.start-date </temporal></subject> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='coverage']/doc:element[@name='start-date']/doc:element/doc:field[@name='value']">
				<subject>
					<temporal encoding="iso8601" point="start"><xsl:value-of select="." /></temporal>
				</subject>
			</xsl:for-each>

			<!-- <subject><temporal encoding="iso8601" point="end"> cg.coverage.end-date </temporal></subject> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='coverage']/doc:element[@name='end-date']/doc:element/doc:field[@name='value']">
				<subject>
					<temporal encoding="iso8601" point="end"><xsl:value-of select="." /></temporal>
				</subject>
			</xsl:for-each>

			<!-- <subject><cartographics><coordinates> cg.coverage.geolocation </coordinates></cartographics></subject> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='cg']/doc:element[@name='coverage']/doc:element[@name='geolocation']/doc:element/doc:field[@name='value']">
				<subject>
					<cartographics>
						<coordinates><xsl:value-of select="." /></coordinates>
					</cartographics>
				</subject>
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
			<!-- <accessCondition type="restriction on access" displayLabel="Access Status"> cg.identifier.status </accessCondition> -->
			<xsl:if test="doc:metadata/doc:element[@name='cg']/doc:element[@name='identifier']/doc:element[@name='status']/doc:element/doc:field[@name='value']">
				<xsl:variable name="access_status"><xsl:value-of select="doc:metadata/doc:element[@name='cg']/doc:element[@name='identifier']/doc:element[@name='status']/doc:element/doc:field[@name='value']/text()"></xsl:value-of></xsl:variable>
				<accessCondition type="restriction on access" displayLabel="Access Status">
					<xsl:value-of select="$access_status"/>
				</accessCondition>
			</xsl:if>

			<!-- <accessCondition type="useAndReproduction"> dc.rights </accessCondition> -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field[@name='value']">
				<accessCondition type="use and reproduction"><xsl:value-of select="." /></accessCondition>
			</xsl:for-each>
		</mods>
	</xsl:template>
</xsl:stylesheet>

