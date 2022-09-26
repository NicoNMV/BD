create database dbdistribuidora01;
use dbdistribuidora01;

create table tbUF (
	IdUF int auto_increment primary key,
	UF char(2) unique
);

create table tbBairro (
	IdBairro int auto_increment primary key,
	Bairro varchar(200)
);

create table tbCidade (
	IdCidade int auto_increment primary key,
	Cidade varchar(200)
);

create table tbEndereco (
	CEP varchar(8) primary key,
	Logradouro varchar(200),
	IdBairro int,
	IdCidade int,
	IdUF int,
    foreign key (IdBairro) references tbBairro(IdBairro),
    foreign key (IdCidade) references tbCidade(IdCidade),
	foreign key (IdUF) references tbUF(IdUF)
);

create table tbCliente (
	Id int primary key auto_increment,
	Nome varchar(50) not null,
	CEP varchar(8) not null,
	CompEnd varchar(50),
    NumEnd char(5),
	foreign key (CEP) references tbEndereco(CEP)
);

create table tbClientePF (
	IdCliente int auto_increment,
	Cpf varchar(11) not null primary key,
	Rg varchar(8),
	RgDig varchar(1),
	Nasc date,
	foreign key (IdCliente) references tbCliente(Id)   
);

create table tbClientePJ (
	IdCliente int auto_increment,
	Cnpj varchar(14) not null primary key,
	IE DECIMAL(11,0),
    foreign key (IdCliente) references tbCliente(Id)
);

create table tbNotaFiscal (
	NF int primary key,
	TotalNota decimal(7,2) not null,
	DataEmissao date not null
);

create table tbFornecedor (
	Codigo int primary key auto_increment,
	Cnpj varchar(14) not null,
	Nome varchar(200),
	Telefone varchar(11)
);

create table tbCompra (
	NotaFiscal int primary key,
	DataCompra date not null,
	ValorTotal decimal(8,2) not null,
	QtdTotal int not null,
	Cod_Fornecedor int,
	foreign key (Cod_Fornecedor) references tbFornecedor(Codigo)
);

create table tbProduto (
	CodBarras varchar(14) primary key,
	Qtd int,
	Nome varchar(50),
	ValorUnitario decimal(6,2) not null
);

create table tbItemCompra (
	Qtd int not null,
	ValorItem decimal(6,2) not null,
	NotaFiscal int,
	CodBarras varchar(14),
	primary key (NotaFiscal, CodBarras),
	foreign key (NotaFiscal) references tbCompra(NotaFiscal),
	foreign key (CodBarras) references tbProduto(CodBarras)
);

create table tbVenda (
	IdCliente int,
	NumeroVenda int auto_increment primary key,
	DataVenda date not null,
	TotalVenda decimal(7,2) not null,
	NotaFiscal int,
	foreign key (IdCliente) references tbCliente(Id),    
	foreign key (NotaFiscal) references tbNotaFiscal(NF)
);

create table tbItemVenda (
	NumeroVenda int,
	CodBarras varchar(14),
	Qtd int,
	ValorItem decimal(6,2),    
	primary key (NumeroVenda, CodBarras),
	foreign key (NumeroVenda) references tbVenda(NumeroVenda),
	foreign key (CodBarras) references tbProduto(CodBarras)
);

-- Fornecedor
insert into tbFornecedor(Nome, Cnpj, Telefone)
	values('Revenda Chico loco', '1245678937123', '11934567897'),
		  ('José FAz Tudo S/A', '1345678937123', '11934567898'),
	      ('Vadalto Entregas', '1445678937123', '11934567899'),    
	      ('Astrogildo das Estrela', '1545678937123', '11934567800'),
          ('Amoroso e Doce', '1645678937123', '11934567801'),
          ('Marcelo Dedal', '1745678937123', '11934567802'),
          ('Franciscano Cachaça', '1845678937123', '11934567803'),
          ('Joãozinho Chupeta', '1945678937123', '11934567804');
          
select * from tbFornecedor;  

-- Cidade
Delimiter $$

create procedure spCidade(vCidade varchar(200))

begin
insert into tbCidade (Cidade)
	values(vCidade); 
