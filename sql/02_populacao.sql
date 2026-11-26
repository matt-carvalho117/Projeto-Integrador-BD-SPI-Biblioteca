-- =====================================================================
-- 1. AUTORES
-- =====================================================================
INSERT INTO autor (nome, pseudonimo, nacionalidade, data_nascimento) VALUES
('John Ronald Reuel Tolkien', 'J.R.R. Tolkien', 'Britânica', '1892-01-03'),
('Joaquim Maria Machado de Assis', NULL, 'Brasileira', '1839-06-21'),
('Clarice Lispector', NULL, 'Brasileira', '1920-12-10'),
('Eric Arthur Blair', 'George Orwell', 'Britânica', '1903-06-25');

-- =====================================================================
-- 2. LIVROS
-- =====================================================================
INSERT INTO livro (titulo, genero, editora, idioma) VALUES
('O Senhor dos Anéis', 'Fantasia', 'HarperCollins', 'Português'),
('O Hobbit', 'Fantasia', 'HarperCollins', 'Português'),
('Dom Casmurro', 'Romance', 'Principis', 'Português'),
('A Hora da Estrela', 'Romance', 'Rocco', 'Português'),
('1984', 'Ficção Científica', 'Companhia das Letras', 'Português');

-- =====================================================================
-- 3. LIVRO_AUTOR (Relacionamento N:N)
-- =====================================================================
INSERT INTO livro_autor (id_livro, id_autor) VALUES
(1, 1), -- O Senhor dos Anéis -> Tolkien
(2, 1), -- O Hobbit -> Tolkien (permite testar "livros de determinado autor")
(3, 2), -- Dom Casmurro -> Machado de Assis
(4, 3), -- A Hora da Estrela -> Clarice Lispector
(5, 4); -- 1984 -> George Orwell

-- =====================================================================
-- 4. LEITORES (CPFs válidos; o trigger limpa a pontuação automaticamente)
-- =====================================================================
INSERT INTO leitor (cpf, nome, telefone, email, status) VALUES
('123.456.789-09', 'João Silva', '(62) 99111-1111', 'joao@email.com', 'Ativo'),
('987.654.321-00', 'Maria Souza', '(62) 99222-2222', 'maria@email.com', 'Bloqueado'),
('111.444.777-35', 'Carlos Pereira', '(62) 99333-3333', 'carlos@email.com', 'Ativo'),
('529.982.247-25', 'Ana Oliveira', '(62) 99444-4444', 'ana@email.com', 'Ativo'),
('390.533.447-05', 'Lucas Mendes', '(62) 99555-5555', 'lucas@email.com', 'Ativo');

-- =====================================================================
-- 5. EXEMPLARES (estado_conservacao e status assumem o DEFAULT da tabela)
-- =====================================================================
INSERT INTO exemplar (id_livro, codigo_barras, localizacao) VALUES
(1, 'BARRAS001', 'Corredor A - Prateleira 1'),
(1, 'BARRAS002', 'Corredor A - Prateleira 1'),
(2, 'BARRAS003', 'Corredor A - Prateleira 2'),
(3, 'BARRAS004', 'Corredor B - Prateleira 1'),
(3, 'BARRAS005', 'Corredor B - Prateleira 1'),
(4, 'BARRAS006', 'Corredor B - Prateleira 3'),
(5, 'BARRAS007', 'Corredor C - Prateleira 1'),
(5, 'BARRAS008', 'Corredor C - Prateleira 1');

-- =====================================================================
-- 6. EMPRÉSTIMOS (Prazo de 7 dias; sem empréstimos para leitor bloqueado)
-- =====================================================================
INSERT INTO emprestimo (id_leitor, id_exemplar, data_retirada, data_prevista_devolucao, data_devolucao) VALUES
-- Empréstimos já devolvidos (histórico e consulta por intervalo de datas)
(1, 1, CURRENT_TIMESTAMP - INTERVAL '20 days', CURRENT_DATE - 13, CURRENT_DATE - 14),
(4, 7, CURRENT_TIMESTAMP - INTERVAL '15 days', CURRENT_DATE - 8, CURRENT_DATE - 9),

-- Empréstimos ativos dentro do prazo (7 dias)
(1, 3, CURRENT_TIMESTAMP, CURRENT_DATE + 7, NULL),                      -- O Hobbit (único exemplar emprestado)
(4, 6, CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_DATE + 4, NULL),  -- A Hora da Estrela (único exemplar emprestado)
(5, 2, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_DATE + 5, NULL),  -- O Senhor dos Anéis

-- Empréstimo em atraso (permite testar consulta de atrasos)
(3, 4, CURRENT_TIMESTAMP - INTERVAL '12 days', CURRENT_DATE - 5, NULL); -- Dom Casmurro (5 dias de atraso)

-- =====================================================================
-- 7. RESERVAS (Obras indisponíveis no momento + histórico de atendida)
-- =====================================================================
INSERT INTO reserva (id_leitor, id_livro, data_reserva, status) VALUES
(5, 2, CURRENT_TIMESTAMP, 'Pendente'),                      -- Lucas reserva "O Hobbit" (sem exemplar disponível)
(1, 4, CURRENT_TIMESTAMP - INTERVAL '1 day', 'Pendente'),   -- João reserva "A Hora da Estrela" (sem exemplar disponível)
(4, 1, CURRENT_TIMESTAMP - INTERVAL '10 days', 'Atendida'); -- Reserva anterior já atendida
