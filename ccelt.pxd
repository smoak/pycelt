cdef extern from "Python.h":
    ctypedef int size_t
    void* PyMem_Malloc(size_t n)

cdef extern from *:
    ctypedef short celt_int16
    ctypedef unsigned short celt_uint16
    ctypedef int celt_int32
    ctypedef unsigned int celt_uint32
    ctypedef char* const_char_ptr "const char*"
    ctypedef float* const_float_ptr "const float*"
    ctypedef unsigned char* const_unsigned_char_ptr "const unsigned char*"

cdef extern from "celt_types.h":
    ctypedef celt_int16* const_celt_int16_ptr "const celt_int16*"


cdef extern from "celt.h":

    ctypedef struct CELTEncoder:
        pass
    
    ctypedef struct CELTDecoder:
        pass

    ctypedef struct CELTMode:
        pass

    ctypedef CELTMode* const_CELTMode_ptr "const CELTMode*"

    # CELTMode stuff
    CELTMode *celt_mode_create(celt_int32 Fs, int frame_size, int *error)
    void celt_mode_destroy(CELTMode *mode)
    int celt_mode_info(const_CELTMode_ptr mode, int request, celt_int32 *value)

    # CELTEncoder stuff
    int celt_encoder_get_size(int channels)
    int celt_encoder_get_size_custom(const_CELTMode_ptr mode, int channels)
    CELTEncoder *celt_encoder_create(int sampling_rate, int channels, int *error)
    CELTEncoder *celt_encoder_create_custom(const_CELTMode_ptr mode, int channels, int *error)
    CELTEncoder *celt_encoder_init(CELTEncoder *st, int sampling_rate, int channels, int *error)
    CELTEncoder *celt_encoder_init_custom(CELTEncoder *st, const_CELTMode_ptr mode, int channels, int *error)
    void celt_encoder_destroy(CELTEncoder *st)
    int celt_encode_float(CELTEncoder *st, const_float_ptr pcm, int frame_size, unsigned char *compressed, int max_compressed_bytes)
    int celt_encode(CELTEncoder *st, const_celt_int16_ptr pcm, int frame_size, unsigned char *compressed, int max_compressed_bytes)
    int celt_encoder_ctl(CELTEncoder * st, int request, ...)

    # CELTDecoder stuff
    int celt_decoder_get_size(int channels)
    int celt_decoder_get_size_custom(const_CELTMode_ptr mode, int channels)
    CELTDecoder *celt_decoder_create(int sampling_rate, int channels, int* error)
    CELTDecoder *celt_decoder_create_custom(const_CELTMode_ptr mode, int channels, int *error)
    CELTDecoder *celt_decoder_init(CELTDecoder *st, int sampling_rate, int channels, int *error)
    CELTDecoder *celt_decoder_init_custom(CELTDecoder *st, const_CELTMode_ptr mode, int channels, int *error)
    void celt_decoder_destroy(CELTDecoder *st)
    int celt_decode_float(CELTDecoder *st, const_unsigned_char_ptr data, int len, float *pcm, int frame_size)
    int celt_decode(CELTDecoder *st, const_unsigned_char_ptr data, int len, celt_int16 *pcm, int frame_size)
    int celt_decoder_ctl(CELTDecoder * st, int request, ...)
    const_char_ptr celt_strerror(int error) # same as const char* celt_strerror(int error) See http://wiki.cython.org/FAQ#HowdoIuse.27const.27.3F

cdef extern from "celt_header.h":
    ctypedef struct CELTHeader:
        char codec_id[8]
        char codec_version[20]
        celt_int32 version_id
        celt_int32 header_size
        celt_int32 sample_rate
        celt_int32 nb_channels
        celt_int32 frame_size
        celt_int32 overlap
        celt_int32 bytes_per_packet
        celt_int32 extra_headers

    int celt_header_init(CELTHeader *header, const_CELTMode_ptr m, int frame_size, int channels)
    int celt_header_to_packet(CELTHeader *header, unsigned char *packet, celt_uint32 size)
    int celt_header_from_packet(unsigned char *packet, celt_uint32 size, CELTHeader *header)