end $$ 

	call spCidade('Rio de Janeiro');
    call spCidade('São Carlos');
    call spCidade('Campinas');
    call spCidade('Franco da Rocha');
    call spCidade('Osasco');
    call spCidade('Pirituba');
    call spCidade('lapa');
    call spCidade('Ponta Grossa');   

select * from tbCidade;

-- Estado
Delimiter $$

create procedure spEstado(vUF char(2))

begin
insert into tbUF (UF)
	values(vUF); 
end $$

	call spEstado('SP');
    call spEstado('RJ');
    call spEstado('RS');
   
select * from tbUF;   

-- Bairro
Delimiter $$

create procedure spBairro(vBairro varchar(200))

begin
insert into tbBairro (Bairro)
	values(vBairro); 
end $$

	call spBairro('Aclimação');
    call spBairro('Capão Redondo');
    call spBairro('Pirituba');
    call spBairro('Liberdade');

select * from tbBairro;

-- Produto
Delimiter $$

create procedure spProd(vCod varchar(14), vNome varchar(50), vValor decimal(6,2), vQtd int)

begin
insert into tbProduto (CodBarras, Nome, ValorUnitario,  Qtd)
	values(vCod, vNome, vValor, vQtd); 
end $$

	call spProd('12345678910111', 'Rei de Papel Mache', '54.61', 120);
    call spProd('12345678910112', 'Bolinha de Sabão', '100.45', 120);
    call spProd('12345678910113', 'Carro Bate Bate', '44', 120);
    call spProd('12345678910114', 'Bola Furada', '10', 120);
    call spProd('12345678910115', 'Maçã Laranja', '99.44', 120);
    call spProd('12345678910116', 'Boneco do Hitler', '124', 200);
    call spProd('12345678910117', 'Farinha de Suruí', '50', 200);
    call spProd('12345678910118', 'Zelador de Cemitério', '24.50', 100);
    
   select * from tbProduto;
   
-- 6) Endereço
delimiter $$
create procedure spInsertEndereco(vCEP varchar(8), vLogradouro varchar(200), vBairro varchar(200), vCidade varchar(200), vUF char(2))
begin

if not exists (select * from tbBairro where Bairro = vBairro) then
    insert into tbbairro (bairro) values (vBairro);
end if;

if not exists (select * from tbCidade where Cidade = vCidade) then
    insert into tbcidade (cidade) values (vCidade);
end if;

if not exists (select * from tbUF where  UF = vUF) then
    insert into tbuf (uf) values (vUF);
end if;

if not exists (select * from tbEndereco where vCEP = CEP) then

    set @idBairroSP = (select idBairro from tbBairro where Bairro = vBairro);
    set @idCidadeSP = (select idCidade from tbCidade where Cidade = vCidade);
    set @idUFSP = (select idUF from tbUF where UF = vUF);

        else
    select 'Já existe';
end if;
insert into tbEndereco(CEP, Logradouro, IdBairro, IdCidade, IdUF) values (vCEP, vLogradouro, @idBairroSP, @idCidadeSP, @idUFSP);
end $$

call spInsertEndereco(12345050, "Rua da Federal", "Lapa", "São Paulo", "SP");
call spInsertEndereco(12345051, "Avenidade Brasil", "Lapa", "São Paulo", "SP");
call spInsertEndereco(12345052, "Rua Liberdade", "Consolação", "São Paulo", "SP");
call spInsertEndereco(12345053, "Avenida Paulista", "Penha", "Rio de Janeiro", "RJ");
call spInsertEndereco(12345054, "Rua Ximbú", "Penha", "Rio de Janeiro", "RJ");
call spInsertEndereco(12345055, "Rua Piu XI", "Penha", "Campinas", "SP");
call spInsertEndereco(12345056, "Rua Chocolate", "Aclimação", "Barra Mansa", "RJ");
call spInsertEndereco(12345057, "Rua Pão na Chapa", "Barra Funda", "Ponta Grossa", "RS");

select * from tbEndereco;
select * from tbBairro;
select * from tbCidade;
select * from tbUF;


