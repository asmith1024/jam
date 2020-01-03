defmodule Jam.Simple do
  @moduledoc """
  Defines functions for simple (and slow), single-process image generation.
  """

  @doc """
  Generates the Mandelbrot set centred on centerX, centerY with width 
  and height pixels, i iterations and s step width, and writes it to filename.
  """
  def mandelbrot(centerX, centerY, width, height, i, s, filename) do
    spec = {width, height, {centerX, centerY}, s, i}
    pixels = Jam.mandelbrot(spec, &Jam.Color.simple2/1)
    BMPv3.write_bmp(filename, width, height, pixels)
  end

  @doc """
  Generates the Julia set centred on centerX, centerY representing the 
  Mandelbrot set point cX, cY with width and height pixels,
  i iterations and s step width, and writes it to filename.
  """
  def julia(centerX, centerY, cX, cY, width, height, i, s, filename) do
    spec = {width, height, {centerX, centerY}, {cX, cY}, s, i}
    pixels = Jam.julia(spec, &Jam.Color.simple2/1)
    BMPv3.write_bmp(filename, width, height, pixels)
  end
end
