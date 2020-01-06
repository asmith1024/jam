defmodule Mix.Tasks.J do
  @moduledoc """
  Renders a Julia set.
  """

  use Mix.Task

  @doc """
  Renders a Julia set given the following parameters:
  Image center X, image center Y, C x, C y (reals)
  width, height, max iterations (integers)
  step value (real)

  The set is written to the file r[center X]i[center Y]cr[C X]ci[C Y]s[step]j.bmp in the current directory.

  ## Examples

  The Julia set centred on the origin of the Mandelbrot set is a circle.

  > mix j 0.0 0.0 0.0 0.0 100 100 1 0.1
  > mix j 0.0 0.0 0.0 0.0 150 150 1 0.028
  > mix j 0.0 0.0 0.0 0.0 100 100 64 0.028

  The set corresponding to an interesting part of the Mandelbrot set:
  
  > mix j 0.0 0.0 -0.74878 0.0659 200 200 256 0.00001

  """
  def run([centerX, centerY, cX, cY, width, height, i, s]) do
    Jam.Simple.julia(
      String.to_float(centerX),
      String.to_float(centerY),
      String.to_float(cX),
      String.to_float(cY),
      String.to_integer(width),
      String.to_integer(height),
      String.to_integer(i),
      String.to_float(s),
      "r#{centerX}i#{centerY}cr#{cX}ci#{cY}s#{s}j.bmp"
    )
  end
end
