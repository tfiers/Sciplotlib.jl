# Only included if Unitful is loaded.

using .Unitful
using .Unitful: Units

as_mpl_type(x::AbstractArray{<:Quantity})  = ustrip(x)
as_mpl_type(x::Quantity)                   = ustrip(x)
as_mpl_type(x::Units)                      = string(x)

has_mixed_dimensions(x::AbstractArray{<:Quantity{T,Dims}}) where {T,Dims}  = false
has_mixed_dimensions(x::AbstractArray{<:Quantity})                         = true
has_mixed_dimensions(x::AbstractArray)                                     = false
