set sql_safe_updates= 0; -- Para poder excluir sem Where. 
-- drop database dbDistribuidora;
create database dbDistribuidora;
use dbDistribuidora;

create table tbCliente(
	IdCli int primary key auto_increment,
    NomeCli varchar(200) not null,
    NumEnd numeric(6) not null,
    CompEnd varchar(50),
    CepCli numeric(8) not null
);

create table tbClientePF(
	CPF numeric(11) primary key,
    RG numeric(9) not null,
    RG_Dig char(1) not null,
    Nasc date not null,
    IdCli int unique not null 
); 

create table tbClientePJ(
	CNPJ numeric(14) primary key,
    IE numeric(11) unique,
    IdCli int unique not null 
);

create table tbProduto(
    CodigoBarras decimal(14) primary key,
    NomeProd varchar(200) not null,
    Valor decimal(5,2) not null,
    Qtd int
);

create table tbVenda(
	CodigoVenda int(10) primary key auto_increment,
    DataVenda date default(current_timestamp()),
    ValorTotal decimal(6,2) not null,
    QtdTotal int not null,
    NotaFiscal int,
    IdCli int not null
);

create table tbNotaFiscal(
	NotaFiscal int primary key,
    TotalNota decimal(7,2) not null,
    DataEmissao date not null
);

create table tbItemVenda(
	CodigoVenda int(10),
    CodigoBarras decimal(14),
    ValorItem decimal(5,2) not null,
    Qtd int not null,
    primary key(CodigoVenda,CodigoBarras)
);

create table tbFornecedor(
	IdFornecedor int auto_increment primary key,
    CNPJ decimal(14,0) not null unique,
    NomeFornecedor varchar(100) not null,
    telefone numeric(11)
);

create table tbCompra(
	NotaFiscalPedido int primary key,
    DataCompra date not null,
    ValorTotal decimal (10,2) not null,
    QtdTotal int not null,
    IdFornecedor int
);

create table tbCompraProduto(
	NotaFiscalPedido int,
    CodigoBarras numeric(14),
    Qtd int,
    ValorItem decimal(10,2),
    primary key(NotaFiscalPedido,CodigoBarras)
);

create table tbEndereco(
	CEP numeric(8) primary key,
    Logradouro varchar(200),
    IdBairro int not null,
    IdCidade int not null,
    IdUF int not null
);

create table tbBairro(
    IdBairro int primary key auto_increment,
    Bairro varchar(200) not null
);

create table tbCidade(
    IdCidade int primary key auto_increment,
    Cidade varchar(200) not null
);

create table tbUF(
    IdUF int primary key auto_increment,
    UF varchar(200) not null
);

alter table tbCliente add foreign key (CepCli) references tbEndereco(CEP);

alter table tbClientePF add foreign key (IdCli) references tbCliente(IdCli);

alter table tbClientePJ add foreign key (IdCli) references tbCliente(IdCli);

alter table tbVenda add foreign key (NotaFiscal) references tbNotaFiscal(NotaFiscal);
alter table tbVenda add foreign key (IdCli) references tbCliente(IdCli);

alter table tbItemVenda add foreign key (CodigoVenda) references tbVenda(CodigoVenda);
alter table tbItemVenda add foreign key (CodigoBarras) references tbProduto(CodigoBarras);

alter table tbCompra add foreign key (IdFornecedor) references tbFornecedor(IdFornecedor);

alter table tbCompraProduto add foreign key (NotaFiscalPedido) references tbCompra(NotaFiscalPedido);
alter table tbCompraProduto add foreign key (CodigoBarras) references tbProduto(CodigoBarras);

alter table tbEndereco add foreign key (IdBairro) references tbBairro(IdBairro);
alter table tbEndereco add foreign key (IdCidade) references tbCidade(IdCidade);
alter table tbEndereco add foreign key (IdUF) references tbUF(IdUF);

delimiter $$
create procedure spSelectErro(vRegistro varchar(50),vExiste enum("já","não"))
begin
	select concat("O registro de: ",vRegistro," ",vExiste," existe na tabela.") as "Erro de insert!";
