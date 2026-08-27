const btdrv_ids = @import("btdrv_ids.zig");
const BIT = @import("../types.zig").BIT;

pub const BtdrvBluetoothPropertyType = enum(i32) {
    BtdrvBluetoothPropertyType_Name              =     1,    //< Name. String, max length 0xF8 excluding NUL-terminator.
    BtdrvBluetoothPropertyType_Address           =     2,    //< \ref BtdrvAddress
    BtdrvBluetoothPropertyType_Unknown3          =     3,    //< Only available with \ref btdrvSetAdapterProperty. Unknown, \ref BtdrvAddress.
    BtdrvBluetoothPropertyType_ClassOfDevice     =     5,    //< 3-bytes, Class of Device.
    BtdrvBluetoothPropertyType_FeatureSet        =     6,    //< 1-byte, FeatureSet. The default is value 0x68.
};

pub const BtdrvAdapterPropertyType = enum(i32) {
    BtdrvAdapterPropertyType_Address             =     0,    //< \ref BtdrvAddress
    BtdrvAdapterPropertyType_Name                =     1,    //< Name. String, max length 0xF8 excluding NUL-terminator.
    BtdrvAdapterPropertyType_ClassOfDevice       =     2,    //< 3-bytes, Class of Device.
    BtdrvAdapterPropertyType_Unknown3            =     3,    //< Only available with \ref btdrvSetAdapterProperty. Unknown, \ref BtdrvAddress.
};

pub const BtdrvEventType = enum(i32) {
    //< BtdrvEventType_* should be used on [12.0.0+]
    BtdrvEventType_InquiryDevice                 =     0,    //< Device found during Inquiry.
    BtdrvEventType_InquiryStatus                 =     1,    //< Inquiry status changed.
    BtdrvEventType_PairingPinCodeRequest         =     2,    //< Pairing PIN code request.
    BtdrvEventType_SspRequest                    =     3,    //< SSP confirm request / SSP passkey notification.
    BtdrvEventType_Connection                    =     4,    //< Connection
    BtdrvEventType_Tsi                           =     5,    //< SetTsi (\ref btdrvSetTsi)
    BtdrvEventType_BurstMode                     =     6,    //< SetBurstMode (\ref btdrvEnableBurstMode)
    BtdrvEventType_SetZeroRetransmission         =     7,    //< \ref btdrvSetZeroRetransmission
    BtdrvEventType_PendingConnections            =     8,    //< \ref btdrvGetPendingConnections
    BtdrvEventType_MoveToSecondaryPiconet        =     9,    //< \ref btdrvMoveToSecondaryPiconet
    BtdrvEventType_BluetoothCrash                =    10,    //< BluetoothCrash

    //< BtdrvEventTypeOld_* should be used on [1.0.0-11.0.1]
    BtdrvEventTypeOld_Unknown0                   =     0,    //< Unused
    BtdrvEventTypeOld_InquiryDevice              =     3,    //< Device found during Inquiry.
    BtdrvEventTypeOld_InquiryStatus              =     4,    //< Inquiry status changed.
    BtdrvEventTypeOld_PairingPinCodeRequest      =     5,    //< Pairing PIN code request.
    BtdrvEventTypeOld_SspRequest                 =     6,    //< SSP confirm request / SSP passkey notification.
    BtdrvEventTypeOld_Connection                 =     7,    //< Connection
    BtdrvEventTypeOld_BluetoothCrash             =    13,    //< BluetoothCrash
};

pub const BtdrvInquiryStatus = enum(i32) {
    BtdrvInquiryStatus_Stopped                   =     0,    //< Inquiry stopped.
    BtdrvInquiryStatus_Started                   =     1,    //< Inquiry started.
};

pub const BtdrvConnectionEventType = enum(i32) {
    BtdrvConnectionEventType_Status              =     0,   //< BtdrvEventInfo::connection::status
    BtdrvConnectionEventType_SspConfirmRequest   =     1,   //< SSP confirm request.
    BtdrvConnectionEventType_Suspended           =     2,   //< ACL Link is now Suspended.
};

