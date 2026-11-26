-- Demonstracao de manipulacao e validacao do banco da biblioteca.
-- Todo o roteiro roda em uma transacao encerrada com ROLLBACK.

BEGIN;

CREATE TEMP TABLE contexto_teste (
    id_livro_crud INT,
    id_livro_regras INT,
    id_exemplar INT,
    id_exemplar_atraso INT,
    id_leitor_ativo INT,
    id_leitor_bloqueado INT,
    id_leitor_atraso INT,
    id_emprestimo INT
) ON COMMIT DROP;

CREATE TEMP TABLE contexto_exemplares_limite (
    ordem INT PRIMARY KEY,
    id_exemplar INT NOT NULL
) ON COMMIT DROP;

INSERT INTO contexto_teste DEFAULT VALUES;

-- ============================================================================
-- 1. INSERT, UPDATE e DELETE com consultas de confirmacao
-- ============================================================================

WITH livro_inserido AS (
    INSERT INTO livro (titulo, genero, editora, idioma)
    VALUES (
        'Livro de teste CRUD ' || txid_current(),
        'Teste',
        'Editora inicial',
        'Portugues'
    )
    RETURNING id_livro
)
UPDATE contexto_teste AS contexto
SET id_livro_crud = livro_inserido.id_livro
FROM livro_inserido;

-- Confirma a insercao.
SELECT id_livro, titulo, genero, editora
FROM livro
WHERE id_livro = (SELECT id_livro_crud FROM contexto_teste);

UPDATE livro
SET editora = 'Editora atualizada'
WHERE id_livro = (SELECT id_livro_crud FROM contexto_teste);

-- Confirma a atualizacao.
SELECT id_livro, titulo, editora
FROM livro
WHERE id_livro = (SELECT id_livro_crud FROM contexto_teste);

DELETE FROM livro
WHERE id_livro = (SELECT id_livro_crud FROM contexto_teste);

-- TRUE confirma que o livro foi excluido dentro da transacao.
SELECT NOT EXISTS (
    SELECT 1
    FROM livro
    WHERE id_livro = (SELECT id_livro_crud FROM contexto_teste)
) AS livro_excluido;

-- ============================================================================
-- 2. Preparacao de registros temporarios para testar as regras de negocio
-- ============================================================================

WITH livro_inserido AS (
    INSERT INTO livro (titulo, genero, editora, idioma)
    VALUES (
        'Livro de teste de integridade ' || txid_current(),
        'Teste',
        'Editora de teste',
        'Portugues'
    )
    RETURNING id_livro
)
UPDATE contexto_teste AS contexto
SET id_livro_regras = livro_inserido.id_livro
FROM livro_inserido;

WITH cpfs_disponiveis AS (
    SELECT serie.numero,
           LPAD(serie.numero::TEXT, 11, '0') AS cpf
    FROM generate_series(0, 9999) AS serie(numero)
    WHERE fn_validar_cpf(LPAD(serie.numero::TEXT, 11, '0'))
      AND NOT EXISTS (
          SELECT 1
          FROM leitor
          WHERE leitor.cpf = LPAD(serie.numero::TEXT, 11, '0')
      )
    ORDER BY serie.numero
    LIMIT 3
),
cpfs_numerados AS (
    SELECT numero,
           cpf,
           ROW_NUMBER() OVER (ORDER BY numero) AS ordem
    FROM cpfs_disponiveis
),
leitores_inseridos AS (
    INSERT INTO leitor (cpf, nome, email, status)
    SELECT SUBSTRING(cpf, 1, 3) || '.' ||
           SUBSTRING(cpf, 4, 3) || '.' ||
           SUBSTRING(cpf, 7, 3) || '-' ||
           SUBSTRING(cpf, 10, 2),
           'Leitor de teste ' || txid_current() || ' ' || ordem,
           'teste_integridade_' || txid_current() || '_' || ordem ||
               '@example.invalid',
           CASE WHEN ordem = 2 THEN 'Bloqueado' ELSE 'Ativo' END
    FROM cpfs_numerados
    RETURNING id_leitor, email
)
UPDATE contexto_teste AS contexto
SET id_leitor_ativo = (
        SELECT id_leitor
        FROM leitores_inseridos
        WHERE email = 'teste_integridade_' || txid_current() || '_1@example.invalid'
    ),
    id_leitor_bloqueado = (
        SELECT id_leitor
        FROM leitores_inseridos
        WHERE email = 'teste_integridade_' || txid_current() || '_2@example.invalid'
    ),
    id_leitor_atraso = (
        SELECT id_leitor
        FROM leitores_inseridos
        WHERE email = 'teste_integridade_' || txid_current() || '_3@example.invalid'
    );

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM contexto_teste
        WHERE id_livro_regras IS NULL
           OR id_leitor_ativo IS NULL
           OR id_leitor_bloqueado IS NULL
           OR id_leitor_atraso IS NULL
    ) THEN
        RAISE EXCEPTION 'Nao foi possivel criar todos os registros de teste.';
    END IF;
