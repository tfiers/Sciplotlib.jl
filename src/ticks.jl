
function _set_ticks(ax, axtypes, minorticks, ticklabels)

    xypairs = zip([ax.xaxis, ax.yaxis], axtypes, minorticks, ticklabels)
    for (axis, axtype, minorticks, ticklabels) in xypairs

        turn_off_minorticks() = axis.set_minor_locator(mpl.ticker.NullLocator())

        if axtype == :range
            # Because we set the rcParam `autolimit_mode` to `data`, xlim/ylim == data range.
            a, b = axis.get_view_interval()
            digits = 2
            axis.set_ticks([round(a, RoundDown; digits), round(b, RoundUp; digits)])
            # Turn off all gridlines.
            axis.grid(which = "major", visible = false)
            turn_off_minorticks()

        elseif axtype == :categorical
            # Do not mess with ticklocs. Except:
            turn_off_minorticks()

        elseif axis.get_scale() == "log"
            # Mpl default is good, do nothing.

        else
            axis.set_major_locator(mpl.ticker.MaxNLocator(nbins = 7, steps = [1, 2, 5, 10]))
            #   `nbins` should probably depend on figure size, i.e. how large texts are wrt
            #   other graphical elements.
            if minorticks
                axis.set_minor_locator(mpl.ticker.AutoMinorLocator())
            else
                turn_off_minorticks()
            end
        end

        # LogLocator places ticks outside limits. So we trim those.
        ticklocs = axis.get_ticklocs()
        a, b = axis.get_view_interval()
        ticklocs = ticklocs[a .≤ ticklocs .≤ b]

        if isnothing(ticklabels)
            ticklabels = [@sprintf "%.4g" t for t in ticklocs]
        end

        units = hasproperty(axis, :unitful_units) ? axis.unitful_units : NoUnits
        if units != NoUnits
            suffix = " " * repr("text/plain", units)
            if axis == ax.xaxis
                prefix_width = round(Int, length(suffix) * 1.6)
                prefix = repeat(" ", prefix_width)  # Imprecise hack to shift label to the
                                                    # right, to get number back under tick.
            else
                prefix = ""
            end
            ticklabels[end] = prefix * ticklabels[end] * suffix
        end

        bbox = Dict(
            :facecolor => mpl.rcParams["figure.facecolor"],
            :edgecolor => "none",
            :pad => 3,  # Relative to fontsize (google "bbox mutation scale").
        )
        # Goal: labels stay visible when overlapping with elements of an adjactent Axes.

        axis.set_ticks(ticklocs, ticklabels; bbox)
    end
end
