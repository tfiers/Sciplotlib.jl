# Sciplotlib.jl

Wrapper around PythonPlot.jl (which is a Julia wrapper of Matplotlib),
with pretty defaults and a productive API.

# ⚠️ Deprecated

(Julia code for customizing python plots is slow. Better to write
plotting code in Python, and then call directly that through PythonCall.jl
(and not use PythonPlot.jl, and this package which wraps it).)
