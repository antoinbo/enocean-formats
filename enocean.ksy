meta:
  id: enocean
  endian: be
doc-ref: https://www.enocean.com/en/support/faq-knowledge-base/
seq:
  - id: messages
    type: esp3_message
    repeat: eos
types:
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
        type: u1
        repeat: expr
        repeat-expr: data_length
      - id: optional_data
        type: u1
        repeat: expr
        repeat-expr: optional_data_length
      - id: data_crc8
        type: u1
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
