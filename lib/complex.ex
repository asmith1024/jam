defmodule Jam.Complex do
  def square({r, i}) do
    {r * r - i * i, 2 * r * i}
  end

  def square_modulus({r, i}) do
    r * r + i * i
  end

  def add({rA, iA}, {rB, iB}) do
    {rA + rB, iA + iB}
  end
end
