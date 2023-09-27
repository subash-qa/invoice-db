-- insert_company
------------------

CREATE OR REPLACE FUNCTION company.insert_company(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
declare
_company_sno bigint;
begin
raise notice '%',p_data;
insert into company.company(
	company_name,
    logo,
    alternate_company_name,
    entity_type, 
    gstin,
    mobile_number,
    email
) 
values(
	(p_data->>'companyName'),
	(p_data->>'logo')::smallint,
	(p_data->>'alternateCompanyName'),
	(p_data->>'entityType')::smallint,
	(p_data->>'gstIn'),
	(p_data->>'mobileNumber'),
	(p_data->>'email')
)
		returning company_sno into _company_sno;
	return (select json_build_object('companySno',_company_sno));	
end;
$BODY$;


--get_company
--------------

CREATE OR REPLACE FUNCTION company.get_company(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
begin
raise notice '%',p_data;
return (select json_agg(json_build_object(
			'companySno',d.company_sno,
			'companyName',d.company_name,
			'logo',d.logo,
			'alternateCompanyName',d.alternate_company_name,
			'entityType',d.entity_type,
			'gstin',d.gstin,
			'mobileNumber',d.mobile_number,
			'email',d.email
)) from ( select * from company.company )d);
 
end;
$BODY$;

-- update_company
-------------------

CREATE OR REPLACE FUNCTION company.update_company(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare
_company_sno bigint;
begin
raise notice '%',p_data;

update company.company set
	company_name = (p_data->>'companyName'),
	logo = (p_data->>'logo'),
	alternate_company_name = (p_data->>'alternateCompanyName'),
	entity_type = (p_data->>'entityType')::smallint, 
    gstin = (p_data->>'gstIn'),
    mobile_number = (p_data->>'mobileNumber'),
    email = (p_data->>'email')
	where company_sno = (p_data->>'companySno')::bigint
returning company_sno into _company_sno;

return (select json_build_object('companySno',_company_sno));

end;
$BODY$;

-- insert_address
------------------

CREATE OR REPLACE FUNCTION company.insert_address(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
declare
_address_sno bigint;
begin
raise notice '%',p_data;
insert into company.address(
	company_sno,
    address_line_1, 
    address_line_2,
    city,
    pincode,
    state
) 
values(
	(p_data->>'companySno'),
	(p_data->>'addressLine1'),
	(p_data->>'addressLine2'),
	(p_data->>'city'),
	(p_data->>'pinCode')::smallint,
	(p_data->>'state')::bigint
)
		returning address_sno into _address_sno;
	return (select json_build_object('addressSno',_address_sno));	
end;
$BODY$;

-- get_address
----------------------

CREATE OR REPLACE FUNCTION company.get_address(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
begin
raise notice '%',p_data;
return (select json_agg(json_build_object(
	'addressSno',address_sno,
	'companySno',company_sno,
    'addressLine1',address_line_1, 
    'addressLine2',address_line_2,
    'city',city,
    'pinCode',pincode
)) from ( select * from company.address )d );
 
end;
$BODY$;


-- update_address
------------------

CREATE OR REPLACE FUNCTION company.update_address(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare
_address_sno bigint;
begin
raise notice '%',p_data;

update company.address set
	address_line_1 = (p_data->>'addressLine1'), 
    address_line_2 = (p_data->>'addressLine2'),
    city = (p_data->>'city'),
    pincode = (p_data->>'pinCode')::smallint,
    state =  (p_data->>'state')::bigint where address_sno = (p_data->>'addressSno')::bigint
returning address_sno into _address_sno;
return (select json_build_object('addressSno',_address_sno));

end;
$BODY$;


-- insert_goods
----------------

CREATE OR REPLACE FUNCTION company.insert_goods(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
declare
_goods_sno bigint;
begin
raise notice '%',p_data;
insert into company.goods(
	company_sno,
    goods_name,
    price,
    inclusive_of_gst,
    gst_rate, 
    none_taxable,
    net_price,
    hsn_code,
    unites,
    cress_amount,
    sku,
    description
) 
values(
	(p_data->>'companySno')::bigint,
	(p_data->>'goodsName'),
	(p_data->>'price')::double precision,
	(p_data->>'inclusiveOfGst')::smallint,
	(p_data->>'gstRate')::smallint,
	(p_data->>'noneTaxable')::numeric,
	(p_data->>'netPrice')::numeric,
	(p_data->>'hsnCode'),
	(p_data->>'unites')::smallint,
	(p_data->>'cressAmount')::numeric,
	(p_data->>'sku') ,
	(p_data->>'description')
)
		returning goods_sno into _goods_sno;
	return (select json_build_object('goodsSno',_goods_sno));	
end;
$BODY$;


-- get_goods
-------------

CREATE OR REPLACE FUNCTION company.get_goods(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
begin
raise notice '%',p_data;
return (select json_agg(json_build_object(
	'goodsSno',goods_sno,
	'companySno',company_sno,
	'goodsName',goods_name,
    'price',price, 
    'inclusiveOfGst',inclusive_of_gst,
    'gstRate',gst_rate,
    'noneTaxable',none_taxable,
	'netPrice',net_price,
	'hsnCode',hsn_code,
	'unites',unites,
	'cressAmount',cress_amount,
	'sku',sku,
	'description',description
)) from ( select * from company.goods )d );
 
end;
$BODY$;


-- update_goods
----------------

CREATE OR REPLACE FUNCTION company.update_goods(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare
_goods_sno bigint;
begin
raise notice '%',p_data;

update company.goods set
	goods_name = (p_data->>'goodsName'),
    price=(p_data->>'price')::double precision,
    inclusive_of_gst=(p_data->>'inclusiveOfGst')::smallint,
    gst_rate=(p_data->>'gstRate')::smallint,
    none_taxable=(p_data->>'noneTaxable')::numeric,
    net_price=(p_data->>'netPrice')::numeric,
    hsn_code=(p_data->>'hsnCode'),
    unites=(p_data->>'unites')::smallint,
    cress_amount=(p_data->>'cressAmount')::numeric,
    sku=(p_data->>'sku'),
    description=(p_data->>'description') where goods_sno = (p_data->>'goodsSno')::bigint
returning goods_sno into _goods_sno;
return (select json_build_object('goodsSno',_goods_sno));

end;
$BODY$;


-- insert_services
------------------

CREATE OR REPLACE FUNCTION company.insert_services(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
declare
_service_sno bigint;
begin
raise notice '%',p_data;
insert into company.services(
	company_sno,
    service_name,
    price,
    inclusive_of_gst,
    gst_rate, 
    net_price,
	sac_code,
    cress_amount,
    none_taxable,
	description
) 
values(
	(p_data->>'companySno')::bigint,
	(p_data->>'serviceName'),
	(p_data->>'price')::double precision,
	(p_data->>'inclusiveOfGst')::smallint,
	(p_data->>'gstRate')::smallint,
	(p_data->>'netPrice')::numeric,
	(p_data->>'sacCode'),
	(p_data->>'cressAmount')::numeric,
	(p_data->>'noneTaxable')::numeric,
	(p_data->>'description')
)
		 returning service_sno into _service_sno;
	return (select json_build_object('serviceSno',_service_sno));	
end;
$BODY$;


-- get_services
----------------

CREATE OR REPLACE FUNCTION company.get_services(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
begin
raise notice '%',p_data;
return (select json_agg(json_build_object(
	'serviceSno',service_sno,
	'serviceName',service_name,
    'price',price,
    'inclusiveOfGst',inclusive_of_gst,
    'gstRate',gst_rate, 
    'netPrice',net_price,
	'sacCode',sac_code,
    'cressAmount',cress_amount,
    'noneTaxable',none_taxable,
	'description',description
	
)) from ( select * from company.services )d );
 
end;
$BODY$;


-- update_services
------------------

CREATE OR REPLACE FUNCTION company.update_services(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare
_service_sno bigint;
begin
raise notice '%',p_data;

update company.services set
	service_name =(p_data->>'serviceName'),
    price=(p_data->>'price')::double precision,
    inclusive_of_gst=(p_data->>'inclusiveOfGst')::smallint,
    gst_rate=(p_data->>'gstRate')::smallint,
    net_price=(p_data->>'netPrice')::numeric,
	sac_code=(p_data->>'sacCode'),
    cress_amount=(p_data->>'cressAmount')::numeric,
    none_taxable=(p_data->>'noneTaxable')::numeric,
	description=(p_data->>'description') where service_sno = (p_data->>'serviceSno')::bigint
returning service_sno into _service_sno;
return (select json_build_object('serviceSno',_service_sno));

end;
$BODY$;
	
