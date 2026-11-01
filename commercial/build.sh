#!/usr/bin/env bash
# Assemble the 30 s DOPE Affiliate Program commercial from the generated clips,
# voiceover lines, music bed and the official DOPE wordmark.
#
# Run from the repository root:
#   CLIPS=path/to/clips ./commercial/build.sh
# The clips directory must contain s1.mp4 s2.mp4 s3a.mp4 s3b.mp4 s4.mp4
# (the Seedance outputs listed in commercial/README.md).
# Set FF="imd-media ffmpeg" where ffmpeg must be called through a wrapper.
set -euo pipefail

FF=${FF:-ffmpeg}
CLIPS=${CLIPS:-commercial/clips}
A=commercial/assets
W=${WORK:-commercial/build}
OUT=${OUT:-artifacts/video.mp4}
mkdir -p "$W" "$(dirname "$OUT")"

LIME=0xC6FF3D
BOLD=$A/fonts/LiberationSans-Bold.ttf
REG=$A/fonts/LiberationSans-Regular.ttf
ENC="-c:v libx264 -preset medium -crf 14 -pix_fmt yuv420p -r 24 -an"
BASE="crop=1920:1080:0:4,setsar=1,fps=24"
GRADE="eq=contrast=1.06:saturation=1.06:gamma=0.98,vignette=angle=PI/5"
# Logo with a lime glow: white wordmark over a blurred lime copy of itself.
# $1 = width in px. Produces a labelled stream [lg].
logo_chain() {
  local g=${2:-1.6}
  echo "[1:v]scale=$1:-1,format=rgba,split[lw][lc];[lc]colorchannelmixer=rr=0.78:gg=1:bb=0.24,pad=iw+240:ih+240:120:120:color=black@0,gblur=sigma=28,colorchannelmixer=aa=$g[gl];[gl][lw]overlay=120:120,format=rgba[lg]"
}

# --- Scene 1 (0-5 s): creator, feed glitches into the portal ----------------
$FF -v error -y -i "$CLIPS/s1.mp4" -vf "trim=0:5,setpts=PTS-STARTPTS,$BASE,$GRADE,fade=t=in:st=0:d=0.4,fade=t=out:st=4.85:d=0.15:color=$LIME" $ENC "$W/seg1.mp4"

# --- Scene 2 (5-12 s): through the portal, DOPE logo reveal ----------------
$FF -v error -y -i "$CLIPS/s2.mp4" -loop 1 -t 7 -i "$A/dope-wordmark-white.png" -filter_complex "\
[0:v]trim=0:7,setpts=PTS-STARTPTS,$BASE,$GRADE,fade=t=in:st=0:d=0.3:color=$LIME[bg];\
$(logo_chain 620 0.9);[lg]fade=t=in:st=1.1:d=0.7:alpha=1[lf];\
[bg][lf]overlay=x=(W-w)/2:y=(H-h)/2-50-6*t:shortest=1,fade=t=out:st=6.9:d=0.1" $ENC "$W/seg2.mp4"

# --- Scene 3 (12-21 s): share link -> network -> trophy --------------------
$FF -v error -y -i "$CLIPS/s3a.mp4" -i "$CLIPS/s3b.mp4" -filter_complex "\
[0:v]trim=0:3.4,setpts=PTS-STARTPTS,$BASE,fade=t=in:st=0:d=0.15,fade=t=out:st=3.28:d=0.12:color=$LIME[a];\
[1:v]trim=3.2:8.8,setpts=PTS-STARTPTS,$BASE,fade=t=in:st=0:d=0.2:color=$LIME,fade=t=out:st=5.5:d=0.1:color=$LIME[b];\
[a][b]concat=n=2:v=1:a=0,$GRADE" $ENC "$W/seg3.mp4"

