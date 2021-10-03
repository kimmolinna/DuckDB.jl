# Julia C-API wrapper for DuckDB
## Installation
pkg> add https://github.com/kimmolinna/julia-duckdb

julia> import DuckDB

Until DuckDB_jll.jl is updated you have to download shared C/C++-library from DuckDB webpage
 [DuckDB Installation](https://duckdb.org/docs/installation/)

DuckDB.libduckdb = "location_of_shared_library"<br>
For example in Linux<br>
DuckDB.libduckdb = "/home/kimmo/libduckdb/libduckdb.so"

## Basics
con = DuckDB.connect(":memory:")<br>
res = DuckDB.execute(con,"CREATE TABLE integers(date DATE, jcol INTEGER)")<br>
res = DuckDB.execute(con,"INSERT INTO integers VALUES ('2021-09-27', 4), ('2021-09-28', 6), ('2021-09-29', 8)")<br>
res = DuckDB.execute(con, "SELECT * FROM integers")
DuckDB.toDataFrame(res)
DuckDB.disconnect(con)