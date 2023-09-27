
--insert_notification
----------------------

CREATE OR REPLACE FUNCTION notification.insert_notification(p_data json)
    RETURNS json
AS $BODY$
declare
notificationSno bigint;
begin

insert into notification.notification(title,message,action_id,router_link,from_id,to_id,created_on,
							   notification_status_cd) values
(p_data->>'title',p_data->>'message',(p_data->>'actionId')::bigint,p_data->>'routerLink'
 ,(p_data->>'fromId')::bigint,(p_data->>'toId')::bigint,portal.get_time_with_zone(json_build_object('timeZone',p_data->>'createdOn'))::timestamp,
(p_data->>'notificationStatusCd')::smallint)
returning notification_sno into notificationSno;

  return (select json_build_object('data',json_build_object('notificationSno',notificationSno)));

end;
$BODY$
LANGUAGE plpgsql;

--get_all_notification
------------------------

CREATE OR REPLACE FUNCTION notification.get_all_notification(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $BODY$
declare 
notificationSno bigint;
begin
return ( select json_build_object('data', (select  json_agg(jsonb_build_object('notificationSno',n.notification_sno,
							 	  'logo',(select company.get_logo(json_build_object('appUserSno',n.from_id))->>'mediaUrl'),
								  'title',n.title,
								  'message',n.message,
								  'actionId',n.action_id,
								  'routerLink',n.router_link,
								  'fromId',n.from_id,
								  'toId',n.to_id,
								  'createdOn',n.created_on,
								  'activeFlag',n.active_flag,
								  'notificationStatusCd',n.notification_status_cd
								 )
				 ||   jsonb_strip_nulls (jsonb_build_object('status',(select follow_status_cd from  company.company_follow where company_follow_sno = n.action_id)))
				) from (select * from notification.notification  where active_flag =true and to_id = (p_data->>'appUserSno')::bigint
										 order by notification_sno desc 
										 offset (p_data->>'skip')::bigint limit (p_data->>'limit')::bigint
										) n)));

end;
$BODY$;


--get_notification_count
-------------------------

CREATE OR REPLACE FUNCTION notification.get_notification_count(p_data json)
    RETURNS json
    
AS $BODY$
declare 
v_notification_count bigint;
begin
select  count(to_id) into v_notification_count from notification.notification 
where active_flag = true and to_id=(p_data->>'appUserSno')::bigint and  notification_status_cd=45;
return (select json_agg( json_build_object('notificationCount',v_notification_count)));
end;
$BODY$
LANGUAGE plpgsql;

--insert_multiple_notification
-------------------------------

CREATE OR REPLACE FUNCTION notification.insert_multiple_notification(p_data json)
    RETURNS json
AS $BODY$
declare
notificationSno bigint;
begin
raise notice 'p_notification_list% ',p_data;

insert into notification.notification (title,message,action_id,router_link,from_id,to_id,created_on,notification_status_cd) 
SELECT (value->>'title')::text,(value->>'message')::text,(value->>'actionId')::bigint,(value->>'routerLink')::text,(value->>'fromId')::bigint,(value->>'toId')::bigint,(value->>'timeZone')::timestamp,(value->>'notificationStatusCd')::smallint
FROM json_array_elements((p_data->>'notificationList')::json);

return ( json_build_object('data',json_build_object('isSuccess',true)));

end;
$BODY$
LANGUAGE plpgsql;

--update_notification_status
----------------------------
CREATE OR REPLACE FUNCTION notification.update_notification_status(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
begin
update notification.notification set notification_status_cd =46   where notification_sno=(p_data->>'notificationSno')::bigint;
return  (json_build_object('notificationSno',(p_data->>'notificationSno')::bigint));
end;
$BODY$;

--update_all_notification_status
--------------------------------

CREATE OR REPLACE FUNCTION notification.update_all_notification_status(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
begin
update notification.notification set notification_status_cd =46   where to_id=(p_data->>'toId')::bigint;
return  (json_build_object('data',json_build_object('notificationSno',(p_data->>'notificationSno')::bigint)));
end;
$BODY$;


--notification.followers_job_notification
-----------------------------------------

CREATE OR REPLACE FUNCTION notification.followers_job_notification(p_data json)
    RETURNS json
AS $BODY$
declare 
o_notification json;
o_push_token json;
companyName text;
begin

select json_agg(json_build_object(
'push_token_id',sc.push_token_id,
'from_id',eu.app_user_sno,
'to_id',sc.app_user_sno,
'company_name',c.company_name
)) into o_notification from employer.job j
inner join employer.employer_user eu on eu.app_user_sno = j.app_user_sno
inner join candidate.employer_followers ef on ef.company_sno = eu.company_sno
inner join employer.company c on c.company_sno = ef.company_sno
inner join candidate.candidate_user cu on cu.candidate_sno = ef.candidate_sno
inner join portal.signin_config sc on sc.app_user_sno = cu.app_user_sno and sc.active_flag = true
where j.job_sno = (p_data->>'jobSno')::bigint limit 1000;

raise notice 'notification %',o_notification;

insert into notification.notification (title,message,action_id,router_link,from_id,to_id,created_on,notification_status_cd)
select 'New Job Posted',INITCAP(n->>'company_name') || ' is posted new job' ,(p_data->>'jobSno')::bigint,'/jobs-list',(n->>'from_id')::bigint,(n->>'to_id')::bigint,portal.get_time_with_zone(json_build_object('timeZone','Asia/Kolkata'))::timestamp,75 
from json_array_elements(o_notification) n returning message into companyName;

select json_agg(i->>'push_token_id') into o_push_token from json_array_elements(o_notification) i;

return json_build_object('notification',json_build_object(
															'notification',json_build_object(
																'title','New Job Posted',
																'body',companyName
															),
															'android',json_build_object(
																'notification',json_build_object(
																	'title','New Job Posted',
																	'body',companyName
															)),
															 'data',json_build_object(
																 'jobSno',(p_data->>'jobSno')::bigint,
															 	  'navigateUrl','/'
															 ),
															 'registration_ids',o_push_token
															));

end;
$BODY$
LANGUAGE plpgsql;



--get_notification_setting
--------------------------

CREATE OR REPLACE FUNCTION notification.get_notification_setting(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare
notificationSetting json;
begin

select json_agg(json_build_object(
	'notificationSettingSno',n.notification_setting_sno,
	'appUserSno',n.app_user_sno
)) into notificationSetting from notification.notification_setting n;
return notificationSetting;
end;
$BODY$;


--insert_notification_setting
-----------------------------

CREATE OR REPLACE FUNCTION notification.insert_notification_setting(
	p_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
notificationSettingSno bigint;
begin

insert into notification.notification_setting(app_user_sno,is_notification) 
					   values (
					   (p_data->>'appUserSno')::bigint,false)
					   returning notification_setting_sno into notificationSettingSno;

return (select json_build_object('notificationSettingSno',notificationSettingSno));
end;
$BODY$;


--delete_notification_setting
-----------------------------


CREATE OR REPLACE FUNCTION notification.delete_notification_setting(p_data json)
RETURNS json
LANGUAGE 'plpgsql'
AS $BODY$
declare
_notification_setting_sno bigint;
begin
delete from notification.notification_setting
where app_user_sno=(p_data->>'appUserSno')::bigint 

returning notification_setting_sno into _notification_setting_sno;

return (select (json_build_object('notificationSettingSno',_notification_setting_sno)));
end;
$BODY$;


--select * from notification.followers_job_notification('{"jobSno":8}');