defmodule Jam.Simple do
  @moduledoc """
  Defines functions for simple (and slow), single-process image generation.
  """

  @doc """
  Generates the Mandelbrot set centred on xO, yO with width 
  and height pixels, i iterations and s step width, writing 
  it to filename.
  """
  def mandelbrot(xO, yO, width, height, i, s, filename) do
    spec = {width, height, {xO, yO}, s, i}
    pixels = Jam.mandelbrot(spec, &Jam.Color.simple2/1)
    BMPv3.write_bmp(filename, width, height, pixels)
  end

  @doc """
  Generates the Julia set centred on xO, yO representing the 
  Mandelbrot set point xC, yC with width and height pixels,
  i iterations and s step width writing it to filename.
  """
  def julia(xO, yO, xC, yC, width, height, i, s, filename) do
    spec = {width, height, {xO, yO}, {xC, yC}, s, i}
    pixels = Jam.julia(spec, &Jam.Color.simple2/1)
    BMPv3.write_bmp(filename, width, height, pixels)
  end
end
