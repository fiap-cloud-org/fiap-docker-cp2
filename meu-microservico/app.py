import os

import pymysql
from flask import Flask, jsonify, render_template, request
from werkzeug.security import generate_password_hash

app = Flask(__name__)
app.json.ensure_ascii = False  # acentos legíveis nas respostas JSON

# Conexão com o MySQL só por variáveis de ambiente (sem senha no código)
DB_CONFIG = {
    'host': os.environ.get('MYSQL_HOST', 'mysql'),
    'port': int(os.environ.get('MYSQL_PORT', '3306')),
    'user': os.environ.get('MYSQL_USER'),
    'password': os.environ.get('MYSQL_PASSWORD'),
    'database': os.environ.get('MYSQL_DATABASE', 'mysql_db'),
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor,
    'connect_timeout': 5,
}

# A coluna senha nunca sai da API
CAMPOS_USUARIO = 'id, nome, email'


def conectar():
    return pymysql.connect(**DB_CONFIG)


@app.route('/', methods=['GET'])
def pagina_usuarios():
    """Página HTML com a lista de usuários e um formulário de cadastro"""
    usuarios, erro = [], None
    try:
        conn = conectar()
        with conn, conn.cursor() as cur:
            cur.execute(f"SELECT {CAMPOS_USUARIO} FROM usuarios ORDER BY id")
            usuarios = cur.fetchall()
    except pymysql.MySQLError as e:
        app.logger.error("Erro ao carregar a página: %s", e)
        erro = "Não foi possível conectar ao MySQL."
    return render_template('index.html', usuarios=usuarios, erro=erro,
                           banco=DB_CONFIG['database'], host=DB_CONFIG['host'])


@app.route('/status', methods=['GET'])
def status():
    try:
        conn = conectar()
        conn.close()
        banco = 'conectado'
    except pymysql.MySQLError:
        banco = 'desconectado'
    return jsonify({
        "status": "online",
        "message": "O microsserviço está OK",
        "banco": banco,
    })


@app.route('/usuarios', methods=['GET'])
def listar_usuarios():
    try:
        conn = conectar()
        with conn, conn.cursor() as cur:
            cur.execute(f"SELECT {CAMPOS_USUARIO} FROM usuarios ORDER BY id")
            return jsonify(cur.fetchall())
    except pymysql.MySQLError as e:
        app.logger.error("Erro ao listar usuários: %s", e)
        return jsonify({"error": "Banco de dados indisponível"}), 503


@app.route('/usuarios/<int:usuario_id>', methods=['GET'])
def buscar_usuario(usuario_id):
    try:
        conn = conectar()
        with conn, conn.cursor() as cur:
            cur.execute(f"SELECT {CAMPOS_USUARIO} FROM usuarios WHERE id = %s", (usuario_id,))
            usuario = cur.fetchone()
    except pymysql.MySQLError as e:
        app.logger.error("Erro ao buscar usuário: %s", e)
        return jsonify({"error": "Banco de dados indisponível"}), 503
    if not usuario:
        return jsonify({"error": "Usuário não encontrado"}), 404
    return jsonify(usuario)


@app.route('/usuarios', methods=['POST'])
def criar_usuario():
    dados = request.get_json(silent=True) or request.form
    nome = (dados.get('nome') or '').strip()
    email = (dados.get('email') or '').strip().lower()
    senha = dados.get('senha') or ''
    if not nome or '@' not in email or len(senha) < 8:
        return jsonify({"error": "Informe nome, e-mail válido e senha com 8 caracteres ou mais"}), 400
    try:
        conn = conectar()
        with conn, conn.cursor() as cur:
            cur.execute(
                "INSERT INTO usuarios (nome, email, senha) VALUES (%s, %s, %s)",
                (nome, email, generate_password_hash(senha)),
            )
            conn.commit()
            novo_id = cur.lastrowid
    except pymysql.IntegrityError:
        return jsonify({"error": "E-mail já cadastrado"}), 409
    except pymysql.MySQLError as e:
        app.logger.error("Erro ao criar usuário: %s", e)
        return jsonify({"error": "Banco de dados indisponível"}), 503
    return jsonify({"id": novo_id, "nome": nome, "email": email}), 201


if __name__ == '__main__':
    # Só para rodar sem Docker; o debug fica desligado a menos que FLASK_DEBUG=1
    app.run(host='0.0.0.0', port=5000, debug=os.environ.get('FLASK_DEBUG') == '1')
