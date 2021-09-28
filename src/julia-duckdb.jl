using DataFrames
include("api.jl")
include("struct.jl")
include("funs.jl")

libduckdb="../build/release/src/libduckdb.so"

duckdb_open(":memory:",handle)
duckdb_connect(handle,connection)
duckdb_query(connection,"CREATE TABLE integers(icol INTEGER, jcol INTEGER);",C_NULL)
duckdb_query(connection,"INSERT INTO integers VALUES (3, 4), (5, 6), (7, 8);",C_NULL)
duckdb_query(connection,"SELECT * FROM integers;",result)
toDF(result)