# UART Receiver VHDL Implementation (uart_rx_fsm.vhd, uart_rx.vhd)

This project implements a standard **UART Receiver** (RX) component in VHDL. It is designed to receive serial data and convert it into 8-bit parallel output with a validity pulse.

## 🏗 Architecture

The receiver is divided into two main modules:

1.  **UART_RX_FSM**: A Finite State Machine that manages the synchronization and timing of the UART protocol (Start bit detection, data sampling, and stop bit validation).
2.  **UART_RX**: The top-level entity that implements the data path, including bit counters, clock cycle counters, and the shift register for incoming data.


## 🛠 Protocol Specifications
* **Data Bits**: 8 bits
* **Stop Bits**: 1 bit
* **Parity**: None
* **Sampling**: The receiver uses a clock cycle counter to sample bits in the middle of their duration for maximum reliability.

## 🚦 FSM States
* `IDLE`: Waiting for a falling edge on the `DIN` line.
* `WAITING_FOR_FIRST_BIT`: Aligning the timing to the center of the start bit.
* `READING_DATA`: Progressively sampling 8 bits of data.
* `WAITING_FOR_STOP_BIT`: Ensuring the line returns to high (idle) state.

## 💻 Interface
### Inputs
* `CLK`: System clock.
* `RST`: Synchronous reset.
* `DIN`: Serial data input.

### Outputs
* `DOUT`: 8-bit parallel data output.
* `DOUT_VLD`: High for one cycle when `DOUT` contains valid data.

## 📝 Usage
Integrate the `UART_RX` entity into your design. Ensure that the clock frequency matches the timing constants defined in the FSM (`CLK_CYCLE_CNT`) based on your desired baud rate.
