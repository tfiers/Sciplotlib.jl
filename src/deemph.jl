
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


function deemph_middle_ticks(x, black = 0.24)
    if isinstance(x, plt.Figure)
        for ax in x.axes
            deemph_middle_ticks(ax, black)
        end
    elseif isinstance(x, plt.Axes)
        deemph_middle_ticks(x.xaxis, black)
        deemph_middle_ticks(x.yaxis, black)
    else
        _deemph_middle_ticks(x, black)
    end
    x
end

isinstance(x, T) = pyconvert(Bool, pybuiltins.isinstance(x, T))

function _deemph_middle_ticks(axis, black)
    color = as_mpl_type(Gray(1 - black))
    ticklabels = pyconvert(Vector, axis.get_ticklabels())
    N = length(ticklabels)
    N_to_deemph = length(ticklabels) - 2
    N_to_deemph > 0 || return
    for t in ticklabels[2:end-1]
        t.set_color(color)
    end
    ticks = get_ticks(axis)
    N = length(axis.get_ticklocs())
    major_ticks = ticks[1:N]
    minor_ticks = ticks[(N+1):end]
    for t in major_ticks[2:end-1]
        t._apply_params(; color)  # Thx https://stackoverflow.com/a/33698352/2611913
    end
    for t in minor_ticks
        t._apply_params(; color)
    end
end

get_ticks(axis) = filter!(x -> isinstance(x, mpl.axis.Tick), pyconvert(Vector, axis.get_children()))
