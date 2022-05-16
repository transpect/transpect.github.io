<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:j="http://marklogic.com/json"
  xmlns:cat="urn:oasis:names:tc:entity:xmlns:xml:catalog"
  xmlns:tr="http://transpect.io"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns="http://docbook.org/ns/docbook" 
  exclude-result-prefixes="xs p cx c j tr cat xlink"
  version="2.0">
  
  <xsl:output indent="yes"/>
  
  <xsl:variable name="repos" select="/cx:document/j:item" as="element(j:item)+"/>
  <xsl:variable name="catalogs" select="/cx:document/j:item/c:files/j:json//j:item[j:path eq 'xmlcatalog/catalog.xml']/cx:document/cat:catalog" as="element(cat:catalog)+"/>
  
  <xsl:template match="/">
    <part version="5.0">
      <title>Modules</title>
      <xsl:apply-templates select="cx:document/j:item">
        <xsl:sort select="j:name"/>
      </xsl:apply-templates>
    </part>
  </xsl:template>
  
  <xsl:template match="/cx:document/j:item">
    <xsl:variable name="base" select="concat('../modules-', j:name, '.html')" as="xs:string"/>
    <!--<xsl:message select="$base"/>-->
    <xsl:variable name="catalog" select="c:files/j:json//j:item[j:path eq 'xmlcatalog/catalog.xml']/cx:document/cat:catalog" as="element(cat:catalog)?"/>
    <xsl:variable name="module-name" select="j:name" as="xs:string"/>
    <xsl:variable name="imported-xproc-steps" select=".//p:declare-step[@type]" as="element(p:declare-step)*"/>
    <chapter>
      <xsl:attribute name="xml:id" select="concat('modules-', $module-name)"/>
      <xsl:attribute name="xml:base" select="$base"/>
      <title><xsl:value-of select="$module-name"/></title>
      <subtitle><xsl:apply-templates select="j:description/node()"/></subtitle>
      <note>
        <title>Repository</title>
        <informaltable>
          <tbody>
            <tr><td>Git URL</td><td><code role="language-markup"><xsl:value-of select="j:clone_005furl"/></code></td></tr>
            <tr><td>SVN URL</td><td><code role="language-markup"><xsl:value-of select="j:svn_005furl"/></code></td></tr>
            <!-- project base URI -->
            <xsl:if test="$catalog/cat:rewriteURI">
              <tr><td>Base URI</td><td><code role="language-markup"><xsl:value-of select="$catalog/cat:rewriteURI[matches(@uriStartString, 'http://transpect\.io')]/@uriStartString"/></code></td></tr>
            </xsl:if>      
          </tbody>
        </informaltable>
        <para><link role="btn-flat  orange lighten-4" xlink:href="{j:html_005furl}">Source ⬇</link></para>
      </note>
      <!-- process distinct xproc steps -->
      <xsl:for-each select=" distinct-values($imported-xproc-steps/@type)">
        <xsl:variable name="type" select="." as="xs:string"/>
        <xsl:apply-templates select="$imported-xproc-steps[@type eq $type][1]">
          <xsl:with-param name="catalog" select="$catalog" as="element(cat:catalog)?"/>
        </xsl:apply-templates>  
      </xsl:for-each>
      <section role="status">
        <title/>
        <para role="last-updated">GitHub sync date: <xsl:value-of select="current-date()"/></para>
      </section>
    </chapter>
  </xsl:template>
  
  <xsl:template match="p:declare-step">
    <xsl:param name="catalog" as="element(cat:catalog)?"/>
    <xsl:variable name="ns-prefix" select="replace(@type, '^(.+?):.+$', '$1')" as="xs:string"/>
    <xsl:variable name="ns-statement" select="concat('xmlns:', $ns-prefix, '=&quot;', namespace-uri-for-prefix($ns-prefix, .), '&quot;')" as="xs:string"/>
    <xsl:variable name="download-url" select="ancestor::cx:document[1]/@xml:base" as="xs:string"/>
    <xsl:if test="@type">
      <section xml:id="{replace(@type, ':', '-')}">
        <title><xsl:value-of select="@type"></xsl:value-of></title>
        <xsl:apply-templates select="p:documentation"/>
        <!--  *
              * evaluate base URI if catalog rewrite exists
              * -->
        <xsl:if test="$catalog/cat:rewriteURI[matches(@uriStartString, 'http://transpect\.io')]">
          <xsl:variable name="rewrite-uri" select="$catalog/cat:rewriteURI[matches(@uriStartString, 'http://transpect\.io')][1]/@uriStartString" as="xs:string"/>
          <xsl:variable name="base-uri" select="replace($download-url, 'https://raw.githubusercontent.com/transpect/.+?/master/', $rewrite-uri)" as="xs:string"/>
          <bridgehead>Import</bridgehead>
          <programlisting><code role="language-markup"><xsl:value-of select="concat('&lt;p:import href=&quot;', $base-uri, '&quot;/&gt;')"/></code></programlisting>        
        </xsl:if>
        
        <!--  *
              * dependencies 
              * -->
        
        <xsl:variable name="dependency" as="xs:string*">
          
          <xsl:for-each select="p:import
                                |p:xslt/p:input[@port eq 'stylesheet']/p:document
                                |p:load[matches(@href, '\.xsl$')]
                                |p:xslt/p:input[@port eq 'stylesheet']/p:inline//xsl:import">
            <xsl:variable name="href" select="@href" as="xs:string"/>
            <xsl:variable name="rewrite-from-uri" select="tr:get-rewrite-from-uri($href, $catalogs)" as="item()*"/>
            <xsl:variable name="dependency-name" 
                          select="/cx:document/j:item[some $i in c:files//cat:catalog/cat:rewriteURI 
                                                      satisfies $i/@uriStartString eq $rewrite-from-uri]/j:name"/>
            <xsl:for-each select="$rewrite-from-uri[. ne 'false']">
              <xsl:sort select="." order="ascending"/>
              <xsl:value-of select="$dependency-name"/>              
            </xsl:for-each>
          </xsl:for-each>
        </xsl:variable>
        <xsl:if test="count(distinct-values($dependency)) gt 0">
          <bridgehead>Dependencies</bridgehead>
          <itemizedlist>
            <xsl:for-each select="distinct-values($dependency)">
              <xsl:variable name="dep-name" select="." as="xs:string"/>
              <listitem>
                <para><link xlink:href="{concat('modules-', ., '.html')}">
                  <xsl:value-of select="$dep-name"/>
                </link></para>
              </listitem>
            </xsl:for-each>
          </itemizedlist>
        </xsl:if>
        
        <!--  *
              * step declaration 
              * -->
        <bridgehead>Synopsis</bridgehead>
