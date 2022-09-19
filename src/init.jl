"""
Matplotlib's style settings [1]. Note that directly editing `mpl.rcParams` has no effect
[2]. Editing this object however does work.

- [1] https://matplotlib.org/stable/tutorials/introductory/customizing.html#the-default-matplotlibrc-file
- [2] https://github.com/JuliaPy/PyPlot.jl#modifying-matplotlibrcparams
"""
rcParams = nothing

"""
A copy of the initial `mpl.rcParams`. Note that we do not use `mpl.rcParamsDefault` or
`mpl.rcParamsOrig`, as these are different to what's actually used by default (e.g. in a
Jupyter notebook).
"""
rcParams_original = nothing

function __init__()
    global rcParams = PyPlot.PyDict(mpl."rcParams")  # String quotes prevent conversion from
    #                                                # Python to Julia dict.
    global rcParams_original = copy(mpl.rcParams)
    set_mpl_style!(sciplotlib_style)
end
