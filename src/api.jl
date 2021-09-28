handle = Ref{Ptr{Cvoid}}()
connection = Ref{Ptr{Cvoid}}()
result = Ref{duckdb_result}()
types=(missing,UInt8,Int8,Int16,Int32,Int64,UInt8,UInt16,UInt32,UInt64,Float32,Float64)

function duckdb_open(db_file,db_handle)
	ccall( (:duckdb_open,libduckdb),Cint,(Ptr{UInt8},Ptr{Cvoid}),db_file,db_handle)
end

function duckdb_connect(db_handle,db_connection)
	ccall( (:duckdb_connect,libduckdb),Cint,(Ptr{Cvoid},Ptr{Cvoid}),db_handle[],db_connection)
end

function duckdb_query(db_connection,db_query,db_result)
	ccall( (:duckdb_query,libduckdb),Cint,(Ptr{Cvoid},Ptr{UInt8},Ptr{Cvoid}),db_connection[],db_query,db_result);
end
