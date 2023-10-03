; *********************************************************************************************************************
; libsndfile.pbi
; by luis
;
; Bindings for libsndfile 1.2.0
; Must be used in conjunction of libsndfile.load.pb to import the actual functions.
;
; Tested on: Windows (x86, x64), Linux (x64)
;
; 1.0, Aug 03 2023, PB 6.02 
; *********************************************************************************************************************

DeclareModule libsndfile

CompilerIf Defined(SEEK_SET, #PB_Constant) = #False
 #SEEK_SET = 0 ;/* set file offset to offset */
 #SEEK_CUR = 1 ;/* set file offset to current plus offset */
 #SEEK_END = 2 ;/* set file offset to EOF plus offset */   
CompilerEndIf
  
; Major formats

#SF_FORMAT_WAV      = $010000 ; Microsoft WAV format (little endian default). 
#SF_FORMAT_AIFF     = $020000 ; Apple/SGI AIFF format (big endian). 
#SF_FORMAT_AU       = $030000 ; Sun/NeXT AU format (big endian). 
#SF_FORMAT_RAW      = $040000 ; RAW PCM data. 
#SF_FORMAT_PAF      = $050000 ; Ensoniq PARIS file format. 
#SF_FORMAT_SVX      = $060000 ; Amiga IFF / SVX8 / SV16 format. 
#SF_FORMAT_NIST     = $070000 ; Sphere NIST format. 
#SF_FORMAT_VOC      = $080000 ; VOC files. 
#SF_FORMAT_IRCAM    = $0A0000 ; Berkeley/IRCAM/CARL 
#SF_FORMAT_W64      = $0B0000 ; Sonic Foundry's 64 bit RIFF/WAV 
#SF_FORMAT_MAT4     = $0C0000 ; Matlab (tm) V4.2 / GNU Octave 2.0 
#SF_FORMAT_MAT5     = $0D0000 ; Matlab (tm) V5.0 / GNU Octave 2.1 
#SF_FORMAT_PVF      = $0E0000 ; Portable Voice Format 
#SF_FORMAT_XI       = $0F0000 ; Fasttracker 2 Extended Instrument 
#SF_FORMAT_HTK      = $100000 ; HMM Tool Kit format 
#SF_FORMAT_SDS      = $110000 ; Midi Sample Dump Standard 
#SF_FORMAT_AVR      = $120000 ; Audio Visual Research 
#SF_FORMAT_WAVEX    = $130000 ; MS WAVE with WAVEFORMATEX 
#SF_FORMAT_SD2      = $160000 ; Sound Designer 2 
#SF_FORMAT_FLAC     = $170000 ; FLAC lossless file format 
#SF_FORMAT_CAF      = $180000 ; Core Audio File format 
#SF_FORMAT_WVE      = $190000 ; Psion WVE format 
#SF_FORMAT_OGG      = $200000 ; Xiph OGG container 
#SF_FORMAT_MPC2K    = $210000 ; Akai MPC 2000 sampler 
#SF_FORMAT_RF64     = $220000 ; RF64 WAV file 
#SF_FORMAT_MPEG		= $230000 ; MPEG-1/2 audio stream 

; Subformats

#SF_FORMAT_PCM_S8   = $0001 ; Signed 8 bit data 
#SF_FORMAT_PCM_16   = $0002 ; Signed 16 bit data 
#SF_FORMAT_PCM_24   = $0003 ; Signed 24 bit data 
#SF_FORMAT_PCM_32   = $0004 ; Signed 32 bit data 

#SF_FORMAT_PCM_U8   = $0005 ; Unsigned 8 bit data (WAV and RAW only) 

#SF_FORMAT_FLOAT    = $0006 ; 32 bit float data 
#SF_FORMAT_DOUBLE   = $0007 ; 64 bit float data 

#SF_FORMAT_ULAW         = $0010 ; U-Law encoded. 
#SF_FORMAT_ALAW         = $0011 ; A-Law encoded. 
#SF_FORMAT_IMA_ADPCM    = $0012 ; IMA ADPCM. 
#SF_FORMAT_MS_ADPCM     = $0013 ; Microsoft ADPCM. 

#SF_FORMAT_GSM610       = $0020 ; GSM 6.10 encoding. 
#SF_FORMAT_VOX_ADPCM    = $0021 ; OKI / Dialogix ADPCM 

#SF_FORMAT_NMS_ADPCM_16 = $0022 ; 16kbs NMS G721-variant encoding
#SF_FORMAT_NMS_ADPCM_24	= $0023	; 24kbs NMS G721-variant encoding
#SF_FORMAT_NMS_ADPCM_32	= $0024	; 32kbs NMS G721-variant encoding

#SF_FORMAT_G721_32  = $0030 ; 32kbs G721 ADPCM encoding
#SF_FORMAT_G723_24  = $0031 ; 24kbs G723 ADPCM encoding 
#SF_FORMAT_G723_40  = $0032 ; 40kbs G723 ADPCM encoding 

#SF_FORMAT_DWVW_12  = $0040 ; 12 bit Delta Width Variable Word encoding
#SF_FORMAT_DWVW_16  = $0041 ; 16 bit Delta Width Variable Word encoding 
#SF_FORMAT_DWVW_24  = $0042 ; 24 bit Delta Width Variable Word encoding 
#SF_FORMAT_DWVW_N   = $0043 ; N bit Delta Width Variable Word encoding 

#SF_FORMAT_DPCM_8   = $0050 ; 8 bit differential PCM (XI only) 
#SF_FORMAT_DPCM_16  = $0051 ; 16 bit differential PCM (XI only) 

#SF_FORMAT_VORBIS   = $0060 ; Xiph Vorbis encoding.
#SF_FORMAT_OPUS     = $0064 ; Xiph/Skype Opus encoding

#SF_FORMAT_ALAC_16  = $0070 ; Apple Lossless Audio Codec (16 bit)
#SF_FORMAT_ALAC_20	= $0071 ; Apple Lossless Audio Codec (20 bit)
#SF_FORMAT_ALAC_24	= $0072 ; Apple Lossless Audio Codec (24 bit)
#SF_FORMAT_ALAC_32	= $0073 ; Apple Lossless Audio Codec (32 bit)

#SF_FORMAT_MPEG_LAYER_I	    = $0080 ; MPEG-1 Audio Layer I
#SF_FORMAT_MPEG_LAYER_II	= $0081 ; MPEG-1 Audio Layer II
#SF_FORMAT_MPEG_LAYER_III   = $0082 ; MPEG-2 Audio Layer III

; Endian-ness options

#SF_ENDIAN_FILE     = $00000000 ; Default file endian-ness
#SF_ENDIAN_LITTLE   = $10000000 ; Force little endian-ness
#SF_ENDIAN_BIG      = $20000000 ; Force big endian-ness 
#SF_ENDIAN_CPU      = $30000000 ; Force CPU endian-ness

#SF_FORMAT_SUBMASK  = $0000FFFF
#SF_FORMAT_TYPEMASK = $0FFF0000
#SF_FORMAT_ENDMASK  = $30000000

#SFC_GET_LIB_VERSION        = $1000
#SFC_GET_LOG_INFO           = $1001
#SFC_GET_CURRENT_SF_INFO    = $1002

#SFC_GET_NORM_DOUBLE            = $1010
#SFC_GET_NORM_FLOAT             = $1011
#SFC_SET_NORM_DOUBLE            = $1012
#SFC_SET_NORM_FLOAT             = $1013
#SFC_SET_SCALE_FLOAT_INT_READ   = $1014
#SFC_SET_SCALE_INT_FLOAT_WRITE  = $1015

#SFC_GET_SIMPLE_FORMAT_COUNT    = $1020
#SFC_GET_SIMPLE_FORMAT          = $1021

#SFC_GET_FORMAT_INFO            = $1028

#SFC_GET_FORMAT_MAJOR_COUNT     = $1030
#SFC_GET_FORMAT_MAJOR           = $1031
#SFC_GET_FORMAT_SUBTYPE_COUNT   = $1032
#SFC_GET_FORMAT_SUBTYPE         = $1033

#SFC_CALC_SIGNAL_MAX            = $1040
#SFC_CALC_NORM_SIGNAL_MAX       = $1041
#SFC_CALC_MAX_ALL_CHANNELS      = $1042
#SFC_CALC_NORM_MAX_ALL_CHANNELS = $1043
#SFC_GET_SIGNAL_MAX             = $1044
#SFC_GET_MAX_ALL_CHANNELS       = $1045

#SFC_SET_ADD_PEAK_CHUNK         = $1050

#SFC_UPDATE_HEADER_NOW          = $1060
#SFC_SET_UPDATE_HEADER_AUTO     = $1061

#SFC_FILE_TRUNCATE  = $1080

#SFC_SET_RAW_START_OFFSET   = $1090

#SFC_SET_DITHER_ON_WRITE    = $10A0
#SFC_SET_DITHER_ON_READ     = $10A1

#SFC_GET_DITHER_INFO_COUNT  = $10A2
#SFC_GET_DITHER_INFO        = $10A3

#SFC_GET_EMBED_FILE_INFO    = $10B0

#SFC_SET_CLIPPING   = $10C0
#SFC_GET_CLIPPING   = $10C1

#SFC_GET_INSTRUMENT = $10D0
#SFC_SET_INSTRUMENT = $10D1

#SFC_GET_LOOP_INFO  = $10E0

#SFC_GET_BROADCAST_INFO = $10F0
#SFC_SET_BROADCAST_INFO = $10F1

#SFC_GET_CHANNEL_MAP_INFO   = $1100
#SFC_SET_CHANNEL_MAP_INFO   = $1101

#SFC_RAW_DATA_NEEDS_ENDSWAP = $1110

; Support for Wavex Ambisonics Format

#SFC_WAVEX_SET_AMBISONIC    = $1200
#SFC_WAVEX_GET_AMBISONIC    = $1201

; RF64 files can be set so that on-close, writable files that have less
; than 4GB of data in them are converted to RIFF/WAV, as per EBU
; recommendations.

#SFC_RF64_AUTO_DOWNGRADE    = $1210

#SFC_SET_VBR_ENCODING_QUALITY   = $1300
#SFC_SET_COMPRESSION_LEVEL		= $1301

; Ogg format commands

#SFC_SET_OGG_PAGE_LATENCY_MS    = $1302
#SFC_SET_OGG_PAGE_LATENCY		= $1303
#SFC_GET_OGG_STREAM_SERIALNO	= $1306

#SFC_GET_BITRATE_MODE			= $1304
#SFC_SET_BITRATE_MODE			= $1305

; Cart Chunk support

#SFC_SET_CART_INFO				= $1400
#SFC_GET_CART_INFO				= $1401

; Opus files original samplerate metadata

#SFC_SET_ORIGINAL_SAMPLERATE	= $1500
#SFC_GET_ORIGINAL_SAMPLERATE	= $1501

; Following commands for testing only

#SFC_TEST_IEEE_FLOAT_REPLACE    = $6001

#SF_STR_TITLE       = $01
#SF_STR_COPYRIGHT   = $02
#SF_STR_SOFTWARE    = $03
#SF_STR_ARTIST      = $04
#SF_STR_COMMENT     = $05
#SF_STR_DATE        = $06
#SF_STR_ALBUM       = $07
#SF_STR_LICENSE     = $08
#SF_STR_TRACKNUMBER = $09
#SF_STR_GENRE       = $10

#SF_STR_FIRST   = #SF_STR_TITLE
#SF_STR_LAST    = #SF_STR_GENRE

#SF_FALSE   = 0
#SF_TRUE    = 1

; Modes for opening files

#SFM_READ   = $10
#SFM_WRITE  = $20
#SFM_RDWR   = $30

#SF_AMBISONIC_NONE      = $40
#SF_AMBISONIC_B_FORMAT  = $41

; Public error values. These are guaranteed to remain unchanged for the duration of the library major version number.
; There are also a large number of private error numbers which are internal to the library which can change at any time.

#SF_ERR_NO_ERROR                = 0
#SF_ERR_UNRECOGNISED_FORMAT     = 1
#SF_ERR_SYSTEM                  = 2
#SF_ERR_MALFORMED_FILE          = 3
#SF_ERR_UNSUPPORTED_ENCODING    = 4

; Channel map values (used with SFC_SET/GET_CHANNEL_MAP)

Enumeration 
#SF_CHANNEL_MAP_INVALID = 0
#SF_CHANNEL_MAP_MONO    = 1
#SF_CHANNEL_MAP_LEFT                    ; Apple calls this 'Left'
#SF_CHANNEL_MAP_RIGHT                   ; Apple calls this 'Right'
#SF_CHANNEL_MAP_CENTER                  ; Apple calls this 'Center'
#SF_CHANNEL_MAP_FRONT_LEFT
#SF_CHANNEL_MAP_FRONT_RIGHT
#SF_CHANNEL_MAP_FRONT_CENTER
#SF_CHANNEL_MAP_REAR_CENTER             ; Apple calls this 'Center Surround' Msft calls this 'Back Center'
#SF_CHANNEL_MAP_REAR_LEFT               ; Apple calls this 'Left Surround' Msft calls this 'Back Left'
#SF_CHANNEL_MAP_REAR_RIGHT              ; Apple calls this 'Right Surround' Msft calls this 'Back Right'
#SF_CHANNEL_MAP_LFE                     ; Apple calls this 'LFEScreen' Msft calls this 'Low Frequency' 
#SF_CHANNEL_MAP_FRONT_LEFT_OF_CENTER    ; Apple calls this 'Left Center'
#SF_CHANNEL_MAP_FRONT_RIGHT_OF_CENTER   ; Apple calls this 'Right Center
#SF_CHANNEL_MAP_SIDE_LEFT               ; Apple calls this 'Left Surround Direct'
#SF_CHANNEL_MAP_SIDE_RIGHT              ; Apple calls this 'Right Surround Direct'
#SF_CHANNEL_MAP_TOP_CENTER              ; Apple calls this 'Top Center Surround'
#SF_CHANNEL_MAP_TOP_FRONT_LEFT          ; Apple calls this 'Vertical Height Left'
#SF_CHANNEL_MAP_TOP_FRONT_RIGHT         ; Apple calls this 'Vertical Height Right'
#SF_CHANNEL_MAP_TOP_FRONT_CENTER        ; Apple calls this 'Vertical Height Center'
#SF_CHANNEL_MAP_TOP_REAR_LEFT           ; Apple and MS call this 'Top Back Left'
#SF_CHANNEL_MAP_TOP_REAR_RIGHT          ; Apple and MS call this 'Top Back Right'
#SF_CHANNEL_MAP_TOP_REAR_CENTER         ; Apple and MS call this 'Top Back Center'
  
#SF_CHANNEL_MAP_AMBISONIC_B_W
#SF_CHANNEL_MAP_AMBISONIC_B_X
#SF_CHANNEL_MAP_AMBISONIC_B_Y
#SF_CHANNEL_MAP_AMBISONIC_B_Z
  
#SF_CHANNEL_MAP_MAX
EndEnumeration

; Bitrate mode values (for use with SFC_GET/SET_BITRATE_MODE)

Enumeration
#SF_BITRATE_MODE_CONSTANT = 0
#SF_BITRATE_MODE_AVERAGE
#SF_BITRATE_MODE_VARIABLE
EndEnumeration

; Enums and typedefs for adding dither on read and write.
; Reserved for future implementation.

#SFD_DEFAULT_LEVEL  = 0
#SFD_CUSTOM_LEVEL   = $40000000
#SFD_NO_DITHER      = 500
#SFD_WHITE          = 501
#SFD_TRIANGULAR_PDF = 502

Structure SF_DITHER_INFO Align #PB_Structure_AlignC 
 type.l
 level.d
 *name
EndStructure

; The loop mode field in SF_INSTRUMENT will be one of the following
Enumeration
#SF_LOOP_NONE = 800
#SF_LOOP_FORWARD
#SF_LOOP_BACKWARD
#SF_LOOP_ALTERNATING
EndEnumeration

; A pointer to a SF_INFO structure is passed to sf_open () and filled in.
; On write, the SF_INFO structure is filled in by the user and passed into
; sf_open ().

Structure SF_INFO Align #PB_Structure_AlignC 
 frames.q
 samplerate.l
 channels.l
 format.l
 sections.l
 seekable.l
EndStructure

; The SF_FORMAT_INFO struct is used to retrieve information about the sound
; file formats libsndfile supports using the sf_command () interface.
; 
; Using this interface will allow applications to support new file formats
; and encoding types when libsndfile is upgraded, without requiring
; re-compilation of the application.
; 
; Please consult the libsndfile documentation (particularly the information
; on the sf_command () interface) for examples of its use.

Structure SF_FORMAT_INFO Align #PB_Structure_AlignC 
 format.l
 *name
 *extension
EndStructure

; Struct used to retrieve information about a file embedded within a
; larger file. See SFC_GET_EMBED_FILE_INFO.

Structure SF_EMBED_FILE_INFO Align #PB_Structure_AlignC 
  offset.q
  length.q
EndStructure

Structure SF_CUE_POINT
 indx.l
 position.l ; unsigned
 fcc_chunk.l
 chunk_start.l   
 block_start.l
 sample_offset.l ; unsigned
 name.a[256] 
EndStructure

Structure SF_INSTRUMENT_LOOP Align #PB_Structure_AlignC 
 mode.l
 start.l ; unsigned
 end_.l  ; unsigned
 count.l ; unsigned
EndStructure

Structure SF_INSTRUMENT Align #PB_Structure_AlignC 
 gain.l
 basenote.b
 detune.b 
 velocity_lo.b
 velocity_hi.b
 key_lo.b
 key_hi.b
 loop_count.l
 loops.SF_INSTRUMENT_LOOP[16]
EndStructure

; Struct used to retrieve loop information from a file

Structure SF_LOOP_INFO Align #PB_Structure_AlignC 
  time_sig_num.w
  time_sig_den.w
  loop_mode.l
  num_beats.l
  bpm.f
  root_key.l  
  future.l[6]
EndStructure

Structure SF_CART_TIMER Align #PB_Structure_AlignC 
 usage.b[4]
 value.l
EndStructure

Structure SF_CHUNK_INFO Align #PB_Structure_AlignC 
 id.b[64]  ; The chunk identifier
 id_size.l ; The size of the chunk identifier
 datalen.l ; The size of that data
 *dataptr  ; Pointer to the data
EndStructure

PrototypeC.q    sf_vio_get_filelen (*user_data)
PrototypeC.q    sf_vio_seek (offset.q, whence, *user_data)
PrototypeC.q    sf_vio_read (*ptr, count.q, *user_data)
PrototypeC.q    sf_vio_write (*ptr, count.q, *user_data)
PrototypeC.q    sf_vio_tell (*user_data)

Structure SF_VIRTUAL_IO
 cb_get_filelen.sf_vio_get_filelen
 cb_seek.sf_vio_seek
 cb_read.sf_vio_read
 cb_write.sf_vio_write
 cb_tell.sf_vio_tell
EndStructure

PrototypeC.i sf_open (path.p-utf8, mode, *sfinfo) : Global sf_open.sf_open
PrototypeC.i sf_open_fd (fd, mode, *sfinfo, close_desc) : Global sf_open_fd.sf_open_fd
PrototypeC.i sf_open_virtual (*sfvirtual, mode, *sfinfo, *user_data) : Global sf_open_virtual.sf_open_virtual
PrototypeC.l sf_error (*sndfile) : Global sf_error.sf_error
PrototypeC.i sf_strerror (*sndfile) : Global sf_strerror.sf_strerror
PrototypeC.i sf_error_number (errnum) : Global sf_error_number.sf_error_number
PrototypeC.l sf_perror (*sndfile) : Global sf_perror.sf_perror
PrototypeC.l sf_error_str (*sndfile, str.p-utf8, len) : Global sf_error_str.sf_error_str
PrototypeC.l sf_command (*sndfile, command, *data_, datasize) : Global sf_command.sf_command
PrototypeC.l sf_format_check (*info) : Global sf_format_check.sf_format_check
PrototypeC.q sf_seek (*sndfile, frames.q, whence) : Global sf_seek.sf_seek
PrototypeC.l sf_set_string (*sndfile, str_type, str.p-utf8) : Global sf_set_string.sf_set_string
PrototypeC.i sf_get_string (*sndfile, str_type) : Global sf_get_string.sf_get_string
PrototypeC.i sf_version_string () : Global sf_version_string.sf_version_string
PrototypeC.i sf_current_byterate (*sndfile) : Global sf_current_byterate.sf_current_byterate
PrototypeC.q sf_read_raw (*sndfile, *ptr, bytes.q) : Global sf_read_raw.sf_read_raw
PrototypeC.q sf_write_raw (*sndfile, *ptr, bytes.q) : Global sf_write_raw.sf_write_raw
PrototypeC.q sf_readf_short (*sndfile, *ptr, frames.q) : Global sf_readf_short.sf_readf_short
PrototypeC.q sf_writef_short (*sndfile, *ptr, frames.q) : Global sf_writef_short.sf_writef_short
PrototypeC.q sf_readf_int (*sndfile, *ptr, frames.q) : Global sf_readf_int.sf_readf_int
PrototypeC.q sf_writef_int (*sndfile, *ptr, frames.q) : Global sf_writef_int.sf_writef_int
PrototypeC.q sf_readf_float (*sndfile, *ptr, frames.q) : Global sf_readf_float.sf_readf_float
PrototypeC.q sf_writef_float (*sndfile, *ptr, frames.q) : Global sf_writef_float.sf_writef_float
PrototypeC.q sf_readf_double (*sndfile, *ptr, frames.q) : Global sf_readf_double.sf_readf_double
PrototypeC.q sf_writef_double (*sndfile, *ptr, frames.q) : Global sf_writef_double.sf_writef_double
PrototypeC.q sf_read_short (*sndfile, *ptr, items.q) : Global sf_read_short.sf_read_short
PrototypeC.q sf_write_short (*sndfile, *ptr, items.q) : Global sf_write_short.sf_write_short
PrototypeC.q sf_read_int (*sndfile, *ptr, items.q) : Global sf_read_int.sf_read_int
PrototypeC.q sf_write_int (*sndfile, *ptr, items.q) : Global sf_write_int.sf_write_int
PrototypeC.q sf_read_float (*sndfile, *ptr, items.q) : Global sf_read_float.sf_read_float
PrototypeC.q sf_write_float (*sndfile, *ptr, items.q) : Global sf_write_float.sf_write_float
PrototypeC.q sf_read_double (*sndfile, *ptr, items.q) : Global sf_read_double.sf_read_double
PrototypeC.q sf_write_double (*sndfile, *ptr, items.q) : Global sf_write_double.sf_write_double
PrototypeC.i sf_close (*sndfile) : Global sf_close.sf_close
PrototypeC   sf_write_sync (*sndfile) : Global sf_write_sync.sf_write_sync

CompilerIf (#PB_Compiler_OS = #PB_OS_Windows)
PrototypeC.i sf_wchar_open (wpath.p-unicode, mode, *sfinfo) : Global sf_wchar_open.sf_wchar_open    
CompilerEndIf

PrototypeC.i sf_set_chunk (*sndfile, *chunk_info) : Global sf_set_chunk.sf_set_chunk
PrototypeC.i sf_get_chunk_iterator (*sndfile, *chunk_info) : Global sf_get_chunk_iterator.sf_get_chunk_iterator
PrototypeC.i sf_next_chunk_iterator (*iterator) : Global sf_next_chunk_iterator.sf_next_chunk_iterator
PrototypeC.i sf_get_chunk_size (*it, *chunk_info) : Global sf_get_chunk_size.sf_get_chunk_size
PrototypeC.i sf_get_chunk_data (*it, *chunk_info) : Global sf_get_chunk_data.sf_get_chunk_data

EndDeclareModule

Module libsndfile
 ; NOP
EndModule
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 7
; Markers = 422
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory