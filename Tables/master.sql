CREATE TABLE IF NOT EXISTS master.additional_charges(
    additional_charges_sno smallserial PRIMARY KEY,
    charges_name text NOT NULL,
    charges_amt numeric,
    active_flag boolean NOT NULL default true
);