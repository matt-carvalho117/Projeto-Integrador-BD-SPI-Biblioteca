-- Consultas de exemplo para o banco de dados da biblioteca (PostgreSQL).

-- ============================================================================
-- 1. SELECT, WHERE, operadores lógicos, filtros e ordenação
-- ============================================================================

-- 1.1 Livros em português dos gêneros fantasia ou romance.
SELECT id_livro, titulo, genero, editora
FROM livro
WHERE idioma = 'Português'
  AND (genero = 'Fantasia' OR genero = 'Romance')
ORDER BY titulo
LIMIT 10;

-- 1.2 Leitores ativos que possuem telefone cadastrado.
SELECT id_leitor, nome, email, telefone
FROM leitor
WHERE status = 'Ativo'
  AND telefone IS NOT NULL
ORDER BY nome;

-- 1.3 Empréstimos em atraso, ainda ativos ou devolvidos após o prazo.
SELECT id_emprestimo, id_leitor, data_prevista_devolucao, data_devolucao
FROM emprestimo
WHERE (data_devolucao IS NULL AND data_prevista_devolucao < CURRENT_DATE)
   OR (data_devolucao IS NOT NULL AND data_devolucao > data_prevista_devolucao)
ORDER BY data_prevista_devolucao
LIMIT 10;

-- ============================================================================
-- 2. Consultas com JOIN (incluindo três ou mais tabelas e LEFT JOIN)
-- ============================================================================

-- 2.1 Exemplares disponíveis, com os dados do livro correspondente.
SELECT l.titulo, l.genero, ex.codigo_barras, ex.localizacao
FROM exemplar ex
JOIN livro l ON l.id_livro = ex.id_livro
WHERE ex.status = 'Disponível'
ORDER BY l.titulo, ex.codigo_barras;

-- 2.2 Empréstimos ativos: leitor, exemplar e livro (quatro tabelas).
SELECT emp.id_emprestimo,
       lei.nome AS nome_leitor,
       l.titulo,
       ex.codigo_barras,
       emp.data_retirada,
       emp.data_prevista_devolucao
FROM emprestimo emp
JOIN leitor lei ON lei.id_leitor = emp.id_leitor
JOIN exemplar ex ON ex.id_exemplar = emp.id_exemplar
JOIN livro l ON l.id_livro = ex.id_livro
WHERE emp.data_devolucao IS NULL
ORDER BY emp.data_prevista_devolucao, lei.nome;

-- 2.3 Todos os leitores e seus empréstimos ativos, inclusive quem não possui
-- nenhum empréstimo ativo.
SELECT lei.id_leitor,
       lei.nome AS nome_leitor,
       emp.id_emprestimo,
       emp.data_prevista_devolucao
FROM leitor lei
LEFT JOIN emprestimo emp
       ON emp.id_leitor = lei.id_leitor
      AND emp.data_devolucao IS NULL
ORDER BY lei.nome, emp.data_prevista_devolucao;

-- ============================================================================
-- 3. Funções de agregação, GROUP BY e HAVING
-- ============================================================================

-- 3.1 Quantidade de livros por gênero, exibindo gêneros com pelo menos
-- dois títulos.
SELECT genero, COUNT(*) AS quantidade_livros
FROM livro
GROUP BY genero
HAVING COUNT(*) >= 2
ORDER BY quantidade_livros DESC, genero;

-- 3.2 Leitores com dois ou mais empréstimos registrados.
SELECT lei.id_leitor, lei.nome, COUNT(emp.id_emprestimo) AS total_emprestimos
FROM leitor lei
JOIN emprestimo emp ON emp.id_leitor = lei.id_leitor
GROUP BY lei.id_leitor, lei.nome
HAVING COUNT(emp.id_emprestimo) >= 2
ORDER BY total_emprestimos DESC, lei.nome;

-- ============================================================================
-- 4. Consultas utilizando subconsultas
-- ============================================================================

-- 4.1 Livros com mais exemplares do que a média por livro.
-- A subconsulta no SELECT é escalar e correlacionada ao livro.
SELECT l.id_livro,
       l.titulo,
       (SELECT COUNT(*)
        FROM exemplar ex
        WHERE ex.id_livro = l.id_livro) AS total_exemplares
FROM livro l
WHERE (SELECT COUNT(*)
       FROM exemplar ex
       WHERE ex.id_livro = l.id_livro) >
      (SELECT AVG(contagem.total_exemplares)
       FROM (
           SELECT l2.id_livro, COUNT(ex2.id_exemplar) AS total_exemplares
           FROM livro l2
           LEFT JOIN exemplar ex2 ON ex2.id_livro = l2.id_livro
           GROUP BY l2.id_livro
       ) AS contagem)
ORDER BY total_exemplares DESC, l.titulo;

-- 4.2 Livros com reserva pendente e sem nenhum exemplar disponível.
SELECT l.id_livro, l.titulo
FROM livro l
WHERE EXISTS (
    SELECT 1
    FROM reserva r
    WHERE r.id_livro = l.id_livro
      AND r.status = 'Pendente'
)
AND NOT EXISTS (
    SELECT 1
    FROM exemplar ex
    WHERE ex.id_livro = l.id_livro
      AND ex.status = 'Disponível'
)
ORDER BY l.titulo;

-- ============================================================================
-- 5. Consultas adicionais para perguntas importantes do negócio
-- ============================================================================

-- 5.1 Quais empréstimos ativos estão atrasados e há quantos dias?
SELECT emp.id_emprestimo,
       lei.nome AS nome_leitor,
       l.titulo,
       emp.data_prevista_devolucao,
       CURRENT_DATE - emp.data_prevista_devolucao AS dias_em_atraso
FROM emprestimo emp
JOIN leitor lei ON lei.id_leitor = emp.id_leitor
JOIN exemplar ex ON ex.id_exemplar = emp.id_exemplar
JOIN livro l ON l.id_livro = ex.id_livro
WHERE emp.data_devolucao IS NULL
  AND emp.data_prevista_devolucao < CURRENT_DATE
ORDER BY dias_em_atraso DESC, lei.nome
LIMIT 10;

-- 5.2 Quais livros têm mais reservas pendentes do que exemplares disponíveis?
-- A consulta ajuda a identificar títulos cuja demanda supera a disponibilidade.
SELECT l.id_livro,
       l.titulo,
       (SELECT COUNT(*)
        FROM reserva r
        WHERE r.id_livro = l.id_livro
          AND r.status = 'Pendente') AS reservas_pendentes,
       (SELECT COUNT(*)
        FROM exemplar ex
        WHERE ex.id_livro = l.id_livro
          AND ex.status = 'Disponível') AS exemplares_disponiveis
FROM livro l
WHERE (SELECT COUNT(*)
       FROM reserva r
       WHERE r.id_livro = l.id_livro
         AND r.status = 'Pendente') >
      (SELECT COUNT(*)
       FROM exemplar ex
       WHERE ex.id_livro = l.id_livro
         AND ex.status = 'Disponível')
ORDER BY reservas_pendentes DESC, l.titulo
LIMIT 10;
