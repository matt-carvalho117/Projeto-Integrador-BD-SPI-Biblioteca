-- Populacao demonstrativa da Biblioteca Carolina Maria de Jesus.
-- Execute depois de 01_criacao.sql. O roteiro e atomico: erro em qualquer
-- etapa cancela a populacao inteira.

BEGIN;

-- 1. AUTORES
INSERT INTO autor (nome, pseudonimo, nacionalidade, data_nascimento) VALUES
('John Ronald Reuel Tolkien', 'J.R.R. Tolkien', 'Britânica', '1892-01-03'),
('Joaquim Maria Machado de Assis', NULL, 'Brasileira', '1839-06-21'),
('Clarice Lispector', NULL, 'Brasileira', '1920-12-10'),
('Eric Arthur Blair', 'George Orwell', 'Britânica', '1903-06-25');

-- 2. LIVROS, incluindo uma obra com exemplar sem historico de movimentacao.
INSERT INTO livro (titulo, genero, editora, idioma) VALUES
('O Senhor dos Anéis', 'Fantasia', 'HarperCollins', 'Português'),
('O Hobbit', 'Fantasia', 'HarperCollins', 'Português'),
('Dom Casmurro', 'Romance', 'Principis', 'Português'),
('A Hora da Estrela', 'Romance', 'Rocco', 'Português'),
('1984', 'Ficção Científica', 'Companhia das Letras', 'Português'),
('Quincas Borba', 'Romance', 'Principis', 'Português');

-- 3. RELACIONAMENTO N:N ENTRE LIVROS E AUTORES.
INSERT INTO livro_autor (id_livro, id_autor) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 3),
(5, 4),
(6, 2);

-- 4. LEITORES; CPFs validos e distintos.
INSERT INTO leitor (cpf, nome, telefone, email, status) VALUES
('123.456.789-09', 'João Silva', '(62) 99111-1111', 'joao@email.com', 'Ativo'),
('987.654.321-00', 'Maria Souza', '(62) 99222-2222', 'maria@email.com', 'Bloqueado'),
('111.444.777-35', 'Carlos Pereira', '(62) 99333-3333', 'carlos@email.com', 'Ativo'),
('529.982.247-25', 'Ana Oliveira', '(62) 99444-4444', 'ana@email.com', 'Ativo'),
('390.533.447-05', 'Lucas Mendes', '(62) 99555-5555', 'lucas@email.com', 'Ativo');

-- 5. EXEMPLARES; BARRAS009 permanece disponivel e sem emprestimos ou reservas.
INSERT INTO exemplar (id_livro, codigo_barras, localizacao) VALUES
(1, 'BARRAS001', 'Corredor A - Prateleira 1'),
(1, 'BARRAS002', 'Corredor A - Prateleira 1'),
(2, 'BARRAS003', 'Corredor A - Prateleira 2'),
(3, 'BARRAS004', 'Corredor B - Prateleira 1'),
(3, 'BARRAS005', 'Corredor B - Prateleira 1'),
(4, 'BARRAS006', 'Corredor B - Prateleira 3'),
(5, 'BARRAS007', 'Corredor C - Prateleira 1'),
(5, 'BARRAS008', 'Corredor C - Prateleira 1'),
(6, 'BARRAS009', 'Corredor B - Prateleira 2');

-- 6. EMPRESTIMOS: devolvidos, em dia, em atraso e ativos.
INSERT INTO emprestimo (id_leitor, id_exemplar, data_retirada, data_prevista_devolucao, data_devolucao) VALUES
-- Historico inicial; prazos de sete dias.
(1, 1, CURRENT_TIMESTAMP - INTERVAL '20 days', CURRENT_DATE - 13, CURRENT_DATE - 14),
(4, 7, CURRENT_TIMESTAMP - INTERVAL '15 days', CURRENT_DATE - 8, CURRENT_DATE - 9),

-- Emprestimos ativos dentro do prazo.
(1, 3, CURRENT_TIMESTAMP, CURRENT_DATE + 7, NULL),
(4, 6, CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_DATE + 4, NULL),
(5, 2, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_DATE + 5, NULL),

-- Emprestimo ativo em atraso, para testar pendencias.
(3, 4, CURRENT_TIMESTAMP - INTERVAL '12 days', CURRENT_DATE - 5, NULL);

