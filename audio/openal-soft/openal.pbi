; *********************************************************************************************************************
; openal.pbi
; by luis
;
; Bindings for OpenaAL Soft 1.23.1
; Must be used in conjunction of openal.load.pb to import the actual functions.
;
; Tested on: Windows, Linux (x86, x64)
;
; 1.0, Jul 28 2023, PB 6.02 
;
; 8-bit PCM data is expressed as an unsigned value over the range 0 to 255, 128 being an audio output level of zero. 
; 16-bit PCM data is expressed as a signed value over the range -32768 to 32767, 0 being an audio output level of zero. 
; Stereo data is expressed in interleaved format, left channel first. 
; Buffers containing more than one channel of data will be played without 3D spatialization.
; *********************************************************************************************************************

DeclareModule openal

; OpenAL API constants
#AL_NONE                      = 0
#AL_FALSE                     = 0
#AL_TRUE                      = 1

#AL_SOURCE_RELATIVE           = $0202
#AL_CONE_INNER_ANGLE          = $1001
#AL_CONE_OUTER_ANGLE          = $1002
#AL_PITCH                     = $1003
#AL_POSITION                  = $1004
#AL_DIRECTION                 = $1005
#AL_VELOCITY                  = $1006
#AL_LOOPING                   = $1007
#AL_BUFFER                    = $1009
#AL_GAIN                      = $100A
#AL_MIN_GAIN                  = $100D
#AL_MAX_GAIN                  = $100E
#AL_ORIENTATION               = $100F
#AL_SOURCE_STATE              = $1010
#AL_INITIAL                   = $1011
#AL_PLAYING                   = $1012
#AL_PAUSED                    = $1013
#AL_STOPPED                   = $1014
#AL_BUFFERS_QUEUED            = $1015
#AL_BUFFERS_PROCESSED         = $1016
#AL_REFERENCE_DISTANCE        = $1020
#AL_ROLLOFF_FACTOR            = $1021
#AL_CONE_OUTER_GAIN           = $1022
#AL_MAX_DISTANCE              = $1023
#AL_SEC_OFFSET                = $1024
#AL_SAMPLE_OFFSET             = $1025
#AL_BYTE_OFFSET               = $1026
#AL_SOURCE_TYPE               = $1027
#AL_STATIC                    = $1028
#AL_STREAMING                 = $1029
#AL_UNDETERMINED              = $1030
#AL_FORMAT_MONO8              = $1100
#AL_FORMAT_MONO16             = $1101
#AL_FORMAT_STEREO8            = $1102
#AL_FORMAT_STEREO16           = $1103
#AL_FREQUENCY                 = $2001
#AL_BITS                      = $2002
#AL_CHANNELS                  = $2003
#AL_SIZE                      = $2004
#AL_UNUSED                    = $2010
#AL_PENDING                   = $2011
#AL_PROCESSED                 = $2012
#AL_NO_ERROR                  = $0000
#AL_INVALID_NAME              = $A001
#AL_INVALID_ENUM              = $A002
#AL_INVALID_VALUE             = $A003
#AL_INVALID_OPERATION         = $A004
#AL_OUT_OF_MEMORY             = $A005
#AL_VENDOR                    = $B001
#AL_VERSION                   = $B002
#AL_RENDERER                  = $B003
#AL_EXTENSIONS                = $B004
#AL_DOPPLER_FACTOR            = $C000
#AL_DOPPLER_VELOCITY          = $C001
#AL_SPEED_OF_SOUND            = $C003
#AL_DISTANCE_MODEL            = $D000
#AL_INVERSE_DISTANCE          = $D001
#AL_INVERSE_DISTANCE_CLAMPED  = $D002
#AL_LINEAR_DISTANCE           = $D003
#AL_LINEAR_DISTANCE_CLAMPED   = $D004
#AL_EXPONENT_DISTANCE         = $D005
#AL_EXPONENT_DISTANCE_CLAMPED = $D006

; OpenAL Context API constants

