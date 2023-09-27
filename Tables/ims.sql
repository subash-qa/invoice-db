CREATE TABLE IF NOT EXISTS ims.invoice(
    invoice_sno bigserial PRIMARY KEY,
    invoice_type smallint, /* Domestic, Estimates, international invoice, bill of supply, delivery challan */
    invoice_number text,
    customer_sno bigint,
    company_sno bigint,
    invoice_date timestamp,
    due_date timestamp,
    item_no bigint,
    qty bigint,
    rate numeric,
    amount numeric,
    adjustment_amount numeric,
    notes text,
    terms_and_conditions text,
    created_by bigint,
    created_on timestamp,
    FOREIGN KEY(created_by) REFERENCES portal.app_user(app_user_sno),
    FOREIGN KEY(customer_sno) REFERENCES customer.customer(customer_sno),
    FOREIGN KEY(company_sno) REFERENCES company.company(company_sno)
);