-- Cliente PF (exercício 7)
delimiter $$
   create procedure spInsertClientePF(vNomeCli varchar(200), vNumEnd  numeric(6), vCompEnd varchar(50), vCepCli numeric(8), vCPF numeric(11), vRG  numeric(9), vRG_Dig char(1), vNasc date, vLogradouro varchar (200), vBairro varchar(200), Vcidade varchar (200), vUF char(2))
   begin
    if not exists(select * from tbClientePF where CPF = vCPF) then
        insert into tbCliente(Nome, NumEnd, CompEnd, Cep) values (vNomeCli, vNumEnd, vCompEnd, vCepCli);
        set @codCli = (select max(Id) from tbCliente);
        insert into tbClientePF(CPF, RG, RGDig, Nasc, IdCliENTE) values (vCPF, vRG, vRG_Dig, vNasc, @codCli);
    end if;
end $$

SET foreign_key_checks = 0; -- Define a checagem da chave estrangeira como zero (Booleana), ent não checa a constraint dela

 
	call spInsertClientePF('Pimpão', '325', null, 12345052, 12345678911, 12345678, 0, '2000-12-10', 'Av. Brasil', 'Lapa', 'Campinas', 'SP');
	call spInsertClientePF('Disney Chaplin', '89', 'Ap. 12', 12345053, 12345678912, 12345679, 0, '2001-11-21', 'Av. Paulista', 'Penha', 'Rio de Janeiro', 'RJ');
	call spInsertClientePF('Marciano', '744', null, 12345054, 12345678913, 12345680, 0, '2001-06-01', 'Rua Ximbú', 'Penha', 'Rio de Janeiro', 'RJ');
	call spInsertClientePF('Lança Perfume', '128', null, 12345055, 12345678914, 12345681, 'X', '2004-04-05', 'Rua Veia', 'Jardim Santa Isabel', 'Cuiabá', 'MT');
	call spInsertClientePF('Remédio Amargo', '2485', null, 12345056, 12345678915, 12345682, 0, '2002-07-15', 'Av. Nova', 'Jardim Santa Isabel', 'Cuiabá', 'MT');

select * from tbcliente;
select * from tbClientePf;

-- Cliente PJ (exercício 8)
delimiter $$
 create procedure spInsertClientePJ(vNomeCli varchar(200), vNumEnd decimal(6,0), vCompEnd varchar(50), vCepCli decimal(8,0),vCNPJ decimal(14,0),vIE decimal(11,0)) 
 begin
	if not exists(select * from tbclientepj where CNPJ = vCNPJ) then
		insert into tbcliente(Nome, NumEnd, CompEnd, Cep) values (vNomeCli, vNumEnd, vCompEnd, vCepCli);
		set @idCli = (select max(Id) from tbcliente);
		insert into tbClientePJ(CNPJ, IE, idCliENTE) values (vCNPJ, vIE,@IdCli);
    end if;
 end $$
 
 SET foreign_key_checks = 0;
 
 call spInsertClientePJ("Pagamada", 159, null, 12345051, 12345678912345, 98765432198);
 call spInsertClientePJ("Caloxando", 69, null, 12345053, 12345678912346, 98765432199);
 call spInsertClientePJ("Semgrana", 189, null, 12345060, 12345678912347, 98765432100);
 call spInsertClientePJ("Cemreais", 5024, "Sala 23", 12345060, 12345678912348, 98765432101);
 call spInsertClientePJ("Durango", 1254, null, 12345060, 12345678912349, 98765432102);
 select * from tbcliente;
 select * from tbClientePJ;
 
 -- Compra (exercício 9)
 delimiter $$
 create procedure spInsertCompra(vNotaFiscal int, vfornecedor varchar(200), vDataCompra date, vCodBarra varchar(14),vValorItem decimal(6,2), vQtd int, vQtdTotal int, vValorTotal decimal(8,2)) 
 begin
	 set @DataVenda = str_to_date(vDataCompra, "%d/%m/%Y");
	if not exists(select * from tbcompra where notafiscal = vnotafiscal) then
		set @forne = (select codigo from tbfornecedor where nome = vFornecedor);
		insert into tbcompra(NotaFiscal, DataCompra, ValorTotal, QtdTotal, Cod_Fornecedor) values (vNotaFiscal, @DataVenda, vValorTotal, vQtdTotal, @forne);
		insert into tbitemcompra(Qtd, ValorItem, Notafiscal, codbarras) values (vQtd, vValorItem, vNotafiscal, vcodbarra);
	else 
		insert into tbitemcompra(Qtd, ValorItem, Notafiscal, codbarras) values (vQtd, vValorItem, vNotafiscal, vcodbarra);
    end if;
 end $$
 
 call spInsertCompra(8459,'Amoroso e Doce', '2018-05-01', 12345678910111, 22.22, 200, 700, 21944.00 );
 call spInsertCompra(2482,'Revenda Chico Loco', '2020-04-22', 12345678910112, 40.50, 180, 180, 7290.00 );
 call spInsertCompra(21563,'Marcelo Dedal', '2020-07-12', 12345678910113, 3.00, 300, 300, 900.00 );
 call spInsertCompra(8459,'Amoroso e Doce', '2020-12-04', 12345678910114, 35.00, 500, 700, 21944.00 );
 call spInsertCompra(156354,'Revenda Chico Loco', '2021-11-23', 12345678910115, 54.00, 350, 350, 18900.00 );
 
 call spInsertCompra(156354,'Revenda Chico Loco', '2021-11-23', 12345678910116, 54.00, 350, 350, 18900.00 );
 
 select * from tbcompra;
 select * from tbitemcompra;
 
 -- Venda (exercício 10)
 describe tbvenda;
 describe tbitemvenda;
 describe tbcliente;
 describe tbproduto;
 
