defmodule ExMagicZigTest do
  use ExUnit.Case
  # doctest ExMagicZig

  # Create shared resource once for the entire module
  setup_all do
    {:ok, shared_ref} = ExMagicZig.new()
    %{shared_ref: shared_ref}
  end

  test "returns ref" do
    {:ok, ref} = ExMagicZig.new()
    assert is_reference(ref)
  end

  test "from_path/2 with invalid resource" do
    assert {:error, "Invalid resource passed"} = ExMagicZig.from_path(nil, "")
  end

  test "from_buffer/2 with invalid resource" do
    assert {:error, "Invalid resource passed"} = ExMagicZig.from_buffer(nil, "")
  end

  # ----- Tests that reuse the same shared resource --------

  test "from_path/2 with valid resource but invalid path", %{shared_ref: ref} do
    assert {:error, "file_not_found"} =
             ExMagicZig.from_path(ref, "/path/that/does/not/exist")
  end

  test "from_buffer/2 with valid resource with empty buffer", %{shared_ref: ref} do
    assert {:ok, "application/x-empty"} = ExMagicZig.from_buffer(ref, <<>>)
  end

  test "from_buffer/2 with valid resource with PNG buffer", %{shared_ref: ref} do
    # Just the 8-byte PNG signature - libmagic needs more context to identify as PNG
    png_signature = <<137, 80, 78, 71, 13, 10, 26, 10>>
    assert {:ok, "application/octet-stream"} = ExMagicZig.from_buffer(ref, png_signature)

    # PNG signature + IHDR chunk header - now libmagic can identify it as PNG
    # Bytes: 89 50 4E 47 0D 0A 1A 0A (PNG signature) + 00 00 00 0D 49 48 44 52 (IHDR chunk)
    png_with_ihdr = <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82>>
    assert {:ok, "image/png"} = ExMagicZig.from_buffer(ref, png_with_ihdr)
  end

  test "from_buffer/2 with valid resource with JPEG buffer", %{shared_ref: ref} do
    jpeg_signature = <<255, 216, 255, 224>>

    assert {:ok, "image/jpeg"} = ExMagicZig.from_buffer(ref, jpeg_signature)
  end

  test "from_buffer/2 with valid resource with real PNG", %{shared_ref: ref} do
    png_data = File.read!("test/fixtures/icon.png")

    assert {:ok, "image/png"} = ExMagicZig.from_buffer(ref, png_data)
  end

  test "from_path/2 with valid resource with invalid path", %{shared_ref: ref} do
    assert {:error, "file_not_found"} = ExMagicZig.from_path(ref, "test/fixtures/ico.png")
  end
end
