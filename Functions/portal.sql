
-- create_menu
----------------

CREATE OR REPLACE FUNCTION portal.create_menu(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare 
 _app_menu_sno int; 
 _app_menu_role int;
 id int;
 role_cd  int[]:= (p_data->>'roleCd')::int[];
 begin
 
	INSERT INTO portal.app_menu(app_menu_sno,title,href,icon,has_sub_menu,parent_menu_sno,router_link,target,seq_no) 
	   VALUES (
               (p_data->>'appMenuSno')::smallint,
               p_data->>'title',
			   p_data->>'href',
			   p_data->>'icon',
		 	  (p_data->>'hasSubMenu')::boolean,
			   (p_data->>'parentMenuSno')::integer,
			   p_data->>'routerLink',
               p_data->>'target',
		   	(p_data->>'seqNo')::smallint
			   )  
	   returning app_menu_sno into _app_menu_sno;
		
		 perform portal.create_menu_by_role(_app_menu_sno,role_cd);
		return (select json_agg(json_build_object('appMenuSno',_app_menu_sno)));
	
	end;
$BODY$;


-- createmenubyrole
---------------------

 CREATE OR REPLACE FUNCTION portal.create_menu_by_role(
	p_app_menu integer,
	role_cd integer[])
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
 id int;
  

 begin
  
    --    delete from portal.app_menu_role where app_menu_sno = p_app_menu; 
	
		    foreach  id in  array role_cd loop
		       INSERT INTO portal.app_menu_role(app_menu_sno,role_cd) 
	           VALUES (p_app_menu,(id)::integer);
		    end loop;
 end;
$BODY$;


-- create_app_menu_role
-------------------------

CREATE OR REPLACE FUNCTION portal.create_app_menu_role(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
appMenuRoleSno bigint;
begin
-- raise notice '%',p_data;

insert into portal.app_menu_role (app_menu_sno,
								  role_cd) values ((p_data->>'appMenuSno')::integer,
												   (p_data->>'roleCd')::integer
												 ) returning app_menu_role_sno into appMenuRoleSno;

  return (select json_build_object('appMenuRoleSno',appMenuRoleSno));

end;
$BODY$;


-- create_menu_by_role
-----------------------
 
 CREATE OR REPLACE FUNCTION portal.create_menu_by_role(
	p_app_menu integer,
	role_cd integer[])
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
 id int;

 begin
    --    delete from portal.app_menu_role where app_menu_sno = p_app_menu; 
	
		    foreach  id in  array role_cd loop
		       INSERT INTO portal.app_menu_role(app_menu_sno,role_cd) 
	           VALUES (p_app_menu,(id)::integer);
		    end loop;
 end;
$BODY$;


-- get_menu
------------

CREATE OR REPLACE FUNCTION portal.get_menu(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
begin
return (select json_agg(json_build_object(
	'title',am.title,
	'href',am.href,
	'icon',am.icon,
	'appMenuSno',am.app_menu_sno,
 	'hasSubMenu',am.has_sub_menu,
    'parentMenuSno',am.parent_menu_sno,
    'routerLink',am.router_link
								 )) from portal.app_menu am );
end;
$BODY$;


--get_menu_role
----------------

CREATE OR REPLACE FUNCTION portal.get_menu_role(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare 
appMenuSno smallint;
begin
raise notice '%',p_data;

return (json_build_object('data',(
	select json_agg(json_build_object(
	'title',f.title,
	'href',f.href,
	'icon',f.icon,
	'appMenuSno',f.app_menu_sno,
 	'hasSubMenu',f.has_sub_menu,
    'parentMenuSno',f.parent_menu_sno,
    'routerLink',f.router_link,
    'target',f.target,
	'isAdmin',coalesce(f.is_admin,false),
	'seqNo',f.seq_no
								 )) from 
	
	(
		select e.title,e.href,e.icon,e.app_menu_sno,e.has_sub_menu,e.parent_menu_sno,e.router_link,e.target,e.is_admin,e.seq_no from (
			select am.title,am.href,am.icon,am.app_menu_sno,am.has_sub_menu,am.parent_menu_sno,am.router_link,am.target,
			(select is_admin from portal.app_menu_user where app_user_sno = (p_data->>'appUserSno')::bigint and app_menu_sno = am.app_menu_sno),
			am.seq_no
			from portal.app_menu_role amr 
		inner join portal.app_menu am on am.app_menu_sno = amr.app_menu_sno
		where amr.role_cd = (p_data->>'roleCd')::int

		union
		
		select am.title,am.href,am.icon,am.app_menu_sno,am.has_sub_menu,am.parent_menu_sno,am.router_link,am.target,
			(select is_admin from portal.app_menu_user where app_user_sno = (p_data->>'appUserSno')::bigint and app_menu_sno = am.app_menu_sno),
			am.seq_no
			from portal.app_menu_role amr 
		inner join portal.app_menu am on am.app_menu_sno = amr.app_menu_sno
		where
		am.app_menu_sno in (select app_menu_sno from portal.app_menu_user where app_user_sno = (p_data->>'appUserSno')::bigint)) e ORDER BY e.seq_no
	)f

)));
end;
$BODY$;



-- update_app_menu_user
-------------------------

CREATE OR REPLACE FUNCTION portal.update_app_menu_user(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare
v_doc jsonb;
begin

delete from portal.app_menu_user amu where amu.app_user_sno = (p_data->>'appUserSno')::bigint;

for v_doc in  SELECT * FROM json_array_elements((p_data->>'menuIds')::json) loop

if ((v_doc->>'isMenuAssign')::boolean = true) or ((v_doc->>'isAdmin')::boolean = true) then

	insert into portal.app_menu_user (app_user_sno,app_menu_sno,is_admin) values ((p_data->>'appUserSno')::bigint,(v_doc->>'appMenuSno')::bigint,(v_doc->>'isAdmin')::boolean);

end if;

end loop;

 return (select(json_build_object('data',json_build_object('appUserSno',(p_data->>'appUserSno')::bigint))));

end;
$BODY$;


-- insert_app_user
-------------------

CREATE OR REPLACE FUNCTION portal.insert_app_user(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare 
i_app_user_sno bigint;
begin
raise notice '%',p_data;

select portal.create_app_user(p_data)->>'appUserSno' into i_app_user_sno;


return (select json_build_object('data',json_build_object('appUserSno',i_app_user_sno)));

exception when sqlstate '23505' then 
return (select json_build_object('message','This Email Id is already exits','isAlready',true));

end;
$BODY$;


-- create_app_user
-------------------

CREATE OR REPLACE FUNCTION portal.create_app_user(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
_app_user_sno bigint;
begin

INSERT INTO portal.app_user(email,password,active_status) values
(p_data->>'email',p_data->>'password',true) returning app_user_sno into _app_user_sno;

perform portal.create_app_user_role(json_build_object('appUserSno',_app_user_sno,'roleCd',
(p_data->>'role')::smallint));

-- perform portal.insert_user_profile((p_data::jsonb || jsonb_build_object('appUserSno',_app_user_sno))::json);

return (select(json_build_object('appUserSno',_app_user_sno)));

end;
$BODY$;


-- create_app_user_role
-------------------------

CREATE OR REPLACE FUNCTION portal.create_app_user_role(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
appUserRoleSno bigint;
begin
-- raise notice '%',p_data;
		

insert into portal.app_user_role(app_user_sno,
				role_cd) values 
((p_data->>'appUserSno')::bigint,
 (p_data->>'roleCd')::smallint) returning app_user_role_sno  INTO appUserRoleSno;
  return (select json_build_object('appUserRoleSno',appUserRoleSno));

end;
$BODY$;


-- signin_user
--------------

CREATE OR REPLACE FUNCTION portal.signin_user(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$

declare
_app_user_sno bigint;
_sigin_config_sno int;
isMailcount int := 0;
roleCd smallint;
roleCdValue text;
_is_notification boolean;
_email text;
_is_new_password boolean;
begin

select au.app_user_sno,au.is_notification,au.email,au.is_new_password into _app_user_sno,_is_notification,_email,_is_new_password from portal.app_user au
where lower(au.email) = lower(p_data->>'email') and au.password = p_data->>'password';
 
 if (_app_user_sno is not null) then
 
  if (select count(*) from portal.signin_config where device_id = p_data->>'deviceId' and app_user_sno = _app_user_sno ) = 0 then
 
    update portal.signin_config set active_flag = false  where device_id = p_data->>'deviceId';

    INSERT INTO portal.signin_config(app_user_sno, push_token_id,device_type_cd, device_id)
    VALUES (_app_user_sno, p_data->>'pushToken',portal.get_enum_sno((json_build_object('cd_value',p_data->>'deviceTypeName','cd_type','device_type_cd'))),
    p_data->>'deviceId') returning signin_config_sno into _sigin_config_sno;
  else
    update portal.signin_config set active_flag = false  where device_id = p_data->>'deviceId';
    update portal.signin_config set push_token_id = p_data->>'pushToken', active_flag = true where app_user_sno = _app_user_sno and device_id = p_data->>'deviceId' returning signin_config_sno into _sigin_config_sno;
 
  end if;

select dtl.cd_value,aur.role_cd, aur into roleCdValue,roleCd from portal.app_user_role aur
inner join portal.codes_dtl dtl on  dtl.codes_dtl_sno = aur.role_cd where aur.app_user_sno = _app_user_sno;


  return (select json_build_object(
  'isLogin',true,
  'msg','Login Successfully',
  'isNotification',_is_notification,							   			   
  'appUserSno',_app_user_sno,
  'signinConfigSno',_sigin_config_sno,
  'roleCdValue',roleCdValue,
  'email',_email,
  'menus',((select portal.get_menu_role(json_build_object('roleCd',roleCd,'appUserSno',_app_user_sno)) )->>'data')::json,
  'roleCd',roleCd,
  'isNewPassword',_is_new_password,
  'profileInfo', (select * from portal.get_profile(json_build_object('appUserSno',_app_user_sno))) 
));
 
 else
 
select count(*) into isMailcount from portal.app_user where lower(email) = lower(p_data->>'email');
  if (isMailcount = 0) then
--   raise exception 'invalid user';
return (select json_build_object('isLogin',false,
 'msg','This Mail Id does not exist'
));
else
-- raise exception 'invalid password';
return (select json_build_object('isLogin',false,
 'msg','Invalid Password'
));
end if;
end if;

end;
$BODY$;		



--get_user_count
-----------------

CREATE OR REPLACE FUNCTION portal.get_user_count(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare 
begin

return (json_agg(json_build_object('count',(select count(*) from portal.app_user))));

end;
$BODY$;




--get_app_user
---------------

CREATE or replace FUNCTION portal.get_app_user(p_data json) RETURNS json
    LANGUAGE plpgsql
    AS $$
declare 
begin
return ( select json_build_object('data',(
	select json_agg(json_build_object(
		'appUserSno',f.app_user_sno,
		'email',f.email,
		'password',f.password,
		'role','Employee',
		'profile',((( select portal.get_user_profile(( select (p_data)::jsonb || ('{"appUserSno": ' || f.app_user_sno ||' }')::jsonb)::json) )->0)::json),
		'work',(select portal.get_user_work(( select (p_data)::jsonb || ('{"appUserSno": ' || f.app_user_sno ||' }')::jsonb)::json) ),
		'contacts',(select portal.get_user_contact(( select (p_data)::jsonb || ('{"appUserSno": ' || f.app_user_sno ||' }')::jsonb)::json) ),
		'settings',(select portal.get_user_settings(( select (p_data)::jsonb || ('{"appUserSno": ' || f.app_user_sno ||' }')::jsonb)::json) ),
		'social',(select portal.get_user_social(( select (p_data)::jsonb || ('{"appUserSno": ' || f.app_user_sno ||' }')::jsonb)::json) ),
		'menuSelectOptions',(select json_agg(json_build_object('name',am.title,'appMenuSno',am.app_menu_sno,'isMenuAssign',false,'isAdmin',false)) 
	from portal.app_menu am 
where app_menu_sno not in (select app_menu_sno from portal.app_menu_role amr where amr.role_cd = f.role_cd)),
		'menuIds',(select json_agg(json_build_object('appMenuSno',app_menu_sno,'isAdmin',is_admin)) from portal.app_menu_user amu where amu.app_user_sno = f.app_user_sno)
	))
	from (select au.app_user_sno,au.email,au.password,aur.role_cd from portal.app_user au
	inner join portal.user_profile up on up.app_user_sno = au.app_user_sno
    inner join portal.app_user_role aur on au.app_user_sno = aur.app_user_sno and aur.role_cd = 
	(select portal.get_enum_sno(json_build_object('cd_value','Employee','cd_type','role_cd')))
where case when p_data->>'searchKey' is not null then ((up.name ilike ('%' || (p_data->>'searchKey') || '%')) or (up.surname ilike ('%' || (p_data->>'searchKey') || '%'))
or (up.mobile_phone ilike ('%' || (p_data->>'searchKey') || '%')) or (au.email ilike ('%' || (p_data->>'searchKey') || '%')) ) else true end  order by au.app_user_sno desc)f
)));
end;
$$;


-- update_user
---------------

CREATE OR REPLACE FUNCTION portal.update_user(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
_app_user_sno bigint;
begin
raise notice '%','update_app_user';
raise notice '%',p_data;
update portal.app_user set 
				email = p_data->>'email',
				password = p_data->>'password'
				,active_status = (p_data->>'status')::boolean 
				where app_user_sno = (p_data->>'appUserSno')::bigint;

return (select(json_build_object('appUserSno',(p_data->>'appUserSno'))));

end;
$BODY$;


-- update_app_user_role
----------------------
						
CREATE OR REPLACE FUNCTION portal.update_app_user_role(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
_app_user_role_sno bigint;
begin
raise notice '%',p_data;
update portal.app_user_role set app_user_sno = (p_data->>'appUserSno')::bigint,role_cd = (p_data->>'role')::smallint 
where app_user_sno = (p_data->>'appUserSno')::bigint returning app_user_role_sno into _app_user_role_sno;

return (select(json_build_object('appUserRoleSno',_app_user_role_sno)));

end;
$BODY$;


-- update_component_title
-------------------------

CREATE OR REPLACE FUNCTION portal.update_component_title(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
componenTitleSno bigint;
begin
-- raise notice '%',p_data;

update portal.component_title set title = (p_data->>'title'),
								subtitle = (p_data->>'subtitle'),
								description = (p_data->>'description'),
								component_type_cd = (p_data->>'componentTypeCd')::smallint,
								active_flag=(p_data->>'activeFlag')::boolean
								where component_title_sno = (p_data->>'componenTitleSno')::bigint 
								returning component_title_sno into componenTitleSno;

  return (select json_build_object('componenTitleSno',componenTitleSno));

end;
$BODY$;


-- update_app_user_status
--------------------------

CREATE OR REPLACE FUNCTION portal.update_app_user_status(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
_app_user_sno bigint;
begin
raise notice '%','update_app_user';
raise notice '%',p_data;
update portal.app_user set active_status = (p_data->>'status')::boolean where app_user_sno = (p_data->>'appUserSno')::bigint;

return (select(json_build_object('appUserSno',(p_data->>'appUserSno'))));

end;
$BODY$;


--get_enum_name
----------------

CREATE OR REPLACE FUNCTION portal.get_enum_name(
	p_cd_sno integer,
	p_cd_type text)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
  cd_value text;
begin

   select d.cd_value into cd_value from portal.codes_dtl d 
   inner join portal.codes_hdr h on d.codes_hdr_sno = h.codes_hdr_sno 
   where d.codes_dtl_sno = p_cd_sno and UPPER(h.code_type) = UPPER(p_cd_type) ;
   
   return cd_value;
end;
$BODY$;


-- get_enum_sno
------------------

CREATE OR REPLACE FUNCTION portal.get_enum_sno(
	p_data json)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
  cd_sno smallint;
begin
   select d.codes_dtl_sno into cd_sno from portal.codes_dtl d 
   inner join portal.codes_hdr h on d.codes_hdr_sno = h.codes_hdr_sno 
   where UPPER(d.cd_value)=UPPER(p_data->>'cd_value') and UPPER(h.code_type) = UPPER(p_data->>'cd_type') ;
   
   return cd_sno;
end;
$BODY$;


--get_enum_names
----------------

CREATE OR REPLACE FUNCTION portal.get_enum_names(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
    
AS $BODY$
declare 
begin

return  (select json_agg(json_build_object('codesDtlSno',d.codes_dtl_sno,'cdValue',d.cd_value,'filter1',d.filter_1,'filter2',d.filter_2)) from (select * from portal.codes_dtl cdl where  
cdl.codes_hdr_sno = (select hdr.codes_hdr_sno from portal.codes_hdr hdr where hdr.code_type = p_data->>'codeType') and case when (p_data->>'filter1') is not null then 
		  filter_1 = (p_data->>'filter1')  else true end order by cdl.seqno asc)d);
end;
$BODY$;


-- get_time_with_zone
------------------------

CREATE OR REPLACE FUNCTION portal.get_time_with_zone(p_data json)
  RETURNS text
 LANGUAGE plpgsql AS
$$
BEGIN

return (select (select now() AT TIME ZONE (p_data->>'timeZone')::text)::text);

END;
$$;



-- get_push_token
------------------

CREATE OR REPLACE FUNCTION portal.get_push_token(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare 
begin

return (select json_build_object('token',(select json_agg(sc.push_token_id) from portal.signin_config sc where sc.active_flag = true and sc.app_user_sno = (p_data->>'appUserSno')::bigint)));
   
end;
$BODY$;


-- get_profile
---------------

CREATE OR REPLACE FUNCTION portal.get_profile(p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
   AS $BODY$
declare
begin
	return (
		select json_build_object(
			 'employeeSno',e.employee_sno,
			 'employeeName', case when (e.middle_name is not null and e.last_name is not null)  then  
							(e.first_name || ' ' || e.middle_name || ' ' || e.last_name)
							when e.middle_name is not null then (e.first_name || ' ' || e.middle_name)
							when e.last_name is not null then (e.first_name || ' ' || e.last_name) else e.first_name  end,
			  'image',(select media.get_media_detail(json_build_object('mediaSno',e.profile_image))->0)
		) from  ems.employee e
inner join ems.emp_user eu on eu.employee_sno = e.employee_sno
where eu.app_user_sno = (p_data->>'appUserSno')::bigint
		   );	
end;
$BODY$;


--logout
----------

CREATE OR REPLACE FUNCTION portal.logout(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
signinConfigSno bigint;
begin
-- raise notice '%',p_data;
update portal.signin_config set active_flag = false
								where signin_config_sno = (p_data->>'signinConfigSno')::bigint 
								returning signin_config_sno into signinConfigSno;

  return (select json_build_object('signinConfigSno',signinConfigSno));

end;
$BODY$;


-- update_password
---------------------

CREATE OR REPLACE FUNCTION portal.update_password(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare 
_app_user_sno bigint;
begin


if((p_data->>'appUserSno')::bigint is not null) then
update portal.app_user
set password = (p_data->>'confirmPassword'),is_new_password=true
where app_user_sno = (p_data->>'appUserSno')::bigint; 

return (select(json_build_object('isUpdate',true)));
 else  
 return (select(json_build_object('msg','This User Does Not Exist')));
  end if;
end;
$BODY$;



