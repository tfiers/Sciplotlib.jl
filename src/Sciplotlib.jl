module Sciplotlib

using Reexport
@reexport using Colors
@reexport using PyPlot: PyPlot, plt, matplotlib as mpl
#    `plt` is set to mpl.pyplot in PyPlot's __init__. `PyPlot as plt` doesn't work.

using PyCall
using Unitful
using Unitful: Units
using ColorVectorSpace
using Printf
using PartialFunctions: $

include("plot.jl")
export plot

include("set.jl")
export set, legend, hylabel

include("colors.jl")
export mix, lighten, darken, deemph, toRGBAtuple,
       black, white, lightgrey, mplcolors,
       C0, C1, C2, C3, C4, C5, C6, C7, C9, C10

include("typecompat.jl")
export as_mpl_type

include("ticks.jl")
include("util.jl")

include("style.jl")
export sciplotlib_style, set_mpl_style!

include("init.jl")
export rcParams, rcParams_original

end
