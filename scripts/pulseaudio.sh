#!/bin/bash
# https://github.com/toadjaune/pulseaudio-config

JOIN_EVERYTHING_WITH_PIPE="tr '\n' '|'"
ADD_NEWLINE_FOR_EACH_DEVICE="sed -e 's/*\{0,1\}[[:space:]]*index/\n\0/g'"
UNJOIN_BY_PIPE="sed 's/|/\n/g'"
GREP_DEFAULT="grep '* index'"
GET_NAME="grep 'name:' | awk -F '<|>' '{print \$2}'"
GET_DEFAULT="$JOIN_EVERYTHING_WITH_PIPE | $ADD_NEWLINE_FOR_EACH_DEVICE | $GREP_DEFAULT | $UNJOIN_BY_PIPE | $GET_NAME"

DEFAULT_INPUT_CMD="pacmd list-sources | $GET_DEFAULT"
DEFAULT_OUTPUT_CMD="pacmd list-sinks | $GET_DEFAULT"

LATENCY_MSEC=5

DEFAULT_MICROPHONE=$(eval "$DEFAULT_INPUT_CMD")
DEFAULT_SPEAKERS=$(eval "$DEFAULT_OUTPUT_CMD")

SCRIPT_ID="audio_sharing_script"

echo "Default input:  $DEFAULT_MICROPHONE"
echo "Default output: $DEFAULT_SPEAKERS"

if [ "$1" == "--info" ] || [ "$1" == "-i" ]; then
    exit 0
else
    echo ""
fi


SHARED_SINK_NAME="SHARED_$SCRIPT_ID"  # for both speakers and microphone
MIC_SINK_NAME="MIC_ONLY_$SCRIPT_ID"   # mic device and SHARED_SINK will be redirected to this sink
                                      # you can also play audio into this sink without hearing it

SHARED_SINK_EXISTS="$(pactl list sinks short | grep $SHARED_SINK_NAME)"
MIC_SINK_EXISTS="$(pactl list sinks short | grep $MIC_SINK_NAME)"


if [ "$1" == "--teardown" ] || [ "$1" == "-t" ]; then
    echo "Unloading modules"
    pactl list modules short | awk "/$SCRIPT_ID/"'{print $1}' | tac | xargs -t -I{} pactl unload-module {}
    exit 0
fi

if [ "$SHARED_SINK_EXISTS" ] || [ "$MIC_SINK_EXISTS" ]; then
    echo "Script modules seem to exist. Did you want to unload them and forgot --teardown flag?"
    exit 1
fi

if [ ! "$SHARED_SINK_EXISTS" ] && [ ! "$MIC_SINK_EXISTS" ]; then
    echo "Creating virtual sinks"
    pactl load-module module-null-sink sink_name=$SHARED_SINK_NAME sink_properties=device.description="$SHARED_SINK_NAME"
    pactl load-module module-null-sink sink_name=$MIC_SINK_NAME sink_properties=device.description="$MIC_SINK_NAME"

    # splitting audio from shared sink to speakers and mic (mic sink)
    pactl load-module module-loopback source=$SHARED_SINK_NAME.monitor sink=$DEFAULT_SPEAKERS latency_msec=$LATENCY_MSEC
    pactl load-module module-loopback source=$SHARED_SINK_NAME.monitor sink=$MIC_SINK_NAME latency_msec=$LATENCY_MSEC
    # redirect mic to mic sink (which will be set as default)
    pactl load-module module-loopback source=$DEFAULT_MICROPHONE sink=$MIC_SINK_NAME latency_msec=$LATENCY_MSEC
fi

# Applications like Discord will probably not be able to set monitor device as input.
# We workaround it by setting virtual2.monitor as default input which makes it default in the app.
pacmd set-default-source $MIC_SINK_NAME.monitor
