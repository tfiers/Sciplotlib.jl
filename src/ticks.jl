
function _set_ticks(ax, args...)

    xypairs = zip([ax.xaxis, ax.yaxis], args...)
    for (axis, axtype, ticklocs, nbins, minorticks, ticklabels, unit, units_in) in xypairs

        turn_off_minorticks() = axis.set_minor_locator(mpl.ticker.NullLocator())

        if axtype == :keep
            continue

        elseif axtype == :range
            # Because we set the rcParam `autolimit_mode` to `data`, xlim/ylim == data range.
            a, b = pyconvert(Vector, axis.get_view_interval())
            digits = 2
            axis.set_ticks([round(a, RoundDown; digits), round(b, RoundUp; digits)])
            # Turn off all gridlines.
            axis.grid(which = "major", visible = false)
            turn_off_minorticks()

        elseif axtype ∈ [:categorical, :cat]
            # Do not mess with ticklocs. Except:
            turn_off_minorticks()

        elseif axis.get_scale() == "log"
            # Mpl default is good, do nothing.

        else
            if ticklocs == :auto
                axis.set_major_locator(mpl.ticker.MaxNLocator(; nbins, steps = [1, 2, 5, 10]))
                #   `nbins` should probably depend on figure size, i.e. how large texts are wrt
                #   other graphical elements.
                #   For `steps` we omit 2.5.
            end
            if minorticks
                axis.set_minor_locator(mpl.ticker.AutoMinorLocator())
            else
                turn_off_minorticks()
            end
        end

        if ticklocs == :auto
            # LogLocator places ticks outside limits. So we trim those.
            ticklocs = pyconvert(Vector, axis.get_ticklocs())
            a, b = pyconvert(Vector, axis.get_view_interval())
            ticklocs = ticklocs[a .≤ ticklocs .≤ b]
        end

        if isnothing(ticklabels)
            ticklabels = [@sprintf "%.4g" t for t in ticklocs]
        end

        if !isnothing(unit) && units_in == :last_ticklabel
            suffix = " $unit"
            if Bool(axis == ax.xaxis)
                prefix_width = round(Int, length(suffix) * 1.6)
                prefix = repeat(" ", prefix_width)  # Imprecise hack to shift label to the
                                                    # right, to get number back under tick.
            else
                prefix = ""
            end
            ticklabels[end] = prefix * ticklabels[end] * suffix
        end

        # bbox = Dict(
        #     "facecolor" => mpl.rcParams["figure.facecolor"],
        #     "edgecolor" => "none",
        #     "pad" => 3,  # Relative to fontsize (google "bbox mutation scale").
        # )
        # Goal: labels stay visible when overlapping with elements of an adjactent Axes.

        # axis.set_ticks(ticklocs, ticklabels; bbox)
        axis.set_ticks(ticklocs, ticklabels)
        # Note that this changes the tick locator to a FixedLocator. As a result, changing
        # the lims (e.g. zooming in) after this, you won't get useful ticks. (Cannot replace
        # by just `axis.set_ticklabels` either: then labels get out of sync with ticks)
        # Solution is to call `set` again, to get good ticks again.
    end
end
