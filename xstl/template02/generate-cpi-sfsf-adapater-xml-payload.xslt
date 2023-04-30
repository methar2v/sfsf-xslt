<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="3.0">

   <xsl:strip-space elements="*"/>
   <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

<!--   <xsl:param name="_source"/>-->
   <xsl:param name="_source" select="webhook"/>
<!--   <xsl:param name="_lastStartDate"/>-->
           <xsl:param name="_lastStartDate" select="'2022-10-10T13:30:15Z'"/>

   <xsl:variable name="_local_lastStartDate">
      <xsl:value-of select="format-dateTime(xs:dateTime($_lastStartDate),'[Y0000][M00][D00][H00][m00][s00]')"/>
   </xsl:variable>

   <xsl:variable name="_mapped_job_requisitions" select="//objects"/>

   <xsl:template name="state">
      <xsl:param name="_state"/>
      <xsl:param name="_close_reason"/>

      <status>
         <PicklistOption>
            <id>
               <!--OPEN┃CLOSED┃HOLD┃REOPEN┃VACANCY_REQUEST_ATTACH┃RESUME┃CREATED-->
               <xsl:choose>
                  <xsl:when test="$_state='CLOSED'">
                     <xsl:if test="string-length($_close_reason)!=0">
                        <xsl:text>29559</xsl:text>
                     </xsl:if>
                     <xsl:if test="string-length($_close_reason)=0">
                        <xsl:text>29558</xsl:text>
                     </xsl:if>
                  </xsl:when>
                  <xsl:when test="$_state='HOLD'">
                     <xsl:text>29560</xsl:text>
                  </xsl:when>
                  <xsl:when test="$_state='REOPEN'">
                     <xsl:text>29563</xsl:text>
                  </xsl:when>
                  <xsl:when test="$_state='RESUME'">
                     <xsl:text>29563</xsl:text>
                  </xsl:when>
               </xsl:choose>
            </id>
         </PicklistOption>
      </status>
   </xsl:template>

   <xsl:template match="vacany_request_id">
      <xsl:variable name="_vacany_request_id" select="."/>
      <xsl:apply-templates
              select="//$_mapped_job_requisitions/JobRequisition[vacancyRecId=$_vacany_request_id]/jobReqId"/>
   </xsl:template>

   <xsl:template match="vacancy">
      <xsl:variable name="_vacancy" select="."/>
      <xsl:apply-templates
              select="//$_mapped_job_requisitions/JobRequisition[vacancyId=$_vacancy]/jobReqId"/>
   </xsl:template>

   <xsl:template match="jobReqId">
      <xsl:element name="{local-name()}">
         <xsl:value-of select="."/>
      </xsl:element>
   </xsl:template>

   <xsl:template match="items">
      <xsl:if test="contains('CLOSED┃HOLD┃REOPEN┃RESUME',state)">
         <JobRequisition>
            <xsl:apply-templates select="./*"/>
            <xsl:call-template name="state">
               <xsl:with-param name="_state" select="state"/>
               <xsl:with-param name="_close_reason" select="account_vacancy_close_reason"/>
            </xsl:call-template>
            <custtravel>
               <PicklistOption>
                  <id>28545</id>
               </PicklistOption>
            </custtravel>
            <custWorkHours>
               <PicklistOption>
                  <id>28545</id>
               </PicklistOption>
            </custWorkHours>
         </JobRequisition>
      </xsl:if>
   </xsl:template>

   <xsl:template match="node()|*"/>

   <xsl:template match="/">
      <!-- insert code here-->
      <JobRequisition>
         <xsl:for-each select="//items">
            <xsl:variable name="_created">
               <xsl:value-of select="format-dateTime(xs:dateTime(created),'[Y0000][M00][D00][H00][m00][s00]')"/>
            </xsl:variable>

            <xsl:choose>
               <xsl:when test="$_source!='webhook'">
                  <xsl:if test="$_created ge $_local_lastStartDate">
                     <xsl:apply-templates select="."/>
                  </xsl:if>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:apply-templates select="."/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each>
      </JobRequisition>
   </xsl:template>

</xsl:stylesheet>