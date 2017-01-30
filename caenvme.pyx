"""
caenvme.pyx
------------------------

2013 - Christian Strandhagen (strandhagen _at_ pit.physik.uni-tuebingen.de)
"""

from exceptions import Exception
import numpy as np

cimport caenvmelib    # import definitions from caenvmelib.pxd
cimport numpy as np


def enum(**enums):
    return type('Enum', (), enums)


BoardTypes = enum(V1718=caenvmelib.cvV1718,
                  V2718=caenvmelib.cvV2718,
                  A2818=caenvmelib.cvA2818,
                  A2719=caenvmelib.cvA2719)

PulserSelect = enum(PulserA=caenvmelib.cvPulserA,
                    PulserB=caenvmelib.cvPulserB)

TimeUnits = enum(u25ns=caenvmelib.cvUnit25ns,
                 u1600ns=caenvmelib.cvUnit1600ns,
                 u410us=caenvmelib.cvUnit410us,
                 u104ms=caenvmelib.cvUnit104ms)

IOSources = enum(ManualSW=caenvmelib.cvManualSW,
                 InputSrc0=caenvmelib.cvInputSrc0,
                 InputSrc1=caenvmelib.cvInputSrc1,
                 Coincidence=caenvmelib.cvCoincidence,
                 VMESignals=caenvmelib.cvVMESignals,
                 MiscSignals=caenvmelib.cvMiscSignals)

OutputSelect = enum(Output0=caenvmelib.cvOutput0,
                    Output1=caenvmelib.cvOutput1,
                    Output2=caenvmelib.cvOutput2,
                    Output3=caenvmelib.cvOutput3,
                    Output4=caenvmelib.cvOutput4)

IOPolarity = enum(Direct=caenvmelib.cvDirect,
                  Inverted=caenvmelib.cvInverted)

LEDPolarity = enum(ActiveHigh=caenvmelib.cvActiveHigh,
                   ActiveLow=caenvmelib.cvActiveLow)

IRQLevels = enum(IRQ1=caenvmelib.cvIRQ1,
                 IRQ2=caenvmelib.cvIRQ2,
                 IRQ3=caenvmelib.cvIRQ3,
                 IRQ4=caenvmelib.cvIRQ4,
                 IRQ5=caenvmelib.cvIRQ5,
                 IRQ6=caenvmelib.cvIRQ6,
                 IRQ7=caenvmelib.cvIRQ7)


class VME_Error(Exception):
    """
    Custom Exception class to handle errors signalled by the VME library via
    errorcodes. For more information on the different errors see the CAEN
    manual.
    """
    def __init__(self, code):
        self.message = caenvmelib.CAENVME_DecodeError(code)

    def __str__(self):
        return self.message


def Init(board_type, link=0, bd_num=0):
    """
    Initialises the connection to the VME controller and returns a handle.

    Before you can communicate with the VME board this function must be
    called. The handle returned by this function, is needed for all further
    communication with this VME controller.
    """
    cdef int handle
    errorcode = caenvmelib.CAENVME_Init(board_type, link, bd_num, &handle)

    if errorcode != 0:
        raise VME_Error(errorcode)

    return handle


def SWRelease():
    """
    Returns the version number of the CAENVMElib library.
    """
    cdef char* release = ''
    errorcode = caenvmelib.CAENVME_SWRelease(release)

    if errorcode != 0:
        raise VME_Error(errorcode)

    return release


def BoardFWRelease(handle):
    """
    Returns the firmware version of the CAEN VME controller.
    """
    cdef char* release = ''
    errorcode = caenvmelib.CAENVME_BoardFWRelease(handle, release)

    if errorcode != 0:
        raise VME_Error(errorcode)

    return release


def DriverRelease(handle):
    """
    Returns the driver version of the CAEN PCI controller. 
    """
    cdef char* release = ''
    errorcode = caenvmelib.CAENVME_DriverRelease(handle, release)

    if errorcode != 0:
        raise VME_Error(errorcode)

    return release


def DeviceReset(handle):
    """
    Resets the CAEN VME controller settings to factory default.
    """
    errorcode = caenvmelib.CAENVME_DeviceReset(handle)

    if errorcode != 0:
        raise VME_Error(errorcode)


def End(handle):
    """
    Releases the VME controller specified by the handle.
    """
    errorcode = caenvmelib.CAENVME_End(handle)

    if errorcode != 0:
        raise VME_Error(errorcode)


cdef _c_SingleReadD32(handle, address):
    """
    This is just a helper function needed to translate the void* expected by
    the c function to something that python understands.
    """
    cdef int data
    errorcode = caenvmelib.CAENVME_ReadCycle(handle,
                                             address,
                                             &data,
                                             caenvmelib.cvA32_U_DATA,
                                             caenvmelib.cvD32)

    if errorcode != 0:
        raise VME_Error(errorcode)

    return data


def SingleReadD32(handle, address):
    """
    Reads a single 32bit word from the given address.
    """
    return _c_SingleReadD32(handle, address)


cdef _c_SingleReadD16(handle, address):
    """
    This is just a helper function needed to translate the void* expected by
    the c function to something that python understands.
    """
    cdef short data
    errorcode = caenvmelib.CAENVME_ReadCycle(handle,
                                             address,
                                             &data,
                                             caenvmelib.cvA32_U_DATA,
                                             caenvmelib.cvD16)
    if errorcode != 0:
        raise VME_Error(errorcode)

    return data


cdef _c_SingleReadD8(handle, address):
    """
    This is just a helper function needed to translate the void* expected by
    the c function to something that python understands.
    """
    cdef short data
    errorcode = caenvmelib.CAENVME_ReadCycle(handle,
                                             address,
                                             &data,
                                             caenvmelib.cvA32_U_DATA,
                                             caenvmelib.cvD8)
    if errorcode != 0:
        raise VME_Error(errorcode)

    return data