end
$$

delimiter $$
create procedure spInsertFornecedor (vCNPJ decimal(14,0), vNomeFornecedor varchar(100) , vTelefone numeric(11))
begin
	insert into tbFornecedor(CNPJ, NomeFornecedor, telefone) values(vCNPJ, vNomeFornecedor, vTelefone);
end
$$

describe tbCidade;
delimiter $$
create procedure spInsertCidade(vCidade varchar(200))
begin
	insert into tbCidade(Cidade) values (vCidade);
end
$$

describe tbUF;
delimiter $$
create procedure spInsertUF(vEstado varchar(200))
begin
	insert into tbUF(UF) values (vEstado);
end
$$

describe tbBairro;
delimiter $$
create procedure spInsertBairro(vBairro varchar(200))
begin
	insert into tbBairro(Bairro) values (vBairro);
end
$$

describe tbProduto;
delimiter $$
create procedure spInsertProduto(vCodigoBarras decimal(14,0), vNome varchar(200), vValor decimal(5,2), vQtd int)
begin
	insert into tbProduto(CodigoBarras,NomeProd,Valor,Qtd) values (vCodigoBarras,vNome,vValor,vQtd);
end
$$

describe tbEndereco;
delimiter $$
create procedure spInsertEndereco(vCep decimal(8,0),vLogradouro varchar(200),vBairro varchar(200), vCidade varchar(200), vEstado varchar(200))
begin
	if not exists(select * from tbUf where UF = vEstado) then
		call spInsertUf(vEstado);
	end if;
    if not exists(select * from tbCidade where Cidade = vCidade) then
		call spInsertCidade(vCidade);
	end if;
    if not exists(select * from tbBairro where Bairro = vBairro) then
		call spInsertBairro(vBairro);
	end if;
	if not exists(select * from tbEndereco where Cep = vCep) then
		set @Bairro = (select IdBairro from tbBairro where Bairro = vBairro);
		set @Cidade = (select IdCidade from tbCidade where Cidade = vCidade);
		set @Estado = (select IdUf from tbUF where Uf = vEstado);
		insert into tbEndereco(CEP,Logradouro,IdBairro,IdCidade,IdUF) values (vCep,vLogradouro,@Bairro,@Cidade,@Estado);
	else 
			call spSelectErro("Endereço","já");
	end if;
end
$$

call spInsertFornecedor(1245678937123, "Revenda Chico Loco", 11934567897);
call spInsertFornecedor(1345678937123, "José Faz Tudo S/A", 11934567898);
call spInsertFornecedor(1445678937123, "Vadalto Entregas", 11934567899);
call spInsertFornecedor(1545678937123, "Astrogildo das Estrelas", 11934567800);
call spInsertFornecedor(1645678937123, "Amoroso e Doce", 11934567801);
call spInsertFornecedor(1745678937123, "Marcelo Dedal", 11934567802);
call spInsertFornecedor(1845678937123, "Franciscano Cachaça", 11934567803);
call spInsertFornecedor(1945678937123, "Joãozinho Chupeta", 11934567804);

call spInsertCidade("Rio de Janeiro");
call spInsertCidade("São Carlos");
call spInsertCidade("Campinas");
call spInsertCidade("Franco da Rocha");
call spInsertCidade("Osasco");
call spInsertCidade("Pirituba");
call spInsertCidade("Ponta Grossa");
call spInsertCidade("São Paulo");
call spInsertCidade("Barra Mansa");

call spInsertUF("SP");
call spInsertUF("RJ");
call spInsertUF("RS");

call spInsertBairro("Aclimação");
call spInsertBairro("Capão Redondo");
call spInsertBairro("Pirituba");
call spInsertBairro("Liberdade");
call spInsertBairro("Lapa");
call spInsertBairro("Penha");
call spInsertBairro("Consolação");
call spInsertBairro("Barra Funda");

