/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- ================================
-- TABELA PESSOA
-- ================================
DROP TABLE IF EXISTS `pessoa`;
CREATE TABLE `pessoa` (
  `id_pessoa` INT NOT NULL,
  `nome_pessoa` VARCHAR(100) NOT NULL,
  `email_pessoa` VARCHAR(70) NOT NULL UNIQUE,
  `senha_pessoa` VARCHAR(255) NOT NULL,
  `endereco_pessoa` VARCHAR(100),
  `telefone_pessoa` VARCHAR(20),
  `data_nascimento` DATE,
  PRIMARY KEY (`id_pessoa`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ================================
-- TABELA CLIENTE
-- ================================
DROP TABLE IF EXISTS `cliente`;
CREATE TABLE `cliente` (
  `id_pessoa` INT NOT NULL,
  PRIMARY KEY (`id_pessoa`),
  CONSTRAINT `fk_cliente_pessoa` FOREIGN KEY (`id_pessoa`) REFERENCES `pessoa` (`id_pessoa`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ================================
-- TABELA FUNCIONARIO
-- ================================
DROP TABLE IF EXISTS `funcionario`;
CREATE TABLE `funcionario` (
  `id_pessoa` INT NOT NULL,
  `cargo` VARCHAR(50),
  PRIMARY KEY (`id_pessoa`),
  CONSTRAINT `fk_funcionario_pessoa` FOREIGN KEY (`id_pessoa`) REFERENCES `pessoa` (`id_pessoa`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ================================
-- TABELA GERENTE
-- ================================
DROP TABLE IF EXISTS `gerente`;
CREATE TABLE `gerente` (
  `id_pessoa` INT NOT NULL,
  PRIMARY KEY (`id_pessoa`),
  CONSTRAINT `fk_gerente_funcionario` FOREIGN KEY (`id_pessoa`) REFERENCES `funcionario` (`id_pessoa`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ================================
-- TABELA PRODUTO
-- ================================
DROP TABLE IF EXISTS `produto`;
CREATE TABLE `produto` (
  `id_produto` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `preco` DECIMAL(10,2) NOT NULL CHECK (`preco` >= 0),
  `f_id_pessoa` INT DEFAULT NULL,
  PRIMARY KEY (`id_produto`),
  CONSTRAINT `fk_produto_funcionario` FOREIGN KEY (`f_id_pessoa`) REFERENCES `funcionario` (`id_pessoa`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ================================
-- TABELA CAMISETA
-- ================================
DROP TABLE IF EXISTS `camiseta`;
CREATE TABLE `camiseta` (
  `id_produto` INT NOT NULL,
  `cor` VARCHAR(50),
  PRIMARY KEY (`id_produto`),
  CONSTRAINT `fk_camiseta_produto` FOREIGN KEY (`id_produto`) REFERENCES `produto` (`id_produto`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ================================
-- TABELA VINIL
-- ================================
DROP TABLE IF EXISTS `vinil`;
CREATE TABLE `vinil` (
  `id_produto` INT NOT NULL,
  `artista` VARCHAR(100),
  PRIMARY KEY (`id_produto`),
  CONSTRAINT `fk_vinil_produto` FOREIGN KEY (`id_produto`) REFERENCES `produto` (`id_produto`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ================================
-- TABELA CD
-- ================================
DROP TABLE IF EXISTS `cd`;
CREATE TABLE `cd` (
  `id_produto` INT NOT NULL,
  `artista` VARCHAR(100),
  PRIMARY KEY (`id_produto`),
  CONSTRAINT `fk_cd_produto` FOREIGN KEY (`id_produto`) REFERENCES `produto` (`id_produto`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ================================
-- TABELA CARRINHO
-- ================================
DROP TABLE IF EXISTS `carrinho`;
CREATE TABLE `carrinho` (
  `id_carrinho` INT NOT NULL AUTO_INCREMENT,
  `c_id_pessoa` INT DEFAULT NULL,
  PRIMARY KEY (`id_carrinho`),
  CONSTRAINT `fk_carrinho_cliente` FOREIGN KEY (`c_id_pessoa`) REFERENCES `cliente` (`id_pessoa`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ================================
-- TABELA ITEM_CARRINHO
-- ================================
DROP TABLE IF EXISTS `item_carrinho`;
CREATE TABLE `item_carrinho` (
  `id_item` INT NOT NULL AUTO_INCREMENT,
  `id_carrinho` INT DEFAULT NULL,
  `id_produto` INT DEFAULT NULL,
  `quantidade` INT NOT NULL CHECK (`quantidade` > 0),
  PRIMARY KEY (`id_item`),
  CONSTRAINT `fk_item_carrinho_carrinho` FOREIGN KEY (`id_carrinho`) REFERENCES `carrinho` (`id_carrinho`) ON DELETE CASCADE,
  CONSTRAINT `fk_item_carrinho_produto` FOREIGN KEY (`id_produto`) REFERENCES `produto` (`id_produto`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ================================
-- TABELA PAGAMENTO
-- ================================
DROP TABLE IF EXISTS `pagamento`;
CREATE TABLE `pagamento` (
  `id_pagamento` INT NOT NULL AUTO_INCREMENT,
  `id_carrinho` INT DEFAULT NULL UNIQUE,
  `forma_pagamento` VARCHAR(50),
  `valor_total` DECIMAL(10,2) NOT NULL CHECK (`valor_total` >= 0),
  `data_pagamento` DATE NOT NULL,
  PRIMARY KEY (`id_pagamento`),
  CONSTRAINT `fk_pagamento_carrinho` FOREIGN KEY (`id_carrinho`) REFERENCES `carrinho` (`id_carrinho`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ================================
-- INSERÇÃO DE DADOS
-- ================================

-- PESSOAS
INSERT INTO `pessoa` (`id_pessoa`, `nome_pessoa`, `email_pessoa`, `senha_pessoa`, `endereco_pessoa`, `telefone_pessoa`, `data_nascimento`) VALUES
(1, 'João da Silva', 'joao@email.com', 'hash1', 'Rua A, 123', '11999990001', '1990-01-15'),
(2, 'Bruno Souza', 'bruno@email.com', 'hash2', 'Rua B, 456', '11999990002', '1988-06-23'),
(3, 'Carlos Lima', 'carlos@email.com', 'hash3', 'Rua C, 789', '11999990003', '1992-09-12'),
(4, 'Daniela Castro', 'daniela@email.com', 'hash4', 'Rua D, 101', '11999990004', '1995-04-05'),
(5, 'Eduardo Alves', 'eduardo@email.com', 'hash5', 'Rua E, 202', '11999990005', '1991-11-20'),
(6, 'Fernanda Rocha', 'fernanda@email.com', 'hash6', 'Rua F, 303', '11999990006', '1985-02-28'),
(7, 'Gustavo Melo', 'gustavo@email.com', 'hash7', 'Rua G, 404', '11999990007', '1989-07-17'),
(8, 'Helena Martins', 'helena@email.com', 'hash8', 'Rua H, 505', '11999990008', '1993-12-01'),
(9, 'Igor Ferreira', 'igor@email.com', 'hash9', 'Rua I, 606', '11999990009', '1990-10-30'),
(10, 'Juliana Dias', 'juliana@email.com', 'hash10', 'Rua J, 707', '11999990010', '1994-08-14');

-- CLIENTES
INSERT INTO `cliente` (`id_pessoa`) VALUES
(1), (2), (3), (4), (5);

-- FUNCIONARIOS
INSERT INTO `funcionario` (`id_pessoa`, `cargo`) VALUES
(6, 'Funcionário'),
(7, 'Funcionário'),
(8, 'Gerente');

-- GERENTE
INSERT INTO `gerente` (`id_pessoa`) VALUES
(8);

-- PRODUTOS
INSERT INTO `produto` (`id_produto`, `nome`, `preco`, `f_id_pessoa`) VALUES
(1, 'Camiseta Rock', 79.90, 6),
(2, 'Vinil Metallica - Master of Puppets', 129.90, 7),
(3, 'CD Angra - Temple of Shadows', 49.90, 6),
(4, 'Camiseta Jazz', 89.90, 7),
(5, 'Vinil Beatles - Revolver', 139.90, 8),
(6, 'CD King Crimson - In the Court of the Crimson King', 49.90, 6),
(7, 'Vinil Megadeth - Rust in Peace', 149.90, 7),
(8, 'CD Metallica - Ride the Lightning', 69.90, 6),
(9, 'Vinil Pink Floyd - Dark Side of the Moon', 159.90, 7),
(10, 'CD Queen - A Night at the Opera', 59.90, 6);

-- CAMISETAS
INSERT INTO `camiseta` (`id_produto`, `cor`) VALUES
(1, 'Preta'),
(4, 'Branca');

-- VINIS
INSERT INTO `vinil` (`id_produto`, `artista`) VALUES
(2, 'Metallica'),
(5, 'The Beatles'),
(7, 'Megadeth'),
(9, 'Pink Floyd');

-- CDS
INSERT INTO `cd` (`id_produto`, `artista`) VALUES
(3, 'Angra'),
(6, 'King Crimson'),
(8, 'Metallica'),
(10, 'Queen');

-- CARRINHOS
INSERT INTO `carrinho` (`id_carrinho`, `c_id_pessoa`) VALUES
(1, 1),
(2, 2),
(3, 3);

-- ITENS CARRINHO
INSERT INTO `item_carrinho` (`id_item`, `id_carrinho`, `id_produto`, `quantidade`) VALUES
(1, 1, 1, 2),
(2, 1, 3, 1),
(3, 2, 2, 1),
(4, 2, 4, 2),
(5, 3, 5, 1);

-- PAGAMENTOS
INSERT INTO `pagamento` (`id_pagamento`, `id_carrinho`, `forma_pagamento`, `valor_total`, `data_pagamento`) VALUES
(1, 1, 'Cartão de Crédito', 209.70, '2025-09-10'),
(2, 2, 'Boleto', 309.80, '2025-09-11'),
(3, 3, 'Pix', 139.90, '2025-09-12');

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
