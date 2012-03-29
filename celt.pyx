cimport ccelt
cimport cpython

cdef class CeltConstants:
    CELT_OK = 0
    CELT_BAD_ARG = -1
    CELT_INVALID_MODE = -2
    CELT_INTERNAL_ERROR = -3
    CELT_CORRUPTED_DATA = -4
    CELT_UNIMPLEMENTED = -5
    CELT_INVALID_STATE = -6
    CELT_ALLOC_FAIL = -7
    CELT_GET_MODE_REQUEST = 1
    CELT_SET_COMPLEXITY_REQUEST = 2
    CELT_SET_PREDICTION_REQUEST = 4
    CELT_SET_VBR_RATE_REQUEST = 6
    CELT_RESET_STATE_REQUEST = 8
    CELT_RESET_STATE = 8
    CELT_GET_FRAME_SIZE = 1000
    CELT_GET_LOOKAHEAD = 1001
    CELT_GET_SAMPLE_RATE = 1003
    CELT_GET_BITSTREAM_VERSION = 2000

cdef class CeltEncoder:

    cdef ccelt.CELTEncoder* _celtencoder
    cdef ccelt.CELTMode* _celtmode

    def __cinit__(self, sampleRate, frameSize, channels):
        self._celtmode = ccelt.celt_mode_create(sampleRate, frameSize, NULL)
        if self._celtmode is NULL:
            raise MemoryError()
        self._celtencoder = ccelt.celt_encoder_create(self._celtmode, channels, NULL)
        if self._celtencoder is NULL:
            raise MemoryError()

    def __dealloc__(self):
        if self._celtencoder is not NULL:
            ccelt.celt_encoder_destroy(self._celtencoder)
        if self._celtmode is not NULL:
            ccelt.celt_mode_destroy(self._celtmode)

    def setPredictionRequest(self, value):
        cdef int v = <int>value
        ccelt.celt_encoder_ctl(self._celtencoder, CeltConstants.CELT_SET_PREDICTION_REQUEST, &v)

    def setVBRRate(self, value):
        cdef int v = <int>value
        ccelt.celt_encoder_ctl(self._celtencoder, CeltConstants.CELT_SET_VBR_RATE_REQUEST, &v)

    def encode(self, pcm, optionalSynthesis, nbCompressedBytes):
        cdef unsigned char* data = <unsigned char*>pcm
        # nbCompressedBytes Maximum number of bytes to use for compressing the frame
        # The number of bytes written to compressed will be the same as 
        # "nbCompressedBytes" unless the stream is VBR and will never be larger.
        cdef unsigned char* compressed = <unsigned char*>ccelt.PyMem_Malloc(nbCompressedBytes)

        cdef unsigned char* optionalData = <unsigned char*>optionalSynthesis
        cdef int len = ccelt.celt_encode(self._celtencoder, <ccelt.celt_int16*>data, 
                <ccelt.celt_int16*>optionalData, compressed, <int>nbCompressedBytes)
        return compressed[:len]
