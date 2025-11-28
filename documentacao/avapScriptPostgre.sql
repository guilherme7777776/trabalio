-- Set schema
SET search_path TO public;

-- DROP em ordem de dependência
DROP TABLE IF EXISTS PAGAMENTO_HAS_FORMA_PAGAMENTO CASCADE;
DROP TABLE IF EXISTS PAGAMENTO CASCADE;
DROP TABLE IF EXISTS ITEM_PEDIDO CASCADE;
DROP TABLE IF EXISTS PEDIDO CASCADE;
DROP TABLE IF EXISTS CD CASCADE;
DROP TABLE IF EXISTS VINIL CASCADE;
DROP TABLE IF EXISTS CAMISETA CASCADE;
DROP TABLE IF EXISTS PRODUTO CASCADE;
DROP TABLE IF EXISTS GERENTE CASCADE;
DROP TABLE IF EXISTS FUNCIONARIO CASCADE;
DROP TABLE IF EXISTS CARGO CASCADE;
DROP TABLE IF EXISTS CLIENTE CASCADE;
DROP TABLE IF EXISTS FORMA_PAGAMENTO CASCADE;
DROP TABLE IF EXISTS PESSOA CASCADE;

-- ========================
-- TABELAS
-- ========================

CREATE TABLE PESSOA (
    id_pessoa INT PRIMARY KEY,
    nome_pessoa VARCHAR(100) NOT NULL,
    email_pessoa VARCHAR(70) NOT NULL,
    senha_pessoa VARCHAR(255) NOT NULL,
    endereco_pessoa VARCHAR(100),
    telefone_pessoa VARCHAR(20),
    data_nascimento DATE
);

CREATE TABLE CLIENTE (
    id_pessoa INT PRIMARY KEY,
    renda_cliente DECIMAL(10,2),
    data_cadastro DATE,
    FOREIGN KEY (id_pessoa) REFERENCES PESSOA(id_pessoa) ON DELETE CASCADE
);

CREATE TABLE CARGO (
    id_cargo SERIAL PRIMARY KEY,
    nome_cargo VARCHAR(50) NOT NULL
);

CREATE TABLE FUNCIONARIO (
    id_pessoa INT PRIMARY KEY,
    salario_funcionario DECIMAL(10,2),
    carga_horaria NUMERIC(5,2) CHECK (carga_horaria > 0),
    id_cargo INT,
    FOREIGN KEY (id_pessoa) REFERENCES PESSOA(id_pessoa) ON DELETE CASCADE,
    FOREIGN KEY (id_cargo) REFERENCES CARGO(id_cargo) ON DELETE SET NULL
);

CREATE TABLE PRODUTO (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) NOT NULL CHECK (preco >= 0),
    id_funcionario INT,
    FOREIGN KEY (id_funcionario) REFERENCES FUNCIONARIO(id_pessoa) ON DELETE SET NULL
);

CREATE TABLE CAMISETA (
    id_produto INT PRIMARY KEY,
    tamanho VARCHAR(10),
    cor VARCHAR(20),
    FOREIGN KEY (id_produto) REFERENCES PRODUTO(id_produto) ON DELETE CASCADE
);

CREATE TABLE VINIL (
    id_produto INT PRIMARY KEY,
    ano_lancamento INT,
    FOREIGN KEY (id_produto) REFERENCES PRODUTO(id_produto) ON DELETE CASCADE
);

CREATE TABLE CD (
    id_produto INT PRIMARY KEY,
    duracao_minutos INT,
    FOREIGN KEY (id_produto) REFERENCES PRODUTO(id_produto) ON DELETE CASCADE
);

-- ALTERADO DE CARRINHO PARA PEDIDO
CREATE TABLE PEDIDO (
    id_pedido SERIAL PRIMARY KEY,
    id_funcionario INT NOT NULL,
    data_pedido DATE,
    id_pessoa INT NOT NULL,
    FOREIGN KEY (id_pessoa) REFERENCES PESSOA(id_pessoa) ON DELETE CASCADE,
    FOREIGN KEY (id_funcionario) REFERENCES FUNCIONARIO(id_pessoa) ON DELETE CASCADE
);

