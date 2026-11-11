-- 1. Tabela Autor
CREATE TABLE autor (
    id_autor SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL
);

-- 2. Tabela Livro
CREATE TABLE livro (
    id_livro SERIAL PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    editora VARCHAR(100),
    ano_publicacao INT
);

-- 3. Tabela N:N Livro_Autor
CREATE TABLE livro_autor (
    id_livro INT NOT NULL REFERENCES livro(id_livro) ON DELETE CASCADE,
    id_autor INT NOT NULL REFERENCES autor(id_autor) ON DELETE CASCADE,
    PRIMARY KEY (id_livro, id_autor)
);

-- 4. Tabela Exemplar (Exemplares físicos vinculados ao Livro)
CREATE TABLE exemplar (
    id_exemplar SERIAL PRIMARY KEY,
    id_livro INT NOT NULL REFERENCES livro(id_livro) ON DELETE CASCADE,
    codigo_barras VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'Disponível' CHECK (status IN ('Disponível', 'Emprestado', 'Manutenção', 'Reservado'))
);

-- 5. Tabela Leitor
CREATE TABLE leitor (
    id_leitor SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    tipo VARCHAR(20) CHECK (tipo IN ('Aluno', 'Professor', 'Servidor')) NOT NULL,
    data_cadastro DATE DEFAULT CURRENT_DATE
);

-- 6. Tabela Empréstimo
CREATE TABLE emprestimo (
    id_emprestimo SERIAL PRIMARY KEY,
    id_exemplar INT NOT NULL REFERENCES exemplar(id_exemplar),
    id_leitor INT NOT NULL REFERENCES leitor(id_leitor),
    data_emprestimo TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_prevista_devolucao DATE NOT NULL,
    data_devolucao TIMESTAMP
a

-- Regra de Negócio: Um exemplar não pode ter dois empréstimos ativos ao mesmo tempo.
-- Criamos um índice único parcial no PostgreSQL onde data_devolucao é NULL (empréstimo aberto).
CREATE UNIQUE INDEX idx_exemplar_emprestimo_ativo 
ON emprestimo (id_exemplar) 
WHERE data_devolucao IS NULL;

-- 7. Tabela Reserva
CREATE TABLE reserva (
    id_reserva SERIAL PRIMARY KEY,
    id_livro INT NOT NULL REFERENCES livro(id_livro),
    id_leitor INT NOT NULL REFERENCES leitor(id_leitor),
    data_reserva TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'Pendente' CHECK (status IN ('Pendente', 'Concluída', 'Cancelada'))
);