#ALC_FALSE                            = $0000
#ALC_TRUE                             = $0001
#ALC_FREQUENCY                        = $1007
#ALC_REFRESH                          = $1008
#ALC_SYNC                             = $1009
#ALC_MONO_SOURCES                     = $1010
#ALC_STEREO_SOURCES                   = $1011
#ALC_NO_ERROR                         = $0000
#ALC_INVALID_DEVICE                   = $A001
#ALC_INVALID_CONTEXT                  = $A002
#ALC_INVALID_ENUM                     = $A003
#ALC_INVALID_VALUE                    = $A004
#ALC_OUT_OF_MEMORY                    = $A005
#ALC_MAJOR_VERSION                    = $1000
#ALC_MINOR_VERSION                    = $1001
#ALC_ATTRIBUTES_SIZE                  = $1002
#ALC_ALL_ATTRIBUTES                   = $1003
#ALC_DEFAULT_DEVICE_SPECIFIER         = $1004
#ALC_DEVICE_SPECIFIER                 = $1005
#ALC_EXTENSIONS                       = $1006
#ALC_EXT_CAPTURE                      = $0001
#ALC_CAPTURE_DEVICE_SPECIFIER         = $0310
#ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER = $0311
#ALC_CAPTURE_SAMPLES                  = $0312
#ALC_ENUMERATE_ALL_EXT                = $0001
#ALC_DEFAULT_ALL_DEVICES_SPECIFIER    = $1012
#ALC_ALL_DEVICES_SPECIFIER            = $1013

; Renderer state management
PrototypeC      alEnable (capability) : Global alEnable.alEnable
PrototypeC      alDisable (capability) : Global alDisable.alDisable
PrototypeC.i    alIsEnabled (capability) : Global alIsEnabled.alIsEnabled

; Context state setting
PrototypeC      alDopplerFactor (value.f) : Global alDopplerFactor.alDopplerFactor
PrototypeC      alDopplerVelocity (value.f) : Global alDopplerVelocity.alDopplerVelocity
PrototypeC      alSpeedOfSound (value.f) : Global alSpeedOfSound.alSpeedOfSound
PrototypeC      alDistanceModel (distancemodel) : Global alDistanceModel.alDistanceModel

; Context state retrieval
PrototypeC.i    alGetString (param) : Global alGetString.alGetString
PrototypeC      alGetBooleanv (param, *values) : Global alGetBooleanv.alGetBooleanv
PrototypeC      alGetIntegerv (param, *values) : Global alGetIntegerv.alGetIntegerv
PrototypeC      alGetFloatv (param, *values) : Global alGetFloatv.alGetFloatv
PrototypeC      alGetDoublev (param, *values) : Global alGetDoublev.alGetDoublev
PrototypeC.i    alGetBoolean (param) : Global alGetBoolean.alGetBoolean
PrototypeC.i    alGetInteger (param) : Global alGetInteger.alGetInteger
PrototypeC.f    alGetFloat (param) : Global alGetFloat.alGetFloat
PrototypeC.d    alGetDouble (param) : Global alGetDouble.alGetDouble

; Error retrieval
PrototypeC.i    alGetError() : Global alGetError.alGetError

; Extension support
PrototypeC.i    alIsExtensionPresent (extname.p-utf8) : Global alIsExtensionPresent.alIsExtensionPresent
PrototypeC.i    alGetProcAddress (fname.p-utf8) : Global alGetProcAddress.alGetProcAddress
PrototypeC.i    alGetEnumValue (ename.p-utf8) : Global alGetEnumValue.alGetEnumValue

; Set listener parameters
PrototypeC      alListenerf (param, value.f) : Global alListenerf.alListenerf
PrototypeC      alListener3f (param, value1.f, value2.f, value3.f) : Global alListener3f.alListener3f
PrototypeC      alListenerfv (param, *values) : Global alListenerfv.alListenerfv
PrototypeC      alListeneri (param, value) : Global alListeneri.alListeneri
PrototypeC      alListener3i (param, value1, value2, value3) : Global alListener3i.alListener3i
PrototypeC      alListeneriv (param, *values) : Global alListeneriv.alListeneriv

