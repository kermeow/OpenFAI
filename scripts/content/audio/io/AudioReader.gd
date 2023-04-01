extends Object
class_name AudioReader

enum Format {
	Unknown,
	MP3,
	OGG,
	WAV
}

static func read_from_file(path:String) -> AudioStream:
	var file = FileAccess.open(path, FileAccess.READ)
	var buffer = file.get_buffer(file.get_length())
	file.close()
	var format = get_audio_format(buffer)
	var stream:AudioStream
	match format:
		Format.MP3:
			stream = AudioStreamMP3.new()
			stream.data = buffer
		Format.Unknown, Format.WAV:
			stream = AudioStreamWAV.new()
			stream.data = buffer
		Format.OGG:
			stream = AudioStreamOggVorbis.new()
			stream.packet_sequence = parse_ogg_buffer(buffer)
	return stream

static func get_audio_format(buffer:PackedByteArray):
	if buffer.slice(0,4) == PackedByteArray([0x4F,0x67,0x67,0x53]): return Format.OGG

	if (buffer.slice(0,4) == PackedByteArray([0x52,0x49,0x46,0x46])
	and buffer.slice(8,12) == PackedByteArray([0x57,0x41,0x56,0x45])): return Format.WAV
	
	if (buffer.slice(0,2) == PackedByteArray([0xFF,0xFB])
	or buffer.slice(0,2) == PackedByteArray([0xFF,0xF3])
	or buffer.slice(0,2) == PackedByteArray([0xFF,0xFA])
	or buffer.slice(0,2) == PackedByteArray([0xFF,0xF2])
	or buffer.slice(0,3) == PackedByteArray([0x49,0x44,0x33])): return Format.MP3
	
	return Format.Unknown

static func parse_ogg_buffer(data:PackedByteArray) -> OggPacketSequence:
	var packets = []
	var granule_positions = []
	var sampling_rate = 0
	var pos = 0
	while pos < data.size():
		# Parse the Ogg packet header
		var header = data.slice(pos, pos + 27)
		pos += 27
		# Check the capture pattern
		if header.slice(0, 4) != "OggS".to_ascii_buffer():
			break
		# Get the packet type
		var packet_type = header.decode_u8(5)
		# Get the granule position
		var granule_position = header.decode_u64(6)
		granule_positions.append(granule_position)
		# Get the segment table
		var segment_table_length = header.decode_u8(26)
		var segment_table = data.slice(pos, pos + segment_table_length)
		pos += segment_table_length
		# Get the packet data
		var packet_data = []
		var appending = false
		for i in range(segment_table_length):
			var segment_size = segment_table.decode_u8(i)
			var segment = data.slice(pos, pos + segment_size)
			if appending: packet_data.back().append_array(segment)
			else: packet_data.append(segment)
			appending = segment_size == 255
			pos += segment_size
		# Add the packet data to the array
		packets.append(packet_data)
		if sampling_rate == 0 and packet_type == 2:
			var info_header = packet_data[0]
			if info_header.slice(1, 7).get_string_from_ascii() != "vorbis":
				break
			sampling_rate = info_header.decode_u32(12)
	var packet_sequence = OggPacketSequence.new()
	packet_sequence.sampling_rate = sampling_rate
	packet_sequence.granule_positions = granule_positions
	packet_sequence.packet_data = packets
	return packet_sequence
