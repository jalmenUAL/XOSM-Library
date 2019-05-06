module namespace xosm_pbd = "xosm_pbd";

import module namespace xosm_gml = 'xosm_gml' at '../repo/XOSM2GmlQueryLibrary.xqy';
import module namespace xosm_sp = 'xosm_sp' at 'XOSMSpatial.xqy';

declare function xosm_pbd:getElementByName($bbox1 as xs:decimal, $bbox2 as xs:decimal, $bbox3 as xs:decimal,
                 $bbox4 as xs:decimal, $layer as xs:string, $name as xs:string)
{
let $element :=
(if ($layer = ".")
then
http:send-request(<http:request method='get' href='http://xosm.ual.es/xosmapiV2/internalGetElementByName/minLon/{$bbox1}/minLat/{$bbox2}/maxLon/{$bbox3}/maxLat/{$bbox4}/name/{web:encode-url($name)}'/>)[2]//oneway
else
http:send-request(<http:request method='get' href='http://xosm.ual.es/xosmapiV2/internalGetElementByName/minLon/{$bbox1}/minLat/{$bbox2}/maxLon/{$bbox3}/maxLat/{$bbox4}/name/{web:encode-url($name)}/layer/{web:encode-url($layer)}'/>)[2]//oneway)
return 
 if ($element[@type = "way" or @type = "polygon"]) then $element[@type = "way" or @type = "polygon"][1]
 else $element[1] 
};

declare function xosm_pbd:getElementsByKV($bbox1 as xs:decimal, $bbox2 as xs:decimal, $bbox3 as xs:decimal,
                 $bbox4 as xs:decimal, $layer as xs:string, $k as xs:string, $v as xs:string)
{
 if ($layer = ".")
then
http:send-request(<http:request method='get' href='http://xosm.ual.es/xosmapiV2/internalGetElementByKV/minLon/{$bbox1}/minLat/{$bbox2}/maxLon/{$bbox3}/maxLat/{$bbox4}/k/{$k}/v/{$v}'/>)[2]//oneway
else 
http:send-request(<http:request method='get' href='http://xosm.ual.es/xosmapiV2/internalGetElementByKV/minLon/{$bbox1}/minLat/{$bbox2}/maxLon/{$bbox3}/maxLat/{$bbox4}/k/{$k}/v/{$v}/layer/{web:encode-url($layer)}'/>)[2]//oneway  
};

declare function xosm_pbd:getElementsByKeyword($bbox1 as xs:decimal, $bbox2 as xs:decimal, $bbox3 as xs:decimal,
                 $bbox4 as xs:decimal, $layer as xs:string, $k as xs:string)
{
if ($layer = ".")
then 
http:send-request(<http:request method='get' href='http://xosm.ual.es/xosmapiV2/internalGetElementByK/minLon/{$bbox1}/minLat/{$bbox2}/maxLon/{$bbox3}/maxLat/{$bbox4}/k/{$k}'/>)[2]//oneway
else 
http:send-request(<http:request method='get' href='http://xosm.ual.es/xosmapiV2/internalGetElementByK/minLon/{$bbox1}/minLat/{$bbox2}/maxLon/{$bbox3}/maxLat/{$bbox4}/k/{$k}/layer/{web:encode-url($layer)}'/>)[2]//oneway
};

declare function xosm_pbd:getLayerByName($bbox1 as xs:decimal, $bbox2 as xs:decimal, $bbox3 as xs:decimal,
                 $bbox4 as xs:decimal, $layer as xs:string, $name as xs:string, $distance as xs:integer)
{  
if ($layer = ".") then
  http:send-request(<http:request method='get' href='http://xosm.ual.es/xosmapiV2/internalGetLayerByName/minLon/{$bbox1}/minLat/{$bbox2}/maxLon/{$bbox3}/maxLat/{$bbox4}/name/{web:encode-url($name)}/distance/{$distance}'/>)[2]//oneway 
else
 http:send-request(<http:request method='get' href='http://xosm.ual.es/xosmapiV2/internalGetLayerByName/minLon/{$bbox1}/minLat/{$bbox2}/maxLon/{$bbox3}/maxLat/{$bbox4}/name/{web:encode-url($name)}/distance/{$distance}/layer/{web:encode-url($layer)}'/>)[2]//oneway 
};

declare function xosm_pbd:getLayerByElement($bbox1 as xs:decimal, $bbox2 as xs:decimal, $bbox3 as xs:decimal,
                 $bbox4 as xs:decimal, $layer as xs:string, $oneway as node(), $distance as xs:integer)
{
 if (empty($oneway/@name))
  then 
   if ($layer = ".") then
   http:send-request(<http:request method='get' href='http://xosm.ual.es/xosmapiV2/internalGetLayerByElement/minLon/{$bbox1}/minLat/{$bbox2}/maxLon/{$bbox3}/maxLat/{$bbox4}/lon/{data($oneway/node[1]/@lon)}/lat/{data($oneway/node[1]/@lat)}/distance/{$distance}'/>)[2]//oneway
   else 
   http:send-request(<http:request method='get' href='http://xosm.ual.es/xosmapiV2/internalGetLayerByElement/minLon/{$bbox1}/minLat/{$bbox2}/maxLon/{$bbox3}/maxLat/{$bbox4}/lon/{data($oneway/node[1]/@lon)}/lat/{data($oneway/node[1]/@lat)}/distance/{$distance}/layer/{web:encode-url($layer)}'/>)[2]//oneway
  else xosm_pbd:getLayerByName($bbox1, $bbox2,$bbox3,$bbox4,$layer,data($oneway/@name),$distance)
};

declare function xosm_pbd:getLayerByBB($bbox1 as xs:decimal, $bbox2 as xs:decimal, $bbox3 as xs:decimal, $bbox4 as xs:decimal)
{
http:send-request(<http:request method='get' href='http://xosm.ual.es/xosmapiV2/internalGetLayerByBB/minLon/{$bbox1}/minLat/{$bbox2}/maxLon/{$bbox3}/maxLat/{$bbox4}'/>)[2]//oneway
};

declare function xosm_pbd:getLayer($bbox1 as xs:decimal, $bbox2 as xs:decimal, $bbox3 as xs:decimal, $bbox4 as xs:decimal, $layer as xs:string)
{
if ($layer = ".") then () else
http:send-request(<http:request method='get' href='http://xosm.ual.es/xosmapiV2/internalGetFullLayer/layer/{$layer}'/>)[2]//oneway
};

declare function xosm_pbd:getCenterFromBB($bbox1 as xs:decimal, $bbox2 as xs:decimal, 
   $bbox3 as xs:decimal, $bbox4 as xs:decimal){
   xosm_sp:centerOfBB($bbox1,$bbox2,$bbox3,$bbox4)
};