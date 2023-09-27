select * from portal.insert_app_user(json_build_object('email','admin@ems.com','password','Apple123','role','1'));


-- create menu
---------------

select * from portal.create_menu('{"appMenuSno":1, "title":"Dashboard","href":"","icon":"pie-chart-alt-2","routerLink":"/dashboard","hasSubMenu":false,
"parentMenuSno":0,"roleCd":"{1}","target":"","seqNo":1}');

select * from portal.create_menu('{"appMenuSno":2,"title":"Customer","href":"","icon":"user","routerLink":"/customer","hasSubMenu":false,
"parentMenuSno":0,"roleCd":"{1}","target":"","seqNo":2}');

select * from portal.create_menu('{"appMenuSno":3,"title":"Invoices","href":"","icon":"calendar-check","routerLink":"/invoice","hasSubMenu":false,
"parentMenuSno":0,"roleCd":"{1}","target":"","seqNo":3}');

select * from portal.create_menu('{"appMenuSno":4,"title":"Master","href":"","icon":"receipt","routerLink":"null","hasSubMenu":true,
"parentMenuSno":0,"roleCd":"{1}","target":"","seqNo":4}');

select * from portal.create_menu('{"appMenuSno":5,"title":"Additional Charges","href":"","icon":"","routerLink":"/additional_charges","hasSubMenu":false,
"parentMenuSno":4,"roleCd":"{1}","target":"","seqNo":5}');

select * from portal.create_menu('{"appMenuSno":6,"title":"Goods&Services","href":"","icon":"","routerLink":"/services","hasSubMenu":false,
"parentMenuSno":4,"roleCd":"{1}","target":"","seqNo":6}');