CREATE DATABASE tech;
USE tech;

CREATE TABLE estoque (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL
);

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';
FLUSH PRIVILEGES;produto,categoria,quantidade,preco_unitario
Mouse Sem Fio Logitech,Perifericos,150,89.90
Teclado Mecanico,Perifericos,80,350.00
Monitor LG 24",Monitores,50,999.90
Webcam Full HD,Acessorios,120,159.50
SSD 500GB,Armazenamento,200,299.00

INSERT INTO estoque (produto, categoria, quantidade, preco_unitario) VALUES ('Mouse Sem Fio Logitech', 'Perifericos', 150, 89.90);
INSERT INTO estoque (produto, categoria, quantidade, preco_unitario) VALUES ('Teclado Mecanico', 'Perifericos', 80, 350.00);
INSERT INTO estoque (produto, categoria, quantidade, preco_unitario) VALUES ('Monitor LG 24"', 'Monitores', 50, 999.90);
INSERT INTO estoque (produto, categoria, quantidade, preco_unitario) VALUES ('Webcam Full HD', 'Acessorios', 120, 159.50);
INSERT INTO estoque (produto, categoria, quantidade, preco_unitario) VALUES ('SSD 500GB', 'Armazenamento', 200, 299.00);

INSERT INTO estoque (produto, categoria, quantidade, preco_unitario)
VALUES ('Cabo HDMI 2m', 'Acessorios', 40, 29.90);

SELECT id, produto, categoria, quantidade, preco_unitario
FROM estoque;

SELECT produto, quantidade
FROM estoque;

UPDATE estoque
SET categoria = 'Acessorios'
WHERE produto = 'Teclado Mecanico';

DELETE FROM estoque
WHERE produto = 'Monitor LG 24"';

import mysql.connector
import csv
import os

# Configurações de conexão
config = {
    'user': 'root',
    'password': '',
    'host': 'localhost',
    'database': 'tech',
    'auth_plugin': 'mysql_native_password'
}

CSV_FILE = '/home/ubuntu/estoque_inicial.csv'

def connect():
    """Estabelece a conexão com o banco de dados."""
    try:
        conn = mysql.connector.connect(**config)
        return conn
    except mysql.connector.Error as err:
        print(f"Erro de conexão: {err}")
        return None

def import_csv(conn):
    """Importa os dados do CSV para a tabela estoque."""
    print("\n--- 2. Importando dados do CSV ---")
    cursor = conn.cursor()
    
    if not os.path.exists(CSV_FILE):
        print(f"Erro: Arquivo CSV não encontrado em {CSV_FILE}")
        return

    with open(CSV_FILE, 'r') as f:
        reader = csv.reader(f)
        next(reader) # Pula o cabeçalho
        
        sql = "INSERT INTO estoque (produto, categoria, quantidade, preco_unitario) VALUES (%s, %s, %s, %s)"
        
        try:
            for row in reader:
                # Converte preco_unitario para float antes de inserir
                row[3] = float(row[3].replace(',', '.'))
                cursor.execute(sql, row)
            conn.commit()
            print(f"Sucesso: {cursor.rowcount} linhas importadas.")
        except mysql.connector.Error as err:
            print(f"Erro ao importar dados: {err}")
            conn.rollback()
        finally:
            cursor.close()

def execute_crud(conn):
    """Executa as operações CRUD solicitadas."""
    cursor = conn.cursor()

    # --- Create ---
    print("\n--- 3.1. Create: Adicionar 'Cabo HDMI 2m' ---")
    new_product = ("Cabo HDMI 2m", "Acessorios", 40, 29.90)
    sql_create = "INSERT INTO estoque (produto, categoria, quantidade, preco_unitario) VALUES (%s, %s, %s, %s)"
    try:
        cursor.execute(sql_create, new_product)
        conn.commit()
        print(f"Sucesso: Produto '{new_product[0]}' adicionado.")
    except mysql.connector.Error as err:
        print(f"Erro ao adicionar produto: {err}")
        conn.rollback()

    # --- Read (Todos os produtos) ---
    print("\n--- 3.2. Read: Mostrar todos os produtos cadastrados ---")
    sql_read_all = "SELECT id, produto, categoria, quantidade, preco_unitario FROM estoque"
    cursor.execute(sql_read_all)
    all_products = cursor.fetchall()
    print("| ID | Produto | Categoria | Quantidade | Preço Unitário |")
    print("|:---|:---|:---|:---|:---|")
    for (id, produto, categoria, quantidade, preco_unitario) in all_products:
        print(f"| {id} | {produto} | {categoria} | {quantidade} | R$ {preco_unitario:.2f} |")

    # --- Read (Nome e Quantidade) ---
    print("\n--- 3.3. Read: Listar apenas nome e quantidade ---")
    sql_read_name_qty = "SELECT produto, quantidade FROM estoque"
    cursor.execute(sql_read_name_qty)
    name_qty_products = cursor.fetchall()
    print("| Produto | Quantidade |")
    print("|:---|:---|")
    for (produto, quantidade) in name_qty_products:
        print(f"| {produto} | {quantidade} |")

    # --- Update ---
    print("\n--- 3.4. Update: Trocar categoria de 'Teclado Mecanico' para 'Acessorios' ---")
    sql_update = "UPDATE estoque SET categoria = %s WHERE produto = %s"
    try:
        cursor.execute(sql_update, ("Acessorios", "Teclado Mecanico"))
        conn.commit()
        print(f"Sucesso: Categoria de 'Teclado Mecanico' atualizada. Linhas afetadas: {cursor.rowcount}")
    except mysql.connector.Error as err:
        print(f"Erro ao atualizar produto: {err}")
        conn.rollback()

    # --- Delete ---
    print("\n--- 3.5. Delete: Excluir 'Monitor LG 24\"' ---")
    sql_delete = "DELETE FROM estoque WHERE produto = %s"
    try:
        cursor.execute(sql_delete, ("Monitor LG 24\"",))
        conn.commit()
        print(f"Sucesso: Produto 'Monitor LG 24\"' excluído. Linhas afetadas: {cursor.rowcount}")
    except mysql.connector.Error as err:
        print(f"Erro ao excluir produto: {err}")
        conn.rollback()

    cursor.close()

def final_read(conn):
    """Mostra o estado final do estoque."""
    print("\n--- 4. Estado Final do Estoque ---")
    cursor = conn.cursor()
    sql_final = "SELECT id, produto, categoria, quantidade, preco_unitario FROM estoque"
    cursor.execute(sql_final)
    final_products = cursor.fetchall()
    
    output = "## Estado Final do Estoque\n\n"
    output += "| ID | Produto | Categoria | Quantidade | Preço Unitário |\n"
    output += "|:---|:---|:---|:---|:---|\n"
    for (id, produto, categoria, quantidade, preco_unitario) in final_products:
        output += f"| {id} | {produto} | {categoria} | {quantidade} | R$ {preco_unitario:.2f} |\n"
    
    cursor.close()
    return output

def main():
    conn = connect()
    if conn:
        import_csv(conn)
        execute_crud(conn)
        final_table = final_read(conn)
        conn.close()
        return final_table
    return "Erro: Não foi possível conectar ao banco de dados."

if __name__ == "__main__":
    result = main()
    # Salva o resultado final em um arquivo para ser lido pelo agente
    with open("/home/ubuntu/final_result.md", "w") as f:
        f.write(result)
    print("\nProcesso concluído. Resultado final salvo em /home/ubuntu/final_result.md")
