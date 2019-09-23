def join: map(tostring) | join(",");
def wrap: "(\(.))";
def wrap(t): t + wrap;
def wkt:
  if .type == "Polygon" then 
    .coordinates | map(flatten | join | wrap) | join | wrap("POLYGON")
  else 
    error("Error: unsupported type \(.type)\n")
  end;
. | wkt



