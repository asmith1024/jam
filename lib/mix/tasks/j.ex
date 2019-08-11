defmodule Mix.Tasks.J do
  use Mix.Task

  def run([xO, yO, xC, yC, width, height, i, s]) do
    Jam.Simple.julia(
      String.to_float(xO),
      String.to_float(yO),
      String.to_float(xC),
      String.to_float(yC),
      String.to_integer(width),
      String.to_integer(height),
      String.to_integer(i),
      String.to_float(s),
      "j.bmp"
    )
  end
end
