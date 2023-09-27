CREATE TABLE IF NOT EXISTS notification.notification(
    notification_sno serial PRIMARY KEY,
    title text,
    message text,
    action_id bigint,
    router_link text,
    from_id bigint,
    to_id bigint NOT NULL,
    created_on timestamp DEFAULT NOW(),
    active_flag boolean DEFAULT true,
	notification_status_cd smallint,
    FOREIGN KEY(from_id) REFERENCES portal.app_user(app_user_sno),
    FOREIGN KEY(to_id) REFERENCES portal.app_user(app_user_sno),
	FOREIGN KEY(notification_status_cd) REFERENCES portal.codes_dtl(codes_dtl_sno)
);


CREATE TABLE IF NOT EXISTS notification.notification_setting(
    notification_setting_sno serial PRIMARY KEY,
    app_user_sno bigint NOT NULL,
    is_notification boolean NOT NULL,
    FOREIGN KEY(app_user_sno) REFERENCES portal.app_user(app_user_sno)
);
