--1.soru
create database havayolu
use havayolu

create table yolcu(
yolcu_id int primary key identity(1,1),
yolcu_adi varchar(10),
yolcu_soyadi varchar(10),
yocu_tckn varchar(11),
yolcu_cinsiyet varchar(5),
yolcu_dtarihi varchar(10)
)
create table ucak(
ucak_id int primary key identity(1,1),
ucak_tipi varchar(50),
yolcu_kapasitesi int
)
create table pilot(
pilot_id int primary key identity(1,1),
pilot varchar(50),
pilot_tckn varchar(11),
)
create table sehirler(
id int primary key identity(1,1),
sehir varchar(50)
)
create table hatlar(
	id int primary key identity(1,1),
	hat varchar(25)
)
create table ucuslar( 
	ucus_kodu  varchar(50) primary key,
	ucak_id int foreign key references ucak(ucak_id),
	pilot_id int foreign key references pilot(pilot_id),
	nereden int foreign key references sehirler(id),
	nereye int foreign key references sehirler(id),
	kalkis_tarihi varchar(20),
	kalkis_saati varchar(10),
	ucus_suresi varchar(20),
	ucus_yonu int foreign key references hatlar(id),
	bilet_fiyati varchar(20),
	satilan_bilet_sayisi int default(0),
)

create table koltuklar(
	id int primary key identity(1,1),
	koltuk_bilgisi varchar(3)
)
create table bilet(
	ucus_kodu varchar(50) foreign key references ucuslar(ucus_kodu),
	yolcu_id int foreign key references yolcu(yolcu_id),
	koltuk_id int foreign key references koltuklar(id)
)

insert into hatlar values('ic hat'),
					     ('dis hat')
insert into pilot values('Hakan Gokdelen','99273636700'),
                        ('Yusuf Iyiucan','99273636701'),
						('Ela Bulut','99273636702')
insert into ucak values('Airbus A321-232',161),
                        ('Boeing 737-800',189),
						('Airbus A321-NEO',182)
insert into sehirler values('Konya'),
                           ('Istanbul'),
						   ('Antalya'),
						   ('Dortmund')
insert into yolcu values('Ali','Kaya','11111111111','Erkek','17.05.1979'),
                        ('Ayse','Dagli','11111111112','Kadin','11.03.1987'),
						('Veli','Alan','11111111113','Erkek','07.10.1981'),
						('Fatma','Dogan','11111111114','Kadin','14.07.1991'),
						('Ayhan','Gezgin','11111111115','Erkek','04.09.2001'),
						('Ece','Gezgin','11111111116','Kadin','11.10.2003'),
						('Filiz','Celik','11111111117','Erkek','23.06.1999'),
						('Kamil','Kurucu','11111111118','Erkek','19.12.1973')
						

--ucus_k/ucak_id/pilot_id/nereden/nereye/kalkis_t/kalkis_s/ucus_s/ucus_y/bilet_f/satilan_bilet_sayisi
insert into ucuslar values('TK2043',1,1,1,2,'25 Mart 2023','05.25','75 dakika',1,'790 TL',4),
                       ('TK2032',2,2,2,4,'13 Nisan 2023','09.30','200 dakika',2,'8500 TL',3),
					   ('TK7532',3,3,2,3,'7 Temmuz 2023','07.30','80 dakika',1,'1200 TL',2)
insert into koltuklar values('A1'),
							('D3'),
							('E6'),
							('F2'),
							('F1'),
							('D3'),
							('H1'),
							('B1'),
							('H3')		
insert into bilet values('TK2043',1,1),	
                        ('TK2043',2,2),	
						('TK2043',3,3),	
						('TK2043',4,4),	
						('TK2032',5,5),	
						('TK2032',6,4),	
						('TK2032',7,6),	
						('TK7532',8,7)	
--8 tablo
select * from hatlar
select * from koltuklar
select * from sehirler
select * from pilot
select * from yolcu
select * from ucak
select * from bilet
select * from ucuslar

