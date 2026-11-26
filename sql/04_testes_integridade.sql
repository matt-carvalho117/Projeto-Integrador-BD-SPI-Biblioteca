INSERT INTO autor (nome, nacionalidade, data_nascimento) 
VALUES ('J.R.R. Tolkien', 'Britânico', '1892-01-03');

INSERT INTO livro (titulo, genero, editora) 
VALUES ('O Senhor dos Anéis', 'Fantasia', 'HarperCollins');

INSERT INTO livro_autor (id_livro, id_autor) 
VALUES (1, 1);

INSERT INTO leitor (cpf, nome, email, status) 
VALUES ('123.456.789-09', 'João Silva', 'joao@email.com', 'Ativo'); 

INSERT INTO leitor (cpf, nome, email, status) 
VALUES ('98765432100', 'Maria Souza', 'maria@email.com', 'Bloqueado'); 

INSERT INTO exemplar (id_livro, codigo_barras, localizacao) 
VALUES (1, 'BARRAS001', 'Corredor A'),
       (1, 'BARRAS002', 'Corredor B');

-- Deve falhar: CPF inválido
INSERT INTO leitor (cpf, nome, email, status) 
VALUES ('111.111.111-11', 'Leitor Inválido', 'invalido@email.com', 'Ativo');

-- Deve falhar: CPF duplicado
INSERT INTO leitor (cpf, nome, email, status) 
VALUES ('12345678909', 'Clone do João', 'clone@email.com', 'Ativo');

-- Deve funcionar: CPF limpo pelo trigger
SELECT cpf FROM leitor WHERE nome = 'João Silva';

-- Deve falhar: Leitor bloqueado
INSERT INTO emprestimo (id_leitor, id_exemplar, data_prevista_devolucao) 
VALUES (2, 1, CURRENT_DATE + 7);

-- Deve funcionar: Empréstimo válido
INSERT INTO emprestimo (id_leitor, id_exemplar, data_prevista_devolucao) 
VALUES (1, 1, CURRENT_DATE + 7);

-- Deve funcionar: Status atualizado para Emprestado
SELECT id_exemplar, status FROM exemplar WHERE id_exemplar = 1;

-- Deve falhar: Exemplar indisponível
INSERT INTO emprestimo (id_leitor, id_exemplar, data_prevista_devolucao) 
VALUES (1, 1, CURRENT_DATE + 10);

-- Deve falhar: Data prevista anterior à retirada
INSERT INTO emprestimo (id_leitor, id_exemplar, data_prevista_devolucao) 
VALUES (1, 2, CURRENT_DATE - 1);

-- Deve falhar: Data devolução anterior à retirada
UPDATE emprestimo 
SET data_devolucao = '2020-01-01' 
WHERE id_emprestimo = 1;

-- Deve funcionar: Devolução válida
UPDATE emprestimo 
SET data_devolucao = CURRENT_DATE 
WHERE id_emprestimo = 1;

-- Deve funcionar: Status volta para Disponível
SELECT id_exemplar, status FROM exemplar WHERE id_exemplar = 1;

INSERT INTO emprestimo (id_leitor, id_exemplar, data_prevista_devolucao) 
VALUES (1, 2, CURRENT_DATE + 7);

-- Deve falhar: Leitor com empréstimo ativo
DELETE FROM leitor WHERE id_leitor = 1;

-- Deve falhar: Livro com exemplares atrelados
DELETE FROM livro WHERE id_livro = 1;

-- Deve funcionar: Cascata apaga livro_autor
DELETE FROM autor WHERE id_autor = 1;
SELECT * FROM livro_autor;