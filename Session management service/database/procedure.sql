drop procedure if exists signIn;
DELIMITER //
CREATE PROCEDURE signIn(
				IN hoivien varchar(255),
                IN matkhau varchar(255),
                IN maytinh int,
                out `status` boolean,
                out	session_id int
                )
BEGIN
    declare tai_khoan varchar(255);
    declare id_may_tinh int;
    declare latest_end_time_account datetime;
    declare start_time datetime;
    declare latest_end_time_pc datetime;
    select `account` into tai_khoan from `Hoi Vien` where `account` =  hoivien and `password`= matkhau;
    select id into id_may_tinh from `may tinh` where id = maytinh;
    if tai_khoan is not null and id_may_tinh is not null then
		select `gio ket thuc`, `gio bat dau` into latest_end_time_account, start_time 
        from `session` 
        where `tai khoan hv`= tai_khoan
        ORDER BY `gio bat dau` DESC
		LIMIT 1;
        select `gio ket thuc` into latest_end_time_pc
        from `session` 
        where `id may tinh` = id_may_tinh
        ORDER BY `gio bat dau` DESC
		LIMIT 1;
        if start_time is null then
			insert into `session` (`gio bat dau`,`id may tinh`,`tai khoan hv`) values (now(),maytinh,hoivien);
			set `status`=true;
            select `Session ID` into session_id from `session` where `id may tinh`=id_may_tinh and `gio ket thuc` is null;
        else
			if latest_end_time_account is null or latest_end_time_pc is null then
				set `status` = FALSE;
			else
				if latest_end_time_account > now() or latest_end_time_pc>now() then
                    set `status`=False;
				else
					insert into `session` (`gio bat dau`,`id may tinh`,`tai khoan hv`) values (now(),maytinh,hoivien);
					set `status`=true;
                    select `Session ID` into session_id from `session` where `id may tinh`=id_may_tinh and `gio ket thuc` is null;
				end if;
			end if;
		end if;
	ELSE
		set `status` = FALSE;
	END IF;
END; 
//
DELIMITER ;
DELIMITER //
create procedure signOutBySessionID(
	in session_id int
)
BEGIN
	update `session` set `gio ket thuc` = now() where `session id` = session_id;
END ;
//
DELIMITER ;
DELIMITER //
create procedure signOutByAccount(
	in `account` char(255)
)
BEGIN
	update `session` set `gio ket thuc` = now() where `tai khoan hv` = `account` and `gio ket thuc` is null;
END ;
//
DELIMITER ;
DELIMITER //
create procedure signOutByPCID(
	in pc_id int
)
BEGIN
	update `session` set `gio ket thuc` = now() where `id may tinh` = pc_id and `gio ket thuc` is null;
END ;
//
DELIMITER ;
DELIMITER //
-- for compute the  price
create procedure getDiscountForProduct(
	in product_id int,
    in so_luong int,
    in date_apply date,
    out ma_khuyen_mai int,
    out muc_giam float
)
begin
	select `khuyen mai`.`ma khuyen mai`, `muc giam` into ma_khuyen_mai, muc_giam from `khuyen mai` join `ap dung san pham` 
    on `khuyen mai`.`ma khuyen mai` = `ap dung san pham`.`ma khuyen mai`
    where `ap dung san pham`.`ma san pham` = product_id 
    and `khuyen mai`.`dieu kien` <= so_luong
    and `khuyen mai`.`ngay bat dau` <= date_apply 
    and `khuyen mai`.`ngay ket thuc`>=date_apply 
    order by `khuyen mai`.`muc giam` desc, `khuyen mai`.`ma khuyen mai` ASC 
    limit 1;