call spInsertProduto(12345678910111,'Rei de Papel Mache',54.61,120);
call spInsertProduto(12345678910112,'Bolinha de Sabão',100.45,120);
call spInsertProduto(12345678910113,'Barro Bate Bate',44.00,120);
call spInsertProduto(12345678910114,'Bola Furada',10.00,120);
call spInsertProduto(12345678910115,'Maçã Laranja',99.44,120);
call spInsertProduto(12345678910116,'Boneco do Hitler',124.00,200);
call spInsertProduto(12345678910117,'Farinha de Surui',50.00,200);
call spInsertProduto(12345678910118,'Zelador de Cemitério',24.50,100);

call spInsertEndereco(12345050, "Rua da Federal", "Lapa", "São Paulo", "SP");
call spInsertEndereco(12345051, "Av Brasil", "Lapa", "Campinas", "SP");
call spInsertEndereco(12345052, "Rua Liberdade", "Consolação", "São Paulo", "SP");
call spInsertEndereco(12345053, "Av Paulista", "Penha", "Rio de Janeiro", "RJ");
call spInsertEndereco(12345054, "Rua Ximbú", "Penha", "Rio de Janeiro", "RJ");
call spInsertEndereco(12345055, "Rua Piu X1", "Penha", "Campinas", "SP");
call spInsertEndereco(12345056, "Rua chocolate", "Aclimação", "Barra Mansa", "RJ");
call spInsertEndereco(12345057, "Rua Pão na Chapa", "Barra Funda", "Ponta Grossa", "RS");

-- 7) 
delimiter $$
 create procedure spInsertClientePf(vNomeCli varchar(200), vNumEnd decimal(6,0), vCompEnd varchar(50), vCepCli decimal(8,0), vCpf decimal(11,0), vRg decimal(9,0), vRg_Dig char(1), vNasc date,vLogradouro varchar(200),vBairro varchar(200), vCidade varchar(200), vEstado varchar(200))
 begin
	if not exists(select * from tbEndereco where CEP = vCepCli) then
		call spInsertEndereco(vCepCli,vLogradouro,vBairro,vCidade, vEstado);
	end if;
		if not exists(select * from tbClientePf where CPF = vCPF) then
			insert into tbCliente(NomeCli,NumEnd,CompEnd,CepCli) values (vNomeCli,vNumEnd,vCompEnd,vCepCli);
			set @idCli = (select max(IdCli) from tbCliente);
			insert into tbClientePf(CPF, RG, RG_Dig, Nasc, IdCli) values (vCPF, vRG, vRG_Dig, vNasc, @IdCli);
		else
			call spSelectErro("Cliente","já");
    end if;
 end
 $$

call spInsertClientePf("Pimpão",325,null,12345051,12345678911,12345678,"0","2000-10-12","Av. Brasil","Lapa","Campinas","SP");
call spInsertClientePf("Disney Chaplin",89,"Ap. 12",12345053,12345678912,12345679,"0","2000-11-21","Av. Brasil","Penha","Rio de Janeiro","RJ");
call spInsertClientePf("Marciano",744,null,12345054,12345678913,12345680,"0","2000-06-01","Rua Ximbu","Penha","Rio de Janeiro","RJ");
call spInsertClientePf("Lança Perfume",128,null,12345059,12345678914,12345681,"X","2000-04-05","Rua veia","Jardim Santa Isabel","Cuiabá","MT");
call spInsertClientePf("Remédio Amargo",2585,null,12345058,12345678915,12345682,"0","2000-07-15","Av Nova","Jardim Santa Isabel","Cuiabá","MT");

