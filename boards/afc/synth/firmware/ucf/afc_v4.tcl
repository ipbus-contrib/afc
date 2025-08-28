#-------------------------------------------------------------------------------
#
#   Copyright 2017 - Rutherford Appleton Laboratory and University of Bristol
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#                                     - - -
#
#   Additional information about ipbus-firmare and the list of ipbus-firmware
#   contacts are available at
#
#       https://ipbus.web.cern.ch/ipbus
#
#-------------------------------------------------------------------------------



set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# Ethernet RefClk (125MHz)
create_clock -period 8.000 -name eth_refclk [get_ports eth_clk_p]

# Ethernet monitor clock hack (62.5MHz)
create_clock -period 16.000 -name clk_dc [get_pins infra/eth/dc_buf/O]

# This is MGTREFCLK0P_113
set_property PACKAGE_PIN AG14 [get_ports eth_clk_p]
set_property PACKAGE_PIN AH14 [get_ports eth_clk_n]
# MGTREFCLK0P_213
#set_property PACKAGE_PIN AG20 [get_ports eth_clk_p]
#set_property PACKAGE_PIN AH20 [get_ports eth_clk_n]

set_property PACKAGE_PIN AJ15 [get_ports eth_rx_p]
set_property PACKAGE_PIN AK15 [get_ports eth_rx_n]

set_property PACKAGE_PIN AL14 [get_ports eth_tx_p]
set_property PACKAGE_PIN AM14 [get_ports eth_tx_n]

# UART pins (not always used). Unfortunately can either be 2V5 or 3V3. 
# Depends on what VAUX is set to.
if { [llength [get_ports {FTDI_RXD}]] > 0} {
    set_property IOSTANDARD LVCMOS25 [get_port {FTDI_RXD FTDI_TXD}]
    set_property PACKAGE_PIN AG29 [get_port {FTDI_RXD}] ; # Data to FT4232 *from* FPGA
    set_property PACKAGE_PIN AG30 [get_port {FTDI_TXD}] ; # Data from FT4232 *to* FPGA

    
}

# Auxillary UART
# UART pins (not always used). Unfortunately can either be 2V5 or 3V3. 
# Depends on what VAUX is set to.
if { [llength [get_ports {FTDI_AUX_RXD}]] > 0} {
    set_property IOSTANDARD LVCMOS25 [get_port {FTDI_AUX_RXD FTDI_AUX_TXD}]
    set_property PACKAGE_PIN AH29 [get_port {FTDI_AUX_RXD}] ; # Data to FT4232 *from* FPGA
    set_property PACKAGE_PIN AH28 [get_port {FTDI_AUX_TXD}] ; # Data from FT4232 *to* FPGA

    # Auxillary UART
}

# I2C switch reset* signal ( connected to IC62 ) 
set_property PACKAGE_PIN AD31 [get_ports fpga_i2c_reset_n ] 
set_property IOSTANDARD LVCMOS25 [get_port {fpga_i2c_reset_n}]

# Free running 125MHz oscillator
create_clock -period 8.000 -name osc_clk [get_ports osc_clk_p]
set_property IOSTANDARD LVDS_25 [get_port {osc_clk_*}]
set_property DIFF_TERM TRUE [get_port {osc_clk_*}]
set_property PACKAGE_PIN AK7 [get_ports osc_clk_p]
set_property PACKAGE_PIN AL7 [get_ports osc_clk_n]

# Clocks derived from system clock
create_generated_clock -name ipbus_clk -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT1]
create_generated_clock -name clk_aux -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT2]
create_generated_clock -name clk_200 -source [get_pins infra/clocks/mmcm/CLKIN1] [get_pins infra/clocks/mmcm/CLKOUT3]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks eth_refclk] -group [get_clocks -include_generated_clocks clk_aux] -group [get_clocks -include_generated_clocks osc_clk] -group [get_clocks -include_generated_clocks ipbus_clk] -group [get_clocks -include_generated_clocks [get_clocks -filter {name =~ infra/eth/phy/*/RXOUTCLK}]] -group [get_clocks -include_generated_clocks [get_clocks -filter {name =~ infra/eth/phy/*/TXOUTCLK}]]
