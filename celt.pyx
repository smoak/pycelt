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
        self.sampleRate = sampleRate
        self.frameSize = frameSize
        self.channels = channels
        cdef int* error

        # create the mode
        self._celtmode = ccelt.celt_mode_create(sampleRate, frameSize, error)
        if error[0] != CeltConstants.CELT_OK:
            raise Exception(ccelt.celt_strerror(error[0]))

        if self._celtmode is NULL:
            raise MemoryError()

        # create the encoder using the mode
        self._celtencoder = ccelt.celt_encoder_create_custom(self._celtmode, channels, error)

        if error[0] != CeltConstants.CELT_OK:
            raise Exception(ccelt.celt_strerror(error[0]))

        if self._celtencoder is NULL:
            raise MemoryError()

    def __dealloc__(self):
        if self._celtencoder is not NULL:
            ccelt.celt_encoder_destroy(self._celtencoder)
        if self._celtmode is not NULL:
            ccelt.celt_mode_destroy(self._celtmode)

    def getBitstreamVersion(self):
        cdef ccelt.celt_int32 *bv
        ccelt.celt_mode_info(self._celtmode, CeltConstants.CELT_GET_BITSTREAM_VERSION, bv)
        return bv[0]

    def setPredictionRequest(self, value):
        self.predictionRequest = value
        cdef int v = <int>value
        ccelt.celt_encoder_ctl(self._celtencoder, CeltConstants.CELT_SET_PREDICTION_REQUEST, &v)

    def setVBRRate(self, value):
        self.vbrRate = value
        cdef int v = <int>value
        ccelt.celt_encoder_ctl(self._celtencoder, CeltConstants.CELT_SET_VBR_RATE_REQUEST, &v)

    def encode(self, pcmData, size):
        cdef unsigned char* pcm = <unsigned char*>pcmData
        # nbCompressedBytes Maximum number of bytes to use for compressing the frame
        # The number of bytes written to compressed will be the same as 
        # "nbCompressedBytes" unless the stream is VBR and will never be larger.
        cdef unsigned char* compressed = <unsigned char*>ccelt.PyMem_Malloc(size)
        len = ccelt.celt_encode(self._celtencoder, <ccelt.celt_int16*>pcm, self.frameSize, compressed, size)
        return compressed[len:]


#cdef class CeltDecoder:

 #   cdef ccelt.CELTMode* _celtmode
  #  cdef ccelt.CELTDecoder* _celtdecoder

   # def __cinit__(self, sampleRate, frameSize, channels):
    #    pass
#        self._celtmode = ccelt.celt_mode_create(sampleRate, frameSize, NULL)
#        if self._celtmode is NULL:
#            raise MemoryError()
#        self._celtdecoder = ccelt.celt_decoder_create_custom(self._celtmode, channels, NULL)
 #       if self._celtdecoder is NULL:
  #          raise MemoryError()

#    def __dealloc__(self):
 #       if self._celtdecoder is not NULL:
  #          ccelt.celt_decoder_destroy(self._celtdecoder)
