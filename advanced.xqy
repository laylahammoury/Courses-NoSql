xquery version "1.0-ml";
xdmp:set-response-content-type("text/html; charset=utf-8"),
'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Top Songs</title>
<link href="css/top-songs.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<div id="wrapper">
<div id="header"><a href="index.xqy"><img src="images/banner.jpg" width="918" height="153" border="0"/></a></div>
<div id="leftcol">
  <p>&#160;</p>
  <p>&#160;</p>
  <p>&#160;</p>
  <p>&#160;</p>
  <p>&#160;</p>
  <p>&#160;</p>
  <p>&#160;</p>
</div>
<div id="rightcol">
  <div id="searchdiv">
  <form name="formadv" method="get" action="index.xqy" id="formadv">
  <input type="hidden" name="advanced" value="advanced"/>
  <table border="0" cellspacing="8">
    <tr>
      <td align="right">&#160;</td>
      <td colspan="4" class="songnamelarge"><span class="tiny">&#160;&#160;</span><br />
        advanced search<br />
        <span class="tiny">&#160;&#160;</span></td>
    </tr>
    <tr>
      <td align="right">Title:</td>
      <td colspan="4"><input type="text" name="title" id="title" size="40"/>
      </td>
    </tr>
    <tr>
      <td align="right">instructor:</td>
      <td colspan="4"><input type="text" name="instructor" id="instructor" size="40"/></td>
    </tr>
    <tr valign="top">
      <td align="right">&#160;</td>
      <td><span class="tiny">&#160;&#160;</span><br /><input type="submit" name="submitbtn" id="submitbtn" value="search"/></td>
      <td>&#160;</td>
      <td>&#160;</td>
      <td>&#160;</td>
    </tr>
  </table>
  </form>
  </div>
</div>
<div id="footer"></div>
</div>
</body>
</html>
