# transpect.github.io

Author: Martin Kraetke


The HTML pages of transpect.github.io are generated automatically with XSLT/XProc-based scripts from 
a source DocBook file where the content is stored. The DocBook XML is splitted into chunks and converted into HTML. 
Each HTML chunk is inserted into an HTML template, which use the Materialize CSS framework, an 
implementation of Googles Material Design.

### prerequisites

* at least Java 1.7
* XML Calabash

### edit the content

The content is stored as DocBook XML file in the `source` directory. You have to follow some markup conventions in DocBook.

* Each `part` represents an main nav entry in the left nav bar.
* Every `part` must contain at least one `chapter` element representing a single web page. The `chapter` element must 
include an `@xml:base` attribute indicating the filename of the HTML page.
```xml
<part>
  <title>About</title>
  <chapter xml:base="index.html">
    <title>transpect</title>
    <subtitle>A open source framework for converting and checking data</subtitle>
    <!-- (…) --> 
  </chapter>
</part>
```
* If a 'part' contains multiple `chapter` elements, then a dropdown with the corresponding entries is generated. 
The dropdown title is the part title and the subentries are the chapter titles.
* `section` elements below a `chapter` are automatically connected witht the left mini-toc.

### build the website

* Checkout the repository with Git and change into the directory.

```
$ git clone https://github.com/transpect/transpect.github.io.git website
$ cd website
```
Execute the XProc build script with XML Calabash

```
$ ./calabash/calabash.sh xpl/build.xpl
```

Commit the HTML files with Git.

```
$ git add *.html
$ git commit -m 'update website'
$ git push
```
