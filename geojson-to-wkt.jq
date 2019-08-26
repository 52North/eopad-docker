def join: map(tostring) | join(",");
def geom2: flatten | join;
def wrap: "(\(.))";
def wrap(t): t + wrap;
def geom3: map(geom2 | wrap) | join;
def geom4: map(geom3 | wrap) | join;
def wkt:
  if .type == "Polygon" then 
    .coordinates | geom3 | wrap("POLYGON")
  else 
    error("Error: unsupported type \(.type)\n")
  end;
. | wkt