delimiter $$
create procedure spInsertVenda(vNumVenda int, vCliente varchar(200), vDataVenda char(10), vCodBarras decimal(14,0), vValorItem decimal(6,2), vQtd int, vTotalVenda int, vNF int)
begin
	set @IdCli = (select Id from tbCliente where Nome = vCliente);
    set @DataVenda = str_to_date(vDataVenda, "%d/%m/%Y");
    set @CodBarras = (select CodBarras from tbProduto where CodBarras = vCodBarras);

	if not exists (select NumeroVenda from tbVenda where NumeroVenda = vNumVenda) then
		insert into tbVenda(IdCliente, NumeroVenda, DataVenda, TotalVenda, NotaFiscal) values (@IdCli, vNumVenda, @DataVenda, vTotalVenda, vNF);
	end if;
        insert into tbItemVenda(NumeroVenda, CodBarras, Qtd, ValorItem) values (vNumVenda, @CodBarras, vQtd, vValorItem);
end $$
 
call spInsertVenda(1, 'Pimpão', '22/08/2022', 12345678910111, 54.61, 1, 54.61, null);
call spInsertVenda(2, 'Lança Perfume', '22/08/2022', 12345678910112, 100.45, 2, 200.90, null);
call spInsertVenda(3, 'Pimpão', '22/08/2022', 12345678910113, 44.00, 1, 44.00, null);

select * from tbvenda;
select * from tbitemvenda;

 -- Nota Fiscal (exercício 11)
  describe tbnotafiscal;
 
delimiter $$
create procedure spInsertNotaFiscal(vNF int, vCliente varchar(200), vDataEmissao char(10))
begin
	set @IdCli = (select Id from tbCliente where Nome = vCliente);
    set @DataEmissao = str_to_date(vDataEmissao, "%d/%m/%y");
	set @ValorTotal = (select sum(TotalVenda) from tbVenda where IdCliente = @IdCli);

	if not exists (select NF from tbNotaFiscal where NF = vNF) then
		insert into tbNotaFiscal(NF, TotalNota, DataEmissao) values (vNF, @ValorTotal, @DataEmissao);
	end if;

   	if not exists (select NotaFiscal from tbVenda where NotaFiscal = vNF) then
		update tbVenda set NotaFiscal = vNF where IdCliente = @IdCli;
	end if;
end $$
 
call spInsertNotaFiscal(359, 'Pimpão', '22/08/2022');
call spInsertNotaFiscal(360,'Lança Perfume', '22/08/2022');

select * from tbNotaFiscal;

-- exercício 12
call spProd(12345678910130,"Camiseta de Poliéster","35.61", "100");
call spProd(12345678910131,"Blusa Frio Moletom","200.00", "100");
call spProd(12345678910132,"Vestido Decote Redondo","144.00", "50");

select * from tbproduto;

