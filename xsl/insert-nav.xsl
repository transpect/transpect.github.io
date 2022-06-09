<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:tr="http://transpect.io"
  xmlns="http://www.w3.org/1999/xhtml"
  version="2.0"
  exclude-result-prefixes="xs dbk tr"
  xpath-default-namespace="http://www.w3.org/1999/xhtml">

  <xsl:import href="http://transpect.io/xslt-util/uri-to-relative-path/xsl/uri-to-relative-path.xsl"/>

  <xsl:variable name="book" select="collection()[2]/dbk:book" as="element(dbk:book)"/>
  
  <xsl:template match="/html/body//*[@id eq 'tr-nav']">
    <xsl:copy>
      <xsl:apply-templates select="@*, *"/>
      <xsl:for-each select="$book/dbk:part">
        <xsl:choose>
          <!-- collapsible menu entry with subentries-->
          <xsl:when test="count(dbk:chapter) gt 1">
            <li class="no-padding">
              <ul class="collapsible collapsible-accordion">
                <li class="naventry-1st" id="{(@xml:id, generate-id())[1]}">
                  <a class="collapsible-header">
                    <xsl:apply-templates select="dbk:title/node()"/>
                  </a>
                  <div class="collapsible-body">
                    <ul>
                      <xsl:message select="concat('  |--', dbk:title)"/>
                      <xsl:for-each select="dbk:chapter">
                        <xsl:message select="concat('  |  |--', dbk:title)"/>
                        <li class="naventry-2nd">
                          <a href="{replace(@xml:base, '^\.\./', '')}">
                            <xsl:apply-templates select="dbk:title/node()"/>
                          </a>
                        </li>
                      </xsl:for-each>                    
                    </ul>
                  </div>
                </li>
              </ul>
            </li>
          </xsl:when>
          <!-- simple menu entry -->
          <xsl:when test="count(dbk:chapter) eq 1">
            <xsl:message select="concat('  |--', dbk:title)"/>
            <li class="naventry-1st">
              <a href="{replace(dbk:chapter/@xml:base, '^\.\./', '')}">
                <xsl:apply-templates select="dbk:title/node()"/>
              </a>
            </li>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes" select="'Part found without chapter element! Please note that for each part at least one chapter is required'"/>
          </xsl:otherwise>
        </xsl:choose>
        
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  <!--  * 
        * identity template
        * -->
  
  <xsl:template match="@*|*">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="comment()"/>
  
</xsl:stylesheet>