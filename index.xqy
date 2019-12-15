xquery version "1.0-ml";
declare namespace ts="http://uwm.edu/courses";
import module namespace search = "http://marklogic.com/appservices/search" at
"/MarkLogic/appservices/search/search.xqy";
declare namespace xf="http://www.w3.org/TR/2002/WD-xquery-operators-20020816";

declare variable $options :=
<options xmlns="http://marklogic.com/appservices/search">
    <transform-results apply="snippet">
        <preferred-elements>
            <element ns="http://uwm.edu/courses" name="descr" />
        </preferred-elements>
    </transform-results>
	 <search:operator name="sort">
        <search:state name="relevance">
            <search:sort-order direction="descending">
                <search:score />
            </search:sort-order>
        </search:state>
        <search:state name="section">
            <search:sort-order direction="ascending" type="xs:string">
                <search:element ns="http://uwm.edu/courses" name="section" />
            </search:sort-order>
            <search:sort-order>
                <search:score />
            </search:sort-order>
        </search:state>
        <search:state name="newest">
            <search:sort-order direction="descending" type="xs:date">
                <search:attribute ns="" name="last"/>
                <search:element ns="http://uwm.edu/courses" name="weeks"/>
            </search:sort-order>
            <search:sort-order>
                <search:score/>
            </search:sort-order>
        </search:state>
        <search:state name="oldest">
            <search:sort-order direction="ascending" type="xs:date">
                <search:attribute ns="" name="last"/>
                <search:element ns="http://uwm.edu/courses" name="weeks"/>
            </search:sort-order>
            <search:sort-order>
                <search:score/>
            </search:sort-order>
        </search:state>            
        <search:state name="title">
            <search:sort-order direction="ascending" type="xs:string">
                <search:element ns="http://uwm.edu/courses" name="title"/>
            </search:sort-order>
            <search:sort-order>
                <search:score/>
            </search:sort-order>
        </search:state>            
        <search:state name="artist">
            <search:sort-order direction="ascending" type="xs:string">
                <search:element ns="http://uwm.edu/courses" name="artist"/>
            </search:sort-order>
            <search:sort-order>
                <search:score/>
            </search:sort-order>
        </search:state>         
    </search:operator>
	<constraint name="title">
        <range type="xs:string" collation="http://marklogic.com/collation/en/S1/AS/T00BB">
            <element ns="http://uwm.edu/courses" name="title" />
            <facet-option>limit=0</facet-option>
        </range>
    </constraint>
	<constraint name="Top5Instructor">
        <range type="xs:string" collation="http://marklogic.com/collation/en/S1/AS/T00BB">
            <element ns="http://uwm.edu/courses" name="instructor" />
            <facet-option>limit=5</facet-option>
            <facet-option>frequency-order</facet-option>
            <facet-option>descending</facet-option>
        </range>
    </constraint>
	<constraint name="Top5Section">
        <range type="xs:string" collation="http://marklogic.com/collation/en/S1/AS/T00BB">
            <element ns="http://uwm.edu/courses" name="section" />
            <facet-option>limit=5</facet-option>
            <facet-option>frequency-order</facet-option>
            <facet-option>descending</facet-option>
        </range>
    </constraint>
	<constraint name="days">
        <range type="xs:string" collation="http://marklogic.com/collation/en/S1/AS/T00BB">
            <element ns="http://uwm.edu/courses" name="days" />
            <facet-option>limit=30</facet-option>
            <facet-option>frequency-order</facet-option>
            <facet-option>descending</facet-option>
        </range>
    </constraint>
</options>;
declare variable $results :=
let $q := xdmp:get-request-field("q", "sort:section")
let $q := local:add-sort($q)
return
search:search($q, $options, xs:unsignedLong(xdmp:get-request-field("start","1")));


(: determines if the end-user set the sort through the drop-down or through editing the search text field or came from the advanced search form :)
declare function local:sort-controller(){
    if(xdmp:get-request-field("advanced")) 
    then 
        let $order := fn:replace(fn:substring-after(fn:tokenize(xdmp:get-request-field("q","sort:relevance")," ")[fn:contains(.,"sort")],"sort:"),"[()]","")
        return 
            if(fn:string-length($order) lt 1)
            then "relevance"
            else $order
    else if(xdmp:get-request-field("submitbtn") or not(xdmp:get-request-field("sortby")))
    then 
        let $order := fn:replace(fn:substring-after(fn:tokenize(xdmp:get-request-field("q","sort:section")," ")[fn:contains(.,"sort")],"sort:"),"[()]","")
        return 
            if(fn:string-length($order) lt 1)
            then "relevance"
            else $order
    else xdmp:get-request-field("sortby")
};

