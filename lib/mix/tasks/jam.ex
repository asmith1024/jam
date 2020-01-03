defmodule Mix.Tasks.Jam do
    @moduledoc """
    Renders a portion of the Mandelbrot set and a portion of the Julia set 
    corresponding to the Mandelbrot image center.
    """
  
    use Mix.Task
  
    @doc """
    Takes the same parameters as Mix.Tasks.M
  
    Executes that task and also Mix.Tasks.J centred on the origin with C 
    equal to the image center point of the Mandelbrot set generated earlier.
    """
    def run([centerX, centerY, width, height, i, s]) do
      Mix.Tasks.M.run([centerX, centerY, width, height, i, s])
      Mix.Tasks.J.run(["0.0", "0.0", centerX, centerY, width, height, i, s])
    end
  end
  