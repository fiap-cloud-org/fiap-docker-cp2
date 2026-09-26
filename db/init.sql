-- O cliente do entrypoint do MySQL lê o script em latin1; sem isso os acentos viram mojibake
SET NAMES utf8mb4;

-- Desabilita temporariamente as chaves estrangeiras para evitar erros de dependência
SET FOREIGN_KEY_CHECKS=0;

-- Tabela de Clientes
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    endereco TEXT
);

-- Tabela de Usuários
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL
);

-- Tabela de Permissões
CREATE TABLE permissoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE
);

-- Tabela de Categorias
CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE
);

-- Tabela de Produtos
CREATE TABLE produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    estoque INT NOT NULL,
    categoria_id INT,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL
);

-- Tabela de Lojas
CREATE TABLE lojas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    endereco TEXT
);

-- Tabela de Pedidos
CREATE TABLE pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT,
    data_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE
);

-- Tabela de Itens do Pedido
CREATE TABLE items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT,
    produto_id INT,
    quantidade INT NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE CASCADE
);

-- Tabela de Estoque
CREATE TABLE estoque (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto_id INT UNIQUE,
    quantidade INT NOT NULL,
    FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE CASCADE
);

-- Tabela de Fornecedores
CREATE TABLE fornecedores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    contato VARCHAR(100),
    endereco TEXT
);

-- Tabela de Orçamentos
CREATE TABLE orcamento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fornecedor_id INT,
    valor DECIMAL(10,2) NOT NULL,
    data_solicitacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fornecedor_id) REFERENCES fornecedores(id) ON DELETE CASCADE
);

-- Tabela de Pagamentos
CREATE TABLE pagamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT,
    metodo VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE
);

-- Tabela de Avaliações
CREATE TABLE avaliacoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto_id INT,
    cliente_id INT,
    nota INT CHECK (nota BETWEEN 1 AND 5),
    comentario TEXT,
    FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE CASCADE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE
);

-- Tabela de Frete
CREATE TABLE frete (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT,
    endereco_entrega TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE
);

-- Inserção de dados para testes

-- Clientes
INSERT INTO clientes (nome, email, telefone, endereco) VALUES
('Carlos Silva', 'carlos@email.com', '11999999999', 'Rua A, 123'),
('Ana Souza', 'ana@email.com', '11988888888', 'Rua B, 456'),
('Pedro Lima', 'pedro@email.com', '11977777777', 'Rua C, 789'),
('Maria Oliveira', 'maria@email.com', '11966666666', 'Rua D, 101'),
('João Santos', 'joao@email.com', '11955555555', 'Rua E, 202');

-- Usuários (senhas guardadas só como hash PBKDF2 de valores aleatórios)
INSERT INTO usuarios (nome, email, senha) VALUES
('Admin', 'admin@email.com', 'pbkdf2:sha256:600000$mZNOjo246kwJaZPR$8a852c71d2579288485026eb01e97e40707cc22324d4ec6568405437572e5c59'),
('Carlos Silva', 'carlos@email.com', 'pbkdf2:sha256:600000$pAfHy3oebvlWwK4S$1eab1816d7b6acdc11e84235171c3adfceb8622c834706c6d0ce6065c6e6a273'),
('Ana Souza', 'ana@email.com', 'pbkdf2:sha256:600000$lkKWlsmlg5lVonHo$9ebfc14a8a184d8c541f846636a8c75bb9a3b62cafccc9b6a3e64a54e984e878'),
('Pedro Lima', 'pedro@email.com', 'pbkdf2:sha256:600000$UrjPbtMj1KUmREOw$a949a64c532bfe1af53015f7c3193d73d75656113964e97df12b3582eba0ccdd'),
('Maria Oliveira', 'maria@email.com', 'pbkdf2:sha256:600000$sXFcHaqyZ0qnIVZB$5bbb941f3373165afa9d9759d4a279999e9fe39d62343af81a554f2abfb079bd');

-- Categorias
INSERT INTO categorias (nome) VALUES
('Eletrônicos'),
('Roupas'),
('Alimentos'),
('Livros'),
('Brinquedos');

-- Produtos
INSERT INTO produtos (nome, descricao, preco, estoque, categoria_id) VALUES
('Notebook', 'Notebook Dell i7', 3500.00, 10, 1),
('Camiseta', 'Camiseta preta de algodão', 50.00, 20, 2),
('Arroz', 'Pacote de arroz 5kg', 30.00, 50, 3),
('Livro Python', 'Livro sobre programação em Python', 80.00, 15, 4),
('Boneca', 'Boneca de pano artesanal', 45.00, 25, 5);

-- Pedidos
INSERT INTO pedidos (cliente_id, status) VALUES
(1, 'Em Processamento'),
(2, 'Enviado'),
(3, 'Entregue'),
(4, 'Cancelado'),
(5, 'Pendente');

-- Itens do Pedido
INSERT INTO items (pedido_id, produto_id, quantidade) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 1),
(5, 5, 2);

-- Pagamentos
INSERT INTO pagamentos (pedido_id, metodo, status) VALUES
(1, 'Cartão de Crédito', 'Aprovado'),
(2, 'Boleto', 'Aguardando Pagamento'),
(3, 'PIX', 'Pago'),
(4, 'Cartão de Débito', 'Recusado'),
(5, 'Transferência Bancária', 'Aprovado');

-- Avaliações
INSERT INTO avaliacoes (produto_id, cliente_id, nota, comentario) VALUES
(1, 1, 5, 'Ótimo produto!'),
(2, 2, 4, 'Boa qualidade'),
(3, 3, 3, 'Poderia ser melhor'),
(4, 4, 5, 'Excelente'),
(5, 5, 4, 'Muito bom!');

-- Reabilita as chaves estrangeiras
SET FOREIGN_KEY_CHECKS=1;