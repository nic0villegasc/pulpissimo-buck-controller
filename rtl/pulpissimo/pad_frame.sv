// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module pad_frame
    (

        input logic [47:0][5:0] pad_cfg_i ,

        // REF CLOCK
        output logic            ref_clk_o ,

        // RESET SIGNALS
        output logic            rstn_o ,

        // JTAG SIGNALS
        output logic            jtag_tck_o ,
        output logic            jtag_tdi_o ,
        input logic             jtag_tdo_i ,
        output logic            jtag_tms_o ,
        output logic            jtag_trst_o ,

        // input logic             oe_sdio_clk_i ,
        // input logic             oe_sdio_cmd_i ,
        // input logic             oe_sdio_data0_i ,
        // input logic             oe_sdio_data1_i ,
        // input logic             oe_sdio_data2_i ,
        // input logic             oe_sdio_data3_i ,
        input logic             oe_spim_sdio0_i ,
        input logic             oe_spim_sdio1_i ,
        input logic             oe_spim_sdio2_i ,
        input logic             oe_spim_sdio3_i ,
        input logic             oe_spim_csn0_i ,
        input logic             oe_spim_csn1_i ,
        input logic             oe_spim_sck_i ,
        // input logic             oe_i2s0_sck_i ,
        // input logic             oe_i2s0_ws_i ,
        // input logic             oe_i2s0_sdi_i ,
        // input logic             oe_i2s1_sdi_i ,
        // input logic             oe_cam_pclk_i ,
        // input logic             oe_cam_hsync_i ,
        // input logic             oe_cam_data0_i ,
        // input logic             oe_cam_data1_i ,
        // input logic             oe_cam_data2_i ,
        // input logic             oe_cam_data3_i ,
        // input logic             oe_cam_data4_i ,
        // input logic             oe_cam_data5_i ,
        // input logic             oe_cam_data6_i ,
        // input logic             oe_cam_data7_i ,
        // input logic             oe_cam_vsync_i ,
        // input logic             oe_i2c0_sda_i ,
        // input logic             oe_i2c0_scl_i ,
        // input logic             oe_uart_rx_i ,
        // input logic             oe_uart_tx_i ,

        // INPUTS SIGNALS TO THE PADS
        // input logic             out_sdio_clk_i ,
        // input logic             out_sdio_cmd_i ,
        // input logic             out_sdio_data0_i ,
        // input logic             out_sdio_data1_i ,
        // input logic             out_sdio_data2_i ,
        // input logic             out_sdio_data3_i ,
        input logic             out_spim_sdio0_i ,
        input logic             out_spim_sdio1_i ,
        input logic             out_spim_sdio2_i ,
        input logic             out_spim_sdio3_i ,
        input logic             out_spim_csn0_i ,
        input logic             out_spim_csn1_i ,
        input logic             out_spim_sck_i ,
        // input logic             out_i2s0_sck_i ,
        // input logic             out_i2s0_ws_i ,
        // input logic             out_i2s0_sdi_i ,
        // input logic             out_i2s1_sdi_i ,
        // input logic             out_cam_pclk_i ,
        // input logic             out_cam_hsync_i ,
        // input logic             out_cam_data0_i ,
        // input logic             out_cam_data1_i ,
        // input logic             out_cam_data2_i ,
        // input logic             out_cam_data3_i ,
        // input logic             out_cam_data4_i ,
        // input logic             out_cam_data5_i ,
        // input logic             out_cam_data6_i ,
        // input logic             out_cam_data7_i ,
        // input logic             out_cam_vsync_i ,
        // input logic             out_i2c0_sda_i ,
        // input logic             out_i2c0_scl_i ,
        // input logic             out_uart_rx_i ,
        // input logic             out_uart_tx_i ,

        // OUTPUT SIGNALS FROM THE PADS
        // output logic            in_sdio_clk_o ,
        // output logic            in_sdio_cmd_o ,
        // output logic            in_sdio_data0_o ,
        // output logic            in_sdio_data1_o ,
        // output logic            in_sdio_data2_o ,
        // output logic            in_sdio_data3_o ,
        output logic            in_spim_sdio0_o ,
        output logic            in_spim_sdio1_o ,
        output logic            in_spim_sdio2_o ,
        output logic            in_spim_sdio3_o ,
        output logic            in_spim_csn0_o ,
        output logic            in_spim_csn1_o ,
        output logic            in_spim_sck_o ,
        // output logic            in_i2s0_sck_o ,
        // output logic            in_i2s0_ws_o ,
        // output logic            in_i2s0_sdi_o ,
        // output logic            in_i2s1_sdi_o ,
        // output logic            in_cam_pclk_o ,
        // output logic            in_cam_hsync_o ,
        // output logic            in_cam_data0_o ,
        // output logic            in_cam_data1_o ,
        // output logic            in_cam_data2_o ,
        // output logic            in_cam_data3_o ,
        // output logic            in_cam_data4_o ,
        // output logic            in_cam_data5_o ,
        // output logic            in_cam_data6_o ,
        // output logic            in_cam_data7_o ,
        // output logic            in_cam_vsync_o ,
        // output logic            in_i2c0_sda_o ,
        // output logic            in_i2c0_scl_o ,
        // output logic            in_uart_rx_o ,
        // output logic            in_uart_tx_o ,

        output logic [1:0]      bootsel_o ,

        // EXT CHIP TP PADS
        inout wire              pad_spim_sdio0 ,
        inout wire              pad_spim_sdio1 ,
        inout wire              pad_spim_sdio2 ,
        inout wire              pad_spim_sdio3 ,
        inout wire              pad_spim_csn0 ,
        inout wire              pad_spim_sck ,

        inout wire              pad_reset_n ,
        inout wire              pad_bootsel0 ,
        inout wire              pad_bootsel1 ,
        inout wire              pad_jtag_tck ,
        inout wire              pad_jtag_tdi ,
        inout wire              pad_jtag_tdo ,
        inout wire              pad_jtag_tms ,
        inout wire              pad_jtag_trst ,
        inout wire              pad_xtal_in
    );

   gf180mcu_fd_io__bi_t padinst_spim_sck_gf180 ( .A(out_spim_sck_i), .Y(in_spim_sck_o), .OE(~oe_spim_sck_i), .IE(oe_spim_sck_i), .PAD(pad_spim_sck), .PD(~pad_cfg_i[6][0]), .PU(1'b0), .CS(1'b0), .SL(1'b0), .PDRV0(1'b0), .PDRV1(1'b0) );
   gf180mcu_fd_io__bi_t padinst_spim_sdio0_gf180 ( .A(out_spim_sdio0_i), .Y(in_spim_sdio0_o), .OE(~oe_spim_sdio0_i), .IE(oe_spim_sdio0_i), .PAD(pad_spim_sdio0), .PD(~pad_cfg_i[0][0]), .PU(1'b0), .CS(1'b0), .SL(1'b0), .PDRV0(1'b0), .PDRV1(1'b0) );
   gf180mcu_fd_io__bi_t padinst_spim_sdio1_gf180 ( .A(out_spim_sdio1_i), .Y(in_spim_sdio1_o), .OE(~oe_spim_sdio1_i), .IE(oe_spim_sdio1_i), .PAD(pad_spim_sdio1), .PD(~pad_cfg_i[1][0]), .PU(1'b0), .CS(1'b0), .SL(1'b0), .PDRV0(1'b0), .PDRV1(1'b0) );
   gf180mcu_fd_io__bi_t padinst_spim_sdio2_gf180 ( .A(out_spim_sdio2_i), .Y(in_spim_sdio2_o), .OE(~oe_spim_sdio2_i), .IE(oe_spim_sdio2_i), .PAD(pad_spim_sdio2), .PD(~pad_cfg_i[2][0]), .PU(1'b0), .CS(1'b0), .SL(1'b0), .PDRV0(1'b0), .PDRV1(1'b0) );
   gf180mcu_fd_io__bi_t padinst_spim_sdio3_gf180 ( .A(out_spim_sdio3_i), .Y(in_spim_sdio3_o), .OE(~oe_spim_sdio3_i), .IE(oe_spim_sdio3_i), .PAD(pad_spim_sdio3), .PD(~pad_cfg_i[3][0]), .PU(1'b0), .CS(1'b0), .SL(1'b0), .PDRV0(1'b0), .PDRV1(1'b0) );
   gf180mcu_fd_io__bi_t padinst_spim_csn0_gf180 ( .A(out_spim_csn0_i), .Y(in_spim_csn0_o), .OE(~oe_spim_csn0_i), .IE(oe_spim_csn0_i), .PAD(pad_spim_csn0), .PD(~pad_cfg_i[4][0]), .PU(1'b0), .CS(1'b0), .SL(1'b0), .PDRV0(1'b0), .PDRV1(1'b0) );

   gf180mcu_fd_io__in_c padinst_bootsel0_gf180 ( .Y(bootsel_o[0]), .PAD(pad_bootsel0), .PU(1'b1), .PD(1'b0) );
   gf180mcu_fd_io__in_c padinst_bootsel1_gf180 ( .Y(bootsel_o[1]), .PAD(pad_bootsel1), .PU(1'b1), .PD(1'b0) );

   gf180mcu_fd_io__in_c padinst_reset_n_gf180 ( .Y(rstn_o), .PAD(pad_reset_n), .PU(1'b1), .PD(1'b0) );
   gf180mcu_fd_io__in_c padinst_clk_ref_gf180 ( .Y(ref_clk_o), .PAD(pad_xtal_in), .PU(1'b0), .PD(1'b0) );

  //JTAG signals
   gf180mcu_fd_io__in_c padinst_jtag_trst_gf180( .Y(jtag_trst_o), .PAD(pad_jtag_trst), .PU(1'b0), .PD(1'b0) );
   gf180mcu_fd_io__in_c padinst_jtag_tms_gf180 ( .Y(jtag_tms_o),  .PAD(pad_jtag_tms),  .PU(1'b0), .PD(1'b0) );
   gf180mcu_fd_io__in_c padinst_jtag_tck_gf180 ( .Y(jtag_tck_o),  .PAD(pad_jtag_tck),  .PU(1'b0), .PD(1'b0) );
   gf180mcu_fd_io__in_c padinst_jtag_tdi_gf180 ( .Y(jtag_tdi_o),  .PAD(pad_jtag_tdi),  .PU(1'b0), .PD(1'b0) );

   gf180mcu_fd_io__bi_t padinst_jtag_tdo_gf180 ( .A(jtag_tdo_i), .PAD(pad_jtag_tdo), .OE(1'b1), .IE(1'b0), .Y(), .CS(1'b0), .PD(1'b0), .PU(1'b0), .SL(1'b0), .PDRV0(1'b0), .PDRV1(1'b0) );

endmodule // pad_frame
