defmodule Jam do
  @moduledoc """
  Generates images of Julia sets and the Mandelbrot set.
  """

  @doc """
  Generates an image of a portion of the Mandelbrot set centred on origin 
  with width and height pixels and step distance between pixels on both 
  the real and imaginary axes. Resolution is determined by iterations.
  Supply {r, i} for origin. Points are rendered into 24-bit RGB values
  by fn_color.
  """
  def mandelbrot({width, height, origin, step, iterations}, fn_color) do
    plane(width, height, origin, step)
    |> Stream.map(&init_mandelbrot(&1, iterations))
    |> Stream.map(&Jam.Mandelbrot.point(&1))
    |> Stream.map(&fn_color.(&1))
  end

  @doc """
  Generates an image of a portion of the Julia set centred on origin 
  where the corresponding Mandelbrot set point is c. It has width 
  and height pixels and step distance between pixels on both the real 
  and imaginary axes.  Resolution is determined by iterations.
  Supply {r, i} for both origin and c. Points are rendered into 24-bit
  RGB values by fn_color.
  """
  def julia({width, height, origin, c, step, iterations}, fn_color) do
    plane(width, height, origin, step)
    |> Stream.map(&init_julia(&1, c, iterations))
    |> Stream.map(&Jam.Mandelbrot.point(&1))
    |> Stream.map(&fn_color.(&1))
  end

  defp plane(width, height, origin, step) do
    range = 0..(width * height - 1)
    mid_point = {mid(width), mid(height), origin}
    Stream.map(range, &init_common(&1, width, mid_point, step))
  end

  defp mid(x) do
    n = div(x, 2)

    case rem(x, 2) do
      0 -> n
      _ -> n + 1
    end
  end

  defp init_common(index, width, {mid_row, mid_col, {r0, i0}}, step) do
    row = div(index, width)
    col = rem(index, width)

    {
      index,
      {
        r0 + (col - mid_col) * step,
        i0 + (row - mid_row) * step
      }
    }
  end

  defp init_mandelbrot({index, c}, iterations) do
    %Jam.Point{
      index: index,
      c: c,
      max_iterations: iterations
    }
  end

  defp init_julia({index, z}, c, iterations) do
    %Jam.Point{
      index: index,
      initial_z: z,
      c: c,
      max_iterations: iterations
    }
  end
end
