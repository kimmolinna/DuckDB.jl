module DuckDB
using DataFrames,Dates,DuckDB_jll
include("struct.jl")
include("api.jl")

function toDF(result)
    columns=unsafe_wrap(Array{duckdb_column},result[].columns,Int64(result[].column_count));
    df = DataFrame();
    for i in 1:Int64(result[].column_count)
        rows = Int64(result[].row_count)
        type_ind = Int64(columns[i].type)+1
        type = duckdb_types[type_ind]
        name = unsafe_string(columns[i].name)
        mask = unsafe_wrap(Array,columns[i].nullmask,rows)
        data = unsafe_wrap(Array,(Ptr{type}(columns[i].data)),rows)
        
        if DUCKDB_TYPE(type_ind) == DUCKDB_TYPE_DATE
            column = Dates.epochdays2date.(data.+719528)
        elseif DUCKDB_TYPE(type_ind) == DUCKDB_TYPE_VARCHAR
            column = unsafe_string.(data)
        else
            column = data
        end    
        
        column = convert(Vector{Union{Missing,eltype(column)}},column)
        column[reinterpret(Bool,mask)] .= missing
        df[!,name] = column           
    end
    return df
end

function dbDisconnect(con)
    duckdb_disconnect(con)
end

function closedb(db)
    duckdb_close(db)
end

dbConnect() = dbConnect(":memory:")

function dbConnect(file)
    db = Ref{Ptr{Cvoid}}()
    con = Ref{Ptr{Cvoid}}()
    duckdb_open(file,db)
    duckdb_connect(db,con)
    return con
end
    
function dbExecute(con,sql) 
    res = Ref{duckdb_result}()
    duckdb_query(con,sql,res)
    return res
end

end # module
