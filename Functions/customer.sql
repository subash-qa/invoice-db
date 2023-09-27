-- insert_customer
--------------------------

CREATE OR REPLACE FUNCTION customer.insert_customer(p_data json)
RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
declare
_customer_sno bigint;
begin
raise notice '%',p_data;
insert into customer.customer(
	title,
	customer_name,
	entity_type,
	mobile_number,
	email,
	customer_gstin,
	gst_registered_name,
	filing_status,
	business_name,
	display_name,
	phone_number,
	fax
) 
values(
	(p_data->>'title'),
	(p_data->>'customerName'),
	(p_data->>'entityType')::smallint,
	(p_data->>'mobileNumber'),
	(p_data->>'email'),
	(p_data->>'customerGstin'),
	(p_data->>'gstRegisteredName'),
	(p_data->>'filingStatus'),
	(p_data->>'businessName'),
	(p_data->>'displayName'),
	(p_data->>'phoneNumber'),
	(p_data->>'fax')
)

		returning customer_sno into _customer_sno;
	return (select json_build_object('customerSno',_customer_sno));	
end;
$BODY$;

-- get_customer
----------------------

CREATE OR REPLACE FUNCTION customer.get_customer(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
begin
raise notice '%',p_data;
return ( select json_agg(json_build_object(
	'title',d.title,
	'customerName',d.customer_name,
	'entityType',d.entity_type,
	'mobileNumber',d.mobile_number,
	'email',d.email,
	'customerGstin',d.customer_gstin,
	'gstRegisteredName',d.gst_registered_name, 
	'filingStatus',d.filing_status,
	'businessName',d.business_name,
	'displayName',d.display_name,
	'phoneNumber',d.phone_number,
	'fax',d.fax 
)) from (select * from  customer.customer)d);
		
end;
$BODY$;

-- update_customer
--------------------------
		
CREATE OR REPLACE FUNCTION customer.update_customer(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare
_company_sno_sno bigint;
begin
raise notice '%',p_data;

update customer.customer set
	title = (p_data->>'title'),
	customer_name = (p_data->>'customerName'),
	entity_type = (p_data->>'entityType')::smallint,
	mobile_number = (p_data->>'mobileNumber'),
	email = (p_data->>'email'),
	customer_gstin = (p_data->>'customerGstin'),
	gst_registered_name = (p_data->>'gstRegisteredName'),
	filing_status = (p_data->>'filingStatus'),
	business_name = (p_data->>'businessName'),
	display_name = (p_data->>'displayName'),
	phone_number = (p_data->>'phoneNumber'),
	fax = (p_data->>'fax') where company_sno = (p_data->>'companySno')::bigint
returning company_sno into _company_sno_sno;
return (select json_build_object('companySno',_company_sno_sno));

end;
$BODY$;
		
		
		
-- insert_billing_address
---------------------------

CREATE OR REPLACE FUNCTION customer.insert_billing_address(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
declare
_billing_address_sno bigint;
begin
raise notice '%',p_data;
insert into customer.billing_address(
	customer_sno ,
    address_line_1,
    address_line_2,
    city ,
    pincode ,
    state,
	country,
	branch_name,
	gstin
) 
values(
	(p_data->>'customerSno'),
	(p_data->>'addressLine1'),
	(p_data->>'addressLine2'),
	(p_data->>'city'),
	(p_data->>'pinCode')::numeric,
	(p_data->>'state'),
	(p_data->>'country')::bigint,
	(p_data->>'branchName'),
	(p_data->>'gstIn')
)

		returning billing_address_sno into _billing_address_sno;
	return (select json_build_object('billingAddressSno',_billing_address_sno));	
end;
$BODY$;
		
	
-- get_billing_address
------------------------

CREATE OR REPLACE FUNCTION customer.get_billing_address(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
begin
raise notice '%',p_data;
return ( select json_agg(json_build_object(
	'billingAddressSno',d.billing_address_sno,
	'customerSno',d.customer_sno,
	'addressLine1',d.address_line_1,
	'addressLine2',d.address_line_2,
	'city',d.city,
	'pinCode',d.pincode,
	'state',d.state,
	'country',d.country,
	'branchName',d.branch_name
	'gstIn',d.gstin
)) from (select * from  customer.billing_address)d);
		
end;
$BODY$;
	
		
-- update_billing_address
--------------------------
		
CREATE OR REPLACE FUNCTION customer.update_billing_address(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare
_billing_address_sno bigint;
begin
raise notice '%',p_data;

update customer.billing_address set
    address_line_1 = (p_data->>'addressLine1'), 
    address_line_2 = (p_data->>'addressLine2'),
    city = (p_data->>'city'),
    pincode = (p_data->>'pinCode')::numeric,
    state = (p_data->>'state'),
	country = (p_data->>'country')::bigint,
	branch_name = (p_data->>'country')::bigint,
	gstin = (p_data->>'gstIn')
		where  customer_sno = (p_data->>'customerSno')::bigint and billing_address_sno = (p_data->>'billingAddressSno')::bigint
returning billing_address_sno into _billing_address_sno;
return (select json_build_object('billingAdressSno',_billing_address_sno));

end;
$BODY$;
	

		
				
-- insert_shipping_address
---------------------------

CREATE OR REPLACE FUNCTION customer.insert_shipping_address(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
declare
_shipping_address_sno bigint;
begin
raise notice '%',p_data;
insert into customer.shipping_address(
	customer_sno ,
    address_line_1, 
    address_line_2,
    city,
    pincode,
    state,
	country,
	branch_name,
	gstin
) 
values(
	(p_data->>'customerSno'),
	(p_data->>'addressLine1'),
	(p_data->>'addressLine2'),
	(p_data->>'city'),
	(p_data->>'pinCode')::numeric,
	(p_data->>'state'),
	(p_data->>'country')::bigint,
	(p_data->>'branchName'),
	(p_data->>'gstIn')
)
		returning shipping_address_sno into _shipping_address_sno;
	return (select json_build_object('shippingAddressSno',_shipping_address_sno));	
end;
$BODY$;
		
	
-- get_shipping_address
------------------------

CREATE OR REPLACE FUNCTION customer.get_shipping_address(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
begin
raise notice '%',p_data;
return ( select json_agg(json_build_object(
	'shippingAddressSno',d.shipping_address_sno,
	'customerSno',d.customer_sno,
	'addressLine1',d.address_line_1,
	'addressLine2',d.address_line_2,
	'city',d.city,
	'pinCode',d.pincode,
	'state',d.state,
	'country',d.country,
	'branchName',d.branch_name
	'gstIn',d.gstin
)) from (select * from  customer.shipping_address)d);
		
end;
$BODY$;
	
		
-- update_shipping_address
--------------------------
		
CREATE OR REPLACE FUNCTION customer.update_shipping_address(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare
_shipping_address_sno bigint;
begin
raise notice '%',p_data;

update customer.shipping_address set
    address_line_1 = (p_data->>'addressLine1'), 
    address_line_2 = (p_data->>'addressLine2'),
    city = (p_data->>'city'),
    pincode = (p_data->>'pinCode')::numeric,
    state = (p_data->>'state'),
	country = (p_data->>'country')::bigint,
	branch_name = (p_data->>'country')::bigint,
	gstin = (p_data->>'gstIn')
		where  customer_sno = (p_data->>'customerSno')::bigint and shipping_address_sno = (p_data->>'shippingAddressSno')::bigint 
returning shipping_address_sno into _shipping_address_sno;
return (select json_build_object('shippingAdressSno',_shipping_address_sno));

end;
$BODY$;
	

	
-- insert_bank_detail
--------------------
		
CREATE OR REPLACE FUNCTION customer.insert_bank_detail(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
declare
_bank_detail_sno bigint;
begin
raise notice '%',p_data;
insert into customer.bank_detail(
	customer_sno ,
    account_number, 
    account_name,
    bank_name,
    ifsc_code,
    account_type,
	branch_name
) 
values(
	(p_data->>'customerSno'),
	(p_data->>'accountNumber')::numeric,
	(p_data->>'accountName'),
	(p_data->>'bankName'),
	(p_data->>'ifscCode'),
	(p_data->>'accountType')::smallint,
	(p_data->>'branchName')
)
	returning bank_detail_sno into _bank_detail_sno;
	return (select json_build_object('bankDetailSno',_bank_detail_sno));	
end;
$BODY$;
	

-- get_bank_detail
------------------------

CREATE OR REPLACE FUNCTION customer.get_bank_detail(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
begin
raise notice '%',p_data;
return ( select json_agg(json_build_object(
	'customerSno',d.customer_sno ,
    'accountNumber',d.account_number, 
    'accountName',account_name,
    'bankName',bank_name,
    'ifscCode',ifsc_code,
    'accountType',account_type,
	'branchName',branch_name
)) from (select * from  customer.bank_detail)d);
		
end;
$BODY$;
		
-- update_bank_detail
----------------------
		
CREATE OR REPLACE FUNCTION customer.update_bank_detail(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare
_bank_detail_sno bigint;
begin
raise notice '%',p_data;

update customer.bank_detail set
	account_number = (p_data->>'accountNumber')::numeric, 
    account_name = (p_data->>'accountName'),
    bank_name = (p_data->>'bankName'),
    ifsc_code = (p_data->>'ifscCode'),
    account_type = (p_data->>'accountType')::smallint,
	branch_name = (p_data->>'branchName') 
	where  customer_sno = (p_data->>'customerSno')::bigint and bank_detail_sno = (p_data->>'bankDetailSno')::bigint
returning bank_detail_sno into _bank_detail_sno;
return (select json_build_object('bankDetailSno',_bank_detail_sno));

end;
$BODY$;
	
	
-- insert_tax
--------------
		
CREATE OR REPLACE FUNCTION customer.insert_tax(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
declare
_tax_sno bigint;
begin
raise notice '%',p_data;
insert into customer.tax(
	customer_sno,
    pan_number, 
    tan_number,
    tds_slab_rate,
    currency_type,
    terms_of_payment,
	apply_reverse_charge,
	export_or_sez_developer
) 
values(
	(p_data->>'customerSno'),
	(p_data->>'panNumber')::numeric,
	(p_data->>'tanNumber')::numeric,
	(p_data->>'tdsSlabRate')::smallint,
	(p_data->>'currencyType')::smallint,
	(p_data->>'termsOfPayment')::smallint,
	(p_data->>'applyReverseCharge')::smallint,
	(p_data->>'exportOrSezDeveloper')::smallint
)
	returning tax_sno into _tax_sno;
	return (select json_build_object('taxSno',_tax_sno));	
end;
$BODY$;
		

-- get_tax
------------

CREATE OR REPLACE FUNCTION customer.get_tax(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
begin
raise notice '%',p_data;
return ( select json_agg(json_build_object(
	'customerSno',d.customer_sno ,
    'panNumber',d.pan_number, 
    'tanNumber',d.tan_number,
    'tdsSlabRate',d.tds_slab_rate,
    'currencyType',d.currency_type,
    'termsOfPayment',d.terms_of_payment,
	'applyReverseCharge',d.apply_reverse_charge,
	'exportOrSezDeveloper',d.export_or_sez_developer
)) from (select * from  customer.bank_detail)d);
		
end;
$BODY$;
		 
-- update_tax
--------------
		
CREATE OR REPLACE FUNCTION customer.update_tax(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare
_tax_sno bigint;
begin
raise notice '%',p_data;

update customer.tax set
	pan_number = (p_data->>'panNumber')::numeric, 
    tan_number= (p_data->>'tanNumber')::numeric,
    tds_slab_rate = (p_data->>'tdsSlabRate')::smallint	,
    currency_type = (p_data->>'currencyType')::smallint,
    terms_of_payment = (p_data->>'termsOfPayment')::smallint,
	apply_reverse_charge = (p_data->>'applyReverseCharge')::smallint,
	export_or_sez_developer = (p_data->>'exportOrSezDeveloper')::smallint
	where  customer_sno = (p_data->>'customerSno')::bigint and tax_sno = (p_data->>'taxSno')::bigint
returning tax_sno into _tax_sno;
return (select json_build_object('taxSno',_tax_sno));

end;
$BODY$;
	