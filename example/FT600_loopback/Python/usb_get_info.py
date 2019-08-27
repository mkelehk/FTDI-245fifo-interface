#coding:utf-8
# Python2.7.12 x86
# WangXuan

import sys
import ftd3xx
from struct import pack
if sys.platform == 'win32':
    import ftd3xx._ftd3xx_win32 as _ft
elif sys.platform == 'linux2':
    import ftd3xx._ftd3xx_linux as _ft

    
def DisplayChipConfiguration(cfg):
    print("Chip Configuration:")
    print("\tVendorID = %#06x" % cfg.VendorID)
    print("\tProductID = %#06x" % cfg.ProductID)
	
	
    print("\tInterruptInterval = %#04x" % cfg.bInterval)
	
    bSelfPowered = "Self-powered" if (cfg.PowerAttributes & _ft.FT_SELF_POWERED_MASK) else "Bus-powered"
    bRemoteWakeup = "Remote wakeup" if (cfg.PowerAttributes & _ft.FT_REMOTE_WAKEUP_MASK) else ""
    print("\tPowerAttributes = %#04x (%s %s)" % (cfg.PowerAttributes, bSelfPowered, bRemoteWakeup))
	
    print("\tPowerConsumption = %#04x" % cfg.PowerConsumption)
    print("\tReserved2 = %#04x" % cfg.Reserved2)

    fifoClock = ["100 MHz", "66 MHz"]	
    print("\tFIFOClock = %#04x (%s)" % (cfg.FIFOClock, fifoClock[cfg.FIFOClock]))
	
    fifoMode = ["245 Mode", "600 Mode"]
    print("\tFIFOMode = %#04x (%s)" % (cfg.FIFOMode, fifoMode[cfg.FIFOMode]))
	
    channelConfig = ["4 Channels", "2 Channels", "1 Channel", "1 OUT Pipe", "1 IN Pipe"]
    print("\tChannelConfig = %#04x (%s)" % (cfg.ChannelConfig, channelConfig[cfg.ChannelConfig]))
	
    print("\tOptionalFeatureSupport = %#06x" % cfg.OptionalFeatureSupport)
    print("\t\tBatteryChargingEnabled  : %d" % 
        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_ENABLEBATTERYCHARGING) >> 0) )
    print("\t\tDisableCancelOnUnderrun : %d" % 
        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_DISABLECANCELSESSIONUNDERRUN) >> 1) )
	
    print("\t\tNotificationEnabled     : %d %d %d %d" %
	    (((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_ENABLENOTIFICATIONMESSAGE_INCH1) >> 2),
        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_ENABLENOTIFICATIONMESSAGE_INCH2) >> 3),
        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_ENABLENOTIFICATIONMESSAGE_INCH3) >> 4),
        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_ENABLENOTIFICATIONMESSAGE_INCH4) >> 5) ))
		
    print("\t\tUnderrunEnabled         : %d %d %d %d" %
        (((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_DISABLEUNDERRUN_INCH1) >> 6),
        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_DISABLEUNDERRUN_INCH2) >> 7),
        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_DISABLEUNDERRUN_INCH3) >> 8),
        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_DISABLEUNDERRUN_INCH4) >> 9) ))
		
    print("\t\tEnableFifoInSuspend     : %d" % 
        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_SUPPORT_ENABLE_FIFO_IN_SUSPEND) >> 10) )
    print("\t\tDisableChipPowerdown    : %d" % 
        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_SUPPORT_DISABLE_CHIP_POWERDOWN) >> 11) )
    print("\tBatteryChargingGPIOConfig = %#02x" % cfg.BatteryChargingGPIOConfig)
	
    print("\tFlashEEPROMDetection = %#02x (read-only)" % cfg.FlashEEPROMDetection)
    print("\t\tCustom Config Validity  : %s" % 
        ("Invalid" if (cfg.FlashEEPROMDetection & (1<<_ft.FT_CONFIGURATION_FLASH_ROM_BIT_CUSTOMDATA_INVALID)) else "Valid") )
    print("\t\tCustom Config Checksum  : %s" % 
        ("Invalid" if (cfg.FlashEEPROMDetection & (1<<_ft.FT_CONFIGURATION_FLASH_ROM_BIT_CUSTOMDATACHKSUM_INVALID)) else "Valid") )
    print("\t\tGPIO Input              : %s" % 
        ("Used" if (cfg.FlashEEPROMDetection & (1<<_ft.FT_CONFIGURATION_FLASH_ROM_BIT_GPIO_INPUT)) else "Ignore") )
    if (cfg.FlashEEPROMDetection & (1<<_ft.FT_CONFIGURATION_FLASH_ROM_BIT_GPIO_INPUT)):
        print("\t\tGPIO 0                  : %s" % 
            ("High" if (cfg.FlashEEPROMDetection & (1<<_ft.FT_CONFIGURATION_FLASH_ROM_BIT_GPIO_0)) else "Low") )
        print("\t\tGPIO 1                  : %s" % 
            ("High" if (cfg.FlashEEPROMDetection & (1<<_ft.FT_CONFIGURATION_FLASH_ROM_BIT_GPIO_1)) else "Low") )
    print("\t\tConfig Used             : %s" % 
        ("Custom" if (cfg.FlashEEPROMDetection & (1<<_ft.FT_CONFIGURATION_FLASH_ROM_BIT_CUSTOM)) else "Default") )
		
    print("\tMSIO_Control = %#010x" % cfg.MSIO_Control)
    print("\tGPIO_Control = %#010x" % cfg.GPIO_Control)
    print("")
    

if __name__ == '__main__':
    D3XX = ftd3xx.create(0, _ft.FT_OPEN_BY_INDEX)
    if D3XX is None:
        print("ERROR: Can't find or open Device!")
        sys.exit()

    if (sys.platform == 'win32' and D3XX.getDriverVersion() < 0x01020006):
        print("ERROR: Old kernel driver version. Please update driver!")
        D3XX.close()
        sys.exit()
        
    devDesc = D3XX.getDeviceDescriptor()
    if devDesc.bcdUSB < 0x300:
        print("Warning: Device is NOT connected using USB3.0 cable or port!")

    cfg = D3XX.getChipConfiguration()
    DisplayChipConfiguration(cfg)
    
        

    D3XX.close()