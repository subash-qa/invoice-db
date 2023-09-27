CREATE OR REPLACE FUNCTION ims.insert_invoice(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
declare
_invoice_sno bigint;
begin
raise notice '%',p_data;
insert into ims.invoice(
	invoice_type,
    invoice_number,
    customer_sno,
    company_sno,
    invoice_date,
    due_date,
    item_no,
    qty,
    rate,
    amount,
    adjustment_amount,
    notes,
    terms_and_conditions,
    created_by,
    created_on
) 
values(
	(p_data->>'invoiceType')::smallint,
	(p_data->>'invoiceNumber'),
	(p_data->>'customerSno')::bigint,
	(p_data->>'companySno')::bigint,
	(p_data->>'invoiceDate')::timestamp,
	(p_data->>'dueDate')::timestamp,
	(p_data->>'itemNo')::bigint,
	(p_data->>'rate')::numeric,
	(p_data->>'amount')::numeric,
	(p_data->>'adjustmentAmount')::numeric,
	(p_data->>'notes'),
	(p_data->>'termsAndConditions'),
	(p_data->>'created_by')::bigint,
	(p_data->>'createdOn')::timestamp
	
)
		returning invoice_sno into _invoice_sno;
	return (select json_build_object('invoiceSno',_invoice_sno));	
end;
$BODY$;