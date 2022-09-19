# On `PyNULL()` and `copy!`:
# https://github.com/JuliaPy/PyCall.jl/issues/699#issuecomment-504616552

"""
Matplotlib's style settings [1]. Note that directly editing `mpl.rcParams` has no effect
[2]. Editing this object however does work.

- [1] https://matplotlib.org/stable/tutorials/introductory/customizing.html#the-default-matplotlibrc-file
- [2] https://github.com/JuliaPy/PyPlot.jl#modifying-matplotlibrcparams
"""
const rcParams = PyNULL()

"""
A copy of the initial `mpl.rcParams`. Note that we do not use `mpl.rcParamsDefault` or
`mpl.rcParamsOrig`, as these are different to what's actually used by default (e.g. in a
Jupyter notebook).
"""
const rcParams_original = PyNULL()

function __init__()
    copy!(rcParams_original, mpl.rcParams)
    copy!(rcParams, PyPlot.PyDict(mpl."rcParams")) # String quotes prevent conversion from
    #                                              # Python to Julia dict.
    set_mpl_style!(sciplotlib_style)
end
