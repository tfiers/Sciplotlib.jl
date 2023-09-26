
# For `bbox` "tight", the shown/saved (w,h) of a figure is often
# different from what you specify in `plt.subplots(figsize=…)`.
# (See also comment on "savefig.bbox" in rcparams.jl).
# This func can find the real size.
#
# Thanks Zack Li (https://github.com/JuliaLang/IJulia.jl/pull/918)
function output_size_px(fig)
    path = tempname() * ".png"
    fig.savefig(path)
    bytes = read(path)
    ntoh.(reinterpret(Int32, bytes[17:24]))
end

output_size(fig) = output_size_px(fig) ./ pyconvert(Int, fig.dpi)

given_size(fig) = pyconvert(Vector, fig.get_size_inches())

aspect_ratio(w, h) = w / h

# (More proper might be a FigSizeInfo struct, maybe to start just with
# one non-type-parametrized NamedTuple field; and then define Base.show
# for it. User can then extract the data. And you can save the sizes, no
# need to recalculate them every time (i.e. not keep creating new png's
# in tempdir haha)).
function print_size_info(fig)
    round2(x) = round(x, digits = 2)
    (wi, hi) = round2.(given_size(fig))
    (wo, ho) = round2.(output_size(fig))
    info(w, h) = ("($w, $h), aspect: ", round2(aspect_ratio(w, h)))
    println("Given size:  ", info(wi, hi)...)
    println("Output size: ", info(wo, ho)...)
    println("Width scaling: figure text will be ", round2(wo / wi), " × size of text in pdf")
end


function set_bbox(bbox = "standard")
    if bbox ∈ ("standard", "tight")  # The dict-like `mpl.rcParams` object errors if not
        mpl.rcParams["savefig.bbox"] = bbox
    end
    # From PythonPlot.jl:
    @eval Main function Base.show(io::IO, m::MIME"image/png", f::PythonPlot.Figure)
        if $(bbox == "standard")  # Can't pass that here.
            f.canvas.print_figure(io, format="png")
        else
            f.canvas.print_figure(io, format="png", bbox_inches=$bbox)
        end
    end
end