-- 8) 
delimiter $$
 create procedure spInsertClientePJ(vNomeCli varchar(200),vCNPJ decimal(14,0),vIE decimal(11,0), vCepCli decimal(8,0), vLogradouro varchar(200), vNumEnd decimal(6,0), vCompEnd varchar(50),vBairro varchar(200), vCidade varchar(200), vEstado varchar(200)) 
 begin
	if not exists(select * from tbEndereco where CEP = vCepCli) then
		call spInsertEndereco(vCepCli,vLogradouro,vBairro,vCidade, vEstado);
	end if;
		if not exists(select * from tbClientePJ where CNPJ = vCNPJ) then
			insert into tbCliente(NomeCli,NumEnd,CompEnd,CepCli) values (vNomeCli,vNumEnd,vCompEnd,vCepCli);
			set @idCli = (select max(IdCli) from tbCliente);
			insert into tbClientePJ(CNPJ, IE, idCli) values (vCNPJ, vIE,@IdCli);
		else
			call spSelectErro("Cliente","já");
		end if;
 end
 $$

call spInsertClientePj("Paganada",12345678912345,98765432198,12345051,"Av. Brasil",159,null,"Lapa","Campinas","SP");
call spInsertClientePj("Caloteando",12345678912346,98765432199,12345053,"Av. Paulista",69,null,"Penha","Rio de Janeiro","RJ");
call spInsertClientePj("Semgrana",12345678912347,98765432100,12345060,"Rua dos Amores",189,null,"Sei lá","Recife","PE");
call spInsertClientePj("Cemreais",12345678912348,98765432101,12345060,"Rua dos Amores",5024,"Sala 23","Sei lá","Recife","PE");
call spInsertClientePj("Durango",12345678912349,98765432102,12345060,"Rua dos Amores",1254,null,"Sei lá","Recife","PE");

-- 9)
delimiter $$
create procedure spInsertCompra(vNotaFiscal int,vFornecedor varchar(100), vCodigoBarras decimal(14,0), vQtd int)
begin
	set @vData = current_timestamp();
    set @valor = (select valor from tbProduto where CodigoBarras = vCodigoBarras);
	if not exists(select * from tbCompra where NotaFiscalPedido = vNotaFiscal) then
        set @Fornecedor = (select IdFornecedor from tbFornecedor where NomeFornecedor = vFornecedor);
		insert into tbCompra(NotaFiscalPedido,DataCompra,ValorTotal,QtdTotal,IdFornecedor) values (vNotaFiscal,@vData,0,0,@Fornecedor);
    end if;
    if not exists(select * from tbCompraProduto where NotaFiscalPedido = vNotaFiscal and CodigoBarras = vCodigoBarras) then
		insert into tbCompraProduto(NotaFiscalPedido,CodigoBarras,Qtd,ValorItem) values (vNotaFiscal,vCodigoBarras,vQtd,@valor);
    else
		call spSelectErro('Compra desse produto','já');
	end if;
end
$$

delimiter //
create trigger TGRUpdateCompra after insert on tbCompraProduto
for each row
begin
	update tbCompra set ValorTotal = ValorTotal + (new.ValorItem * new.Qtd), QtdTotal = QtdTotal + new.Qtd where NotaFiscalPedido = new.NotaFiscalPedido;
end
//

call spInsertCompra(8459,"Amoroso e Doce",12345678910111,200);
call spInsertCompra(2482,"Revenda Chico Loco",12345678910112,180);
call spInsertCompra(21653,"Marcelo Dedal",12345678910113,300);
call spInsertCompra(8459,"Amoroso e Doce",12345678910114,500);
call spInsertCompra(156354,"Revenda Chico Loco",12345678910115,350);

