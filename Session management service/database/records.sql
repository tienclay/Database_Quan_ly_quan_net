USE `internet_store`;
insert into `cau hinh` (id,`kich thuoc man hinh`,`cpu`,`card do hoa`,`ram`,`tan so man hinh`,`gia`) 
values
(1,24,'i5','rtx-3060',16,60,6000),
(2,30,'i7','rtx-3080',32,120,1000),
(3,33,'i7','rtx-3100',32,240,10000);
insert into `khu vuc` (`loai khu vuc`, `phu thu`) 
values
('khong may lanh',0),
('may lanh',1000),
('su kien',5000);
insert into `may tinh` (id,hang,`ngay mua`,`phan loai khu vuc`,`id cau hinh`) 
values
(1,'dell',curdate(),'may lanh',1),
(2,'hp',curdate(),'su kien',3),
(3,'intel',curdate(),'khong may lanh',2);
insert into `San Pham` (`ma san pham`, `gia niem yet`, `ten san pham`) 
values 
(1,1000,'gio choi'),
(2,15000,'mi tom'),
(3, 50000,'card viettel'),
(4, 5000,'Bim bim'),
(5, 20000,'hu tiu');
insert into `Gio Choi` (`ma san pham`) values (1);
insert into `Hoi Vien` (`account`, `ten`,`email`,`password`,`sdt`) values
('hahaha','khach','io@hcmut.edu.vn','$2a$12$z.RpqTSe07c5UkPv2a0gXuva4CqyNYlAaafi7kws.Vf0mVnzAIBSG','0909'),
('hieudz1402','The Hieu','abc@abc.abc','$2a$12$z.RpqTSe07c5UkPv2a0gXuva4CqyNYlAaafi7kws.Vf0mVnzAIBSG','113'),
('a','The Hieu','abc@abc.abc','$2a$12$z.RpqTSe07c5UkPv2a0gXuva4CqyNYlAaafi7kws.Vf0mVnzAIBSG','114'),
('b','The Hieu','abc@abc.abc','$2a$12$z.RpqTSe07c5UkPv2a0gXuva4CqyNYlAaafi7kws.Vf0mVnzAIBSG','115'),
('c','The Hieu','abc@abc.abc','$2a$12$z.RpqTSe07c5UkPv2a0gXuva4CqyNYlAaafi7kws.Vf0mVnzAIBSG','116'),
('d','The Hieu','abc@abc.abc','$2a$12$z.RpqTSe07c5UkPv2a0gXuva4CqyNYlAaafi7kws.Vf0mVnzAIBSG','117');
insert into `nhan vien` (`ho ten`,`gioi tinh`,`ngay sinh`,`ngay ki ket`,`ngay het han`) values ('nhanvien1', 1, '2003-01-01', '2023-01-01', '2024-01-01');
insert into `Le Tan` (id, `account`, `password`,`lich truc`) values (1,'nhanvien1','123','thu 2 thu 3 thu 4');
insert into `Nha Cung Cap` (id,sdt,ten,address) 
values 
(1,'666','hao hao','tphcm'),
(2,'999','viettel','tphcm');
insert into `dich vu them` (`ma san pham`,`id nha cung cap`,`so luong`,`loai san pham`) 
values
(2,1,1000,'do an'),
(3,2,1000,'the nap'),
(4,1,1000,'do an'),
(5,1,1000,'do an');
insert into `khuyen mai` (`ma khuyen mai`,`ten chuong trinh`,`ngay bat dau`,`ngay ket thuc`,`loai`,`dieu kien`,`muc giam`) 
values 
(202350,'happy net','2022-01-01','2025-01-01','product',5,0.5),
(202330,'happy net','2022-01-01','2025-01-01','product',4,0.3),
(202320,'happy net','2022-01-01','2025-01-01','product',3,0.2),
(202310,'happy net','2022-01-01','2025-01-01','product',2,0.1),
(202305,'happy net','2022-01-01','2025-01-01','product',2,0.05);
call  addNewDiscount(112023,'new member',NULL,now(),'2024-01-01 00:00:00',True,100000,0.2);
call  addNewDiscount(122023,'new member',NULL,now(),'2024-01-01 00:00:00',True,200000,0.3);
call  addNewDiscount(1112023,'new member',NULL,now(),'2024-01-01 00:00:00',True,300000,0.5);
insert into `ap dung san pham` (`ma san pham`, `ma khuyen mai`) values 
(3,202330),
(1,202350),
(4,202310),
(5,202305),
(4,202350),
(2,202330),
(2,202350);
insert into `Hoa Don` (`ngay thuc hien`,`tai khoan hv`,`id le tan`) values 
(NOW(),'hieudz1402',1),
(NOW(),'a',1),
(NOW(),'b',1),
(NOW(),'c',1),
(NOW(),'d',1),
(NOW(),'b',1),
(NOW(),'a',1);
CALL addProductToBill(1,10,1);
CALL addProductToBill(2,1,1);
CALL addProductToBill(3,1,1);
CALL addProductToBill(1,2,2);
CALL addProductToBill(3,10,2);
CALL addProductToBill(5,1,2);
CALL addProductToBill(4,7,3);
CALL addProductToBill(1,4,3);
CALL addProductToBill(2,1,3);
CALL addProductToBill(3,5,3);
CALL addProductToBill(1,1,4);
CALL addProductToBill(1,4,5);
CALL addProductToBill(1,3,6);
CALL addProductToBill(4,1,6);
CALL addProductToBill(1,10,7);
CALL addProductToBill(2,10,7);
CALL addProductToBill(3,10,7);
CALL addProductToBill(4,10,7);
CALL addProductToBill(5,10,7);
