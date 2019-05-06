module namespace xosm_open = "xosm_open";

import module namespace xosm_rld = "xosm_rld" at "../repo/XOSMIndexingLibrary.xqy";

declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace dct="http://purl.org/dc/terms/";
declare namespace dbo="http://dbpedia.org/ontology/";
declare namespace geo="http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace foaf="http://xmlns.com/foaf/0.1/";
declare namespace prov="http://www.w3.org/ns/prov#";
declare namespace georss="http://www.georss.org/georss/";

(: AUXILIAR :)

declare function xosm_open:map($a,$b)
{
  if ($a >= $b) then $a * $a + $a + $b 
  else $a + $b * $b
};

(: FOURSQUARE :)

declare function xosm_open:fq($call)
{
  concat($call,"&amp;client_id=5OQB2YDQF1FXJQHX4BAGT0QTCEX3B13GJZWQ0BEWSCVCR00G&amp;client_secret=MRTTYVJH4KNWQFGGJTENXP1RGYHO5BMXQRDLTZVUR3LHCTWQ&amp;v=20160304")
};


(: JSON2OSM :)

declare function xosm_open:json2osm($u,$path,$name,$id,$lat,$lon) 
{

xquery:eval(
'declare variable $url external;
declare variable $path external;
declare variable $id external;
declare variable $name external;
declare variable $lat external;
declare variable $lon external;
declare function local:tags($parent,$node)
{
for $tag in $node
return 
if ($tag/@type="array") then local:tags(concat($parent,name($tag)),$tag/*) union 

(if ($tag/_/text()) then <tag k="{concat($parent,name($tag))}" v="{$tag/_/text()}" /> else ())
else
if ($tag/@type="object") then   local:tags(concat($parent,name($tag)),$tag/*)
else
if (not (name($tag)="_")) then 
<tag k="{concat($parent,name($tag))}" v="{$tag/text()}" />
else ()   
}; 
let $text := fetch:text($url)
let $json := json:parse($text)
return
for $item in $json' || $path ||
' return
<oneway name="{$item' || $name || '}" type="point">
<node version="99" visible="true" id="{$item' || $id || '}" 
  lat="{$item' || $lat || '}" 
  lon="{$item' || $lon || '}">
{
local:tags("",$item/*)
}
</node>
</oneway>
',
map { 'url' : $u })
};

declare function xosm_open:tags($parent,$node)
{
for $tag in $node
return 
if ($tag/@type="array") then xosm_open:tags(concat($parent,name($tag)),$tag/*) union 

(if ($tag/_/text()) then <tag k="{concat($parent,name($tag))}" v="{$tag/_/text()}" /> else ())
else
if ($tag/@type="object") then   xosm_open:tags(concat($parent,name($tag)),$tag/*)
else
if (not (name($tag)="_")) then 
<tag k="{concat($parent,name($tag))}" v="{$tag/text()}" />
else ()   
}; 

(:GEOJSON2OSM:)

declare function xosm_open:geojson2osm($url,$name)
{
let $text := fetch:text($url)
let $json := json:parse($text)
return
(: <osm version='0.6' upload='true' generator='JOSM'>
{ :)
let $features :=$json/json/features/_
for $i in 1 to count($features)
return

if ($features[$i]/geometry/type="Point") then
<oneway name="{$features[$i]/properties/*[name(.)=$name]/text()}" type="point">
<node version="{$i}" visible='true' id="{$i}" 
  lat="{($features[$i]/geometry/coordinates/_)[2]}" 
  lon="{($features[$i]/geometry/coordinates/_)[1]}">
{

xosm_open:tags("",$features[$i]/properties/*)
union
<tag k="name" v="{$features[$i]/properties/*[name(.)=$name]/text()}"/>

}
</node>
</oneway>
else 

 if ($features[$i]/geometry/type="LineString") then
<oneway name="{$features[$i]/properties/*[name(.)=$name]/text()}" type="way">
{
( let $count := count($features[$i]/geometry/coordinates/_)
  for $j in  1 to $count return
  
  <node version="{$i}" id="{xosm_open:map($i,$j)}" visible='true' 
    lat="{(($features[$i]/geometry/coordinates/_)[$j]/_)[2]}" 
    lon="{(($features[$i]/geometry/coordinates/_)[$j]/_)[1]}"/>
),
 <node version="{$i}" id="{xosm_open:map($i,1)}" visible='true' 
    lat="{(($features[$i]/geometry/coordinates/_)[1]/_)[2]}" 
    lon="{(($features[$i]/geometry/coordinates/_)[1]/_)[1]}"/>
  union
  <way version="{$i}" visible='true' id="{$i}">
  {
    (let $count := count($features[$i]/geometry/coordinates/_)
      for $j in  1 to $count return
      <nd version="{$i}" ref='{xosm_open:map($i,$j)}'/>)
      union
      xosm_open:tags("",$features[$i]/properties/*)
      union
      <tag k="name" v="{$features[$i]/properties/*[name(.)=$name]/text()}"/>
     
}
</way>
}
</oneway>
else

 if ($features[$i]/geometry/type="Polygon") then
 <oneway name="{$features[$i]/properties/*[name(.)=$name]/text()}" type="area">
 {
    (let $count := count($features[$i]/geometry/coordinates/_/_)
      for $j in  1 to $count - 1 return
      <node version="{$i}" id="{xosm_open:map($i,$j)}" visible='true' 
        lat="{(($features[$i]/geometry/coordinates/_/_)[$j]/_)[2]}" 
        lon="{(($features[$i]/geometry/coordinates/_/_)[$j]/_)[1]}"/>),  
        
     <node version="{$i}" id="{xosm_open:map($i,1)}" visible='true' 
        lat="{(($features[$i]/geometry/coordinates/_/_)[1]/_)[2]}" 
        lon="{(($features[$i]/geometry/coordinates/_/_)[1]/_)[1]}"/>
     
        union
        <way version="{$i}" visible='true' id="{$i}" >
          {
          (let $count := count($features[$i]/geometry/coordinates/_/_)
           for $j in  1 to $count - 1 return
              <nd version="{$i}" ref='{xosm_open:map($i,$j)}'/>)
              ,
              <nd version="{$i}" ref='{xosm_open:map($i,1)}'/>
              union
               xosm_open:tags("",$features[$i]/properties/*)
              union
              <tag k="name" v="{$features[$i]/properties/*[name(.)=$name]/text()}"/>
              union
              <tag k="area" v="yes"/>
              
              }
            </way>
}</oneway>
else ()
};


(: KML2OSM :)

declare function xosm_open:kml2osm($url,$name)
{
   let $kml := doc($url)
return
(:
<osm version='0.6' upload='true' generator='JOSM'>
{:)
    let $pm := $kml//*[name(.)="Placemark"]
    let $pc := count($pm)
        for $i in 1 to $pc
        return
          if ($pm[$i]/*[name(.)="Point"]) then
            let $tok := tokenize($pm[$i]/*[name(.)="Point"]/*[name(.)="coordinates"],',')
            return
            <oneway name="{$pm[$i]/*[name(.)="ExtendedData"]/*[name(.)="SchemaData"]/*[name(.)="SimpleData" and @name=$name]/text()}" type="point">
            <node version="{$i}" visible='true' id="{$i}" 
                lat="{$tok[2]}" 
                lon="{$tok[1]}">
            {
            (for $p in  $pm[$i]/*[name(.)="ExtendedData"]/*[name(.)="SchemaData"]/*[name(.)="SimpleData"]
              return
              <tag k='{$p/@name}' v='{$p/text()}' />)
              union
              <tag k="name" v="{$pm[$i]/*[name(.)="ExtendedData"]/*[name(.)="SchemaData"]/*[name(.)="SimpleData" and @name=$name]/text()}"/>
               
               
             }
            </node>
            </oneway>
            else 
              if ($pm[$i]/*[name(.)="LineString"]) then
              <oneway name="{$pm[$i]/*[name(.)="ExtendedData"]/*[name(.)="SchemaData"]/*[name(.)="SimpleData" and @name=$name]/text()}" type="way">{
              (let $tok := tokenize($pm[$i]/*[name(.)="LineString"]/*[name(.)="coordinates"],' ')
              let $npoints := count($tok)
              return
              for $j in 1 to $npoints
              let $point := tokenize($tok[$j],',')
              return
              <node version="{$i}" visible='true' id="{xosm_open:map($i,$j)}" 
                lat="{$point[2]}" 
                lon="{$point[1]}"/>),
              (let $tok := tokenize($pm[$i]/*[name(.)="LineString"]/*[name(.)="coordinates"],' ')  
              let $point := tokenize($tok[1],',')
              return
              <node version="{$i}" visible='true' id="{xosm_open:map($i,1)}" 
                lat="{$point[2]}" 
                lon="{$point[1]}"/>)
               
              union
              <way version="{$i}" visible='true' id="{$i}"> 
                {
                    (for $p in  $pm[$i]/*[name(.)="ExtendedData"]/*[name(.)=
                    "SchemaData"]/*[name(.)="SimpleData"]
                    return
                    <tag k='{$p/@name}' v='{$p/text()}' />)
                    
                    union
                    <tag k="name" v="{$pm[$i]/*[name(.)="ExtendedData"]/*[name(.)="SchemaData"]/*[name(.)="SimpleData" and @name=$name]/text()}"/>
                     
                    union
                    (let $tok := tokenize($pm[$i]/*[name(.)="LineString"]/*[name(.)="coordinates"],' ')
                     let $npoints :=count($tok)
                     for $j in 1 to $npoints
                     return
                     <nd version="{$i}" ref="{xosm_open:map($i,$j)}"/>)
                     
                     }
                    </way>}</oneway>
else 
      if ($pm[$i]/*[name(.)="Polygon"]) then
      <oneway name="{$pm[$i]/*[name(.)="ExtendedData"]/*[name(.)="SchemaData"]/*[name(.)="SimpleData" and @name=$name]/text()}" type="area">{
      (let $tok := tokenize($pm[$i]/*[name(.)="Polygon"]/*[name(.)=
      "outerBoundaryIs"]/*[name(.)="LinearRing"]/*[name(.)="coordinates"],' ')
              let $npoints := count($tok)
              return
              for $j in 1 to $npoints - 1
              let $point := tokenize($tok[$j],',')
              return
              <node version="{$i}" visible='true' id="{xosm_open:map($i,$j)}" 
                lat="{$point[2]}" 
                lon="{$point[1]}"/>),
              (let $tok := tokenize($pm[$i]/*[name(.)="Polygon"]/*[name(.)=
      "outerBoundaryIs"]/*[name(.)="LinearRing"]/*[name(.)="coordinates"],' ')
       let $point := tokenize($tok[1],',')
       return
      <node version="{$i}" visible='true' id="{xosm_open:map($i,1)}" 
                lat="{$point[2]}" 
                lon="{$point[1]}"/>)
              union
              <way version="{$i}" visible='true' id="{$i}"> 
                {
                    (for $p in  
                    $pm[$i]/*[name(.)="ExtendedData"]/*[name(.)="SchemaData"]/*[name(.)="SimpleData"]
                    return
                    <tag k='{$p/@name}' v='{$p/text()}' />)
                    union
                    <tag k="name" v="{$pm[$i]/*[name(.)="ExtendedData"]/*[name(.)="SchemaData"]/*[name(.)="SimpleData" and @name=$name]/text()}"/>
                    union
                    <tag k="area" v="yes"/>
                     
                    union
                    (let $tok := tokenize($pm[$i]/*[name(.)="Polygon"]/*[name(.)=
                          "outerBoundaryIs"]/*[name(.)="LinearRing"]/*[name(.)="coordinates"],' ')
                     let $npoints := count($tok)
                     for $j in 1 to $npoints - 1
                     return
                     <nd version="{$i}" ref="{xosm_open:map($i,$j)}"/>),
                     <nd version="{$i}" ref="{xosm_open:map($i,1)}"/>
                     }
                    </way>
    }</oneway>
else () 
};


(: CSV2OSM :)

declare function xosm_open:csv2osm($file,$name,$lon,$lat)
{
 xosm_open:csv($file,$name,$lon,$lat)
};

(: CSV :)

declare function xosm_open:csv($file,$name,$lon,$lat)
{
let $text := fetch:text($file)
let $csv := csv:parse($text, map { 'header': true() })

let $count := count($csv/csv/record)
for $rec in 1 to $count
let $reca := $csv/csv/record[$rec]
return
<oneway name="{$reca/*[name(.)=$name]/text()}" type="point">
<node id="{$rec}" version="1" visible='true' lat="{$reca/*[name(.)=$lat]/text()}" 
lon="{$reca/*[name(.)=$lon]/text()}">
{
  <tag k="name" v="{$reca/*[name(.)=$name]/text()}"/>,
  (for $t in $reca/*
  return
  <tag k="{name($t)}" v="{$t/text()}"   />) 
}
</node>
</oneway>

};

(: WIKIPEDIAELEMENT2SOM :)


declare function xosm_open:wikipediaElement2osm($node)
{
  xosm_open:wiki_element($node)
};

(: WIKIPEDIACOORDINATES2SOM :)

declare function xosm_open:wikipediaCoordinates2osm($lon,$lat)
{
  xosm_open:wiki_coordinates($lon,$lat)
};

(: WIKIPEDIANAME2SOM :)

declare function xosm_open:wikipediaName2osm($Name)
{
  let $add := json:parse(fetch:text("https://nominatim.openstreetmap.org/?format=json&amp;addressdetails=1&amp;q="|| $Name || "&amp;format=json&amp;limit=1"))
  return
  xosm_open:wiki_coordinates($add/json/_/lon,$add/json/_/lat)
  
};


declare function xosm_open:wiki_element($node)
{
  if ($node/way) then 
  xosm_open:dbpedia(($node/node)[1]/@lon,($node/node)[1]/@lat)
  else
  xosm_open:dbpedia($node/node/@lon,$node/node/@lat)
};

declare function xosm_open:wiki_coordinates($lon,$lat)
{
  xosm_open:dbpedia($lon,$lat)
};






declare function xosm_open:rdf_osm($rdf)
{
  for $des in $rdf//rdf:Description[some $x in * satisfies name($x)="dbo:wikiPageID"]
  return 
   <oneway name="{($des/*[name(.)="rdfs:label"])[1]/text()}" type="point">
  <node version='1' upload='true' generator='JOSM' id="{$des/*[name(.)="dbo:wikiPageID"]/text()}" lat="{$des/*[name(.)="geo:lat"]/text()}" 
  lon="{$des/*[name(.)="geo:long"]/text()}">
  {
  
  <tag k="place" v="*"/>,
  <tag k="name" v="{($des/*[name(.)="rdfs:label"])[1]/text()}"/>,
  for $p in $des/* return
  if ($p/@rdf:resource) then
  <tag k="{name($p)}" v="{data($p/@rdf:resource)}"/>
  else
  <tag k="{name($p)}" v="{$p/text()}"/>
  
}
  </node>
  </oneway>
};

declare function xosm_open:dbpedia($lon,$lat)
{
let $url := concat(concat(concat(concat(
  "http://api.geonames.org/findNearbyWikipedia?lat=",$lat),"&amp;lng="),$lon),"&amp;username=myapp")
return
for $wp in  doc($url)/geonames/entry/wikipediaUrl
let $st := concat(concat("http://dbpedia.org/data/",substring-after($wp,"http://en.wikipedia.org/wiki/")),".rdf")
return xosm_open:rdf_osm(doc($st))
};

(: WIKI NAME: DEPRECATED :)

declare function xosm_open:wiki_name($spatialIndex,$name)
{
  let  $s1 :=  xosm_rld:getElementByName ($spatialIndex, $name)
return xosm_open:dbpedia(($s1/node)[1]/@lon,($s1/node)[1]/@lat)
};

(: JSON: DEPRECATED :)

declare function xosm_open:json($url,$name,$key1,$value1,$key2,$value2)
{
let $text := fetch:text($url)
let $json := json:parse($text)
return
(: <osm version='0.6' upload='true' generator='JOSM'>
{ :)
let $features :=$json/json/features/_
for $i in 1 to count($features)
return

if ($features[$i]/geometry/type="Point") then
<oneway name="{$features[$i]/properties/*[name(.)=$name]/text()}" type="point">
<node version="{$i}" visible='true' id="{$i}" 
  lat="{($features[$i]/geometry/coordinates/_)[2]}" 
  lon="{($features[$i]/geometry/coordinates/_)[1]}">
{
(for $p in  $features[$i]/properties/*
return
<tag k='{name($p)}' v='{$p/text()}' />)
union
<tag k="name" v="{$features[$i]/properties/*[name(.)=$name]/text()}"/>
union
<tag k="{$key1}" v="{$value1}" />
}
</node>
</oneway>
else 

 if ($features[$i]/geometry/type="LineString") then
<oneway name="{$features[$i]/properties/*[name(.)=$name]/text()}" type="way">
{
( let $count := count($features[$i]/geometry/coordinates/_)
  for $j in  1 to $count return
  
  <node version="{$i}" id="{xosm_open:map($i,$j)}" visible='true' 
    lat="{(($features[$i]/geometry/coordinates/_)[$j]/_)[2]}" 
    lon="{(($features[$i]/geometry/coordinates/_)[$j]/_)[1]}"/>
),
 <node version="{$i}" id="{xosm_open:map($i,1)}" visible='true' 
    lat="{(($features[$i]/geometry/coordinates/_)[1]/_)[2]}" 
    lon="{(($features[$i]/geometry/coordinates/_)[1]/_)[1]}"/>
  union
  <way version="{$i}" visible='true' id="{$i}">
  {
    (let $count := count($features[$i]/geometry/coordinates/_)
      for $j in  1 to $count return
      <nd version="{$i}" ref='{xosm_open:map($i,$j)}'/>)
      union
      (for $p in  $features[$i]/properties/*
      return
      <tag k='{name($p)}' v='{$p/text()}' />)
      union
      <tag k="name" v="{$features[$i]/properties/*[name(.)=$name]/text()}"/>
      union
      <tag k="{$key2}" v="{$value2}" />
}
</way>
}
</oneway>
else

 if ($features[$i]/geometry/type="Polygon") then
 <oneway name="{$features[$i]/properties/*[name(.)=$name]/text()}" type="area">
 {
    (let $count := count($features[$i]/geometry/coordinates/_/_)
      for $j in  1 to $count - 1 return
      <node version="{$i}" id="{xosm_open:map($i,$j)}" visible='true' 
        lat="{(($features[$i]/geometry/coordinates/_/_)[$j]/_)[2]}" 
        lon="{(($features[$i]/geometry/coordinates/_/_)[$j]/_)[1]}"/>),  
        
     <node version="{$i}" id="{xosm_open:map($i,1)}" visible='true' 
        lat="{(($features[$i]/geometry/coordinates/_/_)[1]/_)[2]}" 
        lon="{(($features[$i]/geometry/coordinates/_/_)[1]/_)[1]}"/>
     
        union
        <way version="{$i}" visible='true' id="{$i}" >
          {
          (let $count := count($features[$i]/geometry/coordinates/_/_)
           for $j in  1 to $count - 1 return
              <nd version="{$i}" ref='{xosm_open:map($i,$j)}'/>)
              ,
              <nd version="{$i}" ref='{xosm_open:map($i,1)}'/>
              union
              (for $p in  $features[$i]/properties/*
              return
              
              <tag k='{name($p)}' v='{$p/text()}' />)
              union
              <tag k="name" v="{$features[$i]/properties/*[name(.)=$name]/text()}"/>
              union
              <tag k="area" v="yes"/>
              union
              <tag k="{$key2}" v="{$value2}" />
              }
            </way>
}</oneway>
else ()
};



(: KML: DEPRECATED :)

declare function xosm_open:kml($url,$name,$key1,$value1,$key2,$value2)
{
let $kml := doc($url)
return
(:
<osm version='0.6' upload='true' generator='JOSM'>
{:)
    let $pm := $kml//*[name(.)="Placemark"]
    let $pc := count($pm)
        for $i in 1 to $pc
        return
          if ($pm[$i]/*[name(.)="Point"]) then
            let $tok := tokenize($pm[$i]/*[name(.)="Point"]/*[name(.)="coordinates"],',')
            return
            <oneway name="{$pm[$i]/*[name(.)="ExtendedData"]/*[name(.)="SchemaData"]/*[name(.)="SimpleData" and @name=$name]/text()}" type="point">
            <node version="{$i}" visible='true' id="{$i}" 
                lat="{$tok[2]}" 
                lon="{$tok[1]}">
            {
            (for $p in  $pm[$i]/*[name(.)="ExtendedData"]/*[name(.)="SchemaData"]/*[name(.)="SimpleData"]
              return
              <tag k='{$p/@name}' v='{$p/text()}' />)
              union
              <tag k="name" v="{$pm[$i]/*[name(.)="ExtendedData"]/*[name(.)="SchemaData"]/*[name(.)="SimpleData" and @name=$name]/text()}"/>
              union
              <tag k="{$key1}" v="{$value1}" />
             }
            </node>
            </oneway>
            else 
              if ($pm[$i]/*[name(.)="LineString"]) then
              <oneway name="{$pm[$i]/*[name(.)="ExtendedData"]/*[name(.)="SchemaData"]/*[name(.)="SimpleData" and @name=$name]/text()}" type="way">{
              (let $tok := tokenize($pm[$i]/*[name(.)="LineString"]/*[name(.)="coordinates"],' ')
              let $npoints := count($tok)
              return
              for $j in 1 to $npoints
              let $point := tokenize($tok[$j],',')
              return
              <node version="{$i}" visible='true' id="{xosm_open:map($i,$j)}" 
                lat="{$point[2]}" 
                lon="{$point[1]}"/>),
              (let $tok := tokenize($pm[$i]/*[name(.)="LineString"]/*[name(.)="coordinates"],' ')  
              let $point := tokenize($tok[1],',')
              return
              <node version="{$i}" visible='true' id="{xosm_open:map($i,1)}" 
                lat="{$point[2]}" 
                lon="{$point[1]}"/>)
               
              union
              <way version="{$i}" visible='true' id="{$i}"> 
                {
                    (for $p in  $pm[$i]/*[name(.)="ExtendedData"]/*[name(.)=
                    "SchemaData"]/*[name(.)="SimpleData"]
                    return
                    <tag k='{$p/@name}' v='{$p/text()}' />)
                    
                    union
                    <tag k="name" v="{$pm[$i]/*[name(.)="ExtendedData"]/*[name(.)="SchemaData"]/*[name(.)="SimpleData" and @name=$name]/text()}"/>
                    union
                    <tag k="{$key1}" v="{$value1}" />
                    union
                    (let $tok := tokenize($pm[$i]/*[name(.)="LineString"]/*[name(.)="coordinates"],' ')
                     let $npoints :=count($tok)
                     for $j in 1 to $npoints
                     return
                     <nd version="{$i}" ref="{xosm_open:map($i,$j)}"/>)
                     
                     }
                    </way>}</oneway>
else 
      if ($pm[$i]/*[name(.)="Polygon"]) then
      <oneway name="{$pm[$i]/*[name(.)="ExtendedData"]/*[name(.)="SchemaData"]/*[name(.)="SimpleData" and @name=$name]/text()}" type="area">{
      (let $tok := tokenize($pm[$i]/*[name(.)="Polygon"]/*[name(.)=
      "outerBoundaryIs"]/*[name(.)="LinearRing"]/*[name(.)="coordinates"],' ')
              let $npoints := count($tok)
              return
              for $j in 1 to $npoints - 1
              let $point := tokenize($tok[$j],',')
              return
              <node version="{$i}" visible='true' id="{xosm_open:map($i,$j)}" 
                lat="{$point[2]}" 
                lon="{$point[1]}"/>),
              (let $tok := tokenize($pm[$i]/*[name(.)="Polygon"]/*[name(.)=
      "outerBoundaryIs"]/*[name(.)="LinearRing"]/*[name(.)="coordinates"],' ')
       let $point := tokenize($tok[1],',')
       return
      <node version="{$i}" visible='true' id="{xosm_open:map($i,1)}" 
                lat="{$point[2]}" 
                lon="{$point[1]}"/>)
              union
              <way version="{$i}" visible='true' id="{$i}"> 
                {
                    (for $p in  
                    $pm[$i]/*[name(.)="ExtendedData"]/*[name(.)="SchemaData"]/*[name(.)="SimpleData"]
                    return
                    <tag k='{$p/@name}' v='{$p/text()}' />)
                    union
                    <tag k="name" v="{$pm[$i]/*[name(.)="ExtendedData"]/*[name(.)="SchemaData"]/*[name(.)="SimpleData" and @name=$name]/text()}"/>
                    union
                    <tag k="area" v="yes"/>
                    union
                    <tag k="{$key1}" v="{$value1}" />
                    union
                    (let $tok := tokenize($pm[$i]/*[name(.)="Polygon"]/*[name(.)=
                          "outerBoundaryIs"]/*[name(.)="LinearRing"]/*[name(.)="coordinates"],' ')
                     let $npoints := count($tok)
                     for $j in 1 to $npoints - 1
                     return
                     <nd version="{$i}" ref="{xosm_open:map($i,$j)}"/>),
                     <nd version="{$i}" ref="{xosm_open:map($i,1)}"/>
                     }
                    </way>
    }</oneway>
else () 
};





(: TIXIK. DEPRECATED :)

declare function xosm_open:tixik_coordinates($lon,$lat)
{
  let $doc := doc(concat(concat(concat(concat("http://www.tixik.com/api/nearby?lat=",$lat),"&amp;lng="),$lon),"&amp;limit=50&amp;key=demo"))
  for $item in $doc/*[name(.)="tixik"]/*[name(.)="items"]/*[name(.)="item"]
  return 
  
  <oneway name="{$item/name/text()}" type="point">
  <node version='1' upload='true' generator='JOSM' id="{$item/id/text()}" lat="{$item/gps_x/text()}"
  lon= "{$item/gps_y/text()}">
  <tag k="name" v="{$item/name/text()}"/>
  </node>
  </oneway>  
};

declare function xosm_open:tixik_name($spatialIndex,$name)
{
  let  $s1 :=  xosm_rld:getElementByName ($spatialIndex, $name)
return xosm_open:tixik_coordinates(($s1/node)[1]/@lat,($s1/node)[1]/@lon)
};

declare function xosm_open:tixik_element($node)
{
  if ($node/way) then 
  xosm_open:tixik_coordinates(($node/node)[1]/@lon,($node/node)[1]/@lat)
  else
  xosm_open:tixik_coordinates($node/node/@lon,$node/node/@lat)
};