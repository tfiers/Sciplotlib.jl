"""
Set Axes properties and apply beautiful defaults.

Options. Each has both an `x`- and a `y`-prefixed version (`xtype`, `yminorticks`, …)
- `type`: one of
    - `:off`: hide all axis artists.
    - `:categorical` or `:cat`: no ticks nor grid. Supply `x`/`yticklabels`.
    - `:range`: ticks and grid mark the data range (and nothing else).
    - `:fraction` or `:frac`: values are ∈ [0,1] and displayed as percentages.
    - `:default`: our opinionated default
    - `:keep`: don't change ticks or labels
- `axloc`: `:left` or `:right` for `x` and `:top` or `:bottom` for `y`.
- `minorticks`: only for `:default` and `:fraction` types: whether to draw minor ticks.
- `unit`: a symbol or string
- `units_in`: one of `:last_ticklabel`, `:axislabel`, and `nothing`.

Arbitrary keywords like `xlabel=("log scale", :loc=>"center")`
are passed on by calling `ax.set_xlabel("log_scale", loc="center")`.

Arguments given in a similar fashion, to the keywords `legend` and `hylabel`, are passed on
to the eponymous functions.
"""
function set(
    ax;
    xtype       = :default,       ytype       = :default,
    xaxloc      = :bottom,        yaxloc      = :left,
    xticks      = :auto,          yticks      = :auto,
    nbins_x     = 7,              nbins_y     = 7,
    xminorticks = true,           yminorticks = true,
    xticklabels = nothing,        yticklabels = nothing,
    xunit       = nothing,        yunit       = nothing,
    xunits_in   = :axislabel,     yunits_in   = :axislabel,
    kw...
)
    # Axis location, spines, ticks, and gridlines.
    if ytype != :keep
        (yaxloc == :right) && ax.yaxis.tick_right()
        yticks_on = ytype ∉ [:categorical, :cat, :off]
        leftticks_on  = (yticks_on && yaxloc == :left)
        rightticks_on = (yticks_on && yaxloc == :right)
            # If `false`, no gridlines, spines, nor ticks. (But can still have ticklabels).
        ax.spines["left" ].set_visible(leftticks_on)
        ax.spines["right"].set_visible(rightticks_on)
        ax.tick_params(left=leftticks_on, right=rightticks_on)
        ax.yaxis.grid(yticks_on)
        (ytype == :off) && ax.yaxis.set_visible(false)
        (ytype ∈ [:fraction, :frac]) && ax.set_ylim(0, 1)
    end
    if xtype != :keep
        (xaxloc == :top) && ax.xaxis.tick_top()
        xticks_on = xtype ∉ [:categorical, :cat, :off]
        bottomticks_on = (xticks_on && xaxloc == :bottom)
        topticks_on    = (xticks_on && xaxloc == :top)
        ax.spines["bottom"].set_visible(bottomticks_on)
        ax.spines["top"   ].set_visible(topticks_on)
        ax.tick_params(bottom=bottomticks_on, top=topticks_on)
        ax.xaxis.grid(xticks_on)
        (xtype == :off) && ax.xaxis.set_visible(false)
        (xtype ∈ [:fraction, :frac]) && ax.set_xlim(0, 1)
    end
    # (No, can't do this in loop to DRY: `.tick_right`, `.set_ylim`, etc. And macro: hard).

    kw = Dict(pairs(kw))
    # ↪ kw is NamedTuple, which is immutable. But we change values here:
    if !isnothing(xunit) && xunits_in == :axislabel
        xlabel = get(kw, :xlabel, pyconvert(String, ax.get_xlabel()))
        kw[:xlabel] = xlabel * " ($xunit)"
    end
    if !isnothing(yunit) && yunits_in == :axislabel
        if :hylabel in keys(kw) && kw[:hylabel] != nothing
            hylab = get(kw, :hylabel, "")
            kw[:hylabel] = hylab * " ($yunit)"
        else
            ylabel = get(kw, :ylabel, pyconvert(String, ax.get_ylabel()))
            kw[:ylabel] = ylabel * " ($yunit)"
        end
    end

    # Instead of calling `ax.set(; kw...)`, we call the individual methods, so that we
    # can pass more than just the one argument for each.
    for (k, v) in kw
        hasproperty(ax, "set_$k") && _call(getproperty(ax, "set_$k"), v)
    end
    :hylabel in keys(kw) && _call(hylabel $ ax, kw[:hylabel])
    :legend in keys(kw) && _call(legend $ ax, kw[:legend])

    # Various defaults that can't be set through rcParams
    ax.grid(axis = "both", which = "minor", color = "#F4F4F4", linewidth = 0.44)
    for pos in ("left", "right", "bottom", "top")
        spine = ax.spines[pos]
        vis = pyconvert(Bool, spine.get_visible())
        spine.set_position(("outward", vis ? 10 : 5))
        # - `Spine.set_position` resets ticks, and in doing so removes text properties.
        #   Hence these must be called before `_set_ticks` below.
        # - For `:categorical`: the spine is not visible, but the ticklabels still are, and
        #   their distance from the axis is determined by spine pos. We need to reset spine
        #   pos: it might have been set too far outwards by a previous (non-categorical)
        #   `set` call via `plot`.
    end

    # Fix default behaviour where only top and left gridlines are visible when gridlines are
    # on the limits.
    ax.yaxis.get_gridlines()[0].set_clip_on(false)  # bottom
    ax.xaxis.get_gridlines()[-1].set_clip_on(false)  # right
    #   Note the python indices: 0 and -1 (not 1 and end)

    # Our opinionated tick defaults.
    _set_ticks(
        ax,
        [xtype, ytype],
        [xticks, yticks],
        [nbins_x, nbins_y],
        [xminorticks, yminorticks],
        [xticklabels, yticklabels],
        [xunit, yunit],
        [xunits_in, yunits_in],
    )

    # Seems that calling `set_major_formatter` before the `set_major_locator` of
    # `_set_ticks` has no effect. Hence we do it after.
    getpercentfmt() = mpl.ticker.PercentFormatter(xmax=1)
    (ytype ∈ [:fraction, :frac]) && ax.yaxis.set_major_formatter(getpercentfmt())
    (xtype ∈ [:fraction, :frac]) && ax.xaxis.set_major_formatter(getpercentfmt())
    return nothing
