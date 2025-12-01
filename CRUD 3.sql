CREATE TABLE produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL
);

INSERT INTO produtos (produto, categoria, quantidade, preco_unitario) VALUES ('Arroz 5kg', 'Mercearia', 50, 25.90);
INSERT INTO produtos (produto, categoria, quantidade, preco_unitario) VALUES ('Feijao 1kg', 'Mercearia', 40, 9.50);

INSERT INTO produtos (produto, categoria, quantidade, preco_unitario) VALUES ('Leite Integral 1L', 'Mercearia', 30, 4.80);
INSERT INTO produtos (produto, categoria, quantidade, preco_unitario) VALUES ('Maca kg', 'Hortifruti', 25, 7.90);
INSERT INTO produtos (produto, categoria, quantidade, preco_unitario) VALUES ('Refrigerante Cola 2L', 'Bebidas', 100, 7.50);

INSERT INTO produtos (produto, categoria, quantidade, preco_unitario)
VALUES ('Iogurte', 'Laticinios', 12, 8.90);

UPDATE produtos
SET categoria = 'Frutas'
WHERE produto = 'Maca kg';

SELECT id, produto, categoria, quantidade, preco_unitario
FROM produtos;
