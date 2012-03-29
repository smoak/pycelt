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

cdef extern from "celt/celt_types.h":
    ctypedef celt_int16* const_celt_int16_ptr "const celt_int16*"

cdef extern from "celt/celt.h":

    ctypedef struct CELTEncoder:
        pass
    
    ctypedef struct CELTDecoder:
        pass

    ctypedef struct CELTMode:
        pass

    ctypedef CELTMode* const_CELTMode_ptr "const CELTMode*"

    CELTMode *celt_mode_create(celt_int32 Fs, int frame_size, int *error)
    void celt_mode_destroy(CELTMode *mode)

    # first param is const CELTMode*
    int celt_mode_info(const_CELTMode_ptr mode, int request, celt_int32 *value)

    CELTEncoder *celt_encoder_create(const_CELTMode_ptr mode, int channels, int *error)

    void celt_encoder_destroy(CELTEncoder *st)

    int celt_encode_float(CELTEncoder *st, const_float_ptr pcm, float *optional_synthesis,
            unsigned char *compressed, int nbCompressedBytes)

    int celt_encode(CELTEncoder *st, const_celt_int16_ptr pcm, celt_int16 *optional_synthesis,
            unsigned char *compressed, int nbCompressedBytes)

    int celt_encoder_ctl(CELTEncoder * st, int request, ...)

    CELTDecoder *celt_decoder_create(const_CELTMode_ptr mode, int channels, int *error)

    void celt_decoder_destroy(CELTDecoder *st)

    int celt_decode_float(CELTDecoder *st, const_unsigned_char_ptr data, int len, float *pcm)

    int celt_decode(CELTDecoder *st, const_unsigned_char_ptr data, int len, celt_int16 *pcm)

    int celt_decoder_ctl(CELTDecoder * st, int request, ...)
    const_char_ptr celt_strerror(int error) # same as const char* celt_strerror(int error) See http://wiki.cython.org/FAQ#HowdoIuse.27const.27.3F
