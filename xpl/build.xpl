<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:tr="http://transpect.io"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:html="http://www.w3.org/1999/xhtml"
  version="1.0" 
  name="build">
  
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
    
  <p:xslt name="insert-nav">
    <p:input port="source">
      <p:pipe port="template" step="build"/>
      <p:pipe port="source" step="build"/>
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
      <p:pipe port="source" step="build"/>
    </p:iteration-source>
    
    <p:xslt name="populate-template">
      <p:input port="source">
        <p:pipe port="result" step="insert-nav"/>
        <p:pipe port="current" step="split"/>
        <p:pipe port="source" step="build"/>
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
      
      <p:store method="xhtml" include-content-type="true" omit-xml-declaration="false">
        <p:with-option name="href" select="//html:html/@xml:base"/>
      </p:store>
      
    </p:for-each>
    
  </p:for-each>
  
</p:declare-step>