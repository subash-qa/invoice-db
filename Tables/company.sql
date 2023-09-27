CREATE TABLE IF NOT EXISTS company.company(
    company_sno bigserial PRIMARY KEY,
    company_name text,
    logo smallint,
    alternate_company_name text, /* constitution of business */
    entity_type smallint, 
    gstin text,
    mobile_number text,
    email text,
    FOREIGN KEY(logo) REFERENCES media.media(media_sno)
);


CREATE TABLE IF NOT EXISTS company.address(
    address_sno bigserial PRIMARY KEY,
    company_sno bigint,
    address_line_1 text,
    address_line_2 text,
    city text,
    pincode smallint,
    state bigint,
    FOREIGN KEY(company_sno) REFERENCES company.company(company_sno)
);


CREATE TABLE IF NOT EXISTS company.goods(
    goods_sno bigserial PRIMARY KEY,
    company_sno bigint,
    goods_name text,
    price double precision,
    inclusive_of_gst smallint, /* select option */
    gst_rate smallint, /* select option */
    none_taxable NUMERIC,
    net_price NUMERIC,
    hsn_code text,
    unites smallint,
    cress_amount NUMERIC,
    sku text,
    description text,
    FOREIGN KEY(company_sno) REFERENCES company.company(company_sno)
);


CREATE TABLE IF NOT EXISTS company.services(
    services_sno bigserial PRIMARY KEY,
    company_sno bigint,
    service_name text,
    price double precision,
    inclusive_of_gst smallint, /* select option */
    gst_rate smallint, /* select option */
    net_price numeric,
    sac_code text,
    cress_amount numeric,
    none_taxable numeric,
    description text,
    FOREIGN KEY(company_sno) REFERENCES company.company(company_sno)
);