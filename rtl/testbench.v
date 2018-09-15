module testbench;
	reg clock;

	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);

		#5 clock = 0;
		repeat (10000) #5 clock = ~clock;
	end

	reg qpi_csb;
	reg qpi_clk;

	reg qpi_io0_reg;
	reg qpi_io1_reg;
	reg qpi_io2_reg;
	reg qpi_io3_reg;

	wire qpi_io0 = qpi_io0_reg;
	wire qpi_io1 = qpi_io1_reg;
	wire qpi_io2 = qpi_io2_reg;
	wire qpi_io3 = qpi_io3_reg;

	wire qpi_rdy;
	wire qpi_err;

	mlaccel_top uut (
		.clock   (clock  ),
		.qpi_csb (qpi_csb),
		.qpi_clk (qpi_clk),
		.qpi_io0 (qpi_io0),
		.qpi_io1 (qpi_io1),
		.qpi_io2 (qpi_io2),
		.qpi_io3 (qpi_io3),
		.qpi_rdy (qpi_rdy),
		.qpi_err (qpi_err)
	);

	reg [7:0] xfer;

	task xfer_start;
		begin
			qpi_clk = 1;
			qpi_csb = 0;
			#17;
		end
	endtask

	task xfer_send;
		begin
			qpi_clk = 0;
			qpi_io0_reg = xfer[4];
			qpi_io1_reg = xfer[5];
			qpi_io2_reg = xfer[6];
			qpi_io3_reg = xfer[7];
			#17;
			qpi_clk = 1;
			qpi_io0_reg = xfer[0];
			qpi_io1_reg = xfer[1];
			qpi_io2_reg = xfer[2];
			qpi_io3_reg = xfer[3];
			#17;
		end
	endtask

	task xfer_send_byte;
		input [7:0] data;
		begin
			xfer = data;
			xfer_send;
		end
	endtask

	task xfer_wait;
		begin
			qpi_clk = 0;
			qpi_io0_reg = 1'bz;
			qpi_io1_reg = 1'bz;
			qpi_io2_reg = 1'bz;
			qpi_io3_reg = 1'bz;
			#17;

			qpi_clk = 1;
			#(2*17);
		end
	endtask

	task xfer_recv;
		begin
			qpi_clk = 0;
			qpi_io0_reg = 1'bz;
			qpi_io1_reg = 1'bz;
			qpi_io2_reg = 1'bz;
			qpi_io3_reg = 1'bz;
			#15;

			xfer[4] = qpi_io0;
			xfer[5] = qpi_io1;
			xfer[6] = qpi_io2;
			xfer[7] = qpi_io3;
			#2;

			qpi_clk = 1;
			qpi_io0_reg = 1'bz;
			qpi_io1_reg = 1'bz;
			qpi_io2_reg = 1'bz;
			qpi_io3_reg = 1'bz;
			#15;

			xfer[0] = qpi_io0;
			xfer[1] = qpi_io1;
			xfer[2] = qpi_io2;
			xfer[3] = qpi_io3;
			#2;
		end
	endtask

	task xfer_stop;
		begin
			xfer = 'bx;
			qpi_clk = 0;
			#17;

			qpi_csb = 1;
			qpi_clk = 1;
			qpi_io0_reg = 1'bz;
			qpi_io1_reg = 1'bz;
			qpi_io2_reg = 1'bz;
			qpi_io3_reg = 1'bz;
			#(2*17);
		end
	endtask

	integer i;

	initial begin
		xfer_stop;

		#200;

		xfer_start;
		xfer_send_byte(8'h 21);
		xfer_send_byte(8'h 01);
		xfer_send_byte(8'h 02);
		xfer_send_byte(8'h 03);
		xfer_send_byte(8'h 04);
		xfer_send_byte(8'h 05);
		xfer_send_byte(8'h 06);
		xfer_send_byte(8'h 07);
		xfer_send_byte(8'h 08);
		xfer_send_byte(8'h 09);
		xfer_send_byte(8'h 0A);
		xfer_send_byte(8'h 0B);
		xfer_send_byte(8'h 0C);
		xfer_stop;

		#20;

		xfer_start;
		xfer_send_byte(8'h 23);
		xfer_send_byte(8'h 01);
		xfer_send_byte(8'h 10);
		xfer_send_byte(8'h 03);
		xfer_wait;
		xfer_recv;
		while (xfer != 8'h 00)
			xfer_recv;
		xfer_stop;

		#20;

		xfer_start;
		xfer_send_byte(8'h 24);
		xfer_send_byte(8'h 03);
		xfer_send_byte(8'h 10);
		xfer_send_byte(8'h 02);
		xfer_wait;
		xfer_recv;
		while (xfer != 8'h 00)
			xfer_recv;
		xfer_stop;

		#20;

		xfer_start;
		xfer_send_byte(8'h 22);
		xfer_wait;
		repeat (8)
			xfer_recv;
		xfer_stop;
	end
endmodule