# --- Scene 4 (21-27 s): trophy rises, lime burst, logo above ----------------
# The generated shot is framed tight, so it is scaled to 82 % and set low in
# the frame over a blurred extension of itself, leaving headroom for the logo.
$FF -v error -y -f lavfi -i "color=black:s=1574x886:d=1,format=gray,geq=lum='255*min(1\,min(min(X/140\,(W-X)/140)\,Y/170))'" -frames:v 1 "$W/mask4.png"
$FF -v error -y -i "$CLIPS/s4.mp4" -loop 1 -t 6 -i "$A/dope-wordmark-white.png" -loop 1 -t 6 -i "$W/mask4.png" -filter_complex "\
[0:v]trim=0:6,setpts=PTS-STARTPTS,$BASE,split[c1][c2];\
[c1]scale=480:270,gblur=sigma=18,scale=1920:1080,eq=brightness=-0.04[ext];\
[c2]scale=1574:886,format=rgba[sm];[2:v]format=gray,scale=1574:886[mk];[sm][mk]alphamerge[smf];\
[ext][smf]overlay=x=173:y=194:shortest=1,$GRADE,fade=t=in:st=0:d=0.2:color=$LIME[bg];\
$(logo_chain 440);[lg]fade=t=in:st=2.2:d=0.8:alpha=1[lf];\
[bg][lf]overlay=x=(W-w)/2:y=-40:shortest=1,fade=t=out:st=5.6:d=0.4" $ENC "$W/seg4.mp4"

# --- Scene 5 (27-30 s): end card -------------------------------------------
$FF -v error -y -i "$CLIPS/s4.mp4" -loop 1 -t 3 -i "$A/dope-wordmark-white.png" -filter_complex "\
[0:v]trim=3:6,setpts=PTS-STARTPTS,$BASE,scale=480:270,gblur=sigma=12,scale=1920:1080,eq=brightness=-0.16:saturation=0.8,\
drawbox=x=0:y=0:w=iw:h=ih:color=0x050a18@0.55:t=fill,vignette=angle=PI/3.5[bg];\
$(logo_chain 560);[lg]fade=t=in:st=0.1:d=0.5:alpha=1[lf];\
[bg][lf]overlay=x=(W-w)/2:y=230:shortest=1,\
drawbox=x=860:y=590:w=200:h=3:color=$LIME@0.9:t=fill:enable='gte(t,0.45)',\
drawtext=fontfile=$BOLD:text='DOPE Affiliate Program':fontsize=74:fontcolor=white:x=(w-text_w)/2:y=630:alpha='min(1,max(0,(t-0.5)/0.4))',\
drawtext=fontfile=$REG:text='Your next move starts here.':fontsize=44:fontcolor=$LIME:x=(w-text_w)/2:y=735:alpha='min(1,max(0,(t-0.8)/0.4))',\
drawtext=fontfile=$BOLD:text='dope.xyz':fontsize=36:fontcolor=white@0.85:x=(w-text_w)/2:y=860:alpha='min(1,max(0,(t-1.1)/0.4))',\
fade=t=in:st=0:d=0.3,fade=t=out:st=2.75:d=0.25" $ENC "$W/seg5.mp4"

# --- Picture lock -----------------------------------------------------------
$FF -v error -y -i "$W/seg1.mp4" -i "$W/seg2.mp4" -i "$W/seg3.mp4" -i "$W/seg4.mp4" -i "$W/seg5.mp4" \
 -filter_complex "[0:v][1:v][2:v][3:v][4:v]concat=n=5:v=1:a=0,noise=alls=3:allf=t" $ENC "$W/picture.mp4"