END;
$$;

INSERT INTO exemplar (id_livro, codigo_barras, localizacao)
SELECT contexto.id_livro_regras,
       'TESTE-' || txid_current() || '-' || serie.numero,
       'Localizacao de teste'
FROM contexto_teste AS contexto
CROSS JOIN generate_series(1, 5) AS serie(numero);

UPDATE contexto_teste
SET id_exemplar = (
        SELECT id_exemplar
        FROM exemplar
        WHERE codigo_barras = 'TESTE-' || txid_current() || '-1'
    ),
    id_exemplar_atraso = (
        SELECT id_exemplar
        FROM exemplar
        WHERE codigo_barras = 'TESTE-' || txid_current() || '-2'
    );

INSERT INTO contexto_exemplares_limite (ordem, id_exemplar)
SELECT serie.numero, exemplar.id_exemplar
FROM generate_series(1, 3) AS serie(numero)
JOIN exemplar
  ON exemplar.codigo_barras =
     'TESTE-' || txid_current() || '-' || (serie.numero + 2);

-- Confirma a criacao dos leitores e do exemplar de teste.
SELECT leitor.id_leitor, leitor.nome, leitor.cpf, leitor.status
FROM leitor
JOIN contexto_teste
  ON leitor.id_leitor IN (
      contexto_teste.id_leitor_ativo,
      contexto_teste.id_leitor_bloqueado
  )
ORDER BY leitor.status;

SELECT exemplar.id_exemplar, livro.titulo, exemplar.codigo_barras, exemplar.status
FROM exemplar
JOIN livro ON livro.id_livro = exemplar.id_livro
WHERE exemplar.id_exemplar = (SELECT id_exemplar FROM contexto_teste);

-- ============================================================================
-- 3. Validacao de chave estrangeira, CPF e restricoes CHECK/UNIQUE
-- ============================================================================

DO $$
BEGIN
    BEGIN
        INSERT INTO exemplar (id_livro, codigo_barras, localizacao)
        VALUES (-1, 'FK-TESTE-' || txid_current(), 'Teste');

        RAISE EXCEPTION 'Falha no teste: a chave estrangeira deveria impedir o INSERT.';
    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE NOTICE 'OK: chave estrangeira impede exemplar sem livro.';
    END;
END;
$$;

DO $$
DECLARE
    v_id_livro INT;
BEGIN
    SELECT id_livro_regras
    INTO v_id_livro
    FROM contexto_teste;

    BEGIN
        INSERT INTO exemplar (id_livro, codigo_barras, localizacao, status)
        VALUES (
            v_id_livro,
            'STATUS-TESTE-' || txid_current(),
            'Teste',
            'Indisponivel'
        );

        RAISE EXCEPTION 'Falha no teste: o status do exemplar deveria ser rejeitado.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'OK: CHECK rejeita status de exemplar nao permitido.';
    END;
END;
$$;

DO $$
BEGIN
    BEGIN
        INSERT INTO leitor (cpf, nome, email, status)
        VALUES (
            '111.111.111-11',
            'Leitor de CPF invalido',
            'cpf_invalido_' || txid_current() || '@example.invalid',
            'Ativo'
        );

        RAISE EXCEPTION 'Falha no teste: o CPF invalido deveria ser rejeitado.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'OK: CHECK rejeita CPF com digitos verificadores invalidos.';
    END;