end;
//
DELIMITER ;
DELIMITER //
CREATE PROCEDURE addProductToBill(
    IN product_id INT,
    IN so_luong INT,
    IN bill_id INT
)
begin
	DECLARE date_apply datetime;
    DECLARE muc_giam FLOAT;
    declare ma_khuyen_mai int;
    DECLARE thanh_tien INT;
    DECLARE bill_cost INT;
    SELECT `ngay thuc hien` INTO date_apply FROM `hoa don` WHERE `ma hoa don` = bill_id;
    CALL getDiscountForProduct(product_id, so_luong, date_apply,ma_khuyen_mai,muc_giam);
    SELECT `gia niem yet` INTO thanh_tien FROM `san pham` WHERE `ma san pham` = product_id;
    SELECT `tong tien` INTO bill_cost FROM `hoa don` WHERE `ma hoa don` = bill_id;
    IF muc_giam IS NOT NULL THEN
        SET thanh_tien = (1 - muc_giam) * thanh_tien*so_luong;
    END IF;

    SET bill_cost = bill_cost + thanh_tien;
    UPDATE `hoa don` SET `tong tien` = bill_cost WHERE `ma hoa don` = bill_id;

    INSERT INTO `chua` (`ma hoa don`, `ma san pham`, `so luong`) VALUES (bill_id, product_id, so_luong);
end;
//
DELIMITER ;
DELIMITER //
create procedure applyDiscountToBill(
	in bill_id int
)
begin
	declare muc_giam float;
    declare bill_cost int;
    declare id_khuyen_mai int;
    declare ngay_thuc_hien datetime;
	select `ngay thuc hien`, `tong tien` into ngay_thuc_hien,bill_cost from `hoa don` where `ma hoa don` = bill_id;
    select `ma khuyen mai` ,`muc_giam` into id_khuyen_mai,muc_giam from `khuyen mai` 
    where `loai` = 'bill' 
    and `dieu kien` <= bill_cost
    and ngay_thuc_hien >= `ngay bat dau`
    and ngay_thuc_hien <= `ngay ket thuc`;
    if id_khuyen_mai is not null then
		set bill_cost = (1-muc_giam)*bill_cost;
        insert into `ap dung hoa don` (`ma hoa don`, `ma khuyen mai`) values (bill_id,id_khuyen_mai);
        update `hoa don` set `tong tien` = bill_cost where `ma hoa don`=bill_id;
    end if;
end;
//
DELIMITER ;
DELIMITER //
create procedure addNewDiscount(
	in id int,
    in program_name varchar(255),
    in program_description varchar(255),
    in start_datetime datetime,
    in end_datetime datetime,
    in apply_on_bill boolean,
    in dieu_kien int,
    in muc_giam float
)
begin
	declare loai_km varchar(255);
    if apply_on_bill then
		set loai_km = 'bill';
	else
		set loai_km = 'product';
    end if;
    insert into `khuyen mai` (`ma khuyen mai`,`ten chuong trinh`,`mo ta`,`ngay bat dau`,`ngay ket thuc`,loai,`dieu kien`,`muc giam`)
    values (id,program_name,program_description,start_datetime,end_datetime,loai_km,dieu_kien,muc_giam);
end;
//
DELIMITER ;
DELIMITER //
create procedure addNewProductForDiscount(
	in discount_id int,
    in product_id int
)
begin
	insert into `ap dung san pham` (`ma san pham`, `ma khuyen mai`) values (product_id,discount_id);
end;
//
DELIMITER ;
DELIMITER //

CREATE PROCEDURE AddHoiVien(
    IN p_account CHAR(255),
    IN p_password CHAR(255),
    IN p_ten CHAR(255),
    IN p_sdt CHAR(10),
    IN p_email CHAR(255)
)
BEGIN
    INSERT INTO `Hoi Vien` (
        `account`,
        `password`,
        `ten`,
        `sdt`,
        `email`
    ) VALUES (
        p_account,
        p_password,
        p_ten,
        p_sdt,
        p_email
    );
END;

//

DELIMITER ;
DROP PROCEDURE IF EXISTS thongKeKhuyenMai;
DELIMITER //
CREATE PROCEDURE thongKeKhuyenMai(
	in ma_khuyen_mai int
)
BEGIN
	Select ct.`ma san pham`, ct.`so luong`,ct.`ma hoa don`
    from `hoa don` as hd natural join
	(SELECT *
	FROM chua as c natural join
	(SELECT km.`ngay bat dau`, km.`ngay ket thuc`,adsp.`ma san pham` 
    from `khuyen mai` AS km 
    natural join `ap dung san pham` as adsp
    where  km.`ma khuyen mai`= ma_khuyen_mai and km.`ma khuyen mai` = adsp.`ma khuyen mai`) as spkm
	where spkm.`ma san pham` = c.`ma san pham`) AS ct
    where hd.`ma hoa don` = ct.`ma hoa don` 
    and hd.`ngay thuc hien` >= ct.`ngay bat dau` 
    and hd.`ngay thuc hien` <= ct.`ngay ket thuc`;
