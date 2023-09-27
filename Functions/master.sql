-- insert_additional_charges
----------------------------

CREATE OR REPLACE FUNCTION master.insert_additional_charges(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
declare
_additional_charges_sno smallint;
begin
raise notice '%',p_data;
insert into master.additional_charges(charges_name,charges_amt,active_flag) values((p_data->>'chargesName'),(p_data->>'chargesAmt')::numeric,(p_data->>'activeFlag')::boolean)
				returning additional_charges_sno into _additional_charges_sno;
	return (select json_build_object('additionalChargesSno',_additional_charges_sno));	
end;
$BODY$;


-- get_additional_charges
-------------------------

CREATE OR REPLACE FUNCTION master.get_additional_charges(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
declare
begin
	return (
		select json_agg(json_build_object(
			'chargesName',charges_name,
			'chargesAmt',charges_amt,
			'activeFlag',active_flag::text
		)) from master.additional_charges 
		   );	
end;
$BODY$;

-- update_additional_charges
----------------------------

CREATE OR REPLACE FUNCTION master.update_additional_charges(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
declare
_additional_charges_sno smallint;
begin
raise notice '%',p_data;

update master.additional_charges  set charges_name = (p_data->>'chargesName'),
charges_amt = (p_data->>'chargesAmt'),
active_flag = (p_data->>'activeFlag')::boolean

where additional_charges_sno = (p_data->>'additional_charges_sno')::smallint

returning  additional_charges_sno into _additional_charges_sno;

return (select json_build_object('additionalChargesSno',_additional_charges_sno));

end;
$BODY$;


-- delete_additional_charges
-----------------------------

CREATE OR REPLACE FUNCTION master.delete_additional_charges(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
declare
 _additional_charges_sno smallint;
begin
raise notice '%',p_data;

delete from master.additional_charges where additional_charges_sno =(p_data->>'additionalChargesSno')::smallint 

returning additional_charges_sno into _additional_charges_sno;

return (select json_build_object('data',json_build_object('additionalChargesSno',additional_charges_sno)));

end;
$BODY$;