END;
$$;

DO $$
DECLARE
    v_cpf VARCHAR(14);
BEGIN
    SELECT leitor.cpf
    INTO v_cpf
    FROM leitor
    JOIN contexto_teste
      ON leitor.id_leitor = contexto_teste.id_leitor_ativo;

    BEGIN
        INSERT INTO leitor (cpf, nome, email, status)
        VALUES (
            v_cpf,
            'Leitor com CPF duplicado',
            'cpf_duplicado_' || txid_current() || '@example.invalid',
            'Ativo'
        );

        RAISE EXCEPTION 'Falha no teste: o CPF duplicado deveria ser rejeitado.';
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'OK: UNIQUE impede CPF duplicado.';
    END;
END;
$$;

DO $$
DECLARE
    v_id_leitor INT;
    v_id_exemplar INT;
BEGIN
    SELECT contexto.id_leitor_ativo, limite.id_exemplar
    INTO v_id_leitor, v_id_exemplar
    FROM contexto_teste AS contexto
    CROSS JOIN contexto_exemplares_limite AS limite
    WHERE limite.ordem = 3;

    BEGIN
        INSERT INTO emprestimo (id_leitor, id_exemplar, data_prevista_devolucao)
        VALUES (v_id_leitor, v_id_exemplar, CURRENT_DATE + 8);

        RAISE EXCEPTION 'Falha no teste: o prazo superior a sete dias deveria ser rejeitado.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'OK: CHECK limita o prazo do emprestimo a sete dias.';
    END;
END;
$$;

DO $$
DECLARE
    v_id_leitor INT;
    v_id_livro INT;
BEGIN
    SELECT id_leitor_ativo, id_livro_regras
    INTO v_id_leitor, v_id_livro
    FROM contexto_teste;

    BEGIN
        INSERT INTO reserva (id_leitor, id_livro, status)
        VALUES (v_id_leitor, v_id_livro, 'Status invalido');

        RAISE EXCEPTION 'Falha no teste: o status da reserva deveria ser rejeitado.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'OK: CHECK rejeita status de reserva nao permitido.';
    END;
END;
$$;

DO $$
DECLARE
    v_id_leitor INT;
    v_id_livro INT;
    v_mensagem TEXT;
BEGIN
    SELECT id_leitor_ativo, id_livro_regras
    INTO v_id_leitor, v_id_livro
    FROM contexto_teste;

    BEGIN
        INSERT INTO reserva (id_leitor, id_livro, status)
        VALUES (v_id_leitor, v_id_livro, 'Pendente');

        RAISE EXCEPTION 'Falha no teste: reserva pendente com exemplar disponivel deveria ser rejeitada.';
    EXCEPTION
        WHEN raise_exception THEN
            GET STACKED DIAGNOSTICS v_mensagem = MESSAGE_TEXT;
            IF v_mensagem NOT LIKE 'Reserva pendente negada: há exemplares disponíveis%' THEN
                RAISE;
            END IF;
            RAISE NOTICE 'OK: trigger so permite reserva pendente sem exemplares disponiveis.';
    END;
END;
$$;

-- ============================================================================
-- 4. Validacao das regras de emprestimo e dos triggers
-- ============================================================================

DO $$
DECLARE
    v_id_leitor INT;
    v_id_exemplar INT;
    v_mensagem TEXT;
BEGIN
    SELECT id_leitor_bloqueado, id_exemplar
    INTO v_id_leitor, v_id_exemplar
    FROM contexto_teste;

    BEGIN
        INSERT INTO emprestimo (id_leitor, id_exemplar, data_prevista_devolucao)
        VALUES (v_id_leitor, v_id_exemplar, CURRENT_DATE + 7);

        RAISE EXCEPTION 'Falha no teste: leitor bloqueado nao deveria poder emprestar.';
    EXCEPTION
        WHEN raise_exception THEN
            GET STACKED DIAGNOSTICS v_mensagem = MESSAGE_TEXT;
            IF v_mensagem NOT LIKE 'Empréstimo negado: o leitor possui status%' THEN
                RAISE;
            END IF;
            RAISE NOTICE 'OK: trigger impede emprestimo por leitor bloqueado.';
    END;