pub const BtdrvExtEventType = enum(i32) {
    BtdrvExtEventType_SetTsi                     =     0,   //< SetTsi (\ref btdrvSetTsi)
    BtdrvExtEventType_ExitTsi                    =     1,   //< ExitTsi (\ref btdrvSetTsi)
    BtdrvExtEventType_SetBurstMode               =     2,   //< SetBurstMode (\ref btdrvEnableBurstMode)
    BtdrvExtEventType_ExitBurstMode              =     3,   //< ExitBurstMode (\ref btdrvEnableBurstMode)
    BtdrvExtEventType_SetZeroRetransmission      =     4,   //< \ref btdrvSetZeroRetransmission
    BtdrvExtEventType_PendingConnections         =     5,   //< \ref btdrvGetPendingConnections
    BtdrvExtEventType_MoveToSecondaryPiconet     =     6,   //< \ref btdrvMoveToSecondaryPiconet
};

pub const BtdrvBluetoothHhReportType = enum(i32) {
    //< BtdrvHidEventType_* should be used on [12.0.0+]
    BtdrvHidEventType_Connection         =    0,    //< Connection. Only used with \ref btdrvGetHidEventInfo.
    BtdrvHidEventType_Data               =    1,    //< DATA report on the Interrupt channel.
    BtdrvHidEventType_SetReport          =    2,    //< Response to SET_REPORT.
    BtdrvHidEventType_GetReport          =    3,    //< Response to GET_REPORT.

    //< BtdrvHidEventTypeOld_* should be used on [1.0.0-11.0.1]
    BtdrvHidEventTypeOld_Connection      =    0,    //< Connection. Only used with \ref btdrvGetHidEventInfo.
    BtdrvHidEventTypeOld_Data            =    4,    //< DATA report on the Interrupt channel.
    BtdrvHidEventTypeOld_Ext             =    7,    //< Response for extensions. Only used with \ref btdrvGetHidEventInfo.
    BtdrvHidEventTypeOld_SetReport       =    8,    //< Response to SET_REPORT.
    BtdrvHidEventTypeOld_GetReport       =    9,    //< Response to GET_REPORT.
};

pub const BtdrvHidConnectionStatus = enum(i32) {
    //< BtdrvHidConnectionStatus_* should be used on [12.0.0+]
    BtdrvHidConnectionStatus_Closed      =    0,
    BtdrvHidConnectionStatus_Opened      =    1,
    BtdrvHidConnectionStatus_Failed      =    2,

    //< BtdrvHidConnectionStatusOld_* should be used on [1.0.0-11.0.1]
    BtdrvHidConnectionStatusOld_Opened   =    0,
    BtdrvHidConnectionStatusOld_Closed   =    2,
    BtdrvHidConnectionStatusOld_Failed   =    8,
};

pub const BtdrvFatalReason = enum(i32) {
    BtdrvFatalReason_Invalid                =    0,    //< Only for \ref BtdrvEventInfo: invalid.
    BtdrvFatalReason_Unknown1               =    1,    //< Can only be triggered by \ref btdrvEmulateBluetoothCrash, not triggered by the sysmodule otherwise.
    BtdrvFatalReason_CommandTimeout         =    2,    //< HCI command timeout.
    BtdrvFatalReason_HardwareError          =    3,    //< HCI event HCI_Hardware_Error occurred.
    BtdrvFatalReason_Enable                 =    7,    //< Only for \ref BtdrvEventInfo: triggered after enabling bluetooth, depending on the value of a global state field.
    BtdrvFatalReason_Audio                  =    9,    //< [12.0.0+] Only for \ref BtdrvEventInfo: triggered by Audio cmds in some cases.
};

pub const BtdrvBleEventType = enum(i32) {
    BtdrvBleEventType_ClientRegistration            =    0,    //< GATT client registration.
    BtdrvBleEventType_ServerRegistration            =    1,    //< GATT server registration.
    BtdrvBleEventType_ConnectionUpdate              =    2,    //< Connection update.
    BtdrvBleEventType_PreferredConnectionParameters =    3,    //< Preferred connection parameters.
    BtdrvBleEventType_ClientConnection              =    4,    //< GATT client connection.
    BtdrvBleEventType_ServerConnection              =    5,    //< GATT server connection.
    BtdrvBleEventType_ScanResult                    =    6,    //< Scan result.
    BtdrvBleEventType_ScanFilter                    =    7,    //< Scan filter status.
    BtdrvBleEventType_ClientNotify                  =    8,    //< GATT client notify.
    BtdrvBleEventType_ClientCacheSave               =    9,    //< GATT client cache save.
    BtdrvBleEventType_ClientCacheLoad               =   10,    //< GATT client cache load.
    BtdrvBleEventType_ClientConfigureMtu            =   11,    //< GATT client configure MTU.
    BtdrvBleEventType_ServerAddAttribute            =   12,    //< GATT server add attribute.
    BtdrvBleEventType_ServerAttributeOperation      =   13,    //< GATT server attribute operation.
};

