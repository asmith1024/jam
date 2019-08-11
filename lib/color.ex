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