-- 10)
delimiter $$
create procedure spInsertVenda(vCliente varchar(100), vCodigoBarras decimal(14), vQtd int, vNotaFiscal int)
begin
	set @vData = current_timestamp();
    set @vTotal = (select Valor from tbProduto where CodigoBarras = vCodigoBarras);
	if exists (select * from tbProduto,tbCliente where CodigoBarras = vCodigoBarras and NomeCli = vCliente) then
		set @idCliente = (select IdCli from tbCliente where NomeCli = vCliente);
		set @codigoVenda = (select CodigoVenda from tbVenda where IdCli = @idCliente);
		if (@codigoVenda is null) then
			insert into tbVenda(IdCli,DataVenda,ValorTotal,QtdTotal,NotaFiscal) values (@idCliente,@vData,0,0,vNotaFiscal);
		end if;
        set @codigoVenda = (select CodigoVenda from tbVenda where IdCli = @idCliente);
		if not exists(select * from tbItemVenda where CodigoVenda = @codigoVenda and CodigoBarras = vCodigoBarras) then
			  insert into tbItemVenda(CodigoVenda,CodigoBarras,ValorItem,Qtd) values (@codigoVenda,vCodigoBarras,@vTotal,vQtd);
        else
			call spSelectErro('Venda desse produto','já');
		end if;
    end if;
	if not exists(select * from tbCliente where NomeCli = vCliente) then call spSelectErro("Cliente","não"); end if;
	if not exists(select * from tbProduto where CodigoBarras = vCodigoBarras) then call spSelectErro("Produto","não"); end if;
end
$$

delimiter //
create trigger TGRUpdateVenda after insert on tbItemVenda
for each row
begin
	update tbVenda set ValorTotal = ValorTotal + (new.ValorItem*new.Qtd), QtdTotal = QtdTotal + new.Qtd where CodigoVenda = new.CodigoVenda;
end
//

call spInsertVenda("Pimpão",12345678910111,1,null);
call spInsertVenda("Lança Perfume",12345678910112,1,null);
call spInsertVenda("Pimpão",12345678910113,2,null);

-- 11)
delimiter $$
create procedure spInsertNotaFiscal(vNotaFiscal int, vCliente varchar(100))
begin
	set @vData = current_date();
    set @idCliente = (select idCli from tbCliente where NomeCli = vCliente);
	set @totalVenda = (select ValorTotal from tbVenda where idCli = @idCliente and DataVenda = @vData);
    if (@totalVenda is null) then call spSelectErro("Venda","não");
    else
		if not exists(select * from tbNotaFiscal where NotaFiscal = vNotaFiscal) then
			insert into tbNotaFiscal(NotaFiscal,TotalNota,DataEmissao) values (vNotaFiscal,@totalVenda,@vData);
		else
			update tbNotaFiscal set TotalNota = @totalVenda where NotaFiscal = vNotaFiscal;
        end if;
	end if;
end
$$

call spInsertNotaFiscal(359,"Pimpão");
call spInsertNotaFiscal(360,"Lança Perfume");

-- 12)
call spInsertProduto(12345678910130, "Camiseta de Poliéster", 35.61, 100);
call spInsertProduto(12345678910131, "Blusa de frio moletom", 200.00, 100);
call spInsertProduto(12345678910132, "Vestido decote redondo", 144.00, 50);

-- 13)
delimiter $$
create procedure spDeleteProduto(vCodigobarras decimal (14,0))
begin
    delete from tbProduto where CodigoBarras = vCodigoBarras;
end $$

call spDeleteProduto(12345678910116);
call spDeleteProduto(12345678910117);

-- 14)
delimiter $$
create procedure spUpdateProduto(vCodigoBarras decimal(14,0), vNome varchar(200), vValor decimal(5,2)) 
begin 
	update tbProduto set NomeProd = vNome, Valor = vValor where CodigoBarras = vCodigoBarras;
end $$

call spUpdateProduto(12345678910111,'Rei de Papel Mache',64.50);
call spUpdateProduto(12345678910112,'Bolinha de Sabão',120.00);
call spUpdateProduto(12345678910113,'Carro Bate Bate',64.00);

-- 15)
delimiter $$
create procedure spSelectProduto() 
begin 
	select * from tbProduto;
end $$

call spSelectProduto();

-- 16)
create table tbProdutoHistorico like tbProduto;

alter table tbProdutoHistorico modify codigoBarras decimal(14,0) not null;
alter table tbProdutoHistorico drop primary key;
describe tbProdutoHistorico;


-- 17)
alter table tbProdutoHistorico add Atualizacao datetime;
alter table tbProdutoHistorico add Ocorrencia varchar(100);
describe tbProdutoHistorico;