-- Historico adicional com devolucoes antecipadas, no prazo e em atraso.
-- Os exemplares usados estao disponiveis; emprestimos ja devolvidos nao os bloqueiam.
INSERT INTO emprestimo (id_leitor, id_exemplar, data_retirada, data_prevista_devolucao, data_devolucao) VALUES
(1, 1, CURRENT_TIMESTAMP - INTERVAL '100 days', CURRENT_DATE - 93, CURRENT_DATE - 94),
(4, 1, CURRENT_TIMESTAMP - INTERVAL '90 days', CURRENT_DATE - 83, CURRENT_DATE - 83),
(5, 1, CURRENT_TIMESTAMP - INTERVAL '80 days', CURRENT_DATE - 73, CURRENT_DATE - 71),
(1, 1, CURRENT_TIMESTAMP - INTERVAL '70 days', CURRENT_DATE - 63, CURRENT_DATE - 64),
(4, 1, CURRENT_TIMESTAMP - INTERVAL '60 days', CURRENT_DATE - 53, CURRENT_DATE - 50),
(5, 5, CURRENT_TIMESTAMP - INTERVAL '55 days', CURRENT_DATE - 48, CURRENT_DATE - 47),
(1, 5, CURRENT_TIMESTAMP - INTERVAL '50 days', CURRENT_DATE - 43, CURRENT_DATE - 44),
(4, 5, CURRENT_TIMESTAMP - INTERVAL '45 days', CURRENT_DATE - 38, CURRENT_DATE - 38),
(5, 5, CURRENT_TIMESTAMP - INTERVAL '40 days', CURRENT_DATE - 33, CURRENT_DATE - 30),
(1, 5, CURRENT_TIMESTAMP - INTERVAL '35 days', CURRENT_DATE - 28, CURRENT_DATE - 29),
(4, 7, CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_DATE - 23, CURRENT_DATE - 23),
(5, 7, CURRENT_TIMESTAMP - INTERVAL '28 days', CURRENT_DATE - 21, CURRENT_DATE - 20),
(1, 7, CURRENT_TIMESTAMP - INTERVAL '26 days', CURRENT_DATE - 19, CURRENT_DATE - 20),
(4, 7, CURRENT_TIMESTAMP - INTERVAL '24 days', CURRENT_DATE - 17, CURRENT_DATE - 14),
(5, 7, CURRENT_TIMESTAMP - INTERVAL '22 days', CURRENT_DATE - 15, CURRENT_DATE - 16),
(1, 8, CURRENT_TIMESTAMP - INTERVAL '20 days', CURRENT_DATE - 13, CURRENT_DATE - 13),
(4, 8, CURRENT_TIMESTAMP - INTERVAL '18 days', CURRENT_DATE - 11, CURRENT_DATE - 10),
(5, 8, CURRENT_TIMESTAMP - INTERVAL '16 days', CURRENT_DATE - 9, CURRENT_DATE - 10),
(1, 8, CURRENT_TIMESTAMP - INTERVAL '14 days', CURRENT_DATE - 7, CURRENT_DATE - 4),
(4, 8, CURRENT_TIMESTAMP - INTERVAL '12 days', CURRENT_DATE - 5, CURRENT_DATE - 6);

-- 7. RESERVAS pendentes, concluidas, canceladas e expiradas.
INSERT INTO reserva (id_leitor, id_livro, data_reserva, status) VALUES
(5, 2, CURRENT_TIMESTAMP, 'Pendente'),
(1, 4, CURRENT_TIMESTAMP - INTERVAL '1 day', 'Pendente'),
(4, 1, CURRENT_TIMESTAMP - INTERVAL '10 days', 'Concluída'),
(1, 2, CURRENT_TIMESTAMP - INTERVAL '5 days', 'Pendente'),
(2, 1, CURRENT_TIMESTAMP - INTERVAL '10 days', 'Cancelada'),
(3, 3, CURRENT_TIMESTAMP - INTERVAL '12 days', 'Expirada'),
(2, 5, CURRENT_TIMESTAMP - INTERVAL '14 days', 'Concluída'),
(5, 4, CURRENT_TIMESTAMP - INTERVAL '3 days', 'Pendente');

-- Confirma que as sete tabelas estao populadas e ha ao menos 60 registros.
DO $$
DECLARE
    v_total_registros BIGINT;
BEGIN
    SELECT SUM(quantidade)
    INTO v_total_registros
    FROM (
        SELECT COUNT(*) AS quantidade FROM autor
        UNION ALL SELECT COUNT(*) FROM livro
        UNION ALL SELECT COUNT(*) FROM livro_autor
        UNION ALL SELECT COUNT(*) FROM leitor
        UNION ALL SELECT COUNT(*) FROM exemplar
        UNION ALL SELECT COUNT(*) FROM emprestimo
        UNION ALL SELECT COUNT(*) FROM reserva
    ) AS contagens;

    IF v_total_registros < 60 THEN
        RAISE EXCEPTION 'Populacao insuficiente: % registros; sao necessarios ao menos 60.',
            v_total_registros;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM autor)
       OR NOT EXISTS (SELECT 1 FROM livro)
       OR NOT EXISTS (SELECT 1 FROM livro_autor)
       OR NOT EXISTS (SELECT 1 FROM leitor)
       OR NOT EXISTS (SELECT 1 FROM exemplar)
       OR NOT EXISTS (SELECT 1 FROM emprestimo)
       OR NOT EXISTS (SELECT 1 FROM reserva) THEN
        RAISE EXCEPTION 'Todas as tabelas do sistema devem possuir dados.';
    END IF;

    RAISE NOTICE 'Populacao validada: % registros nas sete tabelas.', v_total_registros;
END;
$$;

SELECT tabela, quantidade
FROM (
    SELECT 'autor' AS tabela, COUNT(*) AS quantidade FROM autor
    UNION ALL SELECT 'livro', COUNT(*) FROM livro
    UNION ALL SELECT 'livro_autor', COUNT(*) FROM livro_autor
    UNION ALL SELECT 'leitor', COUNT(*) FROM leitor
    UNION ALL SELECT 'exemplar', COUNT(*) FROM exemplar
    UNION ALL SELECT 'emprestimo', COUNT(*) FROM emprestimo
    UNION ALL SELECT 'reserva', COUNT(*) FROM reserva
    UNION ALL
    SELECT 'TOTAL', SUM(quantidade)
    FROM (
        SELECT COUNT(*) AS quantidade FROM autor
        UNION ALL SELECT COUNT(*) FROM livro
        UNION ALL SELECT COUNT(*) FROM livro_autor
        UNION ALL SELECT COUNT(*) FROM leitor
        UNION ALL SELECT COUNT(*) FROM exemplar
        UNION ALL SELECT COUNT(*) FROM emprestimo
        UNION ALL SELECT COUNT(*) FROM reserva
    ) AS contagens
) AS resumo
ORDER BY CASE WHEN tabela = 'TOTAL' THEN 1 ELSE 0 END, tabela;

COMMIT;
