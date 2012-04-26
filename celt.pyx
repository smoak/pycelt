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
    cdef ccelt.celt_int32 sampleRate
    cdef int frameSize
    cdef int channels
    cdef int predictionRequest
    cdef int vbrRate

    def __cinit__(self, sampleRate, frameSize, channels):
        self.sampleRate = sampleRate
        self.frameSize = frameSize
        self.channels = channels
        cdef int error

        # create the mode
        self._celtmode = ccelt.celt_mode_create(sampleRate, frameSize, &error)
        if error != CeltConstants.CELT_OK:
            raise Exception(ccelt.celt_strerror(error))

        if self._celtmode is NULL:
            raise MemoryError()

        # create the encoder using the mode
        self._celtencoder = ccelt.celt_encoder_create_custom(self._celtmode, channels, &error)

        if error != CeltConstants.CELT_OK:
            raise Exception(ccelt.celt_strerror(error))

        if self._celtencoder is NULL:
            raise MemoryError()

    def __dealloc__(self):
        if self._celtencoder is not NULL:
            ccelt.celt_encoder_destroy(self._celtencoder)
        if self._celtmode is not NULL:
            ccelt.celt_mode_destroy(self._celtmode)

    def getBitstreamVersion(self):
        cdef ccelt.celt_int32 bv
        ccelt.celt_mode_info(self._celtmode, CeltConstants.CELT_GET_BITSTREAM_VERSION, &bv)
        return bv

    def setPredictionRequest(self, value):
        self.predictionRequest = value
        ccelt.celt_encoder_ctl(self._celtencoder, CeltConstants.CELT_SET_PREDICTION_REQUEST, &self.predictionRequest)

    def setVBRRate(self, value):
        self.vbrRate = value
        ccelt.celt_encoder_ctl(self._celtencoder, CeltConstants.CELT_SET_VBR_RATE_REQUEST, &self.vbrRate)

    def encode(self, pcmData):
        cdef unsigned char* pcm = <unsigned char*>pcmData
        cdef int size = len(pcmData)
        cdef unsigned char* compressed = <unsigned char*>ccelt.PyMem_Malloc(size)
        l = ccelt.celt_encode(self._celtencoder, <ccelt.celt_int16*>pcm, self.frameSize, compressed, size)
        return compressed[:l]


cdef class CeltDecoder:

    cdef ccelt.CELTMode* _celtmode
    cdef ccelt.CELTDecoder* _celtdecoder
    cdef ccelt.celt_int32 sampleRate
    cdef int frameSize
    cdef int channels

    def __cinit__(self, sampleRate, frameSize, channels):
        self.sampleRate = sampleRate
        self.frameSize = frameSize
        self.channels = channels

        self._celtmode = ccelt.celt_mode_create(sampleRate, frameSize, NULL)

        if self._celtmode is NULL:
            raise MemoryError()

        self._celtdecoder = ccelt.celt_decoder_create_custom(self._celtmode, channels, NULL)

        if self._celtdecoder is NULL:
            raise MemoryError()

    def __dealloc__(self):
        if self._celtdecoder is not NULL:
            ccelt.celt_decoder_destroy(self._celtdecoder)

    def decode(self, compressedData):
        cdef unsigned char* compressed = <unsigned char*>compressedData
        cdef int size = len(compressedData)
        cdef unsigned char* decodedFrame = <unsigned char*>ccelt.PyMem_Malloc(size)
        l = ccelt.celt_decode(self._celtdecoder, compressed, size, <ccelt.celt_int16*>decodedFrame, self.frameSize)
        return decodedFrame[:l]