; Get listener parameters
PrototypeC      alGetListenerf (param, *value) : Global alGetListenerf.alGetListenerf
PrototypeC      alGetListener3f (param, *value1, *value2, *value3) : Global alGetListener3f.alGetListener3f
PrototypeC      alGetListenerfv (param, *values) : Global alGetListenerfv.alGetListenerfv
PrototypeC      alGetListeneri (param, *value) : Global alGetListeneri.alGetListeneri
PrototypeC      alGetListener3i (param, *value1, *value2, *value3) : Global alGetListener3i.alGetListener3i
PrototypeC      alGetListeneriv (param, *values) : Global alGetListeneriv.alGetListeneriv

; Create source objects
PrototypeC      alGenSources (n, *sources) : Global alGenSources.alGenSources

; Delete source objects
PrototypeC      alDeleteSources (n, *sources) : Global alDeleteSources.alDeleteSources

; Verify an ID is for a valid source
PrototypeC.i    alIsSource (source) : Global alIsSource.alIsSource

; Set source parameters
PrototypeC      alSourcef (source, param, value.f) : Global alSourcef.alSourcef
PrototypeC      alSource3f (source, param, value1.f, value2.f, value3.f) : Global alSource3f.alSource3f
PrototypeC      alSourcefv (source, param, *values) : Global alSourcefv.alSourcefv
PrototypeC      alSourcei (source, param, value.i) : Global alSourcei.alSourcei
PrototypeC      alSource3i (source, param, value1, value2, value3) : Global alSource3i.alSource3i
PrototypeC      alSourceiv (source, param, *values) : Global alSourceiv.alSourceiv

; Get source parameters
PrototypeC      alGetSourcef (source, param, *value) : Global alGetSourcef.alGetSourcef
PrototypeC      alGetSource3f (source, param, *value1, *value2, *value3) : Global alGetSource3f.alGetSource3f
PrototypeC      alGetSourcefv (source, param, *values) : Global alGetSourcefv.alGetSourcefv
PrototypeC      alGetSourcei (source, param, *value) : Global alGetSourcei.alGetSourcei
PrototypeC      alGetSource3i (source, param, *value1, *value2, *value3) : Global alGetSource3i.alGetSource3i
PrototypeC      alGetSourceiv (source, param, *values) : Global alGetSourceiv.alGetSourceiv

; Play, restart, or resume a source, setting its state to AL_PLAYING
PrototypeC      alSourcePlay (source) : Global alSourcePlay.alSourcePlay
; Stop a source, setting its state to AL_STOPPED if playing or paused
PrototypeC      alSourceStop (source) : Global alSourceStop.alSourceStop
; Rewind a source, setting its state to AL_INITIAL
PrototypeC      alSourceRewind (source) : Global alSourceRewind.alSourceRewind
; Pause a source, setting its state to AL_PAUSED if playing
PrototypeC      alSourcePause (source) : Global alSourcePause.alSourcePause

; Play, restart, or resume a list of sources atomically
PrototypeC      alSourcePlayv (n, *sources) : Global alSourcePlayv.alSourcePlayv
; Stop a list of sources atomically
PrototypeC      alSourceStopv (n, *sources) : Global alSourceStopv.alSourceStopv
; Rewind a list of sources atomically
PrototypeC      alSourceRewindv (n, *sources) : Global alSourceRewindv.alSourceRewindv
; Pause a list of sources atomically
PrototypeC      alSourcePausev (n, *sources) : Global alSourcePausev.alSourcePausev

; Queue buffers onto a source
PrototypeC      alSourceQueueBuffers (source, nb, *buffers) : Global alSourceQueueBuffers.alSourceQueueBuffers
; Unqueue processed buffers from a source
PrototypeC      alSourceUnqueueBuffers (source, nb, *buffers) : Global alSourceUnqueueBuffers.alSourceUnqueueBuffers

; Create Buffer objects
PrototypeC      alGenBuffers (n, *buffers) : Global alGenBuffers.alGenBuffers
; Delete Buffer objects
PrototypeC      alDeleteBuffers (n, *buffers) : Global alDeleteBuffers.alDeleteBuffers
; Verify an ID is a valid buffer (including the NULL buffer)
PrototypeC.i    alIsBuffer (buffer) : Global alIsBuffer.alIsBuffer

