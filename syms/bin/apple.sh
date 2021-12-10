pacmd unload-module module-loopback
pacmd load-module module-filter-heuristics
pacmd load-module module-filter-apply

pacmd load-module module-loopback source="alsa_input.usb-FongLun_AmazonBasics_Desktop_Mini_Mic_201802-00.multichannel-input" sink="broadcast_sink" latency_msec="1"
pacmd load-module module-loopback source="music_sink.monitor" sink="broadcast_sink" latency_msec="1"

pacmd load-module module-loopback source="voice_chat_sink.monitor" sink="alsa_output.usb-Apple_Inc._Apple_USB_audio_device-00.analog-stereo" latency_msec="1"
pacmd load-module module-loopback source="music_sink.monitor" sink="alsa_output.usb-Apple_Inc._Apple_USB_audio_device-00.analog-stereo" latency_msec="1"


#pactl set-default-sink "alsa_output.usb-Apple_Inc._Apple_USB_audio_device-00.analog-stereo" 
#pactl set-default-source "voice_chat_sink.monitor" 
