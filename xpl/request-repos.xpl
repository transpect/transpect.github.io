<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:j="http://marklogic.com/json"
  version="1.0">
  
  <p:documentation>
    This step use the GitHub API to retrieve information 
    about repositories and XProc pipelines.  
  </p:documentation>
  
  <p:output port="result" sequence="true"/>
  
  <p:option name="token" required="false">
    <p:documentation>
      GitHub access token. If not authentificated, Github limits API requests to 60 per hour.
    </p:documentation>
  </p:option>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

  <p:in-scope-names name="vars"/>
  
  <p:template>
    <p:input port="source">
      <p:empty/>
    </p:input>
    <p:input port="template">
      <p:inline>
        <c:request href="https://api.github.com/orgs/transpect/repos"
          method="get"
          detailed="false">
          <c:header name="Authorization" value="token {$token}"/>
        </c:request>
      </p:inline>
    </p:input>
    <p:input port="parameters">
      <p:pipe port="result" step="vars"/>
    </p:input>
  </p:template>
  
  <p:http-request name="rq-list-repositories"/>
  
  <!-- loop over repositories -->
  
  <p:for-each cx:depends-on="rq-list-repositories">
    <p:iteration-source select="/j:json/j:item"/>
    <p:variable name="repo-full-name" select="j:item/j:full_005fname"/>
    
    <cx:message>
      <p:with-option name="message" select="j:item/j:html_005furl"/>
    </cx:message>

    <p:viewport match="j:item/j:contents_005furl" name="viewport-contents">
      
      <p:template>
        <p:input port="template">
          <p:inline>
            <c:request href="{replace(j:contents_005furl, '\{\+path\}', 'xpl/')}"
              method="get"
              detailed="false">
              <c:header name="Authorization" value="token {$token}"/>
            </c:request>
          </p:inline>
        </p:input>
        <p:input port="parameters">
          <p:pipe port="result" step="vars"/>
        </p:input>
      </p:template>
      
      <p:http-request name="rq-get-xpl-dir"/>
      
      <p:sink/>      
      
      <!-- get catalog dir -->
      
      <p:template>
        <p:input port="source">
          <p:pipe port="current" step="viewport-contents"/>
        </p:input>
        <p:input port="template">
          <p:inline>
            <c:request href="{replace(j:contents_005furl, '\{\+path\}', 'xmlcatalog/')}"
              method="get"
              detailed="false">
              <c:header name="Authorization" value="token {$token}"/>
            </c:request>
          </p:inline>
        </p:input>
        <p:input port="parameters">
          <p:pipe port="result" step="vars"/>
        </p:input>
      </p:template>
      
      <p:http-request name="rq-get-catalog-dir"/>
      
      <p:sink/>
      
      <p:insert cx:depends-on="rq-get-catalog-dir" match="j:contents_005furl" position="last-child">
        <p:input port="source">
          <p:pipe port="current" step="viewport-contents"/>
        </p:input>
        <p:input port="insertion">
          <p:pipe port="result" step="rq-get-catalog-dir"/>
          <p:pipe port="result" step="rq-get-xpl-dir"/>
        </p:input>
      </p:insert>
      
      <p:viewport match="//j:item[j:download_005furl]" name="viewport-file">
        
        <cx:message>
          <p:with-option name="message" select="'=> ' , j:item/j:download_005furl"/>
        </cx:message>
        
        <p:add-attribute attribute-name="href" match="/c:request">
          <p:with-option name="attribute-value" select="j:item/j:download_005furl"/>
          <p:input port="source">
            <p:inline>
              <c:request method="get" detailed="false" override-content-type="application/xml"/>
            </p:inline>
          </p:input>
        </p:add-attribute>
        
        <p:http-request name="rq-get-xpl"/>
        
        <p:insert cx:depends-on="rq-get-xpl-dir" match="j:item/j:download_005furl" position="last-child">
          <p:input port="source">
            <p:pipe port="current" step="viewport-file"/>
          </p:input>
          <p:input port="insertion">
            <p:pipe port="result" step="rq-get-xpl"/>
          </p:input>
        </p:insert>
        
      </p:viewport>
      
    </p:viewport>
    
  </p:for-each>
  
  <p:wrap-sequence wrapper="cx:document"/>
  
</p:declare-step>