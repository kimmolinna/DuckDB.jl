struct duckdb_column
	data::Ptr{Cvoid}
	nullmask::Ptr{UInt8}
    type::Ptr{Int32}
	name::Ptr{UInt8}
	internal_data::Ptr{Cvoid}
end

struct duckdb_result
	column_count::Ptr{UInt64}
	row_count::Ptr{UInt64}
	rows_changed::Ptr{UInt64}
	columns::Ptr{duckdb_column}
	error_message::Ptr{UInt8}
	internal_data::Ptr{Cvoid}
end