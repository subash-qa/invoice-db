CREATE TABLE IF NOT EXISTS customer.customer(
    customer_sno bigserial PRIMARY KEY,
    title smallint not null, /* select option */
    customer_name varchar(25),
    entity_type smallint not null, /* select option */
    mobile_number text,
    email text,
    customer_gstin text,
    gst_registered_name text,
    filing_status text,
    business_name text,
    display_name text,
    phone_number text,
    fax text
);

CREATE TABLE IF NOT EXISTS customer.billing_address(
    billing_address_sno bigserial PRIMARY KEY,
    customer_sno bigint,
    address_line_1 text,
    address_line_2 text,
    city text,
    pincode smallint,
    state bigint,
    country bigint, /* select option */
    branch_name text,
    gstin text,
    FOREIGN KEY(customer_sno) REFERENCES customer.customer(customer_sno)
);

CREATE TABLE IF NOT EXISTS customer.shipping_address(
    shipping_address_sno bigserial PRIMARY KEY,
    customer_sno bigint,
    address_line_1 text,
    address_line_2 text,
    city text,
    pincode smallint,
    state bigint,
    country bigint, /* select option */
    branch_name text,
    gstin text,
    FOREIGN KEY(customer_sno) REFERENCES customer.customer(customer_sno)
);


CREATE TABLE IF NOT EXISTS customer.bank_detail(
    bank_detail_sno bigserial PRIMARY KEY,
    customer_sno bigint,
    account_number numeric,
    account_name text,
    bank_name text,
    ifsc_code text,
    account_type smallint, /* select option */
    branch_name text,
    FOREIGN KEY(customer_sno) REFERENCES customer.customer(customer_sno)
);


CREATE TABLE IF NOT EXISTS customer.tax(
    tax_sno bigserial PRIMARY KEY,
    customer_sno bigint,
    pan_number numeric,
    tan_number numeric,
    tds_slab_rate smallint, /* select option */
    currency_type smallint, /* select option */
    terms_of_payment smallint, /* select option */
    apply_reverse_charge smallint, /* select option */
    export_or_sez_developer smallint, /* select option */
    FOREIGN KEY(customer_sno) REFERENCES customer.customer(customer_sno)
);