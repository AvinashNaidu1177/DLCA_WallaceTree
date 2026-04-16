module half_adder(input a, b, output sum, carry);
    assign {carry, sum} = a + b;
endmodule
module full_adder(input a, b, cin, output sum, carry);
    assign {carry, sum} = a + b + cin;
endmodule

module wallace_4x4(input [3:0] A, B, output [7:0] P);

    wire [3:0] pp [3:0];
    genvar r, c;
    generate
        for (r = 0; r < 4; r = r+1)
            for (c = 0; c < 4; c = c+1)
                assign pp[r][c] = A[r] & B[c];
    endgenerate

    // Layer 1
    wire s1,c1, s2,c2, s3,c3, s4,c4, s5,c5;
    half_adder ha1(.a(pp[0][1]), .b(pp[1][0]),                 .sum(s1), .carry(c1));
    full_adder fa1(.a(pp[0][2]), .b(pp[1][1]), .cin(pp[2][0]), .sum(s2), .carry(c2));
    full_adder fa2(.a(pp[0][3]), .b(pp[1][2]), .cin(pp[2][1]), .sum(s3), .carry(c3));
    full_adder fa3(.a(pp[1][3]), .b(pp[2][2]), .cin(pp[3][1]), .sum(s4), .carry(c4));
    half_adder ha2(.a(pp[2][3]), .b(pp[3][2]),                 .sum(s5), .carry(c5));

    // Layer 2
    wire s2b,c2b, s3b,c3b, s4b,c4b, s5b,c5b, s6,c6;
    half_adder ha3(.a(s2),       .b(c1),                       .sum(s2b), .carry(c2b));
    full_adder fa4(.a(s3),       .b(c2),       .cin(pp[3][0]), .sum(s3b), .carry(c3b));
    half_adder ha4(.a(s4),       .b(c3),                       .sum(s4b), .carry(c4b));
    half_adder ha5(.a(s5),       .b(c4),                       .sum(s5b), .carry(c5b));
    half_adder ha6(.a(pp[3][3]), .b(c5),                       .sum(s6),  .carry(c6));

    // Final two carry-save vectors, explicitly placed by bit position
    // S[7:0]: bit7=0,  bit6=s6,  bit5=s5b, bit4=s4b, bit3=s3b, bit2=s2b, bit1=s1, bit0=pp[0][0]
    // C[7:0]: bit7=c6, bit6=c5b, bit5=c4b, bit4=c3b, bit3=c2b, bit2=0,   bit1=0,  bit0=0
    wire [7:0] vec_s = {1'b0, s6,  s5b, s4b, s3b, s2b, s1,  pp[0][0]};
    wire [7:0] vec_c = {c6,   c5b, c4b, c3b, c2b, 1'b0,1'b0,1'b0    };
    assign P = vec_s + vec_c;

endmodule

`timescale 1ns/1ps
module tb_wallace_4x4;
    reg  [3:0] A, B;
    wire [7:0] P;
    wallace_4x4 uut(.A(A), .B(B), .P(P));
    integer i, j, pass_count, fail_count;
    initial begin
        $display("===========================================");
        $display("  Wallace Tree 4x4 Multiplier - Full Test ");
        $display("===========================================");
        pass_count = 0; fail_count = 0;
        for (i = 0; i < 16; i = i+1)
            for (j = 0; j < 16; j = j+1) begin
                A = i; B = j; #10;
                if (P === A*B) pass_count = pass_count+1;
                else begin
                    $display("FAIL: %0d x %0d | exp %0d | got %0d", A, B, A*B, P);
                    fail_count = fail_count+1;
                end
            end
        $display("-------------------------------------------");
        $display("  %0d passed, %0d failed (of 256)", pass_count, fail_count);
        if (fail_count == 0)
            $display("  ALL TESTS PASSED");
        else
            $display("  SOME TESTS FAILED");
        $display("===========================================");
        $finish;
    end
    initial begin $dumpfile("wallace_4x4.vcd"); $dumpvars(0, tb_wallace_4x4); end
endmodule