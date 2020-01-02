defmodule Mix.Tasks.Single do
  @moduledoc """
  Tests values for a single point.
  """
  use Mix.Task

  @doc """
  Provide Jam.Point initialization values for index, real Z, imaginary Z, real C, imaginary C and max_iterations.
  Prints initial and final Jam.Point values, and pixel color.
  """
  def run([index, rZ, iZ, rC, iC, iterations]) do
    pInitial = %Jam.Point{
      index: String.to_integer(index),
      initial_z: {String.to_float(rZ), String.to_float(iZ)},
      c: {String.to_float(rC), String.to_float(iC)},
      max_iterations: String.to_integer(iterations)
    }

    IO.inspect(pInitial)
    pFinal = Jam.Mandelbrot.point(pInitial)
    IO.inspect(pFinal)
    pixel = Jam.Color.simple1(pFinal)
    IO.inspect(pixel)
  end
end
