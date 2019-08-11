defmodule BMPv3 do
  @moduledoc """
  Windows v3 bitmap format renderer. This code forces 24-bit color, uncompressed, top-to-bottom pixel files.
  Uses the spec here: https://www.fileformat.info/format/bmp/egff.htm
  And some dicussion here: http://www.dragonwins.com/domains/getteched/bmp/bmpfileformat.htm 
  Idea from here: https://www.youtube.com/watch?v=9o5bDiCiJ90&feature=youtu.be
  """

  @doc """
  Writes a Windows v3 bitmap to filename. 
  The bitmap will be x_pixels wide and y_pixels high. 
  Provide sorted list of {index, 24-bit RGB} rgbs.
  """
  def write_bmp(filename, x_pixels, y_pixels, rgbs) do
    hdr_bytes = preamble(x_pixels, y_pixels)
    rgb_bytes = pixels(rgbs, x_pixels)
    bytes = hdr_bytes <> rgb_bytes
    File.write!(filename, bytes)
  end

  @doc """
  Returns a bitstring representing the file and image headers 
  of a bitmap with the supplied pixel dimensions. All the 
  faffing around is dealing with little-endian-ness.
  """
  def preamble(x_pixels, y_pixels) do
    size_r1_r2 = <<0::size(64)>>
    offset = <<54::size(8)>> <> <<0::size(24)>>
    size = <<40::size(8)>> <> <<0::size(24)>>
    width = reverse(<<x_pixels::size(32)>>)
    height = reverse(<<-1 * y_pixels::size(32)>>)
    planes = <<1::size(8)>> <> <<0::size(8)>>
    bits_pixel = <<24::size(8)>> <> <<0::size(8)>>
    trailer = <<0::size(192)>>

    "BM" <>
      size_r1_r2 <>
      offset <>
      size <>
      width <>
      height <>
      planes <>
      bits_pixel <>
      trailer
  end

  defp reverse(binary) do
    binary |> :binary.bin_to_list() |> Enum.reverse() |> :binary.list_to_bin()
  end

  @doc """
  Provide an unsorted list of { index, <<r, g, b>> } and image width in pixels.
  Returns pixel data with padded scan lines as a bitstring.
  """
  def consolidate_pixels(unsorted, width) do
    Enum.sort(unsorted, &sort_pixels(&1, &2))
    |> pixels(width)
  end

  @doc """
  Provide a sorted list of { index, <<r, g, b>> } and image width in pixels.
  Returns pixel data with padded scan lines as a bitstring.
  """
  def pixels(sorted, width) do
    padding = pad_bytes(width)

    sorted
    |> Enum.map(&map_scan_lines(&1, width, padding))
    |> Enum.join()
  end

  defp pad_bytes(width) do
    case rem(width * 3, 4) do
      0 ->
        ""

      n ->
        bits = (4 - n) * 8
        <<0::size(bits)>>
    end
  end

  defp map_scan_lines({index, rgb}, width, padding) when rem(index, width) == width - 1 do
    rgb <> padding
  end

  defp map_scan_lines({_, rgb}, _, _) do
    rgb
  end

  defp sort_pixels({iA, _}, {iB, _}) do
    iA < iB
  end
end
