defmodule Jam.Complex do
  @moduledoc """
  Methods for working with complex numbers.
  """

  @doc """
  Returns the square of the point {r, i}
  """
  def square({r, i}) do
    {r * r - i * i, 2 * r * i}
  end

  @doc """
  Returns the square of the distance from the origin to the point {r, i}
  """
  def square_modulus({r, i}) do
    r * r + i * i
  end

  @doc """
  Returns the vector sum of the points {aR, aI}, {bR, bI}
  """
  def add({aR, aI}, {bR, bI}) do
    {aR + bR, aI + bI}
  end
end
