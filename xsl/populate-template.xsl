<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns="http://www.w3.org/1999/xhtml"
  version="2.0"
  exclude-result-prefixes="xs xlink dbk"
  xpath-default-namespace="http://www.w3.org/1999/xhtml">
  
  <xsl:variable name="chapter" select="collection()[2]/*" as="element(dbk:chapter)"/>
  
  <!--  * 
        * insert nodes
        * -->
    
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="html">
    <xsl:copy>
      <xsl:apply-templates select="$chapter/@xml:base"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="title">
    <xsl:copy>
      <xsl:apply-templates select="$chapter/dbk:title/node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/html/body//*[@id eq 'tr-title']">
    <xsl:copy>
      <xsl:apply-templates select="$chapter/dbk:title/node()|@*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/html/body//*[@id eq 'tr-subtitle']">
    <xsl:copy>
      <xsl:apply-templates select="$chapter/dbk:subtitle/node()|@*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- inject main content -->
  
  <xsl:template match="/html/body//*[@id eq 'tr-content']">
    <xsl:copy>
      <xsl:apply-templates select="$chapter/* except ($chapter/dbk:title|$chapter/dbk:subtitle)|@*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- make nav element active -->
  
  <xsl:template match="/html/body//*[@id eq 'tr-nav']//li[a/@href eq $chapter/@xml:base]">
    <xsl:copy>
      <xsl:attribute name="class" select="concat('active ', @class)"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/html/body//*[@id eq 'tr-nav']//ul[matches(@class, 'collapsible') and .//li[a/@href eq $chapter/@xml:base]]/li[1]">
    <xsl:copy>
      <xsl:attribute name="class" select="concat('active ', @class)"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/html/body//*[@id eq 'tr-nav']//ul[matches(@class, 'collapsible') and .//li[a/@href eq $chapter/@xml:base]]/li[1]/a">
    <xsl:copy>
      <xsl:attribute name="class" select="concat('active ', @class)"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/html/body//*[@id eq 'tr-nav']//ul[matches(@class, 'collapsible') and .//li[a/@href eq $chapter/@xml:base]]/li/div[@class eq 'collapsible-body']">
    <xsl:copy>
      <xsl:attribute name="style" select="'display:block'"/>
      <xsl:apply-templates select="@class|node()"/>
    </xsl:copy>
  </xsl:template>
    
  <!-- mini-section-toc -->
  
  <xsl:template match="/html/body//*[@id eq 'tr-toc']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:for-each select="$chapter/dbk:section">
        <li>
          <a href="{concat('#', generate-id())}">
            <xsl:if test="position() eq 1">
              <xsl:attribute name="class" select="'active'"/>
            </xsl:if>
            <xsl:apply-templates select="dbk:title/node()"/>
          </a>
        </li>
      </xsl:for-each>
      
    </xsl:copy>
  </xsl:template>

  <!--  * 
        * transform DocBook to XHTML5
        * -->


  <xsl:template match="@role">
    <xsl:attribute name="class" select="."/>
  </xsl:template>

  <xsl:template match="dbk:section[not(parent::dbk:section)]">
    <div id="{generate-id()}" class="section col s12 scrollspy">
      <xsl:apply-templates select="@*|node()"/>
    </div>
  </xsl:template>
  
  <xsl:template match="dbk:section[ancestor::dbk:section]">
    <div>
      <xsl:apply-templates select="@*|node()"/>
    </div>
  </xsl:template>
  
  <xsl:template match="dbk:simplesect">
    <div>
      <xsl:apply-templates select="@*|node()"/>
    </div>
  </xsl:template>
  
  <xsl:template match="dbk:simplesect/dbk:title">
    <h5>
      <xsl:apply-templates select="@*|node()"/>
    </h5>
  </xsl:template>
  
  <!-- headlines -->
  
  <xsl:template match="dbk:section/dbk:title">
    <xsl:variable name="level" select="count(ancestor::dbk:section) + 1" as="xs:integer"/>
    <xsl:element name="{concat('h', $level)}">
      <xsl:if test="$level eq 2">
        <xsl:attribute name="class" select="'header'"/>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="dbk:bridgehead">
    <h4>
      <xsl:apply-templates select="@*|node()"/>
    </h4>
  </xsl:template>
    
  <xsl:template match="dbk:para">
    <p>
      <xsl:apply-templates select="@*|node()"/>
    </p>
  </xsl:template>
  
  <!-- hyperlinks -->
  
  <xsl:template match="dbk:link">
    <a href="{@xlink:href}" target="_blank">
      <xsl:apply-templates select="@*|node()"/>
    </a>
  </xsl:template>
  
  <!-- lists -->
  
  <xsl:template match="dbk:itemizedlist">
    <ul>
      <xsl:apply-templates select="@*|node()"/>
    </ul>
  </xsl:template>
  
  <xsl:template match="dbk:orderedlist">
    <ol>
      <xsl:apply-templates select="@*|node()"/>
    </ol>
  </xsl:template>
  
  <xsl:template match="dbk:itemizedlist/dbk:listitem|dbk:orderedlist/dbk:listitem">
    <li>
      <xsl:apply-templates select="@*|node()"/>
    </li>
  </xsl:template>
  
  <xsl:template match="dbk:variablelist">
    <dl>
      <xsl:apply-templates select="@*|node()"/>
    </dl>
  </xsl:template>
  
  <xsl:template match="dbk:varlistentry">
    <xsl:apply-templates select="@*|node()"/>
  </xsl:template>
  
  <xsl:template match="dbk:varlistentry/dbk:term">
    <dt>
      <xsl:apply-templates select="@*|node()"/>
    </dt>
  </xsl:template>
  
  <xsl:template match="dbk:varlistentry/dbk:listitem">
    <dd>
      <xsl:apply-templates select="@*|node()"/>
    </dd>
  </xsl:template>
  
  <!-- tables -->

  <xsl:template match="dbk:table|dbk:informaltable">
    <table class="{local-name()}">
      <xsl:apply-templates select="@*|node()"/>
    </table>
  </xsl:template>
  
  <xsl:template match="dbk:tr|dbk:td|dbk:thead|dbk:tbody|dbk:foot">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>
  
  <!-- programm listings -->
  
  <xsl:template match="dbk:programlisting|dbk:programlistingco">
    <pre>
      <xsl:apply-templates select="@*|node()"/>
    </pre>
  </xsl:template>
  
  <xsl:template match="dbk:code|dbk:command|dbk:computeroutput">
    <code class="{local-name()}">
      <xsl:apply-templates select="@*|node()"/>
    </code>
  </xsl:template>

  <!--  * 
        * identity template
        * -->

  <xsl:template match="@*|*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  
  
</xsl:stylesheet>