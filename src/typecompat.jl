
as_mpl_type(x::Symbol)    = string(x)
as_mpl_type(x::Colorant)  = toRGBAtuple(x)
as_mpl_type(x)            = x
