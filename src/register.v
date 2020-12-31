module register (
    in,     // input -> data input
    out,    // output -> data output
    clock,  // input -> clock
    reset   // input -> resets register
);

always @(posedge clock) begin
    if (reset)
        out <= 0;
    else
        out <= in;
end

endmodule