END;
//
DELIMITER ;
DELIMITER //
CREATE PROCEDURE getTotalTimeByPCConfigID(
	in configID int
)
BEGIN
	select ss.`gio bat dau`, ss.`gio ket thuc`, pc.ID 
    from `Session` as ss 
    join `may tinh` as pc
    on pc.ID = ss.`ID may tinh`
    where pc.`id cau hinh` = configID;
END;
//
DELIMITER ;
DELIMITER //
CREATE PROCEDURE getCostByPCid(
	in pcID int
)
BEGIN
	SELECT `may tinh`.ID,`phu thu`, `gia` from
    `may tinh` JOIN `cau hinh` JOIN `khu vuc`
    ON `may tinh`.`phan loai khu vuc` = `khu vuc`.`loai khu vuc` and `may tinh`.`id cau hinh` = `cau hinh`.ID
    WHERE `may tinh`.ID = pcID;
END;
//
DELIMITER ;
DELIMITER //
CREATE PROCEDURE updateUserBalance(
	in balanceChange int, -- balanceChange < 0 if minus, >0 if add to account,
    in accountHV char(255)
)
BEGIN
	DECLARE currentBalance int;
	SELECT `so du` into currentBalance from `hoi vien` where `account` = accountHV;
    SET currentBalance = balanceChange + currentBalance;
    UPDATE `hoi vien` SET `so du` = currentBalance where `acount` = accountHV;
END ;
//
DELIMITER ;
DELIMITER //
CREATE PROCEDURE getUserData(
	in accountHV char(255),
    in passwordHV char(255)
)
BEGIN
	SELECT * FROM `hoi vien` WHERE `account`=accountHV and `password` = passwordHV;
END;
//
DELIMITER ;
drop procedure if exists UpdateHoiVienRecord;
DELIMITER //
CREATE PROCEDURE UpdateHoiVienRecord(
    IN p_account CHAR(255),
    IN `old_password` CHAR(255),
    IN p_password CHAR(255),
    IN p_ten CHAR(255),
    IN p_sdt CHAR(10),
    IN p_email CHAR(255),
    IN p_level INT
)
BEGIN
    -- Update a record in the Hoi Vien table
    UPDATE `Hoi Vien`
    SET
        `password` = p_password,
        `ten` = p_ten,
        `sdt` = p_sdt,
        `email` = p_email,
        `level` = p_level
    WHERE
        `account` = p_account
        and `password` = `old_password`;
END; //
DELIMITER ;
DELIMITER //
CREATE PROCEDURE getPassword(
	in p_account char(255)
)
BEGIN
	select `password` from `hoi vien` where `account` = p_account;
END;
//
DELIMITER ;
DELIMITER //
CREATE PROCEDURE thongKeSPKhuyenMai(
	in ma_khuyen_mai int
)
BEGIN
	Select `ma san pham`, `ten san pham`, `so luong`
    from `san pham` as sp natural join
	(Select ct.`ma san pham`, ct.`so luong`
    from `hoa don` as hd natural join
	(SELECT *
	FROM chua as c natural join
	(SELECT km.`ngay bat dau`, km.`ngay ket thuc`,adsp.`ma san pham` 
    from `khuyen mai` AS km 
    natural join `ap dung san pham` as adsp
    where  km.`ma khuyen mai`= ma_khuyen_mai and km.`ma khuyen mai` = adsp.`ma khuyen mai`) as spkm
	where spkm.`ma san pham` = c.`ma san pham`) AS ct
    where hd.`ma hoa don` = ct.`ma hoa don` 
    and hd.`ngay thuc hien` >= ct.`ngay bat dau` 
    and hd.`ngay thuc hien` <= ct.`ngay ket thuc`) as kq
    where sp.`ma san pham` = kq.`ma san pham`;
END;
//
DELIMITER ;

