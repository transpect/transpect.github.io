<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:j="http://marklogic.com/json"
  xmlns:tr="http://transpect.io"
  name="sync-with-github"
  type="tr:sync-with-github"
  version="1.0">
  
  <p:documentation>
    This step use the GitHub API to request information 
    about repositories and XProc pipelines.  
  </p:documentation>
  
  <p:output port="result">
    <p:documentation>
      Provides a transparent JSON document containing the 
      requested results.
    </p:documentation>
  </p:output>
  
  <p:option name="token" required="false">
    <p:documentation>
      GitHub access token. If not authentificated, Github limits API requests to 60 per hour.
    </p:documentation>
  </p:option>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/github-api/xpl/list-repos.xpl"/>
  <p:import href="http://transpect.io/github-api/xpl/repo-directory-list.xpl"/>
  
  <!-- provide a list of all repositories -->
    
  <tr:list-repos name="rq-list-repositories">
    <p:with-option name="token" select="$token"/>
    <p:with-option name="username" select="'transpect'"/>
    <p:with-option name="group" select="'orgs'"/>
  </tr:list-repos>
  
  <!-- loop over repositories -->
  
  <p:for-each cx:depends-on="rq-list-repositories" name="iterate-over-repos">
    <p:iteration-source select="/j:json/j:item"/>
    <p:variable name="repo-full-name" select="j:item/j:full_005fname"/>
    
    <cx:message>
      <p:with-option name="message" select="j:item/j:html_005furl"/>
    </cx:message>
    
    <tr:repo-directory-list>
      <p:with-option name="token" select="$token"/>
      <p:with-option name="contents-url" select="replace(j:item/j:contents_005furl, '/\{\+path\}', '')"/>
    </tr:repo-directory-list>
    
    <p:wrap match="/j:json" wrapper="c:files" name="wrap-files"/>
    
    <p:insert match="j:item" position="last-child">
      <p:input port="source">
        <p:pipe port="current" step="iterate-over-repos"/>
      </p:input>
      <p:input port="insertion">
        <p:pipe port="result" step="wrap-files"/>
      </p:input>
    </p:insert>
    
    <p:viewport match="//j:download_005furl[not(@type eq 'null')][matches(., '^(.+?/xmlcatalog/catalog.xml)|(.+?\.(xpl|xsl|))$')]" name="viewport">
      
      <cx:message>
        <p:with-option name="message" select="'[get] ', j:download_005furl"/>
      </cx:message>
      
      <p:add-attribute attribute-name="href" match="/c:request" name="construct-get-file-request">
        <p:with-option name="attribute-value" select="j:download_005furl">
          <p:pipe port="current" step="viewport"/>
        </p:with-option>
        <p:input port="source">
          <p:inline>
            <c:request method="get" detailed="false" override-content-type="application/xml"/>
          </p:inline>
        </p:input>
      </p:add-attribute>
      
      <p:try>
        <p:group>
          <p:http-request name="rq-get-file" cx:depends-on="construct-get-file-request"/>
        </p:group>
        <p:catch name="catch">
          
          <p:identity>
            <p:input port="source">
              <p:pipe port="error" step="catch"/>
            </p:input>
          </p:identity>
          
          <cx:message>
            <p:with-option name="message" select="'[ERROR] could not fetch file: ', j:download_005furl"/>
          </cx:message>
          
        </p:catch>
      </p:try>
      
      <p:wrap wrapper="cx:document" match="/*"/>
      
      <p:add-attribute attribute-name="xml:base" match="/cx:document">
        <p:with-option name="attribute-value" select="j:download_005furl">
          <p:pipe port="current" step="viewport"/>
        </p:with-option>
      </p:add-attribute>
      
    </p:viewport>
    
  </p:for-each>
    
  <p:wrap-sequence wrapper="cx:document"/>
  
</p:declare-step>
