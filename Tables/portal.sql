--portal schema tables

CREATE TABLE IF NOT EXISTS portal.codes_hdr(
    codes_hdr_sno smallserial PRIMARY KEY,
    code_type text NOT NULL,
    active_flag boolean NOT NULL default true
);

CREATE TABLE IF NOT EXISTS portal.codes_dtl(
    codes_dtl_sno smallserial PRIMARY KEY,
    codes_hdr_sno smallint NOT NULL,
    cd_value TEXT NOT NULL,
    seqno INT,
    filter_1 TEXT,
    filter_2 TEXT,
    active_flag boolean NOT NULL default true,
    FOREIGN KEY(codes_hdr_sno) REFERENCES portal.codes_hdr(codes_hdr_sno)
);

CREATE TABLE IF NOT EXISTS portal.app_user(
    app_user_sno bigserial PRIMARY KEY,
    email varchar(254) NOT NULL UNIQUE,
    active_status boolean,
    password varchar(16) not null, -- user_status_cd smallint NOT NULL,
    azure_id text,
    is_notification boolean default true,
	is_new_password boolean default false
);


CREATE TABLE IF NOT EXISTS portal.app_user_role(
    app_user_role_sno bigserial PRIMARY KEY,
    app_user_sno bigint NOT NULL,
    role_cd smallint NOT NULL,
    --FOREIGN KEY(app_user_sno) REFERENCES portal.app_user(app_user_sno)
    FOREIGN KEY(role_cd) REFERENCES portal.codes_dtl(codes_dtl_sno)
);


-- CREATE TABLE IF NOT EXISTS portal.otp(
--     otp_sno bigserial PRIMARY KEY,
--     app_user_sno BIGINT NOT NULL,
--     email_otp varchar(6) not null,
--     api_otp varchar(10) NOT NULL,
--     push_otp varchar(10) NOT NULL,
--     device_id text NOT NULL,
--     expire_time TIMESTAMP NOT NULL,
--     active_flag boolean NOT NULL default true,
--     FOREIGN KEY(app_user_sno) REFERENCES portal.app_user(app_user_sno)
-- );


CREATE TABLE IF NOT EXISTS portal.signin_config(
    signin_config_sno bigserial PRIMARY KEY,
    app_user_sno bigint NOT NULL,
    push_token_id text,
    device_type_cd smallint NOT NULL,
    device_id text NOT NULL,
    active_flag boolean default true,
    --FOREIGN KEY(app_user_sno) REFERENCES portal.app_user(app_user_sno),
    FOREIGN KEY(device_type_cd) REFERENCES portal.codes_dtl(codes_dtl_sno)
);



CREATE TABLE IF NOT EXISTS portal.app_menu (
    app_menu_sno smallserial PRIMARY KEY,
    title text not null,
    href text,
    icon text,
    target text,
    has_sub_menu boolean,
    parent_menu_sno integer,
    router_link text,
    seq_no smallint not null default 0
);

CREATE TABLE IF NOT EXISTS portal.app_menu_role (
    app_menu_role_sno smallserial PRIMARY KEY,
    app_menu_sno integer NOT NULL,
    role_cd integer NOT NULL,
    FOREIGN KEY(app_menu_sno) REFERENCES portal.app_menu(app_menu_sno)
);


CREATE TABLE IF NOT EXISTS portal.app_menu_user (
    app_menu_user_sno smallserial PRIMARY KEY,
    app_menu_sno integer NOT NULL,
    app_user_sno bigint NOT NULL,
    is_admin boolean,
    FOREIGN KEY(app_menu_sno) REFERENCES portal.app_menu(app_menu_sno)
    --FOREIGN KEY(app_user_sno) REFERENCES portal.app_user(app_user_sno)
);





