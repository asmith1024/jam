defmodule Mix.Tasks.Single do
  use Mix.Task

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