-- 18)
alter table tbProdutoHistorico add constraint pk_ProdHist primary key (CodigoBarras,Atualizacao,Ocorrencia);

-- 19)
delimiter // 
create trigger TGRInsertProdutoHistorico after insert on tbProduto
for each row
begin
	insert into tbProdutoHistorico
    set CodigoBarras = new.CodigoBarras, 
    NomeProd = new.NomeProd,
    Valor = new.valor,
    Qtd = new.qtd,
    Atualizacao = current_timestamp(),
	Ocorrencia = "Novo";
end//

call spInsertProduto(12345678910119,"Água Mineral",1.99,500);
select * from tbProduto;
select * from tbProdutoHistorico;

-- Exe 20
delimiter //
create trigger TGRUpdateProduto after update on tbProduto
for each row
begin
insert into tbProdutoHistorico
set CodigoBarras = new.CodigoBarras, 
    NomeProd = new.NomeProd,
    Valor = new.valor,
    Qtd = new.qtd,
    Atualizacao = current_timestamp(),
	Ocorrencia = "Atualizado";
end//

call spSelectProduto();
call spUpdateProduto(12345678910119,'água Mineral',2.99);
select * from tbProduto;
select * from tbProdutoHistorico;

-- 21)
call spSelectProduto();

-- 22)
call spInsertVenda("Disney Chaplin",12345678910111,1,null);
call spInsertVenda("Lança Perfume",12345678910114,10,null);
call spInsertVenda("Durango",12345678910114,5,null);

-- 23)
select * from tbVenda ORDER BY CodigoVenda desc limit 1;

-- 24)
select * from tbItemVenda ORDER BY CodigoVenda desc limit 1;

-- 25)
delimiter $$
 create procedure spSelectCliente(vNomeCli varchar(200))
begin 
	select *from tbCliente where NomeCli = vNomeCli;
end $$

call spSelectCliente('Durango');
call spSelectCliente('Disney Chaplin');
 
 -- 26)
delimiter //
Create trigger TRGUpdateProdutoItemVenda after insert on tbItemVenda
for each row
begin
	update tbProduto set Qtd = Qtd - new.Qtd where CodigoBarras = new.CodigoBarras;
end
//

show create procedure spInsertVenda;

-- 27)
call spInsertVenda("Paganada",12345678910114,15,null);
select * from tbVenda;
select * from tbitemvenda
select * from tbcliente;

-- 28
call spSelectProduto(); 

-- 29)
delimiter //
Create trigger TRGUpdateCompraProduto after insert on tbCompraProduto
for each row
begin
	update tbProduto set Qtd = Qtd + new.Qtd where CodigoBarras = new.CodigoBarras;
end
//

-- 30) 
call spInsertCompra(10548, 'Amoroso e Doce', 12345678910111,100);

-- 31)
call spSelectProduto();

-- 32)

select * from tbCliente
inner join tbClientePF
on tbCliente.IdCLi = tbClientePF.IdCLi;

-- 33)
select * from tbCliente
inner join tbClientePJ
on tbCliente.IdCLi = tbClientePJ.IdCLi;

-- 34)
select tbCliente.IdCLi, NomeCli, CNPJ, IE, tbClientePJ.IdCLi from tbCliente
inner join tbClientePJ
on tbCliente.IdCLi = tbClientePJ.IdCLi;

-- 35)
select tbCliente.IdCli as "Código", NomeCli as "Nome", CPF, RG, Nasc as "Data de Nascimento" from tbCliente
inner join tbClientePF
on tbCliente.IdCLi = tbClientePF.IdCLi;

-- 36)
select * from tbCliente
inner join tbClientePJ on tbCliente.IdCLi = tbClientePJ.IdCLi
inner join tbEndereco on tbEndereco.CEP = tbCliente.CepCli

