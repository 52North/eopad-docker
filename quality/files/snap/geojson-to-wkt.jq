def wrap: "(\(.))";
def type(t): t + wrap;
def geom1: map(tostring) | join(" ");
def geom2: map(geom1) | join(",");
def geom3: map(geom2 | wrap) | join(",");
def geom4: map(geom3 | wrap) | join(",");
def wkt:
  if .type == "Point" then 
    .coordinates | geom1 | type("POINT")
  elif .type == "MultiPoint" then 
    .coordinates | geom2  | type("MULTIPOINT")
  elif .type == "LineString" then 
    .coordinates | geom2  | type("LINESTRING")
  elif .type == "MultiLineString" then 
    .coordinates | geom3 | type("MULTILINESTRING")
  elif .type == "Polygon" then 
    .coordinates | geom3 | type("POLYGON")
  elif .type == "MultiPolygon" then 
    .coordinates | geom4 | type("MULTIPOLYGON")
  elif .type == "GeometryCollection" then 
    .geometries | map(wkt) | join(",") | type("GEOMETRYCOLLECTION")
  else 
    error("Error: unsupported type \(.type)\n")
  end;
. | wkt