def BlockReadD32(handle, address, nwords):
    """
    32-bit block transfer.
    """
    cdef int transferred
    cdef np.ndarray data = np.zeros(nwords, dtype='uint32')
    size = nwords * 4  # each word has 32bit (=4 bytes)

    errorcode = caenvmelib.CAENVME_BLTReadCycle(handle,
                                                address,
                                                <void*> data.data,
                                                size,
                                                caenvmelib.cvA32_U_BLT,
                                                caenvmelib.cvD32,
                                                &transferred)

    if errorcode != 0:
        raise VME_Error(errorcode)

    if transferred != size:
        raise Exception('Size does not match')

    return data


def BlockReadD16(handle, address, nwords):
    """
    Pseudo 16-bit block transfer.
    """
    cdef int transferred
    cdef np.ndarray data = np.zeros(nwords, dtype='uint16')

    size = (nwords * 4) / 2  # transfer half the number of 32bit (=4byte) words

    errorcode = caenvmelib.CAENVME_BLTReadCycle(handle,
                                                address,
                                                <void*> data.data,
                                                size,
                                                caenvmelib.cvA32_U_BLT,
                                                caenvmelib.cvD32,
                                                &transferred)

    if errorcode != 0:
        raise VME_Error(errorcode)

    if transferred != size:
        raise Exception('Size does not match')

    return data


def SingleReadD16(handle, address):
    """
    Reads a single 16-bit word from the given address.
    """
    return _c_SingleReadD16(handle, address)


def SingleReadD8(handle, address):
    """
    Reads a single 8-bit word from the given address.
    """
    return _c_SingleReadD8(handle, address)


def SingleWriteD32(handle, address, data):
    """
    Writes a single 32-bit word (data) to the given address.
    """
    cdef int cdata = data
    errorcode = caenvmelib.CAENVME_WriteCycle(handle,
                                              address,
                                              &cdata,
                                              caenvmelib.cvA32_U_DATA,
                                              caenvmelib.cvD32)

    if errorcode != 0:
        raise VME_Error(errorcode)


def SingleWriteD16(handle, address, data):
    """
    Writes a single 16-bit word to the given address.
    """
    cdef int cdata = data
    errorcode = caenvmelib.CAENVME_WriteCycle(handle,
                                              address,
                                              &cdata,
                                              caenvmelib.cvA32_U_DATA,
                                              caenvmelib.cvD16)

    if errorcode != 0:
        raise VME_Error(errorcode)


def SingleWriteD8(handle, address, data):
    """
    Writes a single 8-bit word to the given address.
    """
    cdef int cdata = data
    errorcode = caenvmelib.CAENVME_WriteCycle(handle,
                                              address,
                                              &cdata,
                                              caenvmelib.cvA32_U_DATA,
                                              caenvmelib.cvD8)

    if errorcode != 0:
        raise VME_Error(errorcode)


def SetPulserConf(handle, pulser, period, width, time_unit,
                  n_pulses, start_signal, reset_signal):
    """
    Configures a pulser on the VME controller board.
    """
    errorcode = caenvmelib.CAENVME_SetPulserConf(handle,
                                                 pulser,
                                                 period,
                                                 width,
                                                 time_unit,
                                                 n_pulses,
                                                 start_signal,
                                                 reset_signal)

    if errorcode != 0:
        raise VME_Error(errorcode)


def SetOutputConf(handle, output_select,
                  output_polarity, led_polarity, source):
    """
    Configures an output line on the VME controller board.
    """

    errorcode = caenvmelib.CAENVME_SetOutputConf(handle,
                                                 output_select,
                                                 output_polarity,
                                                 led_polarity,
                                                 source)

    if errorcode != 0:
        raise VME_Error(errorcode)


def StartPulser(handle, pulser):
    """
    Starts pulser.
    """
    errorcode = caenvmelib.CAENVME_StartPulser(handle, pulser)

    if errorcode != 0:
        raise VME_Error(errorcode)


def StopPulser(handle, pulser):
    """
    Starts pulser.
    """
    errorcode = caenvmelib.CAENVME_StartPulser(handle, pulser)

    if errorcode != 0:
        raise VME_Error(errorcode)


def IRQEnable(handle, mask):
    errorcode = caenvmelib.CAENVME_IRQEnable(handle, mask)

    if errorcode != 0:
        raise VME_Error(errorcode)


def IRQDisable(handle, mask):
    errorcode = caenvmelib.CAENVME_IRQDisable(handle, mask)

    if errorcode != 0:
        raise VME_Error(errorcode)


def IRQWait(handle, mask, timeout):
    errorcode = caenvmelib.CAENVME_IRQWait(handle, mask, timeout)

    if errorcode != 0:
        raise VME_Error(errorcode)


def IRQCheck(handle):
    cdef unsigned char* mask = ''
    errorcode = caenvmelib.CAENVME_IRQCheck(handle, mask)

    if errorcode != 0:
        raise VME_Error(errorcode)

    return mask


cdef _c_IACKCycle(handle, irq_level):
    """
    This is just a helper function needed to translate the void* expected by
    the c function to something that python understands.
    """
    cdef unsigned char* vector = ''
    errorcode = caenvmelib.CAENVME_IACKCycle(handle,
                                             irq_level,
                                             vector,
                                             caenvmelib.cvD8)

    if errorcode != 0:
        raise VME_Error(errorcode)

    return vector


def IACKCycle(handle, irq_level):
    return _c_IACKCycle(handle, irq_level)
