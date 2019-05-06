module namespace xosm_item = "xosm_item";

import module namespace geo = "http://expath.org/ns/geo";
import module namespace xosm_gml = "xosm_gml" at "XOSM2Gml.xqy";


declare namespace gml='http://www.opengis.net/gml';


(: CREATION :)

declare function xosm_item:point($name,$lat,$lon,$tags)
{
  <oneway name="{$name}" type="point">
  {
  xosm_item:node($name,$lat,$lon,$tags)
  }
  </oneway>
};

declare function xosm_item:pointDistance($name,$lat,$lon,$distance,$tags)
{
  <oneway name="{$name}" type="point" distance="{$distance}">
  {
  xosm_item:node($name,$lat,$lon,$tags) 
  
  }
  </oneway>
};

declare function xosm_item:way($name,$segments,$nodes)
{
  <oneway name="{$name}" type="way">
  {
  $segments,
  $nodes
  }
  </oneway>
};

declare function xosm_item:wayDistance($name,$ways,$distance)
{
  <oneway name="{$name}" type="way" distance="{$distance}">
  {
 $ways
  }
  </oneway>
};

declare function xosm_item:area($name,$ways)
{
  <oneway name="{$name}" type="area">
  {
  $ways
  }
  </oneway>
};

declare function xosm_item:areaDistance($name,$ways,$distance)
{
  <oneway name="{$name}" type="area" distance="{$distance}">
  {
 $ways
  }
  </oneway>
};



declare function xosm_item:polygon($name,$ways)
{
  <oneway name="{$name}" type="polygon">
  {
  $ways
  }
  </oneway>
};

declare function xosm_item:polygonDistance($name,$ways,$distance)
{
  <oneway name="{$name}" type="polygon" distance="{$distance}">
  {
 $ways
  }
  </oneway>
};

declare function xosm_item:node($id,$lon,$lat,$tags)
{
  <node id="{$id}" lon="{$lon}" lat="{$lat}">
  {$tags}
  </node>
};


declare function xosm_item:segment($id,$refs,$tags)
{
  <way id="{$id}">
  {$refs,
  $tags}
  </way>
};

declare function xosm_item:ref($id,$lon,$lat)
{
  <nd ref="{$id}"/>
};

declare function xosm_item:tag($k,$v)
{
 <tag k="{$k}" v="{$v}"/>
};

(: ACCESS :)

declare function xosm_item:lon($node)
{
  $node/node/@lon
};

declare function xosm_item:lat($node)
{
  $node/node/@lat
};

declare function xosm_item:name($item)
{
  $item/@name
};

declare function xosm_item:refs($item)
{
  $item//nd
};

declare function xosm_item:tags($item)
{
  $item//tag
};

declare function xosm_item:segments($way)
{
  $way//way
};

declare function xosm_item:nodes($way)
{
  $way//node
};

declare function xosm_item:id($way)
{
  $way/@id
};


(: OPERATIONS :)

declare function xosm_item:length($oneway)
{
(if ($oneway[@type="way"]) then 
geo:length(xosm_gml:_osm2GmlLine($oneway)) * (math:pi() div 180) * 6378137
else 0) 
};

declare function xosm_item:area($oneway)
{
if ($oneway[@type="area" or @type = "polygon"]) then geo:area(xosm_gml:_osm2GmlPolygon($oneway)) * (math:pi() div 180) * 6378137 * (math:pi() div 180) * 6378137  
  else 0  
};

declare function xosm_item:distance($oneway,$oneway2)
{
geo:distance(
    
  if ($oneway[@type="way"]) then xosm_gml:_osm2GmlLine($oneway)
  else if ($oneway[@type="area" or @type = "polygon"]) then xosm_gml:_osm2GmlPolygon($oneway) 
  else xosm_gml:_osm2GmlPoint($oneway/node/@lat,$oneway/node/@lon),
  
  if ($oneway2[@type="way"]) then xosm_gml:_osm2GmlLine($oneway2) else 
  if ($oneway2[@type="area" or @type = "polygon"]) then xosm_gml:_osm2GmlPolygon($oneway2) else
  xosm_gml:_osm2GmlPoint($oneway2/node/@lat,$oneway2/node/@lon))
};

 