-- ALTERADO DE ITEM_CARRINHO PARA ITEM_PEDIDO
CREATE TABLE ITEM_PEDIDO (
    id_item SERIAL PRIMARY KEY,
    pedido_id_pedido INT NOT NULL,
    produto_id_produto INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    preco_unitario DECIMAL(10,2) NOT NULL CHECK (preco_unitario >= 0),
    FOREIGN KEY (pedido_id_pedido) REFERENCES PEDIDO(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (produto_id_produto) REFERENCES PRODUTO(id_produto) ON DELETE CASCADE
);

CREATE TABLE FORMA_PAGAMENTO (
    id_forma_pagamento SERIAL PRIMARY KEY,
    nome_forma_pagamento VARCHAR(50) NOT NULL
);

-- id_carrinho → id_pedido
CREATE TABLE PAGAMENTO (
    id_pagamento SERIAL PRIMARY KEY,
    id_pedido INT UNIQUE NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL CHECK (valor_total >= 0),
    data_pagamento TIMESTAMP NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES PEDIDO(id_pedido) ON DELETE CASCADE
);

CREATE TABLE PAGAMENTO_HAS_FORMA_PAGAMENTO (
    id_pagamento INT NOT NULL,
    id_forma_pagamento INT NOT NULL,
    valor_pago DECIMAL(10,2) NOT NULL CHECK (valor_pago >= 0),
    PRIMARY KEY (id_pagamento, id_forma_pagamento),
    FOREIGN KEY (id_pagamento) REFERENCES PAGAMENTO(id_pagamento) ON DELETE CASCADE,
    FOREIGN KEY (id_forma_pagamento) REFERENCES FORMA_PAGAMENTO(id_forma_pagamento) ON DELETE CASCADE
);

-- ========================
-- INSERÇÕES CORRIGIDAS
-- ========================

INSERT INTO PESSOA (id_pessoa, nome_pessoa, email_pessoa, senha_pessoa, endereco_pessoa, telefone_pessoa, data_nascimento) VALUES
(1, 'João Silva', 'joao@empresa.com', 'senha123', 'Rua A, 10', '99990001', '1985-05-10'),
(2, 'Maria Santos', 'maria@empresa.com', 'senha456', 'Rua B, 20', '99990002', '1990-07-15'),
(3, 'Carlos Lima', 'carlos@empresa.com', 'senha789', 'Rua C, 30', '99990003', '1988-03-22'),
(4, 'Ana Pereira', 'ana@cliente.com', 'senha111', 'Rua D, 40', '88880001', '1992-02-20'),
(5, 'Bruno Costa', 'bruno@cliente.com', 'senha222', 'Rua E, 50', '88880002', '1987-11-05'),
(6, 'Carla Rocha', 'carla@cliente.com', 'senha333', 'Rua F, 60', '88880003', '1995-08-30'),
(7, 'Fabio Souza', 'fabio@empresa.com', 'senha321', 'Rua G, 70', '99990004', '1983-01-05'),
(8, 'Gabriela Alves', 'gabriela@empresa.com', 'senha654', 'Rua H, 80', '99990005', '1991-09-10'),
(9, 'Helena Martins', 'helena@empresa.com', 'senha987', 'Rua I, 90', '99990006', '1987-12-20'),
(10, 'Igor Campos', 'igor@empresa.com', 'senha159', 'Rua J, 100', '99990007', '1986-06-25');

-- CARGO
INSERT INTO CARGO (nome_cargo) VALUES
('Vendedor'),
('Gerente'),
('Caixa');

-- FUNCIONARIO
INSERT INTO FUNCIONARIO (id_pessoa, salario_funcionario, carga_horaria, id_cargo) VALUES
(1, 3000.00, 44.0, 1),
(2, 4000.00, 40.0, 2),
(3, 2500.00, 36.0, 1),
(7, 3500.00, 42.0, 2),
(8, 3200.00, 40.0, 1),
(9, 3100.00, 38.0, 1),
(10, 3600.00, 44.0, 3);


INSERT INTO CLIENTE (id_pessoa, renda_cliente, data_cadastro) VALUES
(4, 5000.00, '2025-10-10'),
(5, 7000.00, '2025-10-11'),
(6, 3000.00, '2025-10-12');

-- PRODUTOS
INSERT INTO PRODUTO (id_produto, nome, preco, id_funcionario) VALUES
(1, 'Camiseta Iron Maiden - The Trooper', 89.90, 1),
(2, 'Vinil Metallica - Master of Puppets', 149.90, 2),
(3, 'CD Angra - Rebirth', 54.90, 1),
(4, 'Camiseta Pink Floyd - Dark Side of the Moon', 99.90, 2),
(5, 'Vinil Queen - A Night at the Opera', 159.90, 3),
(6, 'CD Dream Theater - Images and Words', 59.90, 1),
(7, 'Camiseta Led Zeppelin - IV', 84.90, 2),
(8, 'Vinil Nirvana - Nevermind', 139.90, 3),
(9, 'CD Rush - Moving Pictures', 49.90, 1),
(10, 'Camiseta AC/DC - Back in Black', 89.90, 2);

-- CAMISETAS
INSERT INTO CAMISETA (id_produto, tamanho, cor) VALUES
(1, 'M', 'Preto'),
(4, 'G', 'Preto'),
(7, 'M', 'Branco'),
(10, 'G', 'Preto');

-- VINIS
INSERT INTO VINIL (id_produto, ano_lancamento) VALUES
(2, 1986),
(5, 1975),
(8, 1991);

-- CDS
INSERT INTO CD (id_produto, duracao_minutos) VALUES
(3, 61),
(6, 57),
(9, 44);

-- PEDIDOS (somente clientes 4, 5 e 6)
INSERT INTO PEDIDO (id_funcionario, data_pedido, id_pessoa) VALUES
(1, '2025-10-13', 4),  -- Ana Pereira atendida por João
(2, '2025-10-14', 5),  -- Bruno Costa atendido por Maria
(3, '2025-10-15', 6),  -- Carla Rocha atendida por Carlos
(7, '2025-10-16', 4),  -- Ana faz outro pedido com Fabio
(8, '2025-10-17', 5),  -- Bruno faz outro pedido com Gabriela
(9, '2025-10-18', 6),  -- Carla faz outro pedido com Helena
(10, '2025-10-19', 4), -- Ana faz outro pedido com Igor
(2, '2025-10-20', 5);  -- Bruno faz mais um com Maria

-- ITENS DOS PEDIDOS
INSERT INTO ITEM_PEDIDO (pedido_id_pedido, produto_id_produto, quantidade, preco_unitario) VALUES
-- Pedido 1 (Ana)
(1, 1, 1, 89.90),
(1, 3, 1, 54.90),

-- Pedido 2 (Bruno)
(2, 2, 1, 149.90),
(2, 4, 1, 99.90),

-- Pedido 3 (Carla)
(3, 5, 1, 159.90),
(3, 6, 1, 59.90),

-- Pedido 4 (Ana)
(4, 7, 1, 84.90),
(4, 8, 1, 139.90),

-- Pedido 5 (Bruno)
(5, 9, 1, 49.90),
(5, 10, 1, 89.90),

-- Pedido 6 (Carla)
(6, 3, 1, 54.90),
(6, 4, 1, 99.90),
(6, 2, 1, 149.90),

-- Pedido 7 (Ana)
(7, 1, 2, 89.90),
(7, 5, 1, 159.90),

-- Pedido 8 (Bruno)
(8, 8, 1, 139.90),
(8, 10, 1, 89.90);

-- PAGAMENTOS
INSERT INTO PAGAMENTO (id_pedido, data_pagamento, valor_total) VALUES
(1, '2025-10-13 14:30:00', 144.80),
(2, '2025-10-14 10:15:00', 249.80),
(3, '2025-10-15 12:50:00', 218.80),
(4, '2025-10-16 13:45:00', 224.80),
(5, '2025-10-17 09:25:00', 139.80),
(6, '2025-10-18 15:40:00', 303.70),
(7, '2025-10-19 18:10:00', 339.70),
(8, '2025-10-20 20:05:00', 228.80);

-- FORMAS DE PAGAMENTO
INSERT INTO FORMA_PAGAMENTO (nome_forma_pagamento) VALUES
('Cartão de Crédito'),
('Boleto Bancário'),
('Pix'),
('Dinheiro');

-- PAGAMENTO_HAS_FORMA_PAGAMENTO
INSERT INTO PAGAMENTO_HAS_FORMA_PAGAMENTO (id_pagamento, id_forma_pagamento, valor_pago) VALUES
(1, 1, 144.80),  -- Cartão
(2, 3, 249.80),  -- Pix
(3, 2, 218.80),  -- Boleto
(4, 4, 224.80),  -- Dinheiro
(5, 1, 139.80),  -- Cartão
(6, 3, 303.70),  -- Pix
(7, 1, 339.70),  -- Cartão
(8, 4, 228.80);  -- Dinheiro

