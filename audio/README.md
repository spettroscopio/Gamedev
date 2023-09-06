# AUDIO
AUDIO for P1ureBasic.<br>
AUDIO is a module built on top of OpenAL Soft (1.23.1) and LibSndFile (1.2.0), and as the name suggests it offers an alternative way to play sounds in PureBasic.<br>

It can use different backends that are automatically selected based on what is available on the OS.<br>

On Windows has support for the following backends: WinMM, DirectSound, WASAPI.<br>

On Linux has support for the following backends: PulseAudio, ALSA, SndIO, SDL2.<br>

It should be able to read any sound file format supported by LibSndFile, the ones I tested in mono and stereo are: Wave, MP3, OGG, Flac. 

It works on Windows (32/64 bits) and Linux (64 bits).<br>
<br>

The sub-repository is organized this way:

| directory | contents |
| ------ | ------ |
| assets | Sound files in different formats used for testing. |
| libsndfile | The import of the LibSndFile library. |
| openal-soft | The import of the OpenAL Soft library. |
| test | Short examples to demonstrates the use of the commands in practice. |

### What you need to run this ?
Just PureBasic. The only dependencies are the OpenAL Soft and LibSndFile libraries and they are included.<br>
All the test code should work inside the IDE without the need of altering paths, looking for libraries around, etc.<br>

### What you have to do to distribute something compiled with SGL ?
The binaries of the LibSndFile library are under audio/libsndfile/lib.<br>
The binaries of the OpenAL Soft library are under audio/openal-soft/lib.<br>
If you build an executable then the correct dinamic libraries must be copied to the same directory of the executable, or under ./lib or ./bin below that directory.<br>
The initialization of the libraries will look there.<br>

For announcements, comments, questions please go [here](https://www.purebasic.fr/).

