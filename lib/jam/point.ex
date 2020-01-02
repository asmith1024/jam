defmodule Jam.Point do
  @moduledoc """
  Contains the state of a point on the Mandelbrot set or a Julia set.
  Set xy to the integral coordinates of the pixel corresponding to this point.
  Values for initial_z, c and max_iterations are required to calculate set membership.
  For the Mandelbrot set, initial_z is 0 and c is the point on the complex plane being examined.
  For the Julia set, initial_z is the point on the complex plane being examined and c is a point on the Mandelbrot set.
  The Mandelbrot set can be thought of as the map of all Julia sets.
  For both sets, z is the last-calculated value of the iteration function.
  If iterations < max_iterations the point being examined is not in the set.
  """
  defstruct index: 0,
            initial_z: {0.0, 0.0},
            c: {0.0, 0.0},
            max_iterations: 0,
            z: {0.0, 0.0},
            iterations: 0
end