pub const BtdrvGattAttributeType = enum(i32) {
    BtdrvGattAttributeType_IncludedService  =    0,    //< Included service
    BtdrvGattAttributeType_Characteristic   =    1,    //< Characteristic
    BtdrvGattAttributeType_Descriptor       =    2,    //< Descriptor
    BtdrvGattAttributeType_Service          =    3,    //< Service
};

pub const BtdrvGattAttributePermission = enum(i32) {
    BtdrvGattAttributePermission_Read                    = BIT(0),
    BtdrvGattAttributePermission_ReadEncrypted           = BIT(1),
    BtdrvGattAttributePermission_ReadEncryptedMitm       = BIT(2),
    BtdrvGattAttributePermission_Write                   = BIT(4),
    BtdrvGattAttributePermission_WriteEncrypted          = BIT(5),
    BtdrvGattAttributePermission_WriteEncryptedMitm      = BIT(6),
    BtdrvGattAttributePermission_WriteSigned             = BIT(7),
    BtdrvGattAttributePermission_WriteSignedMitm         = BIT(8),

    BtdrvGattAttributePermission_ReadAllowed             = btdrv_ids.BtdrvGattAttributePermission_Read | btdrv_ids.BtdrvGattAttributePermission_ReadEncrypted | btdrv_ids.BtdrvGattAttributePermission_ReadEncryptedMitm,
    BtdrvGattAttributePermission_ReadAuthRequired        = btdrv_ids.BtdrvGattAttributePermission_ReadEncrypted,
    BtdrvGattAttributePermission_ReadMitmRequired        = btdrv_ids.BtdrvGattAttributePermission_ReadEncryptedMitm,
    BtdrvGattAttributePermission_ReadEncryptedRequired   = btdrv_ids.BtdrvGattAttributePermission_ReadEncrypted | btdrv_ids.BtdrvGattAttributePermission_ReadEncryptedMitm,

    BtdrvGattAttributePermission_WriteAllowed            = btdrv_ids.BtdrvGattAttributePermission_Write | btdrv_ids.BtdrvGattAttributePermission_WriteEncrypted | btdrv_ids.BtdrvGattAttributePermission_WriteEncryptedMitm | btdrv_ids.BtdrvGattAttributePermission_WriteSigned | btdrv_ids.BtdrvGattAttributePermission_WriteSignedMitm,
    BtdrvGattAttributePermission_WriteAuthRequired       = btdrv_ids.BtdrvGattAttributePermission_WriteEncrypted | btdrv_ids.BtdrvGattAttributePermission_WriteSigned,
    BtdrvGattAttributePermission_WriteMitmRequired       = btdrv_ids.BtdrvGattAttributePermission_WriteEncryptedMitm | btdrv_ids.BtdrvGattAttributePermission_WriteSignedMitm,
    BtdrvGattAttributePermission_WriteEncryptedRequired  = btdrv_ids.BtdrvGattAttributePermission_WriteEncrypted | btdrv_ids.BtdrvGattAttributePermission_WriteEncryptedMitm,
    BtdrvGattAttributePermission_WriteSignedRequired     = btdrv_ids.BtdrvGattAttributePermission_WriteSigned | btdrv_ids.BtdrvGattAttributePermission_WriteSignedMitm,
};

pub const BtdrvGattCharacteristicProperty = enum(i32) {
    BtdrvGattCharacteristicProperty_Broadcast            = BIT(0),
    BtdrvGattCharacteristicProperty_Read                 = BIT(1),
    BtdrvGattCharacteristicProperty_WriteNoResponse      = BIT(2),
    BtdrvGattCharacteristicProperty_Write                = BIT(3),
    BtdrvGattCharacteristicProperty_Notify               = BIT(4),
    BtdrvGattCharacteristicProperty_Indicate             = BIT(5),
    BtdrvGattCharacteristicProperty_Authentication       = BIT(6),
    BtdrvGattCharacteristicProperty_ExtendedProperties   = BIT(7),
};