end

"""Given a tuple `x = ("arg", :key => "val")`, call `f("arg"; key="val")`."""
function _call(f, x::Tuple)
    firstkw = findfirst(el -> el isa Pair, x)
    if isnothing(firstkw)
        args = x
        kwargs = ()
    else
        args = x[1:firstkw-1]
        kwargs = x[firstkw:end]
    end
    f((args .|> as_mpl_type)...; (kwargs |> mapvals $ as_mpl_type)...)
end

_call(f, x) = f(x |> as_mpl_type)

"""
Add a legend to the axes. Change the order of the items in the legend using
`reorder = [plot_order => legend_order,]`. Eg passing `(4 => 1, 1 => 2)` will make the
4th plotted line come 1st in the legend, and the 1st plotted line come 2nd.
"""
function legend(ax; reorder = false, legendkw...)
    handles, labels = ax.get_legend_handles_labels()
    order = collect(0:length(handles)-1)  # Python indexing
    if reorder != false
        for (i_old, i_new) in reorder
            insert!(order, i_new, popat!(order, i_old))
        end
    end
    ax.legend([handles[i] for i in order], [labels[i] for i in order]; legendkw...)
end

"""Add a horizontal ylabel."""
function hylabel(ax, s; loc="left", dx=0, dy=4, fontsize=mpl.rcParams["axes.labelsize"], kw...)
    offset = mpl.transforms.ScaledTranslation(dx / 72, dy / 72, ax.figure.dpi_scale_trans)
    transform = ax.transAxes + offset
    x = (loc == "left") ? 0 : (loc == "center") ? 0.5 : 1
    t = ax.text(; x, y=1, s, transform, ha=loc, va="bottom", fontsize, kw...)
    ax.hylabel = t
end


function rm_ticks_and_spine(ax, where="bottom")
    # You could also go `ax.xaxis.set_visible(false)`;
    # but that removes gridlines too. This keeps 'em.
    ax.spines[where].set_visible(false)
    ax.tick_params(which="both"; Dict(Symbol(where)=>false)...)
    if where ∈ ("bottom", "top")
        ax.set_xlabel(nothing)
        ax.set_xticklabels([])
    else
        ax.set_ylabel(nothing)
        ax.set_yticklabels([])
    end
end
