module hazard_detection_unit (
    EX_mem_to_reg,              // input -> "mem_to_reg" from execution stage
    EX_destination_register,    // input -> destination register from execution stage
    ID_read_register_0,         // input -> read register 0 from instruction decode stage
    ID_read_register_1,         // input -> read register 1 from instruction decode stage
    stale                       // output -> high if processor must stale
);

// -- Determine hazard ----------------------------------------
wire data_hazard = (
    EX_mem_to_reg &&
    (
        (EX_destination_register == ID_read_register_0) ||
        (EX_destination_register == ID_read_register_1)
    );
);

// -- Set signals ---------------------------------------------
assign stale = data_hazard;

endmodule