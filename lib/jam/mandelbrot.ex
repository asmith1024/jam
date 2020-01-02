defmodule Jam.Mandelbrot do
  @moduledoc """
  Calculates the state of a Jam.Point
  """

  @doc """
  Provide Jam.Point p with initial_z, c and max_iterations.
  Returns p with z and iterations set.
  """
  def point(%Jam.Point{} = p) do
    case iterate(p.initial_z, p.c, p.max_iterations) do
      {z, 0} -> %{p | z: z, iterations: p.max_iterations}
      {z, n} -> %{p | z: z, iterations: p.max_iterations - n}
    end
  end

  defp iterate(z, _, iterations_left) when iterations_left < 1 do
    {z, 0}
  end

  defp iterate(z, c, iterations_left) do
    case escape?(z) do
      true -> {z, iterations_left + 1}
      _ -> iterate(nextZ(z, c), c, iterations_left - 1)
    end
  end

  defp nextZ(z, c) do
    z
    |> Jam.Complex.square()
    |> Jam.Complex.add(c)
  end

  defp escape?(z) do
    Jam.Complex.square_modulus(z) > 4.0
  end
end
