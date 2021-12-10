#!/bin/sh

pacmd load-module module-null-sink sink_name=voice_chat_sink sink_properties=device.description=Voice-Sink
pacmd load-module module-null-sink sink_name=music_sink sink_properties=device.description=Music-Sink channels=2 rate=192000
pacmd load-module module-null-sink sink_name=broadcast_sink sink_properties=device.description=Broadcast-Sink channels=2 rate=192000


