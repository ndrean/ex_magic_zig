defmodule ExMagicZig do
  @moduledoc """
  Use `libmagic` in `Eixir` to identify file types and formats by analyzing file content and structure rather than relying on file extensions.
  It uses the default libmagic "mime" database and it returns MIME types.
  """

  use Zig,
    otp_app: :ex_magic_zig,
    c: [link_lib: [system: "magic"]],
    resources: [:MagicResource]

  ~Z"""
  const beam = @import("beam");
  const root = @import("root");

  const std = @import("std");
  const m = @cImport(@cInclude("magic.h"));

  const MagicCookie = struct {
      cookie: m.magic_t,
  };

  pub const MagicResource = beam.Resource(*MagicCookie, root, .{.Callbacks = MagicCallbacks},);

  pub const MagicCallbacks = struct {
      pub fn dtor(handle: **MagicCookie) void {
          m.magic_close(handle.*.cookie);
          beam.allocator.destroy(handle.*);
      }
  };



  /// NIF: Create a new `libmagic` resource.
  /// Sets up the `libmagic` cookie with `MAGIC_MIME_TYPE` flag as returned resource.
  pub fn new() !beam.term {
      const handle = beam.allocator.create(MagicCookie) catch |err| {
          return beam.make_error_pair(err, .{});
      };
      errdefer beam.allocator.destroy(handle);

      handle.cookie = m.magic_open(m.MAGIC_MIME_TYPE) orelse {
          return beam.make_error_pair(error.MagicOpenFailed, .{});
      };
      errdefer m.magic_close(handle.cookie);

      if (m.magic_load(handle.cookie, null) != 0) {
        return beam.make_error_pair(error.MagicLoadFailed, .{});
      }

      const resource = MagicResource.create(handle, .{}) catch |err| {
          return beam.make_error_pair(err, .{});
      };
      return beam.make(.{.ok, resource}, .{});
  }



  /// NIF: Get the MIME type of a file at `path`.
  ///
  /// `resource` is a reference created by `new/0`.
  ///
  /// Returns `{:ok, mime_type}` or `{:error, reason}`.
  pub fn z_from_path(resource: MagicResource, path: []const u8) !beam.term {
    std.fs.cwd().access(path, .{}) catch {
        return beam.make_error_pair("file_not_found", .{});
    };

    const cookie = resource.unpack().*.cookie;
    const path_z = beam.allocator.dupeZ(u8, path) catch |err| {
      return beam.make_error_pair(err, .{});
    };
    defer beam.allocator.free(path_z);

    const res = m.magic_file(cookie, path_z.ptr);

    if (m.magic_errno(cookie) != 0) {
      const err_str = if (m.magic_error(cookie)) |msg| std.mem.span(msg) else "unknown error";
      return beam.make_error_pair(err_str, .{});
    }

    return beam.make(.{.ok, std.mem.span(res)}, .{});
  }


  /// NIF: Get the MIME type of a binary buffer.
  ///
  /// `resource` is a reference created by `new/0`.
  ///
  /// Returns `{:ok, mime_type}` or `{:error, reason}`.
  pub fn z_from_buffer(resource: MagicResource, buffer: []const u8) !beam.term {
      const cookie = resource.unpack().*.cookie;
      const res = m.magic_buffer(cookie, buffer.ptr, buffer.len) orelse {
        return beam.make_error_pair(error.MagicBufferFailed, .{});
      };
      return beam.make(.{.ok, std.mem.span(res)}, .{});
  }

  """

  @doc """
  Checks if `libmagic` is installed and creates a new `libmagic` resource.

  Use the returned reference in calls to `from_path/2` and `from_buffer/2`.
  """
  @spec up() :: {:ok, reference()} | {:error, String.t()}
  def up do
    case System.cmd("pkg-config", ["--exists", "libmagic"]) do
      {_, 0} -> new()
      {_, _} -> {:error, "libmagic not found. Please install libmagic development files."}
    end
  end

  @doc """
  Get the MIME type of a file at `path`.

  `resource` is a reference created by `new/0`.
  """
  @spec from_path(reference(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def from_path(resource, path) do
    if !is_reference(resource) do
      {:error, "Invalid resource passed"}
    else
      z_from_path(resource, path)
    end
  end

  @doc """
  Get the MIME type of a binary buffer.

  `resource` is a reference created by `new/0`.
  """
  @spec from_buffer(reference(), binary()) :: {:ok, String.t()} | {:error, String.t()}
  def from_buffer(resource, path) do
    if !is_reference(resource) do
      {:error, "Invalid resource passed"}
    else
      z_from_buffer(resource, path)
    end
  end
end
