DROP DATABASE IF EXISTS freshmart;

CREATE DATABASE freshmart;

USE freshmart;

CREATE TABLE produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL
);

produto,categoria,quantidade,preco_unitario
Arroz 5kg,Mercearia,50,25.90
Feijao 1kg,Mercearia,40,9.50
Leite Integral 1L,Laticinios,30,4.80
Pao Frances 500g,Padaria,60,6.50
Maca kg,Hortifruti,25,7.90

INSERT INTO produtos (produto, categoria, quantidade, preco_unitario) VALUES ('Arroz 5kg', 'Mercearia', 50, 25.90);
INSERT INTO produtos (produto, categoria, quantidade, preco_unitario) VALUES ('Feijao 1kg', 'Mercearia', 40, 9.50);
INSERT INTO produtos (produto, categoria, quantidade, preco_unitario) VALUES ('Leite Integral 1L', 'Laticinios', 30, 4.80);
INSERT INTO produtos (produto, categoria, quantidade, preco_unitario) VALUES ('Pao Frances 500g', 'Padaria', 60, 6.50);
INSERT INTO produtos (produto, categoria, quantidade, preco_unitario) VALUES ('Maca kg', 'Hortifruti', 25, 7.90);

INSERT INTO produtos (produto, categoria, quantidade, preco_unitario)
VALUES ('Refrigerante Cola 2L', 'Bebidas', 100, 7.50);

SELECT id, produto, categoria, quantidade, preco_unitario
FROM produtos;

SELECT produto, quantidade
FROM produtos;

UPDATE produtos
SET categoria = 'Mercearia'
WHERE produto = 'Leite Integral 1L';

DELETE FROM produtos
WHERE produto = 'Pao Frances 500g';

import mysql.connector
import csv
import os

# Configurações de conexão
config = {
    'user': 'root',
    'password': '',
    'host': 'localhost',
    'database': 'freshmart',
    'auth_plugin': 'mysql_native_password'
}

CSV_FILE = '/home/ubuntu/upload/Produtos-Página1.csv'

def connect():
    """Estabelece a conexão com o banco de dados."""
    try:
        conn = mysql.connector.connect(**config)
        return conn
    except mysql.connector.Error as err:
        print(f"Erro de conexão: {err}")
        return None

def import_csv(conn):
    """Importa os dados do CSV para a tabela produtos."""
    print("\n--- 2. Importando dados do CSV ---")
    cursor = conn.cursor()
    
    if not os.path.exists(CSV_FILE):
        print(f"Erro: Arquivo CSV não encontrado em {CSV_FILE}")
        return

    with open(CSV_FILE, 'r') as f:
        reader = csv.reader(f)
        next(reader) # Pula o cabeçalho
        
        sql = "INSERT INTO produtos (produto, categoria, quantidade, preco_unitario) VALUES (%s, %s, %s, %s)"
        
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
    """Executa as operações CRUD de demonstração."""
    cursor = conn.cursor()

    # --- Create ---
    print("\n--- 3.1. Create: Adicionar 'Refrigerante Cola 2L' ---")
    new_product = ("Refrigerante Cola 2L", "Bebidas", 100, 7.50)
    sql_create = "INSERT INTO produtos (produto, categoria, quantidade, preco_unitario) VALUES (%s, %s, %s, %s)"
    try:
        cursor.execute(sql_create, new_product)
        conn.commit()
        print(f"Sucesso: Produto '{new_product[0]}' adicionado.")
    except mysql.connector.Error as err:
        print(f"Erro ao adicionar produto: {err}")
        conn.rollback()

    # --- Read (Todos os produtos) ---
    print("\n--- 3.2. Read: Mostrar todos os produtos cadastrados ---")
    sql_read_all = "SELECT id, produto, categoria, quantidade, preco_unitario FROM produtos"
    cursor.execute(sql_read_all)
    all_products = cursor.fetchall()
    print("| ID | Produto | Categoria | Quantidade | Preço Unitário |")
    print("|:---|:---|:---|:---|:---|")
    for (id, produto, categoria, quantidade, preco_unitario) in all_products:
        print(f"| {id} | {produto} | {categoria} | {quantidade} | R$ {preco_unitario:.2f} |")

    # --- Read (Nome e Quantidade) ---
    print("\n--- 3.3. Read: Listar apenas nome e quantidade ---")
    sql_read_name_qty = "SELECT produto, quantidade FROM produtos"
    cursor.execute(sql_read_name_qty)
    name_qty_products = cursor.fetchall()
    print("| Produto | Quantidade |")
    print("|:---|:---|")
    for (produto, quantidade) in name_qty_products:
        print(f"| {produto} | {quantidade} |")

    # --- Update ---
    print("\n--- 3.4. Update: Trocar categoria de 'Leite Integral 1L' para 'Mercearia' ---")
    sql_update = "UPDATE produtos SET categoria = %s WHERE produto = %s"
    try:
        cursor.execute(sql_update, ("Mercearia", "Leite Integral 1L"))
        conn.commit()
        print(f"Sucesso: Categoria de 'Leite Integral 1L' atualizada. Linhas afetadas: {cursor.rowcount}")
    except mysql.connector.Error as err:
        print(f"Erro ao atualizar produto: {err}")
        conn.rollback()

    # --- Delete ---
    print("\n--- 3.5. Delete: Excluir 'Pao Frances 500g' ---")
    sql_delete = "DELETE FROM produtos WHERE produto = %s"
    try:
        cursor.execute(sql_delete, ("Pao Frances 500g",))
        conn.commit()
        print(f"Sucesso: Produto 'Pao Frances 500g' excluído. Linhas afetadas: {cursor.rowcount}")
    except mysql.connector.Error as err:
        print(f"Erro ao excluir produto: {err}")
        conn.rollback()

    cursor.close()

def final_read(conn):
    """Mostra o estado final do estoque."""
    print("\n--- 4. Estado Final do Estoque ---")
    cursor = conn.cursor()
    sql_final = "SELECT id, produto, categoria, quantidade, preco_unitario FROM produtos"
    cursor.execute(sql_final)
    final_products = cursor.fetchall()
    
    output = "## Estado Final da Tabela 'produtos'\n\n"
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
    with open("/home/ubuntu/freshmart_final_result.md", "w") as f:
        f.write(result)
    print("\nProcesso concluído. Resultado final salvo em /home/ubuntu/freshmart_final_result.md")
