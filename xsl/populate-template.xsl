<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:tr="http://transpect.io"
  xmlns="http://www.w3.org/1999/xhtml"
  version="2.0"
  exclude-result-prefixes="xs xlink dbk tr"
  xpath-default-namespace="http://www.w3.org/1999/xhtml">
  
  <xsl:import href="http://transpect.io/xslt-util/uri-to-relative-path/xsl/uri-to-relative-path.xsl"/>
  
  <xsl:variable name="current-chapter" select="collection()[2]/*" as="element(dbk:chapter)"/>
  <xsl:variable name="book" select="collection()[3]/*" as="element(dbk:book)"/>
  
  <!--  * 
        * insert nodes
        * -->
    
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="html">
    <xsl:copy>
      <xsl:apply-templates select="$current-chapter/@xml:base"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="body">
    <xsl:copy>
      <xsl:apply-templates select="$current-chapter/@xml:id"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="title">
    <xsl:copy>
      <xsl:apply-templates select="$current-chapter/dbk:title/node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/html/body//*[@id eq 'tr-title']">
    <xsl:copy>
      <xsl:apply-templates select="@*, $current-chapter/dbk:title/node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/html/body//*[@id eq 'tr-subtitle']">
    <xsl:copy>
      <xsl:apply-templates select="@*, $current-chapter/dbk:subtitle/node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- inject main content -->
  
  <xsl:template match="/html/body//*[@id eq 'tr-content']">
    <xsl:copy>
      <xsl:apply-templates select="@*, $current-chapter/* except ($current-chapter/dbk:title|$current-chapter/dbk:subtitle)"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- make nav li element active -->
  
  <xsl:template match="html/body//*[@id eq 'tr-nav']//li[some $i in .//a satisfies $i/@href eq tokenize($current-chapter/@xml:base, '/')[last()]]">
    <xsl:copy>
      <xsl:attribute name="class" select="concat('active ', @class)"/>
      <xsl:apply-templates select="@* except @class, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="html/body//*[@id eq 'tr-nav']//li[some $i in .//a satisfies $i/@href eq tokenize($current-chapter/@xml:base, '/')[last()]]/a[@class eq 'collapsible-header']">
    <xsl:copy>
      <xsl:attribute name="class" select="concat('active ', @class)"/>
      <xsl:apply-templates select="@* except @class, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="html/body//*[@id eq 'tr-nav']//li[some $i in .//a satisfies $i/@href eq tokenize($current-chapter/@xml:base, '/')[last()]]/div[@class eq 'collapsible-body']">
    <xsl:copy>
      <xsl:attribute name="style" select="'display:block'"/>
      <xsl:apply-templates select="@* except @style, node()"/>
    </xsl:copy>
  </xsl:template>
    
  <!-- mini-section-toc -->
  
  <xsl:template match="/html/body//*[@id eq 'tr-toc']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:for-each select="$current-chapter/dbk:section">
        <li>
          <a href="{concat('#', (@xml:id, generate-id())[1])}">
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
  
  <!-- attributes -->

  <xsl:template match="@role">
    <xsl:attribute name="class" select="."/>
  </xsl:template>

  <xsl:template match="@xml:id">
    <xsl:attribute name="id" select="."/>
  </xsl:template>
  
  <xsl:template match="@xlink:href">
    <xsl:attribute name="href" select="."/>
  </xsl:template>

  <!-- sections -->

  <xsl:template match="dbk:section[not(parent::dbk:section)]">
    <div id="{(@xml:id, generate-id())[1]}" class="section scrollspy">
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
      <xsl:attribute name="class" select="if($level eq 2) then 'header' else '', parent::dbk:section/@role"/>
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
  
  <!-- hyperlinks and cross-references -->
  
  <xsl:template match="dbk:link">
    <a href="{@xlink:href}">
      <xsl:apply-templates select="@*"/>
      <xsl:if test="starts-with(@xlink:href, 'http') and not(matches(@role, 'btn'))">
        <xsl:text>&#x27bc;&#x202f;</xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  
  <xsl:template match="dbk:xref">
    <xsl:variable name="linkend" select="@linkend" as="xs:string"/>
    <xsl:variable name="match" select="$book//*[@xml:id eq $linkend]" as="element()"/>
    <xsl:variable name="reference" select="if(tokenize($match/base-uri(), '/')[last()] eq tokenize(base-uri(), '/')[last()])
                                           then concat('#', @linkend)
                                           else concat(tokenize($match/base-uri(), '/')[last()], '#', @linkend)" as="xs:string"/>
    <a href="{$reference}"><xsl:value-of select="if($match/dbk:title) then $match/dbk:title/text() else $match/text()"/></a>
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
  
  <!-- images -->
  
  <xsl:template match="dbk:informalfigure">
    <xsl:variable name="fileuri" select="tr:uri-to-relative-path(collection()[2]/base-uri(), dbk:mediaobject/dbk:imageobject/dbk:imagedata/@fileref)" as="xs:string"/>
    <figure class="{local-name()}">
      <img class="responsive-img" src="{$fileuri}" alt="{dbk:mediaobject/dbk:alt}"/>
    </figure>
  </xsl:template>
  
  <!-- tables -->

  <xsl:template match="dbk:table|dbk:informaltable">
    <table class="{local-name()}">
      <xsl:apply-templates select="@*|node()"/>
    </table>
  </xsl:template>
  
  <xsl:template match="dbk:tr|dbk:td|dbk:thead|dbk:tbody|dbk:tgroup|dbk:foot">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>
  
  <!-- notes and annotations -->
  
  <xsl:template match="dbk:note|dbk:annotation">
    <div class="card">
      <div class="card-content">
        <xsl:apply-templates select="@*|node()"/>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template match="dbk:note/dbk:title|dbk:annotation/dbk:title">
    <span class="card-title">
      <xsl:apply-templates select="@*|node()"/>
    </span>
  </xsl:template>
  
  <!-- programm listings -->
  
  <xsl:template match="dbk:programlisting|dbk:programlistingco">
    <pre>
      <xsl:apply-templates select="@*|node()"/>
    </pre>
  </xsl:template>
  
  <xsl:template match="dbk:code|dbk:parameter|dbk:markup|dbk:literal|dbk:code|dbk:command|dbk:computeroutput|dbk:filename">
    <code class="{(@role, concat('language-', local-name()))[1]}">
      <xsl:apply-templates select="@*|node()"/>
    </code>
  </xsl:template>
  
  <!-- character styles -->
  
  <xsl:template match="dbk:emphasis">
    <em>
      <xsl:apply-templates select="@*|node()"/>
    </em>
  </xsl:template>
  
  <xsl:template match="dbk:emphasis[@role = ('italic', 'emphasis', 'em', 'i')]">
    <em>
      <xsl:apply-templates select="@*|node()"/>
    </em>
  </xsl:template>
  
  <xsl:template match="dbk:emphasis[@role = ('bold', 'strong', 'b')]">
    <strong>
      <xsl:apply-templates select="@*|node()"/>
    </strong>
  </xsl:template>
  
  <xsl:template match="dbk:emphasis[@role = ('bold-italic')]">
    <strong>
      <em>
        <xsl:apply-templates select="@*|node()"/>  
      </em>
    </strong>
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
