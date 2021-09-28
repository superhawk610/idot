# This script will display a Graphviz graphic from STDIN
# using iTerm's built-in support for rendering images.
#
# Prerequisites:
#
#     $ brew install graphviz librsvg
#
module Idot
  VERSION = "0.1.0"

  class CLI
    @tmux = false
    @filename = "idot.svg"

    @@graph_color_scheme = "rdpu9"
    @@graph_color = "1"
    @@graph_style = [
      "-Gpad=0.2",
      "-Gbgcolor=none", # transparent
      %(-Ncolorscheme=#{@@graph_color_scheme}),
      %(-Ecolorscheme=#{@@graph_color_scheme}),
      %(-Ncolor=#{@@graph_color}),
      %(-Nfontcolor=#{@@graph_color}),
      %(-Ecolor=#{@@graph_color}),
    ]

    def initialize
      @svg = File.tempfile("out.svg", mode = "w")
      @png = File.tempfile("out.png", mode = "w")
    end

    def finalize
      @svg.delete
      @png.delete
    end

    def run
      Process.new("dot", ["-Tsvg"].concat(@@graph_style), input: STDIN, output: @svg, error: STDERR).wait
      Process.new("rsvg-convert", ["-a", "-h", "300", @svg.path], output: @png, error: STDERR).wait
      png = File.read(@png.path)

      esc
      print "]1337;File=inline=1;name="
      Base64.strict_encode(@filename, STDOUT)
      printf ";size=%d:", png.size
      Base64.strict_encode(png, STDOUT)
      print "\a\n"
    end

    private def esc
      print @tmux ? "\033Ptmux;\033]033" : "\033"
    end
  end
end

Idot::CLI.new.run