<programlisting><code role="language-markup"><xsl:value-of select="concat('&lt;',  @type, ' ', $ns-statement, '&gt;&#xa;')"/>        
      <xsl:for-each select="(p:input, p:output)">
        <xsl:value-of select="concat('  &lt;', name(), ' port=&quot;',  @port, '&quot;',
          if(@sequence) then concat(' sequence=&quot;', @sequence, '&quot;') else '',
          if(@primary) then concat(' primary=&quot;', @primary, '&quot;') else '',
          '/&gt;&#xa;')"/>
      </xsl:for-each>
      <xsl:for-each select="p:option">
        <xsl:value-of select="concat('  &lt;p:option name=&quot;',  @name, '&quot;', 
          if(@required) then concat(' required=&quot;', @required, '&quot;') else '',
          if(@select) then concat(' select=&quot;', @select, '&quot;') else '',
          '/&gt;&#xa;')"/>
      </xsl:for-each>
          <xsl:value-of select="concat('&lt;/', @type, '&gt;')"></xsl:value-of>
      </code></programlisting>
      </section>
    </xsl:if>
    
  </xsl:template>
  
  <xsl:template match="p:documentation">
    <para>
      <xsl:apply-templates/>  
    </para>
  </xsl:template>
  
  <xsl:template match="p:documentation/text()">
    <xsl:analyze-string select="." regex="\n\s*\n" flags="m">
      <xsl:matching-substring>
        <br/>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
  <xsl:template match="@*|*">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="tr:get-rewrite-from-uri">
    <xsl:param name="uri" as="xs:string"/>
    <xsl:param name="catalogs" as="element(cat:catalog)+"/>
    <xsl:variable name="path" select="replace($uri, '^(https?|file)://', '')" as="xs:string"/>
    <xsl:variable name="path-tokens" select="tokenize($path, '/')" as="xs:string+"/>
    <xsl:variable name="remove-last-item" select="remove($path-tokens, count($path-tokens))" as="xs:string*"/>
    <xsl:variable name="construct-path" select="string-join($remove-last-item, '/')" as="xs:string"/>
    <xsl:variable name="matching-rewrites" select="$catalogs/cat:rewriteURI[matches(@uriStartString, $construct-path)]" as="element(cat:rewriteURI)*"/>
    <xsl:choose>
      <!-- URI rewrite exists -->
      <xsl:when test="count($catalogs/cat:rewriteURI[matches(@uriStartString, $uri)]) eq 1">
        <xsl:value-of select="$catalogs/cat:rewriteURI[matches(@uriStartString, $uri)]/@uriStartString"/>
      </xsl:when>
      <!-- URI rewrite exists for URI part -->
      <xsl:when test="count($path-tokens) gt 1 and count($matching-rewrites) ne 1">
        <xsl:value-of select="tr:get-rewrite-from-uri($construct-path, $catalogs)"/>
      </xsl:when>
      <xsl:when test="count($matching-rewrites) gt 1">
        <xsl:value-of select="false()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$matching-rewrites/@uriStartString"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>