-- 37)
select tbCliente.IdCli, NomeCli , CEP, Logradouro, NumEnd, CompEnd, Bairro, Cidade, UF from tbCliente
inner join tbClientePJ on tbCliente.IdCLi = tbClientePJ.IdCLi
inner join tbEndereco on tbCliente.CepCli = tbEndereco.CEP
inner join tbBairro on tbEndereco.IdBairro = tbBairro.IdBairro
inner join tbCidade on tbEndereco.IdCidade = tbCidade.IdCidade
inner join tbUF on tbEndereco.IdUF = tbUf.IdUF

-- 38)
delimiter $$
 create procedure spSelectClientePFisicaId(vId int)
begin 
	if exists (select * from tbClientePf where tbClientePf.IdCli = vId) then
    select tbCliente.IdCli, NomeCli , CPF, RG, RG_Dig as "Digito", Nasc, CEP, Logradouro, NumEnd, CompEnd, Bairro, Cidade, UF from tbCliente
inner join tbClientePF on tbCliente.IdCLi = tbClientePF.IdCLi 
inner join tbEndereco on tbCliente.CepCli = tbEndereco.CEP
inner join tbBairro on tbEndereco.IdBairro = tbBairro.IdBairro
inner join tbCidade on tbEndereco.IdCidade = tbCidade.IdCidade
inner join tbUF on tbEndereco.IdUF = tbUf.IdUF 
where  tbCliente.IdCli = vId;
else select ("Esse cliente não existe");
end if;
end $$

drop procedure spSelectClientePFisicaId;

call spSelectClientePFisicaId (2);
call spSelectClientePFisicaId (7);

describe tbClientePf;
select tbClientePf;

-- 39)
select tbProduto.CodigoBarras, NomeProd, Valor, tbProduto.Qtd, tbVenda.QtdTotal, ValorItem, tbItemVenda.CodigoBarras, tbVenda.CodigoVenda from tbProduto
left join tbItemVenda on tbProduto.CodigoBarras = tbItemVenda.CodigoBarras
left join tbVenda on tbItemVenda.CodigoVenda = tbVenda.CodigoVenda;

select * from tbproduto;
select * from tbVenda;
select * from tbItemVenda;

-- 40)
select NotaFiscalPedido as "Nota Fiscal", DataCompra, ValorTotal, QtdTotal, tbCompra.IdFornecedor as "Código", tbFornecedor.IdFornecedor as "Código", CNPJ, NomeFornecedor as "Nome", Telefone from tbCompra
right join tbfornecedor on tbFornecedor.IdFornecedor = tbCompra.IdFornecedor;

describe tbProduto;
describe tbVenda;
describe tbitemVenda;

-- 41)
select tbFornecedor.IdFornecedor as "Código", CNPJ, NomeFornecedor as "Nome", Telefone
from tbcompra right join tbfornecedor on tbFornecedor.IdFornecedor = tbCompra.IdFornecedor where tbCompra.IdFornecedor is null;

select * from tbcompraproduto;
select * from tbfornecedor;
select * from tbcompra; 

-- 42)
select tbCliente.IdCli, NomeCli, DataVenda, tbProduto.CodigoBarras, NomeProd, ValorItem, tbItemVenda.CodigoVenda from tbVenda
inner join tbCliente on tbVenda.IdCli = tbCliente.IdCli
inner join tbItemVenda on tbItemVenda.Codigovenda = tbVenda.CodigoVenda
inner join tbProduto on tbProduto.CodigoBarras = tbItemVenda.CodigoBarras order by NomeCli asc;

delete from tbItemVenda where CodigoVenda = 2 and CodigoBarras = 12345678910114;
delete from tbItemVenda
select * from tbItemVenda;
describe tbitemVenda;
describe tbVenda;
describe tbProduto;


-- 43)
select Bairro
from tbVenda 
inner join tbCliente on tbVenda.IdCli = tbCliente.IdCli 
inner join tbEndereco on tbCliente.CepCli = tbEndereco.CEP
right join tbBairro on tbendereco.IdBairro = tbBairro.IdBairro
where tbVenda.IdCli is null

select * from tbBairro;


