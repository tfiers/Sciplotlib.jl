module Sciplotlib

using Reexport
using Colors
export Colors  # We don't `@reexport` Colors, as it's got a huge namespace.

@reexport using PythonCall  # export `pyconvert`, `pybuiltins` (for `isinstance(…)`), etc

@reexport using PythonPlot: PythonPlot, pyplot as plt
@reexport using PythonPlot: matplotlib as mpl

using Requires
using ColorVectorSpace
using Printf
using PartialFunctions: $


include("plot.jl")
export plot, hist

include("set.jl")
export set, legend, hylabel, rm_ticks_and_spine

include("colors.jl")
export mix, lighten, darken, deemph, toRGBAtuple,
       black, white, lightgrey, Gray, mplcolors,
       C0, C1, C2, C3, C4, C5, C6, C7, C9, C10

include("typecompat.jl")
export as_mpl_type

include("ticks.jl")
include("util.jl")

include("figsize.jl")
export print_size_info, set_bbox

include("rcparams.jl")
export sciplotlib_style, set_mpl_style!

# include("precompile.jl")
# _precompile_()
# ↪ We can't: may not call any py during precompile stage.

include("init.jl")
export rcParams, rcParams_original

end
