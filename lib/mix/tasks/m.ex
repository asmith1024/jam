defmodule Mix.Tasks.M do
  use Mix.Task

  def run([xO, yO, width, height, i, s]) do
    Jam.Simple.mandelbrot(
      String.to_float(xO),
      String.to_float(yO),
      String.to_integer(width),
      String.to_integer(height),
      String.to_integer(i),
      String.to_float(s),
      "m.bmp"
    )
  end
end
