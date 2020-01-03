defmodule Mix.Tasks.Circle do
  @moduledoc """
  Debug routines that create simple shapes.
  """

  use Mix.Task

  @doc """
  Provide width and height in pixels. 
  Provide radius and step in reals.
  Provide center of circle as a real-format pixel location x, y.

  Writes a red circle on a blue background to file circle.bmp to the current directory.

  ## Examples

  Full circle centered on the mid-point of the image:

  > mix circle 100 100 25.0 1.0 0.0 0.0

  Setting sun:

  > mix circle 100 100 50.0 1.0 0.0 50.0

  Top-left quadrant:

  > mix circle 100 100 50.0 1.0 -50.0 -50.0

  """
  def run([width, height, radius, step, x, y]) do
    cspec = {
      String.to_float(x),
      String.to_float(y),
      String.to_float(radius) * String.to_float(radius)
    }

    rgbs =
      plane(
        String.to_integer(width),
        String.to_integer(height),
        String.to_float(step)
      )
      |> Enum.map(&shape_member(&1, cspec))
      |> Enum.map(&Jam.Color.circle1(&1))

    BMPv3.write_bmp(
      "circle.bmp",
      String.to_integer(width),
      String.to_integer(height),
      rgbs
    )
  end

  defp plane(width, height, step) do
    range = 0..(width * height - 1)
    mid_row = mid(height)
    mid_col = mid(width)
    Stream.map(range, &init(&1, width, mid_row, mid_col, step))
  end

  defp shape_member({index, {x, y}}, {xC, yC, radius_sq}) do
    dx = xC - x
    dy = yC - y
    {index, dx * dx + dy * dy <= radius_sq}
  end

  defp mid(x) do
    n = div(x, 2)

    case rem(x, 2) do
      0 -> n
      _ -> n + 1
    end
  end

  defp init(index, width, mid_row, mid_col, step) do
    row = div(index, width)
    col = rem(index, width)

    {
      index,
      {
        (col - mid_col) * step,
        (row - mid_row) * step
      }
    }
  end
end