; Copies data into the buffer, interpreting it using the specified format and samplerate
PrototypeC      alBufferData (buffer, format, *databuff, size, samplerate) : Global alBufferData.alBufferData

; Set buffer parameters
PrototypeC      alBufferf (buffer, param, value.f) : Global alBufferf.alBufferf
PrototypeC      alBuffer3f (buffer, param, value1.f, value2.f, value3.f) : Global alBuffer3f.alBuffer3f
PrototypeC      alBufferfv (buffer, param, *values) : Global alBufferfv.alBufferfv
PrototypeC      alBufferi (buffer, param, value) : Global alBufferi.alBufferi
PrototypeC      alBuffer3i (buffer, param, value1, value2, value3) : Global alBuffer3i.alBuffer3i
PrototypeC      alBufferiv (buffer, param, *values) : Global alBufferiv.alBufferiv

; Get buffer parameters
PrototypeC      alGetBufferf (buffer, param, *value) : Global alGetBufferf.alGetBufferf
PrototypeC      alGetBuffer3f (buffer, param, *value1, *value2, *value3) : Global alGetBuffer3f.alGetBuffer3f
PrototypeC      alGetBufferfv (buffer, param, *values) : Global alGetBufferfv.alGetBufferfv
PrototypeC      alGetBufferi (buffer, param, *value) : Global alGetBufferi.alGetBufferi
PrototypeC      alGetBuffer3i (buffer, param, *value1, *value2, *value3) : Global alGetBuffer3i.alGetBuffer3i
PrototypeC      alGetBufferiv (buffer, param, *values) : Global alGetBufferiv.alGetBufferiv

; Context management
PrototypeC.i    alcCreateContext (*device, *attrlist) : Global alcCreateContext.alcCreateContext
PrototypeC.i    alcMakeContextCurrent (*context) : Global alcMakeContextCurrent.alcMakeContextCurrent
PrototypeC      alcProcessContext (*context) : Global alcProcessContext.alcProcessContext
PrototypeC      alcSuspendContext (*context) : Global alcSuspendContext.alcSuspendContext
PrototypeC      alcDestroyContext (*context) : Global alcDestroyContext.alcDestroyContext
PrototypeC.i    alcGetCurrentContext() : Global alcGetCurrentContext.alcGetCurrentContext
PrototypeC.i    alcGetContextsDevice (*context) : Global alcGetContextsDevice.alcGetContextsDevice

; Device management
PrototypeC.i    alcOpenDevice (devicename.p-utf8) : Global alcOpenDevice.alcOpenDevice
PrototypeC.i    alcCloseDevice (*device) : Global alcCloseDevice.alcCloseDevice

; Error support
PrototypeC.i    alcGetError (*device) : Global alcGetError.alcGetError

; Extension support
PrototypeC.i    alcIsExtensionPresent (*device, extname.p-utf8) : Global alcIsExtensionPresent.alcIsExtensionPresent
PrototypeC.i    alcGetProcAddress (*device, fname.p-utf8) : Global alcGetProcAddress.alcGetProcAddress
PrototypeC.i    alcGetEnumValue (*device, ename.p-utf8) : Global alcGetEnumValue.alcGetEnumValue

; Query functions
PrototypeC.i    alcGetString (*device, param) : Global alcGetString.alcGetString
PrototypeC      alcGetIntegerv (*device, param, size, *values) : Global alcGetIntegerv.alcGetIntegerv

; Capture functions
PrototypeC.i    alcCaptureOpenDevice (devicename.p-utf8, frequency, format, buffersize) : Global alcCaptureOpenDevice.alcCaptureOpenDevice
PrototypeC.i    alcCaptureCloseDevice (*device) : Global alcCaptureCloseDevice.alcCaptureCloseDevice
PrototypeC      alcCaptureStart (*device) : Global alcCaptureStart.alcCaptureStart
PrototypeC      alcCaptureStop (*device) : Global alcCaptureStop.alcCaptureStop
PrototypeC      alcCaptureSamples (*device, *buffer, samples) : Global alcCaptureSamples.alcCaptureSamples

EndDeclareModule

Module openal
 ; NOP
EndModule

; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 7
; Folding = -
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory