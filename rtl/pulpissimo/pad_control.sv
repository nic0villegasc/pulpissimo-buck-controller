// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`define SPI_STD_TX  2'b00
`define SPI_STD_RX  2'b01
`define SPI_QUAD_TX 2'b10
`define SPI_QUAD_RX 2'b11

module pad_control #(
    parameter int unsigned N_UART = 1,
    parameter int unsigned N_SPI = 1,
    parameter int unsigned N_I2C = 1
) (

        //********************************************************************//
        //*** PERIPHERALS SIGNALS ********************************************//
        //********************************************************************//

        // PAD CONTROL REGISTER
        input  logic [63:0][1:0] pad_mux_i            ,
        input  logic [63:0][5:0] pad_cfg_i            ,
        output logic [47:0][5:0] pad_cfg_o            ,

        // GPIOS
        input  logic [31:0]      gpio_out_i           ,
        output logic [31:0]      gpio_in_o            ,
        input  logic [31:0]      gpio_dir_i           ,
        input  logic [31:0][5:0] gpio_cfg_i           ,

        // UART
        input  logic             uart_tx_i            ,
        output logic             uart_rx_o            ,

        // I2C
        input  logic [N_I2C-1:0] i2c_scl_out_i,
        output logic [N_I2C-1:0] i2c_scl_in_o,
        input  logic [N_I2C-1:0] i2c_scl_oe_i,
        input  logic [N_I2C-1:0] i2c_sda_out_i,
        output logic [N_I2C-1:0] i2c_sda_in_o,
        input  logic [N_I2C-1:0] i2c_sda_oe_i,

        // SPI MASTER
        input  logic [N_SPI-1:0]      spi_clk_i,
        input  logic [N_SPI-1:0][3:0] spi_csn_i,
        input  logic [N_SPI-1:0][3:0] spi_oen_i,
        input  logic [N_SPI-1:0][3:0] spi_sdo_i,
        output logic [N_SPI-1:0][3:0] spi_sdi_o,

        // TIMER
        input  logic [3:0]       timer0_i             ,
        input  logic [3:0]       timer1_i             ,
        input  logic [3:0]       timer2_i             ,
        input  logic [3:0]       timer3_i             ,

        //********************************************************************//
        //*** PAD FRAME SIGNALS **********************************************//
        //********************************************************************//

        // PADS OUTPUTS
        output logic             out_spim_sdio0_o ,
        output logic             out_spim_sdio1_o ,
        output logic             out_spim_sdio2_o ,
        output logic             out_spim_sdio3_o ,
        output logic             out_spim_csn0_o  ,
        output logic             out_spim_sck_o   ,

        // PAD INPUTS
        input logic              in_spim_sdio0_i  ,
        input logic              in_spim_sdio1_i  ,
        input logic              in_spim_sdio2_i  ,
        input logic              in_spim_sdio3_i  ,
        input logic              in_spim_csn0_i   ,
        input logic              in_spim_sck_i    ,

        // OUTPUT ENABLE
        output logic             oe_spim_sdio0_o  ,
        output logic             oe_spim_sdio1_o  ,
        output logic             oe_spim_sdio2_o  ,
        output logic             oe_spim_sdio3_o  ,
        output logic             oe_spim_csn0_o   ,
        output logic             oe_spim_sck_o
    );


   logic s_alt0,s_alt1,s_alt2,s_alt3;

   // check invariants
   if (N_SPI  <  1 || N_SPI  >  2) $error("The current verion of Pad control supports only 1 or 2 SPI peripherals");
   if (N_I2C  != 2) $error("The current version of Pad control only supports exactly 2 I2C peripherals");
   if (N_UART != 1) $error("The current version of Pad control only supports exactly 1 UART peripherals");

   // DEFINE DEFAULT FOR NOT USED ALTERNATIVES
   assign s_alt0 = 1'b0;
   assign s_alt1 = 1'b0;
   assign s_alt2 = 1'b0;
   assign s_alt3 = 1'b0;

   /////////////////////////////////////////////////////////////////////////////////////////////
   // OUTPUT ENABLE
   /////////////////////////////////////////////////////////////////////////////////////////////
   assign oe_spim_sdio0_o  = (pad_mux_i[0 ] == 2'b00) ? ~spi_oen_i[0][0]    : ((pad_mux_i[0 ] == 2'b01) ? i2c_sda_oe_i[0] : ((pad_mux_i[0 ] == 2'b10) ? 1'b1 : s_alt3 ));
   assign oe_spim_sdio1_o  = (pad_mux_i[1 ] == 2'b00) ? ~spi_oen_i[0][1]    : ((pad_mux_i[1 ] == 2'b01) ? i2c_scl_oe_i[0] : ((pad_mux_i[1 ] == 2'b10) ? 1'b1 : s_alt3 ));
   assign oe_spim_sdio2_o  = (pad_mux_i[2 ] == 2'b00) ? ~spi_oen_i[0][2]    : ((pad_mux_i[2 ] == 2'b01) ? 1'b1            : ((pad_mux_i[2 ] == 2'b10) ? 1'b1 : s_alt3 ));
   assign oe_spim_sdio3_o  = (pad_mux_i[3 ] == 2'b00) ? ~spi_oen_i[0][3]    : ((pad_mux_i[3 ] == 2'b01) ? 1'b0            : ((pad_mux_i[3 ] == 2'b10) ? 1'b1 : s_alt3 ));
   assign oe_spim_sck_o    = (pad_mux_i[4 ] == 2'b00) ? 1'b1                : ((pad_mux_i[4 ] == 2'b01) ? gpio_dir_i[0]   : ((pad_mux_i[4 ] == 2'b10) ? 1'b1 : s_alt3 ));
   assign oe_spim_csn0_o   = (pad_mux_i[5 ] == 2'b00) ? 1'b1                : ((pad_mux_i[5 ] == 2'b01) ? gpio_dir_i[1]   : ((pad_mux_i[5 ] == 2'b10) ? 1'b1 : s_alt3 ));

   /////////////////////////////////////////////////////////////////////////////////////////////
   // DATA OUTPUT
   /////////////////////////////////////////////////////////////////////////////////////////////
   assign out_spim_sdio0_o    = (pad_mux_i[0 ] == 2'b00) ? spi_sdo_i[0][0]    : ((pad_mux_i[0 ] == 2'b01) ? i2c_sda_out_i[0] : ((pad_mux_i[0 ] == 2'b10) ? timer1_i[0] : s_alt3 ));
   assign out_spim_sdio1_o    = (pad_mux_i[1 ] == 2'b00) ? spi_sdo_i[0][1]    : ((pad_mux_i[1 ] == 2'b01) ? i2c_scl_out_i[0] : ((pad_mux_i[1 ] == 2'b10) ? timer1_i[1] : s_alt3 ));
   assign out_spim_sdio2_o    = (pad_mux_i[2 ] == 2'b00) ? spi_sdo_i[0][2]    : ((pad_mux_i[2 ] == 2'b01) ? uart_tx_i        : ((pad_mux_i[2 ] == 2'b10) ? timer1_i[2] : s_alt3 ));
   assign out_spim_sdio3_o    = (pad_mux_i[3 ] == 2'b00) ? spi_sdo_i[0][3]    : ((pad_mux_i[3 ] == 2'b01) ? 1'b0             : ((pad_mux_i[3 ] == 2'b10) ? timer2_i[0] : s_alt3 ));
   assign out_spim_sck_o      = (pad_mux_i[4 ] == 2'b00) ? spi_clk_i[0]       : ((pad_mux_i[4 ] == 2'b01) ? gpio_out_i[0 ]   : ((pad_mux_i[4 ] == 2'b10) ? timer2_i[1] : s_alt3 ));
   assign out_spim_csn0_o     = (pad_mux_i[5 ] == 2'b00) ? spi_csn_i[0][0]    : ((pad_mux_i[5 ] == 2'b01) ? gpio_out_i[1 ]   : ((pad_mux_i[5 ] == 2'b10) ? timer2_i[2] : s_alt3 ));

   /////////////////////////////////////////////////////////////////////////////////////////////
   // DATA INPUT
   /////////////////////////////////////////////////////////////////////////////////////////////

   //    UART
   assign uart_rx_o     = (pad_mux_i[38] == 2'b00) ? in_spim_sdio3_i : 1'b1;

   //    SPI
   assign spi_sdi_o[0][0] = (pad_mux_i[33] == 2'b00) ? in_spim_sdio0_i : 1'b0;
   assign spi_sdi_o[0][1] = (pad_mux_i[34] == 2'b00) ? in_spim_sdio1_i : 1'b0;
   assign spi_sdi_o[0][2] = (pad_mux_i[35] == 2'b00) ? in_spim_sdio2_i : 1'b0;
   assign spi_sdi_o[0][3] = (pad_mux_i[36] == 2'b00) ? in_spim_sdio3_i : 1'b0;

   //    I2C0
   assign i2c_sda_in_o[0]      = (pad_mux_i[43] == 2'b00) ? in_spim_sdio0_i : 1'b1;
   assign i2c_scl_in_o[0]      = (pad_mux_i[44] == 2'b00) ? in_spim_sdio1_i : 1'b1;

   //    GPIO
   assign gpio_in_o[0]  = (pad_mux_i[0]  == 2'b01) ? in_spim_sck_i : 1'b0 ;
   assign gpio_in_o[1]  = (pad_mux_i[1]  == 2'b01) ? in_spim_csn0_i : 1'b0 ;

   // PAD CFG mux between default and GPIO
   assign pad_cfg_o[0]  = (pad_mux_i[0]  == 2'b01) ? gpio_cfg_i[0]  : pad_cfg_i[0];
   assign pad_cfg_o[1]  = (pad_mux_i[1]  == 2'b01) ? gpio_cfg_i[1]  : pad_cfg_i[1];
   assign pad_cfg_o[2]  = (pad_mux_i[2]  == 2'b01) ? gpio_cfg_i[2]  : pad_cfg_i[2];
   assign pad_cfg_o[3]  = (pad_mux_i[3]  == 2'b01) ? gpio_cfg_i[3]  : pad_cfg_i[3];
   assign pad_cfg_o[4]  = (pad_mux_i[4]  == 2'b01) ? gpio_cfg_i[4]  : pad_cfg_i[4];
   assign pad_cfg_o[5]  = (pad_mux_i[5]  == 2'b01) ? gpio_cfg_i[5]  : pad_cfg_i[5];
   assign pad_cfg_o[6]  = (pad_mux_i[6]  == 2'b01) ? gpio_cfg_i[6]  : pad_cfg_i[6];
   assign pad_cfg_o[7]  = (pad_mux_i[7]  == 2'b01) ? gpio_cfg_i[7]  : pad_cfg_i[7];
   assign pad_cfg_o[8]  = (pad_mux_i[8]  == 2'b01) ? gpio_cfg_i[8]  : pad_cfg_i[8];
   assign pad_cfg_o[9]  = (pad_mux_i[9]  == 2'b01) ? gpio_cfg_i[9]  : pad_cfg_i[9];
   assign pad_cfg_o[10] = (pad_mux_i[10] == 2'b01) ? gpio_cfg_i[10] : pad_cfg_i[10];
   assign pad_cfg_o[11] = (pad_mux_i[11] == 2'b01) ? gpio_cfg_i[11] : pad_cfg_i[11];
   assign pad_cfg_o[12] = (pad_mux_i[12] == 2'b01) ? gpio_cfg_i[12] : pad_cfg_i[12];
   assign pad_cfg_o[13] = (pad_mux_i[13] == 2'b01) ? gpio_cfg_i[13] : pad_cfg_i[13];
   assign pad_cfg_o[14] = (pad_mux_i[14] == 2'b01) ? gpio_cfg_i[14] : pad_cfg_i[14];
   assign pad_cfg_o[15] = (pad_mux_i[15] == 2'b01) ? gpio_cfg_i[15] : pad_cfg_i[15];
   assign pad_cfg_o[16] = (pad_mux_i[16] == 2'b01) ? gpio_cfg_i[16] : pad_cfg_i[16];
   assign pad_cfg_o[17] = (pad_mux_i[17] == 2'b01) ? gpio_cfg_i[17] : pad_cfg_i[17];
   assign pad_cfg_o[18] = (pad_mux_i[18] == 2'b01) ? gpio_cfg_i[18] : pad_cfg_i[18];
   assign pad_cfg_o[19] = (pad_mux_i[19] == 2'b01) ? gpio_cfg_i[19] : pad_cfg_i[19];
   assign pad_cfg_o[20] = (pad_mux_i[20] == 2'b01) ? gpio_cfg_i[20] : pad_cfg_i[20];
   assign pad_cfg_o[21] = (pad_mux_i[21] == 2'b01) ? gpio_cfg_i[21] : pad_cfg_i[21];
   assign pad_cfg_o[22] = (pad_mux_i[22] == 2'b01) ? gpio_cfg_i[22] : pad_cfg_i[22];
   assign pad_cfg_o[23] = (pad_mux_i[23] == 2'b01) ? gpio_cfg_i[23] : pad_cfg_i[23];
   assign pad_cfg_o[24] = (pad_mux_i[24] == 2'b01) ? gpio_cfg_i[24] : pad_cfg_i[24];
   assign pad_cfg_o[25] = (pad_mux_i[25] == 2'b01) ? gpio_cfg_i[25] : pad_cfg_i[25];
   assign pad_cfg_o[26] =                                             pad_cfg_i[26];
   assign pad_cfg_o[27] =                                             pad_cfg_i[27];
   assign pad_cfg_o[28] =                                             pad_cfg_i[28];
   assign pad_cfg_o[29] =                                             pad_cfg_i[29];
   assign pad_cfg_o[30] =                                             pad_cfg_i[30];
   assign pad_cfg_o[31] =                                             pad_cfg_i[31];
   assign pad_cfg_o[32] =                                             pad_cfg_i[32];
   assign pad_cfg_o[33] = (pad_mux_i[33] == 2'b01) ? gpio_cfg_i[26] : pad_cfg_i[33];
   assign pad_cfg_o[34] = (pad_mux_i[34] == 2'b01) ? gpio_cfg_i[27] : pad_cfg_i[34];
   assign pad_cfg_o[35] = (pad_mux_i[35] == 2'b01) ? gpio_cfg_i[28] : pad_cfg_i[35];
   assign pad_cfg_o[36] = (pad_mux_i[36] == 2'b01) ? gpio_cfg_i[29] : pad_cfg_i[36];
   assign pad_cfg_o[37] = (pad_mux_i[37] == 2'b01) ? gpio_cfg_i[30] : pad_cfg_i[37];
   assign pad_cfg_o[38] = (pad_mux_i[38] == 2'b01) ? gpio_cfg_i[31] : pad_cfg_i[38];

endmodule