--2.soru
--Bir uçuşa bir yolcu ekleneceğinde önce uçağın kapasitesinin dolu olup olmadığını kontrol ediniz, kapasite uygun ise o uçuş için satılan bilet sayısını “TRIGGER”
--yapısını kullanarak 1 arttırınız.
create trigger trg_kapasite_kontrolu on bilet for insert as
begin
	declare @u_kodu varchar(50)
	set @u_kodu = (select ucus_kodu from inserted)
	if (select yolcu_kapasitesi from ucak where ucak_id=(select ucak_id from ucuslar where ucus_kodu=@u_kodu))>(select satilan_bilet_sayisi from ucuslar where ucus_kodu=@u_kodu)
		begin 
		update ucuslar set satilan_bilet_sayisi += 1 where ucus_kodu=@u_kodu
		select * from inserted
		end
	else 
		begin 
		print('Ucak kapasitesi dolu!')
		delete from bilet where yolcu_id = (select yolcu_id from inserted)
		end 
end

--3.soru
--Yolcunun satın almak istediği koltuğun müsaitlik durumunu kontrol ediniz. Müsaitse koltuğu yolcuya tahsis ediniz değilse “Bu koltuk müsait değil” uyarısı yazdırınız.
create proc bilet_al
(
	@ucus_kodu varchar(50),
	@yolcu_id int,
	@koltuk_id int
)
as
begin
	if @koltuk_id in (select koltuk_id from bilet where ucus_kodu=@ucus_kodu)
		begin
			print 'Bu koltuk musait degil!'
		end
	else 
		begin
			insert into bilet values(@ucus_kodu,@yolcu_id,@koltuk_id)
		end
end

--3 ve 2.soru kontrolu
select * from bilet
select * from ucuslar
insert into yolcu values('Ayten','Kaya','11111111119','Kadin','15.02.1983')
update ucuslar set satilan_bilet_sayisi=189 where ucak_id=3
insert into bilet values('TK7532',9,8)
insert into bilet values('TK2032',9,8)
bilet_al 'TK2032',1,8
bilet_al 'TK2032',1,1


--4.soru: Bir yolcu bilgisi silindiğinde o yolcunun geçmiş tüm uçuşlarının da silinmesini sağlayınız.
alter table bilet add constraint fk_yolcu foreign key(yolcu_id)  references yolcu(yolcu_id)  on delete cascade

--5.soru
-- iç hat uçuşlardaki yolcu ad-soyad, koltuk_bilgisi, bilet fiyatı, uçağın kalkacağı ve iniş yapacağı şehir bilgisi,
-- kalkış tarihi ve saati, uçuş_kodu bilgilerini getiren sorguyu yazınız.
select 
yolcu.yolcu_adi,
yolcu.yolcu_soyadi,
koltuklar.koltuk_bilgisi,
ucuslar.bilet_fiyati,
sehirler.sehir as kalkacak,
sehirler.sehir as inecek,
ucuslar.kalkis_tarihi,
ucuslar.kalkis_saati,
ucuslar.ucus_kodu
from bilet
inner join yolcu on yolcu.yolcu_id=bilet.yolcu_id
inner join koltuklar on koltuklar.id=bilet.koltuk_id
inner join ucuslar on ucuslar.ucus_kodu=bilet.ucus_kodu
inner join sehirler on sehirler.id=ucuslar.nereden or sehirler.id=ucuslar.nereye
where ucuslar.ucus_yonu=1

--soru 6
--iç hat uçuş fiyatlarına %30, dış hat uçuş fiyatlarına %50 zam uygulayan kodu “CASE” yapısını kullanarak yazınız.
select bilet_fiyati, ucus_yonu,
case ucus_yonu when 1 then cast((substring(bilet_fiyati,1,charindex(' ',bilet_fiyati))) as int)*0.3 end as '%30  zam',
case ucus_yonu when 2 then cast((substring(bilet_fiyati,1,charindex(' ',bilet_fiyati))) as int)*0.5 end as '%50  zam' 
from ucuslar