# --- Sound design (synthesised) ---------------------------------------------
# glitch 0.9 s, whoosh into portal 4.2 s, impact 5.0 s, logo shimmer 6.0 s,
# share whoosh 14.9 s, impact 21.0 s, shimmer 23.3 s, end-card hit 27.0 s.
$FF -v error -y \
 -f lavfi -i "anoisesrc=c=white:a=0.5:d=0.8:r=48000" \
 -f lavfi -i "anoisesrc=c=pink:a=0.6:d=1.2:r=48000" \
 -f lavfi -i "sine=f=46:d=1.6:r=48000" \
 -f lavfi -i "sine=f=2637:d=1.4:r=48000" \
 -f lavfi -i "sine=f=3951:d=1.4:r=48000" \
 -filter_complex "\
[0]tremolo=f=22:d=1,highpass=f=1200,lowpass=f=9000,afade=t=in:d=0.05,afade=t=out:st=0.6:d=0.2,volume=0.35,aformat=channel_layouts=stereo,asplit=1[g];\
[1]highpass=f=250,lowpass=f=5000,afade=t=in:d=0.9,afade=t=out:st=0.9:d=0.3,volume=0.55,aformat=channel_layouts=stereo,asplit=2[w1][w2];\
[2]volume=1.4,afade=t=out:st=0.05:d=1.5,aformat=channel_layouts=stereo,asplit=3[i1][i2][i3];\
[3][4]amix=inputs=2,tremolo=f=9:d=0.5,afade=t=in:d=0.08,afade=t=out:st=0.2:d=1.2,volume=0.12,aformat=channel_layouts=stereo,asplit=2[s1][s2];\
[g]adelay=900|900[a1];[w1]adelay=3900|3900[a2];[i1]adelay=4950|4950[a3];[s1]adelay=6000|6000[a4];\
[w2]adelay=14300|14300[a5];[i2]adelay=21000|21000[a6];[s2]adelay=23300|23300[a7];[i3]adelay=27000|27000[a8];\
[a1][a2][a3][a4][a5][a6][a7][a8]amix=inputs=8:normalize=0,apad=whole_dur=30,atrim=0:30" \
 -c:a pcm_s16le "$W/sfx.wav"

# --- Voiceover: five lines placed on the scene timings ----------------------
$FF -v error -y -i "$A/vo1.mp3" -i "$A/vo2.mp3" -i "$A/vo3.mp3" -i "$A/vo4.mp3" -i "$A/vo5.mp3" -filter_complex "\
[0]aresample=48000,aformat=channel_layouts=stereo,adelay=400|400[v1];\
[1]aresample=48000,aformat=channel_layouts=stereo,adelay=6000|6000[v2];\
[2]aresample=48000,aformat=channel_layouts=stereo,adelay=12600|12600[v3];\
[3]aresample=48000,aformat=channel_layouts=stereo,adelay=21400|21400[v4];\
[4]aresample=48000,atempo=1.12,aformat=channel_layouts=stereo,adelay=26150|26150[v5];\
[v1][v2][v3][v4][v5]amix=inputs=5:normalize=0,apad=whole_dur=30,atrim=0:30,\
highpass=f=80,acompressor=threshold=0.125:ratio=3:attack=5:release=120,equalizer=f=3500:t=q:w=1:g=2" \
 -c:a pcm_s16le "$W/vo.wav"

# --- Mix: music ducked under VO, plus SFX, normalised -----------------------
$FF -v error -y -i "$A/music.wav" -i "$W/vo.wav" -i "$W/sfx.wav" -filter_complex "\
[0]aresample=48000,aformat=channel_layouts=stereo,atrim=0:30,afade=t=in:d=0.3,afade=t=out:st=28.6:d=1.4,volume=0.55[m];\
[1]asplit=2[vo][key];\
[m][key]sidechaincompress=threshold=0.02:ratio=8:attack=15:release=400[md];\
[md][vo][2]amix=inputs=3:normalize=0:weights='1 1.4 0.8',alimiter=limit=0.95,loudnorm=I=-15:TP=-1.5:LRA=9,aresample=48000" \
 -c:a pcm_s16le "$W/mix.wav"

# --- Final encode: H.264 + AAC, faststart ------------------------------------
$FF -v error -y -i "$W/picture.mp4" -i "$W/mix.wav" -map 0:v -map 1:a \
 -c:v libx264 -preset slow -crf 18 -maxrate 12M -bufsize 24M -pix_fmt yuv420p -profile:v high -level 4.1 \
 -c:a aac -b:a 192k -ar 48000 -t 30 -movflags +faststart "$OUT"
echo "wrote $OUT"
