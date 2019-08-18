defmodule Jam.Color do
  use Bitwise

  @moduledoc """
  Provides methods for converting a Jam.Point struct to a 24-bit RGB color. 
  """

  @doc """
  Points in the set are black. Points outside are mod 3 for color, mod 127 for intensity.
  """
  def simple1(%Jam.Point{index: index, max_iterations: max, iterations: i}) when i == max do
    {index, <<0::size(24)>>}
  end

  def simple1(%Jam.Point{index: index, iterations: i}) do
    intensity = rem(i, 127) + 128
    rgb = intensity <<< (16 - rem(i, 3) * 8)
    {index, <<rgb::size(24)>>}
  end

  @doc """
  Points in the set are shades of grey based on quantized final Z.
  Points outside the set are iterations mod 191 for red intensity 
  with blue and green intensity determined by the fractional component
  of final Z.
  """
  def simple2(%Jam.Point{index: index, max_iterations: max, iterations: i, z: final_z})
      when i == max do
    quant =
      Jam.Complex.square_modulus(final_z)
      |> pipe_mult(64.0)
      |> Kernel.trunc()

    red = rem(quant, 210) + 45
    green = red <<< 8
    blue = red <<< 16
    {index, <<red + green + blue::size(24)>>}
  end

  def simple2(%Jam.Point{index: index, iterations: i, z: final_z}) do
    red = rem(i, 191) + 64

    quant =
      Jam.Complex.square_modulus(final_z)
      |> pipe_sub(4.0)
      |> pipe_mult(1_000.0)
      |> Kernel.trunc()

    intensity = rem(quant, 255)

    gb =
      if quant - 499 > 0 do
        intensity <<< 16
      else
        intensity <<< 8
      end

    {index, <<red + gb::size(24)>>}
  end

  defp pipe_mult(op_a, op_b) do
    op_a * op_b
  end

  defp pipe_sub(sub_from, sub) do
    sub_from - sub
  end

  @doc """
  Colors a circle. Red if you're in it, blue if not.
  """
  def circle1({index, in?}) do
    shift =
      case in? do
        true -> 0
        _ -> 16
      end

    rgb = 255 <<< shift
    {index, <<rgb::size(24)>>}
  end
end
