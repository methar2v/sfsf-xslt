<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="3.0">

   <xsl:strip-space elements="*"/>
   <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

<!--   <xsl:param name="_postStartDate"/>-->
      <xsl:param name="_postStartDate" select="current-dateTime()"/>
<!--   <xsl:param name="_postEndDate"/>-->
      <xsl:param name="_postEndDate" select="'2022-12-31T00:00:00Z'"/>

   <xsl:template match="JobRequisition">
      <xsl:if test="exists(jobReqPostings/JobRequisitionPosting)=false() or
                    jobReqPostings/JobRequisitionPosting[postingStatus='Expired'] or
                    jobReqPostings/JobRequisitionPosting[postingStatus='Deleted']">
         <xsl:copy>
            <__metadata>
               <uri>
                  <xsl:value-of select="concat('odata/v2/JobRequisition(',jobReqId,')L')"/>
               </uri>
               <type>SFOData.JobRequisition</type>
            </__metadata>
            <jobReqPostings>
               <xsl:copy-of select="jobReqId"/>
               <postStartDate>
                  <xsl:variable name="_lpsd"
                                select="( $_postStartDate - xs:dateTime('1970-01-01T00:00:00') ) div xs:dayTimeDuration('PT1S') * 1000"/>
                  <xsl:value-of select="concat('/Date(',$_lpsd,')/')"/>
               </postStartDate>
               <postEndDate>
                  <xsl:variable name="_lped"
                                select="( xs:dateTime($_postEndDate) - xs:dateTime('1970-01-01T00:00:00') ) div xs:dayTimeDuration('PT1S') * 1000"/>
                  <xsl:value-of select="concat('/Date(',$_lped,')/')"/>
               </postEndDate>
               <xsl:if test="string-length(confidentiality/PicklistOption/externalCode)!=0">
                  <xsl:choose>
                     <xsl:when test="confidentiality/PicklistOption/externalCode='No'">
                        <boardId>_external</boardId>
                     </xsl:when>
                     <xsl:otherwise>
                        <boardId>_private_external</boardId>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:if>
               <xsl:if test="string-length(confidentiality/PicklistOption/externalCode)=0">
                  <boardId>_external</boardId>
               </xsl:if>
            </jobReqPostings>
         </xsl:copy>
      </xsl:if>
   </xsl:template>

   <xsl:template match="/">
      <JobRequisition>
         <xsl:apply-templates select="//JobRequisition/JobRequisition"/>
      </JobRequisition>
   </xsl:template>

</xsl:stylesheet>