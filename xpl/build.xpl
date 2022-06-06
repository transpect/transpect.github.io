<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:tr="http://transpect.io"
  version="1.0" 
  name="build-website" 
  type="tr:build-website">
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    Builds the framework reference hosted on transpect.io
  </p:documentation>
  
  <p:input port="source" primary="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <dl><dt>source</dt><dd>expects the DocBook source document</dd></dl>
    </p:documentation>
    <p:document href="../source/source.xml"/>
  </p:input>
  
  <p:input port="template" primary="false">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <dl><dt>source</dt><dd>expects the XHTML skeleton document</dd></dl>
    </p:documentation>
    <p:document href="../template/template.html"/>
  </p:input>
  
  <p:option name="sync" select="'no'">
    <p:documentation>
      Whether to sync information from GitHub repositories.
    </p:documentation>
  </p:option>
  <p:option name="token"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  <p:import href="sync-with-github.xpl"/>
  
  <p:choose name="sync">
    <p:when test="$sync eq 'yes'">
      
      <p:sink/>
      
      <tr:sync-with-github>
        <p:log port="result" href="../github-dump-log.xml"/>
        <p:with-option name="token" select="$token"/>
      </tr:sync-with-github>
      
      <p:xslt>
        <p:input port="stylesheet">
          <p:document href="../xsl/json-2-docbook.xsl"/>
        </p:input>
        <p:input port="parameters">
          <p:empty/>
        </p:input>
      </p:xslt>
      
      <p:store include-content-type="true" href="../source/modules.xml"/>
      
    </p:when>
    <p:otherwise>
      <p:sink/>
    </p:otherwise>
  </p:choose>
  
  <p:xinclude name="xinclude" cx:depends-on="sync">
    <p:input port="source">
      <p:pipe port="source" step="build-website"/>
    </p:input>
  </p:xinclude>
  
  <p:xslt name="insert-nav">
    <p:input port="source">
      <p:pipe port="template" step="build-website"/>
      <p:pipe port="result" step="xinclude"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xsl/insert-nav.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>
  
  <p:for-each name="split">
    <p:iteration-source select="//dbk:chapter">
      <p:pipe port="result" step="xinclude"/>
    </p:iteration-source>
    
    <p:xslt name="populate-template">
      <p:input port="source">
        <p:pipe port="result" step="insert-nav"/>
        <p:pipe port="current" step="split"/>
        <p:pipe port="result" step="xinclude"/>
      </p:input>
      <p:input port="stylesheet">
        <p:document href="../xsl/populate-template.xsl"/>
      </p:input>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
    </p:xslt>
    
    <p:for-each>
      <p:iteration-source select="//html:html"/>
      
      <p:store method="xhtml" include-content-type="true" omit-xml-declaration="false" indent="true">
        <p:with-option name="href" select="//html:html/@xml:base"/>
      </p:store>
      
    </p:for-each>
    
  </p:for-each>
  
</p:declare-step>
