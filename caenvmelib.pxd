"""
caenvmelib.pxd
------------------------

2013 - Christian Strandhagen (strandhagen _at_ pit.physik.uni-tuebingen.de)
"""

"""
In this section type definitions from the CAENVMEtypes header are repeated, so
they can be used by python.
"""
cdef extern from "/local/scratch0/astro/VME_lib/CAENVMEtypes.h":
    ctypedef CVErrorCodes CAENVME_API

    enum CVBoardTypes:
        cvV1718
        cvV2718
        cvA2818
        cvA2719
        
    enum CVErrorCodes:
        cvSuccess
        cvBusError
        cvCommError
        cvGenericError
        cvInvalidParam
        cvTimeoutError
    
    enum CVAddressModifier:
        cvA16_S
        cvA16_U
        cvA16_LCK
        cvA24_S_BLT
        cvA24_S_PGM
        cvA24_S_DATA
        cvA24_S_MBLT
        cvA24_U_BLT
        cvA24_U_PGM
        cvA24_U_DATA
        cvA24_U_MBLT
        cvA24_LCK
        cvA32_S_BLT
        cvA32_S_PGM
        cvA32_S_DATA
        cvA32_S_MBLT
        cvA32_U_BLT
        cvA32_U_PGM
        cvA32_U_DATA
        cvA32_U_MBLT
        cvA32_LCK
        cvCR_CSR
    
    enum CVDataWidth:
        cvD8
        cvD16
        cvD32
        cvD64
        cvD16
        cvD32
        cvD64
    
    enum CVPulserSelect:
        cvPulserA
        cvPulserB
    
    enum CVTimeUnits:
        cvUnit25ns
        cvUnit1600ns
        cvUnit410us
        cvUnit104ms
    
    enum CVIOSources:
        cvManualSW
        cvInputSrc0
        cvInputSrc1
        cvCoincidence
        cvVMESignals
        cvMiscSignals
    
    enum CVOutputSelect:
        cvOutput0
        cvOutput1
        cvOutput2
        cvOutput3
        cvOutput4
    
    enum CVIOPolarity:
        cvDirect
        cvInverted
    
    enum CVLEDPolarity:
        cvActiveHigh
        cvActiveLow
    
    enum CVIRQLevels:
        cvIRQ1
        cvIRQ2
        cvIRQ3
        cvIRQ4
        cvIRQ5
        cvIRQ6
        cvIRQ7


"""
In this section the functions from CAENVMElib which should be callable from 
python are declared. Note that some variable types are different (e.g. int 
instead of uint32_t, ...)
"""
cdef extern from "/local/scratch0/astro/VME_lib/CAENVMElib.h":
    const char * CAENVME_DecodeError(CVErrorCodes Code)
    CAENVME_API CAENVME_Init(CVBoardTypes BdType, short Link, 
                                                 short BdNum, int *Handle)
                                                 
    CAENVME_API CAENVME_SWRelease(char *SwRel)
    CAENVME_API CAENVME_BoardFWRelease(int Handle, char *FWRel)
    CAENVME_API CAENVME_DriverRelease(int Handle, char *Rel)
    CAENVME_API CAENVME_DeviceReset(int Handle)
    CAENVME_API CAENVME_End(int Handle)
    CAENVME_API CAENVME_ReadCycle(int Handle, 
                                                           int Address, 
                                                           void *Data,
                                                           CVAddressModifier AM, 
                                                           CVDataWidth DW)
                                                           
    CAENVME_API CAENVME_WriteCycle(int Handle, 
                                                           int Address, 
                                                           void *Data,
                                                           CVAddressModifier AM, 
                                                           CVDataWidth DW)
                                                           
    CAENVME_API CAENVME_BLTReadCycle(int Handle, 
                                                                int Address, 
                                                                void *Buffer,
                                                                int Size, 
                                                                CVAddressModifier AM, 
                                                                CVDataWidth DW, 
                                                                int *count)
                                                                
    CAENVME_API CAENVME_SetPulserConf(int Handle, CVPulserSelect PulSel,
                                                                int Period, int Width, 
                                                                CVTimeUnits Unit, 
                                                                int PulseNo, CVIOSources Start, 
                                                                CVIOSources Reset)
                                                                
    CAENVME_API CAENVME_SetOutputConf(int Handle, CVOutputSelect OutSel, 
                                                                  CVIOPolarity OutPol, 
                                                                  CVLEDPolarity LEDPol, 
                                                                  CVIOSources Source)
                                                                  
    CAENVME_API CAENVME_StartPulser(int Handle, CVPulserSelect PulSel)
    CAENVME_API CAENVME_StopPulser(int Handle, CVPulserSelect PulSel)
    CAENVME_API CAENVME_IRQEnable(int Handle, int mask)
    CAENVME_API CAENVME_IRQDisable(int Handle, int mask)
    CAENVME_API CAENVME_IRQWait(int Handle, int mask, int timeout)
    CAENVME_API CAENVME_IRQCheck(int Handle, unsigned char *mask)
    CAENVME_API CAENVME_IACKCycle(int Handle, CVIRQLevels Level, 
                                                          void *vector, CVDataWidth DW)
                                                                                                                                                                                        
                                                                                                                                                                                        