END;
$$;

WITH emprestimo_inserido AS (
    INSERT INTO emprestimo (id_leitor, id_exemplar, data_prevista_devolucao)
    SELECT id_leitor_ativo, id_exemplar, CURRENT_DATE + 7
    FROM contexto_teste
    RETURNING id_emprestimo
)
UPDATE contexto_teste AS contexto
SET id_emprestimo = emprestimo_inserido.id_emprestimo
FROM emprestimo_inserido;

-- Confirma o emprestimo e a mudanca automatica do status do exemplar.
SELECT emprestimo.id_emprestimo,
       leitor.nome AS nome_leitor,
       livro.titulo,
       exemplar.status AS status_exemplar,
       emprestimo.data_prevista_devolucao,
       emprestimo.data_devolucao
FROM emprestimo
JOIN leitor ON leitor.id_leitor = emprestimo.id_leitor
JOIN exemplar ON exemplar.id_exemplar = emprestimo.id_exemplar
JOIN livro ON livro.id_livro = exemplar.id_livro
WHERE emprestimo.id_emprestimo = (SELECT id_emprestimo FROM contexto_teste);

DO $$
DECLARE
    v_id_leitor INT;
    v_id_exemplar INT;
    v_mensagem TEXT;
BEGIN
    SELECT id_leitor_ativo, id_exemplar
    INTO v_id_leitor, v_id_exemplar
    FROM contexto_teste;

    BEGIN
        INSERT INTO emprestimo (id_leitor, id_exemplar, data_prevista_devolucao)
        VALUES (v_id_leitor, v_id_exemplar, CURRENT_DATE + 7);

        RAISE EXCEPTION 'Falha no teste: exemplar emprestado nao deveria ser emprestado novamente.';
    EXCEPTION
        WHEN raise_exception THEN
            GET STACKED DIAGNOSTICS v_mensagem = MESSAGE_TEXT;
            IF v_mensagem NOT LIKE 'Empréstimo negado: o exemplar não está disponível%' THEN
                RAISE;
            END IF;
            RAISE NOTICE 'OK: trigger impede novo emprestimo do exemplar indisponivel.';
    END;
END;
$$;

DO $$
DECLARE
    v_id_leitor INT;
    v_id_exemplar INT;
BEGIN
    SELECT id_leitor_ativo, id_exemplar
    INTO v_id_leitor, v_id_exemplar
    FROM contexto_teste;

    BEGIN
        UPDATE exemplar
        SET status = 'Disponível'
        WHERE id_exemplar = v_id_exemplar;

        INSERT INTO emprestimo (id_leitor, id_exemplar, data_prevista_devolucao)
        VALUES (v_id_leitor, v_id_exemplar, CURRENT_DATE + 7);

        RAISE EXCEPTION 'Falha no teste: o indice deveria impedir dois emprestimos ativos.';
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'OK: indice unico permite no maximo um emprestimo ativo por exemplar.';
    END;
END;
$$;

INSERT INTO emprestimo (
    id_leitor,
    id_exemplar,
    data_retirada,
    data_prevista_devolucao
)
SELECT id_leitor_atraso,
       id_exemplar_atraso,
       CURRENT_TIMESTAMP - INTERVAL '8 days',
       CURRENT_DATE - 1
FROM contexto_teste;

-- Confirma o registro ativo em atraso usado no teste de elegibilidade.
SELECT id_emprestimo, id_leitor, data_prevista_devolucao, data_devolucao
FROM emprestimo
WHERE id_leitor = (SELECT id_leitor_atraso FROM contexto_teste)
  AND data_devolucao IS NULL;

DO $$
DECLARE
    v_id_leitor INT;
    v_id_exemplar INT;
    v_mensagem TEXT;
