defmodule Mix.Tasks.M do
  @moduledoc """
  Renders a portion of the Mandelbrot set.
  """

  use Mix.Task

  @doc """
  Renders a portion of the Mandelbrot set given the following parameters:
  Image center X, image center Y (reals)
  width, height, max iterations (integers)
  step value (real)

  The set is written to the file r[center X]i[center Y]s[step]m.bmp in the current directory.

  ## Examples

  The classic image:

  > mix m 0.0 0.0 100 100 1 0.1
  > mix m -0.5 0.0 200 200 256 0.01

  """
  def run([centerX, centerY, width, height, i, s]) do
    Jam.Simple.mandelbrot(
      String.to_float(centerX),
      String.to_float(centerY),
      String.to_integer(width),
      String.to_integer(height),
      String.to_integer(i),
      String.to_float(s),
      "r#{centerX}i#{centerY}s#{s}m.bmp"
    )
  end
end
