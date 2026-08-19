meta:
  id: enocean
  endian: be
doc-ref: https://www.enocean.com/en/support/faq-knowledge-base/
seq:
  - id: messages
    type: esp3_message
    repeat: eos
types:
  eurid:
    seq:
      - id: address
        type: u4
    instances:
      is_broadcast:
        value: address == 0xFFFFFFFF
  esp3_message:
    seq:
      - id: sync
        type: u1
        repeat: until
        repeat-until: _ == 0x55
      - id: data_length
        type: u2
      - id: optional_data_length
        type: u1
      - id: packet_type
        type: u1
        enum: packet_types
      - id: header_crc8
        type: u1
      - id: data
        type:
          switch-on: packet_type
          cases:
            "packet_types::radio_erp1": radio_erp1_data(data_length)
            "packet_types::response": response_data(data_length)
            "packet_types::radio_sub_tel": radio_erp1_data(data_length)
            _: esp3_data(data_length)
      - id: optional_data
        type:
          switch-on: packet_type
          cases:
            "packet_types::radio_erp1": radio_erp1_optional_data(optional_data_length)
            "packet_types::radio_sub_tel": radio_sub_tel_optional_data(optional_data_length)
            _: esp3_optional_data(optional_data_length)
      - id: data_crc8
        type: u1
  esp3_data:
    params:
      - id: data_length
        type: u2
    seq:
      - id: data
        type: u1
        repeat: expr
        repeat-expr: data_length
  esp3_optional_data:
    params:
      - id: optional_data_length
        type: u1
    seq:
      - id: optional_data
        type: u1
        repeat: expr
        repeat-expr: optional_data_length
  radio_erp1_data:
    params:
      - id: data_length
        type: u2
    seq:
      - id: r_org
        type: u1
      - id: data
        # size: data_length - 6
        type: u1
        repeat: expr
        repeat-expr: data_length - 6
      - id: sender
        type: eurid
      - id: status
        type: u1
  radio_erp1_optional_data:
    params:
      - id: optional_data_length
        type: u1
    seq:
      - id: number_of_subtelegrams
        type: u1
      - id: destination
        type: eurid
      - id: signal_strength
        type: u1
      - id: security_level
        type: u1
        enum: security_levels
  response_data:
    params:
      - id: data_length
        type: u2
    seq:
      - id: code
        type: u1
        enum: response_code
      - id: data
        size: data_length - 1
  radio_sub_tel_optional_data:
    params:
      - id: optional_data_length
        type: u2
    seq:
      - id: sub_tel_num
        type: u1
        doc: Total number s of received sub-telegrams (including repeated sub-telegrams)
      - id: destination
        type: eurid
        doc: |
          Broadcast: 0xFFFFFFFF
          Addressed (ADT): Destination ID
      - id: dbm
        type: u1
        doc: |
          Send case: 0xFF
          Receive case: best RSSI value of all received subtelegrams (value decimal without minus)
      - id: security_level
        type: u1
        enum: security_levels
        doc: |
          Send Case: Will be ignored (Security is selected by link table entries)
          Receive case:
          0x00: Telegram not processed
          0x01: Obsolete (old security concept)
          0x02: Telegram decrypted
          0x03: Telegram authenticated
          0x04: Telegram decrypted + authenticated
      - id: timestamp
        type: u2
        doc: Reference timestamp of 1 st sub-telegram (using system time with 1ms increments)
      - id: sub_telegrams
        type: radio_sub_telegram
        repeat: expr
        repeat-expr: sub_tel_num
  radio_sub_telegram:
    seq:
      - id: offset
        type: u1
        doc: Relative time offset (in ms) between this sub-telegram and the 1st sub-telegram
      - id: rssi
        type: u1
        doc: RSSI value of each subtelegram
      - id: status
        type: u1
        doc: Telegram control bits of each subtelegram – used in case of repeating, switch telegram encapsulation, checksum type identification
enums:
  packet_types:
    # 0x00 --- Reserved
    0x01: radio_erp1
    0x02: response
    0x03: radio_sub_tel
    0x04: event
    0x05: common_command
    0x06: smart_ack_command
    0x07: remote_man_command
    # 0x08 --- Reserved
    0x09: radio_message
    0x0A: radio_erp2
    # 0x0B --- Reserved
    0x0C: command_accepted
    # 0x0D ... 0x0F --- Reserved
    0x10: radio_802_15_4
    0x11: radio_2_4_ghz_config
    # 0x12 ... 0xFF --- Reserved
  security_levels:
    0x00:
      id: not_processed
      doc: Telegram was not processed
    0x01:
      id: obsolete
      doc: Obsolete (old security concept)
    0x02:
      id: decrypted
      doc: Telegram was decrypted
    0x03:
      id: authenticated
      doc: Telegram was authenticated
    0x04:
      id: decrypted_and_authenticated
      doc: Telegram was decrypted + authenticated
  response_code:
    0x00:
      id: ret_ok
      doc: The request was executed
    0x01:
      id: ret_error
      doc: The request resulted in an error
    0x02:
      id: ret_not_supported
      doc: The requested functionality is not supported by this module
    0x03:
      id: ret_wrong_param
      doc: An incorrect parameter value was provided in the request
    0x04:
      id: ret_operation_denied
      doc: The requested operation is not permitted
    0x05:
      id: ret_lock_set
      doc: Duty cycle lock is active (This is temporarily preventing telegram transmission)
    0x06:
      id: ret_buffer_too_small
      doc: The provided telegram is too long for transmission
    0x07:
      id: ret_no_free_buffer
      doc: The provided telegram cannot currently be transmitted due to other telegrams still being queued up for transmission
    0x90:
      id: baseid_out_of_range
      doc: The selected BaseID range is not valid
    0x91:
      id: baseid_max_reached
      doc: The maximum number of BaseID changes has been reached