BEGIN
    SELECT contexto.id_leitor_atraso, limite.id_exemplar
    INTO v_id_leitor, v_id_exemplar
    FROM contexto_teste AS contexto
    CROSS JOIN contexto_exemplares_limite AS limite
    WHERE limite.ordem = 3;

    BEGIN
        INSERT INTO emprestimo (id_leitor, id_exemplar, data_prevista_devolucao)
        VALUES (v_id_leitor, v_id_exemplar, CURRENT_DATE + 7);

        RAISE EXCEPTION 'Falha no teste: leitor em atraso nao deveria poder emprestar.';
    EXCEPTION
        WHEN raise_exception THEN
            GET STACKED DIAGNOSTICS v_mensagem = MESSAGE_TEXT;
            IF v_mensagem NOT LIKE 'Empréstimo negado: o leitor possui empréstimo em atraso%' THEN
                RAISE;
            END IF;
            RAISE NOTICE 'OK: trigger bloqueia novo emprestimo enquanto houver atraso.';
    END;
END;
$$;

INSERT INTO emprestimo (id_leitor, id_exemplar, data_prevista_devolucao)
SELECT contexto.id_leitor_ativo,
       limite.id_exemplar,
       CURRENT_DATE + 7
FROM contexto_teste AS contexto
JOIN contexto_exemplares_limite AS limite ON limite.ordem <= 2
ORDER BY limite.ordem;

DO $$
DECLARE
    v_id_leitor INT;
    v_id_exemplar INT;
    v_mensagem TEXT;
BEGIN
    SELECT contexto.id_leitor_ativo, limite.id_exemplar
    INTO v_id_leitor, v_id_exemplar
    FROM contexto_teste AS contexto
    CROSS JOIN contexto_exemplares_limite AS limite
    WHERE limite.ordem = 3;

    BEGIN
        INSERT INTO emprestimo (id_leitor, id_exemplar, data_prevista_devolucao)
        VALUES (v_id_leitor, v_id_exemplar, CURRENT_DATE + 7);

        RAISE EXCEPTION 'Falha no teste: o quarto emprestimo ativo deveria ser rejeitado.';
    EXCEPTION
        WHEN raise_exception THEN
            GET STACKED DIAGNOSTICS v_mensagem = MESSAGE_TEXT;
            IF v_mensagem NOT LIKE 'Empréstimo negado: limite de 3 empréstimos ativos%' THEN
                RAISE;
            END IF;
            RAISE NOTICE 'OK: trigger limita o leitor a tres emprestimos ativos.';
    END;
END;
$$;

DO $$
DECLARE
    v_id_emprestimo INT;
BEGIN
    SELECT id_emprestimo
    INTO v_id_emprestimo
    FROM contexto_teste;

    BEGIN
        UPDATE emprestimo
        SET data_devolucao = data_retirada::DATE - 1
        WHERE id_emprestimo = v_id_emprestimo;

        RAISE EXCEPTION 'Falha no teste: data de devolucao anterior a retirada deveria ser rejeitada.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'OK: CHECK rejeita data de devolucao anterior a retirada.';
    END;
END;
$$;

UPDATE emprestimo
SET data_devolucao = CURRENT_DATE
WHERE id_emprestimo = (SELECT id_emprestimo FROM contexto_teste);

-- Confirma a devolucao e a liberacao automatica do exemplar.
SELECT emprestimo.id_emprestimo,
       emprestimo.data_devolucao,
       exemplar.codigo_barras,
       exemplar.status AS status_exemplar
FROM emprestimo
JOIN exemplar ON exemplar.id_exemplar = emprestimo.id_exemplar
WHERE emprestimo.id_emprestimo = (SELECT id_emprestimo FROM contexto_teste);

DO $$
DECLARE
    v_id_livro INT;
BEGIN
    SELECT id_livro_regras
    INTO v_id_livro
    FROM contexto_teste;

    BEGIN
        DELETE FROM livro
        WHERE id_livro = v_id_livro;

        RAISE EXCEPTION 'Falha no teste: livro com exemplar deveria ser protegido.';
    EXCEPTION
        WHEN restrict_violation THEN
            RAISE NOTICE 'OK: chave estrangeira impede excluir livro com exemplar associado.';
    END;
END;
$$;

-- Confirma que o livro protegido continua cadastrado.
SELECT EXISTS (
    SELECT 1
    FROM livro
    WHERE id_livro = (SELECT id_livro_regras FROM contexto_teste)
) AS livro_com_exemplar_preservado;

-- Desfaz todos os dados de demonstracao e testes.
ROLLBACK;
