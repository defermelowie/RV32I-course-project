module register (
    in,             // input -> data input
    write_enable,   // input -> write enable
    out,            // output -> data output
    clock,          // input -> clock
    reset           // input -> resets register
);

always @(posedge clock) begin
    if (reset)
        out <= 0;
    else if (write_enable)
        out <= in;
end

endmodule