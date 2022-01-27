module Sciplotlib

using PyPlot: PyPlot as plt, matplotlib as mpl
using PyCall
using Unitful
using Unitful: Units
using Colors
using ColorVectorSpace
using Printf
using PartialFunctions: $

include("plot.jl")
export plot

include("set.jl")
export set, legend, hylabel

include("style.jl")
export mplstyle

include("colors.jl")
export mix, lighten, darken, deemph, toRGBAtuple,
       black, white, lightgrey, mplcolors,
       C0, C1, C2, C3, C4, C5, C6, C7, C9, C10

include("typecompat.jl")
export as_mpl_type

include("ticks.jl")
include("util.jl")

end
