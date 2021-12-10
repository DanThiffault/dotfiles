pacmd unload-module module-loopback
pacmd unload-module module-filter-apply
pacmd unload-module module-filter-heuristics

pacmd load-module module-loopback source="alsa_input.usb-FongLun_AmazonBasics_Desktop_Mini_Mic_201802-00.multichannel-input" sink="broadcast_sink" latency_msec="1"
#pacmd load-module module-loopback source="music_sink.monitor" sink="broadcast_sink" latency_msec="1"

pacmd load-module module-loopback source="voice_chat_sink.monitor" sink="bluez_sink.28_11_A5_76_8D_2C.a2dp_sink" latency_msec="1"
pacmd load-module module-loopback source="music_sink.monitor" sink="bluez_sink.28_11_A5_76_8D_2C.a2dp_sink" latency_msec="1"



