# SPDX-License-Identifier: GPL-3.0-or-later AND Apache-2.0
# SPDX-FileCopyrightText: 2026 SNAPKITTYWEST

defmodule Swarm.DylanCodec do
  @moduledoc """
  Dylan binary frame codec.

  Frame layout (matches the Swift reference implementation):

      magic(4) + agent_id(16) + op(1) + flags(1) + seq(2 BE) + len(2 BE) + payload(len) + crc32(4 BE)

  - Magic: "DYLA" (0x44594C41)
  - Header size: 26 bytes (4+16+1+1+2+2)
  - CRC32 IEEE (polynomial 0xEDB88320) computed over header + payload
  - CRC appended as uint32 big-endian
  """

  @magic <<0x44, 0x59, 0x4C, 0x41>>
  @header_size 26

  @doc """
  Encode a Dylan frame.

  - `agent_id` - 16-byte binary
  - `op`       - unsigned 8-bit integer
  - `flags`    - unsigned 8-bit integer
  - `seq`      - unsigned 16-bit integer
  - `payload`  - binary payload
  """
  @spec encode(binary(), non_neg_integer(), non_neg_integer(), non_neg_integer(), binary()) ::
          binary()
  def encode(agent_id, op, flags, seq, payload)
      when is_binary(agent_id) and byte_size(agent_id) == 16 and
             is_integer(op) and op >= 0 and op <= 255 and
             is_integer(flags) and flags >= 0 and flags <= 255 and
             is_integer(seq) and seq >= 0 and seq <= 0xFFFF and
             is_binary(payload) do
    len = byte_size(payload)

    header =
      <<@magic::binary, agent_id::binary-size(16), op::unsigned-8, flags::unsigned-8,
        seq::unsigned-big-16, len::unsigned-big-16>>

    data = <<header::binary, payload::binary>>
    crc = :erlang.crc32(data)

    <<data::binary, crc::unsigned-big-32>>
  end

  @doc """
  Decode a Dylan frame binary.

  Returns `{:ok, map}` on success or `{:error, reason}` on failure.
  The map contains `:agent_id`, `:op`, `:flags`, `:seq`, and `:payload`.
  """
  @spec decode(binary()) :: {:ok, map()} | {:error, atom()}
  def decode(<<@magic::binary, rest::binary>> = frame) when byte_size(frame) >= @header_size + 4 do
    <<agent_id::binary-size(16), op::unsigned-8, flags::unsigned-8, seq::unsigned-big-16,
      len::unsigned-big-16, tail::binary>> = rest

    expected_tail_size = len + 4

    if byte_size(tail) == expected_tail_size do
      <<payload::binary-size(len), crc_received::unsigned-big-32>> = tail

      data_size = @header_size + len
      <<data::binary-size(data_size), _::binary>> = frame
      crc_computed = :erlang.crc32(data)

      if crc_computed == crc_received do
        {:ok,
         %{
           agent_id: agent_id,
           op: op,
           flags: flags,
           seq: seq,
           payload: payload
         }}
      else
        {:error, :crc_mismatch}
      end
    else
      {:error, :invalid_length}
    end
  end

  def decode(<<@magic::binary, _::binary>>) do
    {:error, :frame_too_short}
  end

  def decode(_) do
    {:error, :invalid_magic}
  end
end
