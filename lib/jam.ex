defmodule Jam do
  @moduledoc """
  Generates images of Julia sets and the Mandelbrot set.
  """

  @doc """
  Generates an image of a portion of the Mandelbrot set centred on center_xy 
  with width and height pixels and step distance between pixels on both 
  the real and imaginary axes. Resolution is determined by iterations.
  Supply {r, i} for center_xy. Points are rendered into 24-bit RGB values
  by fn_color.
  """
  def mandelbrot({width, height, center_xy, step, iterations}, fn_color) do
    plane(width, height, center_xy, step)
    |> Stream.map(&init_mandelbrot(&1, iterations))
    |> Stream.map(&Jam.Mandelbrot.point(&1))
    |> Stream.map(&fn_color.(&1))
  end

  @doc """
  Generates an image of a portion of the Julia set centred on center_xy 
  where the corresponding Mandelbrot set point is c_xy. It has width 
  and height pixels and step distance between pixels on both the real 
  and imaginary axes.  Resolution is determined by iterations.
  Supply {r, i} for both center_xy and c_xy. Points are rendered into 24-bit
  RGB values by fn_color.
  """
  def julia({width, height, center_xy, c_xy, step, iterations}, fn_color) do
    plane(width, height, center_xy, step)
    |> Stream.map(&init_julia(&1, c_xy, iterations))
    |> Stream.map(&Jam.Mandelbrot.point(&1))
    |> Stream.map(&fn_color.(&1))
  end

  defp plane(width, height, center_xy, step) do
    range = 0..(width * height - 1)
    top_left_offset = top_left_offset(width, height, center_xy, step)
    Stream.map(range, &init_common(&1, width, top_left_offset, step))
  end

  defp top_left_offset(width, height, {oR, oI}, step) do
    {oR - mid(width) * step, oI + mid(height) * step}
  end

  defp mid(x) do
    n = div(x, 2)

    case rem(x, 2) do
      0 -> n
      _ -> n + 1
    end
  end

  defp init_common(index, width, {imgR, imgI}, step) do
    row = div(index, width)
    col = rem(index, width)

    {index, {imgR + col * step, imgI - row * step}}
  end

  defp init_mandelbrot({index, c_xy}, iterations) do
    %Jam.Point{
      index: index,
      c: c_xy,
      max_iterations: iterations
    }
  end

  defp init_julia({index, z_xy}, c_xy, iterations) do
    %Jam.Point{
      index: index,
      initial_z: z_xy,
      c: c_xy,
      max_iterations: iterations
    }
  end
end