-- exercício 13
delimiter $$
create procedure spDeleteProduto(vCodBarras decimal(14,0))
begin
	delete from tbProduto where CodBarras = vCodBarras;
end $$

SET SQL_SAFE_UPDATES = 0;

call spDeleteProduto (12345678910116);
call spDeleteProduto (12345678910117);

select * from tbProduto;

-- exercício 14
delimiter $$
create procedure spUpdateProduto(vCodBarras decimal(14,0), vValorUnitario decimal(6,2))
begin
	update tbProduto set  ValorUnitario = vValorUnitario where CodBarras = vCodBarras; 
end 
$$

call spUpdateProduto ("12345678910111", "64.50");
call spUpdateProduto ("12345678910112", "120.00");
call spUpdateProduto ("12345678910113", "64.00");

select * from tbProduto;

-- exercício 15
delimiter $$
create procedure spSelectProduto()
begin 
	select * from tbProduto;
end
$$

call spSelectProduto;

-- exercício 16
create table tbProdutoHistorico like tbProduto;
describe tbProdutoHistorico;

-- exercício 17
alter table tbProdutoHistorico add Ocorrencia varchar(20);
alter table tbProdutoHistorico add atualizacao datetime;
describe tbProdutoHistorico;

-- exercício 18
alter table tbProdutoHistorico drop primary key;
alter table tbProdutoHistorico add constraint PK_ProdHistorico primary key (CodBarras, Ocorrencia, Atualizacao); 
describe tbProdutoHistorico;

-- exercício 19
describe tbProdutoHistorico;

delimiter // 
create trigger trg_ProdHistorico after insert on tbProduto 
  for each row 
begin
	insert into tbProdutoHistorico
		set CodBarras = new.CodBarras,
				Qtd = new.Qtd,
				Nome = new.Nome,
				ValorUnitario = new.ValorUnitario,
				atualizacao = current_timestamp(),
				Ocorrencia = "novo"; 
end;
// 

call spProd(12345678910119,"Agua Mineral","1.99", "500");

call spProd(12345678910199,"Boneca","21.00", "200");

select * from tbProduto;
select * from tbProdutoHistorico;

-- exercício 20 
delimiter // 
create trigger trg_ProdHistoricoUpdate before update on tbProduto 
  for each row 
begin
	insert into tbProdutoHistorico
		set CodBarras = new.CodBarras,
				Qtd = new.Qtd,
				Nome = new.Nome,
				ValorUnitario = new.ValorUnitario,
				atualizacao = current_timestamp(),
				Ocorrencia = "Atualizado"; 
end;
// 

call spUpdateProduto(12345678910119, '2.99');

select * from tbProduto;
select * from tbProdutoHistorico;  
describe tbProduto;   

-- exercício 21
call spSelectProduto;

-- exercício 22
call spInsertVenda(4, 'Disney Chaplin', '26/09/2022', 12345678910111, 65.00, 1, 65.00, null);

-- exercício 23
select * from tbvenda order by NumeroVenda DESC limit 1;

-- exercício 24
select * from tbitemvenda order by NumeroVenda DESC limit 1;

-- exercício 25
delimiter $$
create procedure spSelectClinete(NomeCli varchar(100))
begin 
	select * from tbCliente where Nome = NomeCli;
end
$$

call spSelectClinete('Disney Chaplin');

select * from tbcliente;

-- exercício 26
delimiter //
Create trigger trgUpdateProdutoItemVenda after insert on tbItemVenda
for each row
begin
	update tbProduto 
    set Qtd = Qtd - new.Qtd where CodBarras = new.CodBarras;
end
//

-- exercíico 27
call spInsertVenda(5, "Paganada", "26/09/2022", 12345678910114, 10.00, 15, 150.00, null);

-- exercício 28
call spSelectProduto();

-- exercício 29 
delimiter //
Create trigger trgUpdateProdutoCompra after insert on tbItemCompra
for each row
begin
	update tbProduto 
    set Qtd = Qtd + new.Qtd where CodBarras = new.CodBarras;
end
//

-- exercício 30
 call spInsertCompra(10548, "Amoroso e Doce", '10/09/2022', 12345678910111, 40.00, 100, 100, 4000.00);
 
 -- exercício 31
call spSelectProduto();