pub const BtdrvGattAuthReqType = enum(i32) {
    BtdrvGattAuthReqType_None           =    0,
    BtdrvGattAuthReqType_NoMitm         =    1,
    BtdrvGattAuthReqType_Mitm           =    2,
    BtdrvGattAuthReqType_SignedNoMitm   =    3,
    BtdrvGattAuthReqType_SignedMitm     =    4,
};

pub const BtdrvBleAdBit = enum(i32) {
    BtdrvBleAdBit_DeviceName    =  BIT(0),
    BtdrvBleAdBit_Flags         =  BIT(1),
    BtdrvBleAdBit_Manufacturer  =  BIT(2),
    BtdrvBleAdBit_TxPower       =  BIT(3),
    BtdrvBleAdBit_Service32     =  BIT(4),
    BtdrvBleAdBit_IntRange      =  BIT(5),
    BtdrvBleAdBit_Service       =  BIT(6),
    BtdrvBleAdBit_ServiceSol    =  BIT(7),
    BtdrvBleAdBit_ServiceData   =  BIT(8),
    BtdrvBleAdBit_SignData      =  BIT(9),
    BtdrvBleAdBit_Service128Sol = BIT(10),
    BtdrvBleAdBit_Appearance    = BIT(11),
    BtdrvBleAdBit_PublicAddress = BIT(12),
    BtdrvBleAdBit_RandomAddress = BIT(13),
    BtdrvBleAdBit_Service32Sol  = BIT(14),
    BtdrvBleAdBit_Proprietary   = BIT(15),
    BtdrvBleAdBit_Service128    = BIT(16),
};

pub const BtdrvBleAdFlag = enum(i32) {
    BtdrvBleAdFlag_None                         = 0,
    BtdrvBleAdFlag_LimitedDiscovery             = BIT(0),
    BtdrvBleAdFlag_GeneralDiscovery             = BIT(1),
    BtdrvBleAdFlag_BrEdrNotSupported            = BIT(2),
    BtdrvBleAdFlag_DualModeControllerSupport    = BIT(3),
    BtdrvBleAdFlag_DualModeHostSupport          = BIT(4),
};

pub const BtdrvAudioEventType = enum(i32) {
    BtdrvAudioEventType_None                =     0,   //< None
    BtdrvAudioEventType_Connection          =     1,   //< Connection
};

pub const BtdrvAudioOutState = enum(i32) {
    BtdrvAudioOutState_Stopped              =     0,   //< Stopped
    BtdrvAudioOutState_Started              =     1,   //< Started
};

pub const BtdrvAudioCodec = enum(i32) {
    BtdrvAudioCodec_Pcm                     =     0,   //< Raw PCM
};

pub const BtdrvAddress = extern struct {
    addrs: [0x6]u8
};

pub const BtdrvClassOfDevice = extern struct {
    class_of_dev: [0x3]u8
};

pub const BtdrvAdapterPropertyOld = extern struct {
    addr:   BtdrvAddress,
    class:  BtdrvClassOfDevice,
    name:   [0xF9]i8,
    feature: u8
};

pub const BtdrvAdapterProperty = extern struct {
    __type:      u8,
    size:        u8,
    data: [0x100]u8
};

pub const BtdrvAdapterPropertySet = extern struct {
    addr:   BtdrvAddress,
    class:  BtdrvClassOfDevice,
    name:   [0xF9]u8
};

pub const BtdrvBluetoothPinCode = extern struct {
    code: [0x10]i8
};

pub const BtdrvPinCode = extern struct {
    code: [0x10]i8,
    len:  u8
};

pub const BtdrvHidData = extern struct {
    size: u16,
    data: [0x280]u8
};

pub const BtdrvHidReport = extern struct {
    size: u16,
    data: [0x2BC]u8
};

pub const BtdrvPlrStatistics = extern struct {
    unk_x0: [0x84]u8
};

pub const BtdrvPlrList = extern struct {
    unk_x0: [0xA4]u8
};

pub const BtdrvChannelMapList = extern struct {
    unk_x0: [0x88]u8
};

pub const BtdrvGattAttributeUuid = extern struct {
    size: u32,
    uuid: u8
};

pub const BtdrvGattId = extern struct {
    instance:   u8,
    pad:        [3]u8,
    uuid:       BtdrvGattAttributeUuid
};

