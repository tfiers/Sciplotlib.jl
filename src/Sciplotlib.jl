module Sciplotlib

using Reexport
@reexport using Colors
@reexport using PyPlot: PyPlot, plt
# `plt` is set to mpl.pyplot in PyPlot's __init__. `PyPlot as plt` doesn't work.

using PyPlot: matplotlib as mpl
# We don't `@reexport` this, to avoid the frequent
# `WARNING: could not import PyPlot.mpl into VoltoMapSim`

using PyCall
using Unitful
using Unitful: Units
using ColorVectorSpace
using Printf
using PartialFunctions: $

include("plot.jl")
export plot, hist

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

include("precompile.jl")
_precompile_()

include("init.jl")
export rcParams, rcParams_original

end
