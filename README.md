# audio_conversion

This project is intended to save an audio stream from another chrome tab and convert that to a WAV file.

The wav file conversion doesn't currently work.

I am using the js package https://github.com/upadhyaypushpendra/webm-to-wav-converter
although I am open to using other packages to solve the issue as long as they are not too large (or can be loaded
in the background so as not to delay app startup, but even then I would't want more than a few MB)

This is tested on [✓] Flutter (Channel stable, 3.3.5, on macOS 12.6 21G115 darwin-arm, locale en-AU) 
but probably also works on older versions.

Here is a loom video showing how it works: https://www.loom.com/share/0754aa8871c245bfbef44e718fe55e3e

The main constraints are:
- The solution must run ON the users device (the audio cannot be sent to a server for conversion).
- It cannot involve the user installing any additional software manually.
- Any packages used for conversion must be very small <100kb. If they are larger than that, they must be loaded after the app starts up to not cause a delay (although even in that case they should not be more than 5-10MB)

