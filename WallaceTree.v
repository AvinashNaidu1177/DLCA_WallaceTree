module half_adder(
    input  a, b,
    output sum, carry
);
    assign sum   = a ^ b;
    assign carry = a & b;
endmodule

module full_adder(
    input  a, b, cin,
    output sum, carry
);
    assign sum   = a ^ b ^ cin;
    assign carry = (a & b) | (b & cin) | (a & cin);
endmodule

module wallace_4x4(
    input  [3:0] A, B,
    output [7:0] P
);

    
    wire pp00,pp01,pp02,pp03;
    wire pp10,pp11,pp12,pp13;
    wire pp20,pp21,pp22,pp23;
    wire pp30,pp31,pp32,pp33;

    assign {pp03,pp02,pp01,pp00} = {A[0]&B[3], A[0]&B[2], A[0]&B[1], A[0]&B[0]};
    assign {pp13,pp12,pp11,pp10} = {A[1]&B[3], A[1]&B[2], A[1]&B[1], A[1]&B[0]};
    assign {pp23,pp22,pp21,pp20} = {A[2]&B[3], A[2]&B[2], A[2]&B[1], A[2]&B[0]};
    assign {pp33,pp32,pp31,pp30} = {A[3]&B[3], A[3]&B[2], A[3]&B[1], A[3]&B[0]};

    
    wire s1, c1;
    half_adder ha1 (.a(pp01),  .b(pp10),  .sum(s1), .carry(c1));

    wire s2, c2;
    full_adder fa1 (.a(pp02),  .b(pp11),  .cin(pp20), .sum(s2), .carry(c2));

    wire s3, c3;
    full_adder fa2 (.a(pp03),  .b(pp12),  .cin(pp21), .sum(s3), .carry(c3));
    // pp30 passes to layer 2

    wire s4, c4;
    full_adder fa3 (.a(pp13),  .b(pp22),  .cin(pp31), .sum(s4), .carry(c4));

    wire s5, c5;
    half_adder ha2 (.a(pp23),  .b(pp32),  .sum(s5), .carry(c5));

    wire s3b, c3b;
    full_adder fa4 (.a(s3),   .b(c2),   .cin(pp30), .sum(s3b), .carry(c3b));

    wire s4b, c4b;
    full_adder fa5 (.a(s4),   .b(c3),   .cin(c3b),  .sum(s4b), .carry(c4b));

    wire s5b, c5b;
    full_adder fa6 (.a(s5),   .b(c4),   .cin(c4b),  .sum(s5b), .carry(c5b));

    wire s6, c6;
    full_adder fa7 (.a(pp33), .b(c5),   .cin(c5b),  .sum(s6),  .carry(c6));
    wire [7:0] row_s, row_c;
    assign row_s = {c6,  s6,  s5b, s4b, s3b, s2,  s1,  pp00};
    assign row_c = {1'b0,1'b0,1'b0,1'b0,1'b0,c1,  1'b0,1'b0};

    assign P = row_s + row_c;

endmodule
`timescale 1ns/1ps

module tb_wallace_4x4;

    // Inputs
    reg  [3:0] A, B;

    // Output
    wire [7:0] P;

    // Instantiate DUT
    wallace_4x4 uut (
        .A(A),
        .B(B),
        .P(P)
    );

    integer i, j;
    integer pass_count, fail_count;
    reg [7:0] expected;

    initial begin
        $display("============================================");
        $display("  Wallace Tree 4x4 Multiplier ? Full Test  ");
        $display("============================================");

        pass_count = 0;
        fail_count = 0;

        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                A = i[3:0];
                B = j[3:0];
                #10; // wait for combinational logic to settle

                expected = A * B;

                if (P === expected) begin
                    pass_count = pass_count + 1;
                end else begin
                    $display("FAIL: %0d x %0d | expected %0d | got %0d",
                              A, B, expected, P);
                    fail_count = fail_count + 1;
                end
            end
        end

        $display("--------------------------------------------");
        $display("  Results: %0d passed, %0d failed (of 256)",
                  pass_count, fail_count);

        if (fail_count == 0)
            $display("  ALL TESTS PASSED");
        else
            $display("  SOME TESTS FAILED ? check wiring above");

        $display("============================================");
        $finish;
    end

    // Optional: waveform dump for GTKWave / ModelSim
    initial begin
        $dumpfile("wallace_4x4.vcd");
        $dumpvars(0, tb_wallace_4x4);
    end

endmodule