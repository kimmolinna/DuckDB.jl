function toDF(db_result)
    columns=unsafe_wrap(Array,db_result[].columns,Int64(db_result[].column_count));
    df = DataFrame();
    for i in 1:Int64(db_result[].column_count)
        type = types[Int64(columns[i].type)+1]
        name = unsafe_string(columns[i].name)
        mask = unsafe_wrap(Array,columns[i].nullmask,Int64(result[].row_count))
        column = convert(Vector{Union{Missing,type}},unsafe_wrap(Array,(Ptr{type}(columns[i].data)),Int64(result[].row_count)))
        column[reinterpret(Bool,mask)] .= missing
        df[!,name] = column
    end
    return df
end