(: adds sort to the search query string :)
declare function local:add-sort($q){
    let $sortby := local:sort-controller()
    return
        if($sortby)
        then
            let $old-sort := local:get-sort($q)
            let $q :=
                if($old-sort)
                then search:remove-constraint($q,$old-sort,$options)
                else $q
            return fn:concat($q," sort:section")
        else $q
};

declare function local:result-controller()
{
	(: if(xdmp:get-request-field("advanced")) then ()
	else  :)
	if(xdmp:get-request-field("q"))
	then local:search-results()
	else local:default-results()
};


declare function local:search-results()
{
	let $start := xs:unsignedLong(xdmp:get-request-field("start"))
	let $q := xdmp:get-request-field("q")
	let $items :=
			for $course in $results/search:result
			let $uri := fn:data($course/@uri)
			let $course-doc := fn:doc($uri)
			return 
			<div class="card w-100 mx-5 m-3">
				<h5 class="card-header"> {$course-doc//ts:title/text()}</h5>
				<div class="card-body">
					<h5 class="card-title"> Course number :- {$course-doc//ts:course}</h5>
					<p class="card-text">{fn:tokenize($course-doc//ts:descr, " ") [1 to 70]}
						{local:description($course)}
					</p>
                    <div>Course days are:  {fn:string-join(distinct-values($course-doc//ts:days/text()), ' ')} </div> 
                    <div>Course instructor/s :  {fn:string-join(distinct-values($course-doc//ts:instructor/text()), ' ')} </div> 
				</div>
			</div>
	return
	if($items)
		then (local:pagination($results), $items)
	else <div>Sorry, no results for your search.<br/><br/><br/></div>
};
(: gets the current sort argument from the query string :)
declare function local:get-sort($q){
    fn:replace(fn:tokenize($q," ")[fn:contains(.,"sort")],"[()]","")
};

declare function local:facets()
{
    for $facet in $results/search:facet
    let $facet-count := fn:count($facet/search:facet-value)
    let $facet-name := fn:data($facet/@name)
		return
			if($facet-count > 0)
			then <div class="facet">
					<div class="purplesubheading">
					<img src="images/checkblank.gif"/>{$facet-name}
					</div>
					{
							for $val in $facet/search:facet-value
							let $print := if($val/text()) then $val/text() else "Unknown"
							let $qtext := ($results/search:qtext)
							let $sort := local:get-sort($qtext)
							let $this :=
								if (fn:matches($val/@name/string(),"\W"))
								then fn:concat('"',$val/@name/string(),'"')
								else if ($val/@name eq "") then '""'
								else $val/@name/string()
							let $this := fn:concat($facet/@name,':',$this)
							let $selected := fn:matches($qtext,$this,"i")
							let $icon := 
								if($selected)
								then <img src="images/checkmark.gif"/>
								else <img src="images/checkblank.gif"/>
							let $link := 
								if($selected)
								then search:remove-constraint($qtext,$this,$options)
								else if(fn:string-length($qtext) gt 0)
								then fn:concat("(",$qtext,")"," AND ",$this)
								else $this
							let $link := if($sort and fn:not(local:get-sort($link))) then fn:concat($link," ",$sort) else $link
							let $link := fn:encode-for-uri($link)
							return
								<div class="facet-value">{$icon}<a href="index.xqy?q={$link}">
								{fn:lower-case($print)}</a> [{fn:data($val/@count)}]</div>
					}          
				</div>
			else <div>&#160;</div>
};

declare function local:description($course)
{
for $text in $course/search:snippet/search:match/node()
return if(fn:node-name($text) eq xs:QName("search:highlight"))
then <span class="highlight">{$text/text()}</span>
else $text
};
declare function local:default-results()
{
(
		let $z := xdmp:dayname-from-date(fn:current-date())
		for $course in /ts:course_listing		 
        (: TODO check IN days :)
		let $onDay := fn:contains(fn:string-join(distinct-values($course//ts:days/text()), ' '), local:get-UMTWRFS-day-name-format($z))
		where if($onDay) then 1 else 0
		return (
			<div class="card w-100 mx-5 m-3">
				<h5 class="card-header"> "{$course//ts:title/text()}" IN {fn:string-join(distinct-values($course//ts:days/text()), ' ')}</h5>
				<div class="card-body">
					<h5 class="card-title"> Course name :- {$course//ts:course}</h5>
					<p class="card-text">{fn:tokenize($course//ts:descr, " ") [1 to 70]}
					 credits :- {$course//ts:credits}<br/>
					 level :- {$course//ts:level}<br/>
					 restrictions :- {fn:substring($course//ts:restrictions,4,50)}...

						<a href="index.xqy?uri={xdmp:url-encode(fn:base-uri($course))}">[more]</a>
					</p>
					<div class="container">
							{local:sections-show($course//ts:section_listing)}
					</div>
				</div>
			</div>
		)	   	
)[1 to 10]
};
declare function local:sections-show($secSections){
	for $sec in $secSections
	return 
	<div class="toast col-sm-5 mx-3">
  		<div class="toast-header">
    		<strong class="mr-auto"> {$sec//ts:section}</strong>
    		<small class="text-muted">start :- {$sec//ts:start } </small>
    		<small class="text-muted">end :- {$sec//ts:end} </small>
		</div>
		<div class="toast-body">
			instructor :- {$sec//ts:instructor}<br/>
			comments :- {$sec//ts:comments}
		</div>
	</div>
};
declare function local:pagination($resultspag)
{
    let $start := xs:unsignedLong($resultspag/@start)
    let $length := xs:unsignedLong($resultspag/@page-length)
    let $total := xs:unsignedLong($resultspag/@total)
    let $last := xs:unsignedLong($start + $length -1)
    let $end := if ($total > $last) then $last else $total
    let $qtext := $resultspag/search:qtext[1]/text()
    let $next := if ($total > $last) then $last + 1 else ()
    let $previous := if (($start > 1) and ($start - $length > 0)) then fn:max((($start - $length),1)) else ()
    let $next-href := 
         if ($next) 
         then fn:concat("/index.xqy?q=",if ($qtext) then fn:encode-for-uri($qtext) else (),"&amp;start=",$next,"&amp;submitbtn=page")
         else ()
    let $previous-href := 
         if ($previous)
         then fn:concat("/index.xqy?q=",if ($qtext) then fn:encode-for-uri($qtext) else (),"&amp;start=",$previous,"&amp;submitbtn=page")
         else ()
    let $total-pages := fn:ceiling($total div $length)
    let $currpage := fn:ceiling($start div $length)
    let $pagemin := 
        fn:min(for $i in (1 to 4)
        where ($currpage - $i) > 0
        return $currpage - $i)
    let $rangestart := fn:max(($pagemin, 1))
    let $rangeend := fn:min(($total-pages,$rangestart + 4))
    
    return (
        <div id="countdiv"><b>{$start}</b> to <b>{$end}</b> of {$total}</div>,
        <i></i>,
        if($rangestart eq $rangeend)
        then ()
        else
            <div id="pagenumdiv"> 
               { if ($previous) then <a href="{$previous-href}" title="View previous {$length} results"><img src="images/prevarrow.gif" class="imgbaseline"  border="0" /></a> else () }
               {
                 for $i in ($rangestart to $rangeend)
                 let $page-start := (($length * $i) + 1) - $length
                 let $page-href := concat("/index.xqy?q=",if ($qtext) then encode-for-uri($qtext) else (),"&amp;start=",$page-start,"&amp;submitbtn=page")
                 return 
                    if ($i eq $currpage) 
                    then <b>&#160;<u>{$i}</u>&#160;</b>
                    else <span class="hspace">&#160;<a href="{$page-href}">{$i}</a>&#160;</span>
                }
               { if ($next) then <a href="{$next-href}" title="View next {$length} results"><img src="images/nextarrow.gif" class="imgbaseline" border="0" /></a> else ()}
            </div>
    )
};
declare function local:get-UMTWRFS-day-name-format($dayName){
	if($dayName = 'Sunday') 
  then 'U' 
  else 
    if($dayName = 'Thursday') then 'R' 
    else fn:substring($dayName, 1, 1)
};


xdmp:set-response-content-type("text/html; charset=utf-8"),
'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Crourses Project</title>
<link href="css/top-songs.css" rel="stylesheet" type="text/css"/>

</head>
<body>
<div id="header">
    <div class="font-weight-bolder text-sm-center">  Welcome To PPU Courses </div>
    <div>
         Today is : {xdmp:dayname-from-date(fn:current-date())} {xdmp:get-request-field("oo")}
    </div>
</div>

<div class="container ">
<div class=" row" >	
<div class="col-sm-3">
  <img src="images/checkblank.gif"/>{local:facets()}
  <br />
  <div class="tinynoitalics"><img src="images/checkblank.gif"/>(e.g. 1965-10-31)</div>
</div>
<div class="col-sm-9">
  <form name="form1" method="get" action="index.xqy" id="form1">
  <div id="searchdiv">
	<div class="d-flex justify-content-center">
	  	<input type="text" class="form-control w-75 mx-4" name="q" id="q" size="50" value="{local:add-sort(xdmp:get-request-field("q"))}"/>
		<button class="btn btn-primary" type="button" id="reset_button" onclick="document.getElementById('bday').value = ''; document.getElementById('q').value = ''; document.location.href='index.xqy'">x</button>
    	<input  style="border:0; width:0; height:0; background-color: #A7C030" type="text" size="0" maxlength="0"/>
		<input class="btn btn-primary" type="submit" id="submitbtn" name="submitbtn" value="search"/>
 
	</div>
   </div>
  </form>
  <div id="container" class="row">
  {  local:result-controller()  }  	
  </div>
</div>
</div>


</div>


</body>
</html>
