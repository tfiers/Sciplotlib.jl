
# See also ./init.jl

# Docs: https://matplotlib.org/stable/users/explain/customizing.html#the-default-matplotlibrc-file
#
sciplotlib_style = Dict(
    "font.size"            => 11,  # Points. Same as my LaTeX \documentclass[a4paper,11pt]{memoir}
                                   # Sizes like "smaller", "small", "x-small" scale relative to this.

    "axes.spines.top"      => false,
    "axes.spines.right"    => false,
    "axes.grid"            => true,
    "axes.axisbelow"       => true,  # Grid _below_ patches (such as histogram bars), not on top.
    "axes.grid.which"      => "both",
    "grid.linewidth"       => 0.5,        # These are for major grid. Minor grid styling
    "grid.color"           => "#E7E7E7",  #     is set in `set!`.

    "xtick.direction"      => "in",
    "ytick.direction"      => "in",
    "xtick.labelsize"      => "small", # Default is "medium"
    "ytick.labelsize"      => "small", # idem
    "legend.fontsize"      => "small", # Default is "medium"
    "axes.titlesize"       => "medium",
    "axes.titlepad"        => 12,      # Distance to axis. Default: 6.0 (pts)
    "axes.labelsize"       => 9,
    "xaxis.labellocation"  => "center",
    "axes.titlelocation"   => "center",

    "legend.borderpad"     => 0.6,
    "legend.borderaxespad" => 0.2,

    "lines.solid_capstyle" => "round",

    "figure.facecolor"     => "white",
    "figure.figsize"       => (4, 2.4),
    "figure.dpi"           => 200,
    "savefig.dpi"          => "figure",
    "savefig.bbox"         => "tight",   # Default is "standard".
        # IJulia display is hard-coded to "tight" (https://github.com/JuliaPy/PythonPlot.jl/issues/31)
        # So setting "tight" here replicates on disk the figs shown in IJulia.
        # See also `./figsize.jl`.

    "axes.autolimit_mode"  => "round_numbers",  # Default: "data"
    "axes.xmargin"         => 0,
    "axes.ymargin"         => 0,
)

"""
Reset Matplotlib's style to `rcParams_original`, then apply the supplied dictionary of
`rcParams` settings. Call without arguments to reset to Matplotlib's defaults. To reset to
Sciplotlib's defaults, pass `sciplotlib_style`.

The initial reset is so that you can experiment with parameters; namely add and then remove
entries. Without the reset, once a parameter was set it would stay set.
"""
function set_mpl_style!(updatedRcParams = nothing)
    pymerge!(rcParams, rcParams_original)
    isnothing(updatedRcParams) || pymerge!(rcParams, updatedRcParams)
    return rcParams
end
# You can also simply do `mpl.rcParams["some.key"] = value` and it'll work :)
# Thx PythonCall.

function pymerge!(base, new)
    for (key, val) in new
        base[key] = val
    end
end

pymerge!(base, new::Py) = pymerge!(base, py_dictlike_to_Dict(new))

py_dictlike_to_Dict(x) = Dict(key => x[key] for key in x)
# `pyconvert(Dict, mpl.rcParams)` no work: it's some dict superclass,
# and you get a "fatal inheritance error: could not merge MROs".
