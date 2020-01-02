defmodule Mix.Tasks.M do
  @moduledoc """
  Renders the Mandelbrot set.
  """

  use Mix.Task

  @doc """
  Renders the Mandelbrot set given the following parameters:
  Origin X, origin Y (reals)
  width, height, max iterations (integers)
  step value (real)

  The set is written to the file m.bmp in the current directory.

  ## Examples

  The classic image:

  > mix m 0.0 0.0 100 100 1 0.1
  > mix m -0.5 0.0 200 200 256 0.01

  """
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