pub const BtdrvGattAttribute = extern struct {
    id:         BtdrvGattId,
    __type:     u16,
    handle:     u16,
    group:      u16,
    property:   u8,
    primary:    bool
};

pub const BtdrvLeConnectionParams = extern struct {
    addr:           BtdrvAddress,
    min_interval:   u16,
    max_internal:   u16,
    min_len:        u16,
    max_len:        u16,
    slave_lat:      u16,
    supervision:    u16,
    preference:     u8,
    pad:            u8
};

pub const BtdrvBleConnectionParameter = extern struct {
    min_interval:   u16,
    max_interval:   u16,
    min_len:        u16,
    max_len:        u16,
    supervision:    u16
};

pub const BtdrvBleAdvertisePacketData = extern struct {
    adv_data_mask:      u32,                            //< Bitmask of following AD data to be included in advertising packets \ref BtdrvBleAdBit
    flag:               u8,                             //< AD flag value to be advertised \ref BtdrvBleAdFlag. Included with BtdrvBleAdBit_Flags
    manu_data_len:      u8,                             //< Size of manu_data below
    manu_data:          [0x1F]u8,                       //< Manufacturer-specific data to be advertised. Included with BtdrvBleAdBit_Manufacturer
    pad:                [1]u8,                          //< Padding
    appearance_data:    u16,                             //< Device appearance data to be advertised \ref BtdrvAppearanceType. Included with BtdrvBleAdBit_Appearance
    num_service:        u8,                              //< Number of services in uuid_val array below
    pad2:               [3]u8,                           //< Padding
    uuid_val:           [0x6]BtdrvGattAttributeUuid,    //< Array of 16-bit UUIDs to be advertised \ref BtdrvGattAttributeUuid. Included with BtdrvBleAdBit_Service
    service_data_len:   u8,                              //< Size of service_data below
    pad3:               [1]u8,                          //< Padding
    service_data_uuid:  u16,                            //< 16-bit UUID of service_data below
    service_data:       [0x1F]u8,                       //< Service data to be advertised. Included with BtdrvBleAdBit_ServiceData
    is_scan_rsp:        bool,                           //< Whether this is an inquiry scan response or advertising data
    tx_power:           u8,                             //< Inquiry transmit power to be advertised. Included with BtdrvBleAdBit_TxPower
    pad4:               [3]u8,                          //< Padding
};

pub const BtdrvBleAdvertisement = extern struct {
    size:   u8,
    __type: u8,
    data:   [0x1D]u8
};

pub const BtdrvBleAdvertiseFilter = extern struct {
    index:      u8,
    adv:        BtdrvBleAdvertisement,
    mask:       [0x1D]u8,
    mas_size:   u8
};

pub const BtdrvBleAdvertisePacketParameter = extern struct {
    company_id:    u16,
    pattern_data:  [6]u8
};

pub const BtdrvBleScanResult = extern struct {
    unk_x0:   u8,
    addr:     BtdrvAddress,
    unk_x7:   [0x139]u8,
    count:    i32,
    unk_x144: i32
};

pub const BtdrvBleConnectionInfo = extern struct {
    connection_handle:  u32,
    addr:               BtdrvAddress,
    pad:                [2]u8,
};

pub const BtdrvLeEventInfo = extern struct {
    unk_x0:         u32,
    unk_x4:         u32,
    unk_x8:         u8,
    pad:            [3]u8,
    uuid0:          BtdrvGattAttributeUuid,
    uuid1:          BtdrvGattAttributeUuid,
    uuid2:          BtdrvGattAttributeUuid,
    size:           u16,
    data:           [0x3B6]u8,
};

pub const BtdrvBleClientGattOperationInfo = extern struct {
    unk_x0:         u8,
    pad:            [3]u8,
    unk_x4:         u32,
    unk_x8:         u8,
    pad2:           [3]u8,
    uuid0:          BtdrvGattAttributeUuid,
    uuid1:          BtdrvGattAttributeUuid,
    uuid2:          BtdrvGattAttributeUuid,
    size:           u64,
    data:           [0x200]u8
};

pub const BtdrvPcmParameter = extern struct {
    unk_x0:             u32,
    sample_rate:        i32,
    bits_per_sample:    u32,
};

pub const BtdrvAudioControlButtonState = extern struct {
    unk_x0:  [0x10]u8,
};