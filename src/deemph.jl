
"""
De-emphasise part of an Axes by colouring it light grey.
`part` is one of {:xlabel, :ylabel, :xaxis, :yaxis}.
"""
function deemph(part::Symbol, ax; color = lightgrey)
    color = toRGBAtuple(color)
    if part == :xlabel
        ax.xaxis.get_label().set_color(color)
    elseif part == :ylabel
        ax.yaxis.get_label().set_color(color)
        hasproperty(ax, :hylabel) && ax.hylabel.set_color(color)
    elseif part == :xaxis
        foreach(loc -> ax.spines[loc].set_color(color), ["top", "bottom"])
        ax.tick_params(; axis = "x", which = "both", color, labelcolor = color)
    elseif part == :yaxis
        foreach(loc -> ax.spines[loc].set_color(color), ["left", "right"])
        ax.tick_params(; axis = "y", which = "both", color, labelcolor = color)
    end
end


function deemph_middle_ticks(x; kw...)
    if isinstance(x, plt.Figure)
        for ax in x.axes
            deemph_middle_ticks(ax; kw...)
        end
    elseif isinstance(x, plt.Axes)
        deemph_middle_ticks(x.xaxis; kw...)
        deemph_middle_ticks(x.yaxis; kw...)
    else
        _deemph_middle_ticks(x; kw...)
    end
    x
end

isinstance(x, T) = pyconvert(Bool, pybuiltins.isinstance(x, T))

function _deemph_middle_ticks(
    axis;
    ticklabel_black = 0.24,
    major_tick_black = 0,
    minor_tick_black = 0,
)
    gray(black) = as_mpl_type(Gray(1 - black))
    ticklabels = pyconvert(Vector, axis.get_ticklabels())
    N = length(ticklabels)
    N_to_deemph = length(ticklabels) - 2
    N_to_deemph > 0 || return
    for t in ticklabels[2:end-1]
        t.set_color(color = gray(ticklabel_black))
    end
    ticks = get_ticks(axis)
    N = length(axis.get_ticklocs())
    major_ticks = ticks[1:N]
    minor_ticks = ticks[(N+1):end]
    # Thx https://stackoverflow.com/a/33698352/2611913 for `tick._apply_params()`
    for t in major_ticks[2:end-1]
        t._apply_params(color = gray(major_tick_black))
    end
    for t in minor_ticks
        t._apply_params(color = gray(minor_tick_black))
    end
end

get_ticks(axis) = filter!(x -> isinstance(x, mpl.axis.Tick), pyconvert(Vector, axis.get_children()))
