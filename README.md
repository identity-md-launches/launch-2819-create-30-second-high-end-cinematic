# DOPE Affiliate Program: "The Next Move Is Yours" (30 s commercial)

**Output:** `artifacts/video.mp4` (delivered separately, not tracked in Git).

| Property | Value |
|---|---|
| Duration | 30.000 s |
| Dimensions | 1920 × 1080 (16:9), 24 fps, progressive |
| Video | H.264 High profile, yuv420p, about 11.4 Mb/s |
| Audio | AAC-LC, 48 kHz stereo, about 200 kb/s; −15.2 LUFS integrated, −1.2 dBFS peak |
| Container | MP4 with `+faststart` (moov atom at the front), so it plays in browsers |
| File size | 43.7 MB |

## Edit / timeline

| Time | Scene | Picture | Voiceover |
|---|---|---|---|
| 0–5 s | The opportunity | Creator at a curved monitor scrolling a grid of look-alike promo thumbnails. The screen glitches (RGB tearing) and becomes a lime-green vortex portal. Ends on a lime flash. | "The internet is full of noise. What if you could turn your influence into something more?" |
| 5–12 s | The reveal | Camera flies through a lime portal into a chrome-and-crystal digital world. The official DOPE wordmark fades in with a lime glow over the bright centre. | "Meet DOPE. An opportunity to be part of something bigger." |
| 12–21 s | The affiliate experience | Close-up: a hand taps share on a phone and a lime beam fires out. Cut on a lime flash to a creator holding a phone while lime connections reach the people around them and climb into a giant chrome trophy that lights up. | "Share DOPE. Bring your people. Grow together." |
| 21–27 s | The payoff | A chrome trophy rises from a black mirror floor as the camera orbits. Lime energy bursts across the floor and haze. The DOPE wordmark appears above the trophy. | "Your influence. Your network. Your next move." |
| 27–30 s | End card | DOPE wordmark; lime rule; **DOPE Affiliate Program**; *Your next move starts here.*; dope.xyz | "Explore the DOPE Affiliate Program at dope.xyz." |

The ad states no commission rates, earnings or program terms. On-screen text is limited to the three end-card lines and the wordmark.

## How it was made

- **Picture:** five clips from ByteDance `seedance-1-pro-fast` on Replicate, at 1080p, text-to-video. Prompts and prediction IDs are in `commercial/shots.json`. Generated clips are 1920×1088; the edit crops them to 1080.
- **Logo:** the official DOPE wordmark taken from dope.xyz's `apple-touch-icon.png` (`commercial/assets/dope-apple-touch-icon.png`, 180×180). It was cropped, upscaled 10× with edge smoothing, and saved as a white alpha PNG (`commercial/assets/dope-wordmark-white.png`). The AI clips never draw the logo; it is always composited from this file.
- **Voiceover:** `minimax/speech-02-hd`, voice `English_Deep-VoicedGentleman`, one file per line (`commercial/assets/vo1–5.mp3`). The last line is sped up 1.12× to fit the 3 s end card.
- **Music:** `google/lyria-2`, a 30 s instrumental cue described as energetic cinematic electronic trailer music (`commercial/assets/music.wav`). It is ducked under the VO with a sidechain compressor.
- **Sound design:** synthesised in ffmpeg: glitch burst (0.9 s), portal whoosh and impact (4–5 s), logo shimmers (6 s, 23.3 s), share whoosh (14.3 s), trophy impact (21 s), end-card hit (27 s).
- **Finishing:** a common grade (contrast, saturation, vignette), light film grain, lime-flash transitions, then loudness-normalised and encoded with libx264 + AAC.
- **Rebuild:** `CLIPS=<dir with s1 s2 s3a s3b s4 .mp4> ./commercial/build.sh` (set `FF="imd-media ffmpeg"` where a wrapper is required). The source clips (about 75 MB) are not committed because of their size. They can be re-downloaded or regenerated from `commercial/shots.json`; Replicate deletes outputs after a while, so regeneration may be needed.
- **Fonts:** Liberation Sans (`commercial/assets/fonts`, license included). It stands in for DOPE's brand typeface, which could not be obtained.

## Limitations

- **Brand assets:** dope.xyz sits behind a Cloudflare challenge, so the only official asset I could get was the 180 px apple-touch-icon wordmark. The upscaled logo is clean at the sizes used but not vector-perfect; its edges are very slightly soft and rounded. Brand colours other than the lime/navy given in the brief, plus the brand typeface and any real affiliate-program copy, were not available. Swap in the official vector logo and font before broadcast.
- **AI-generated footage:** these are AI generations, not a live shoot, and they show it in places:
  - Scene 1's monitor shows small, illegible UI text and faces in the feed thumbnails.
  - Scene 3's second shot is staged and fairly static: people stand in a row in front of the trophy.
  - The creator in Scene 1 is not the same person as in Scene 3, so there is no consistent character.
  - Scene 4's shot is scaled to 82% over a blurred extension of itself to make room for the logo; the soft edges are visible on close inspection.
- **Voice:** the voiceover is synthetic TTS (MiniMax). It is confident but not a human performance.
- **Music:** an AI-generated cue, not a licensed track. The licensing terms of each Replicate model apply.
- **Quality check:** I checked the result with ffprobe (codecs, duration, faststart), EBU R128 loudness, per-window VO/music levels and frame contact sheets. Nobody has done an independent visual or creative review.
