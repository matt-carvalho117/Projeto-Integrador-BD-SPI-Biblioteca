-- ============================================================================
-- 1. LIMPEZA SEGURA DO AMBIENTE (Ordem inversa de dependência: Filhas -> Pais)
-- ============================================================================

DROP VIEW IF EXISTS vw_status_emprestimos;
DROP VIEW IF EXISTS vw_disponibilidade_acervo;

DROP TABLE IF EXISTS reserva;
DROP TABLE IF EXISTS emprestimo;
DROP TABLE IF EXISTS livro_autor;
DROP TABLE IF EXISTS exemplar;

DROP TABLE IF EXISTS leitor;
DROP TABLE IF EXISTS livro;
DROP TABLE IF EXISTS autor;

DROP FUNCTION IF EXISTS fn_validar_e_bloquear_exemplar();
DROP FUNCTION IF EXISTS fn_liberar_exemplar_devolucao();
DROP FUNCTION IF EXISTS fn_limpar_cpf_leitor();
DROP FUNCTION IF EXISTS fn_validar_cpf(VARCHAR);


-- ============================================================================
-- 2. FUNÇÃO DE VALIDAÇÃO MATEMÁTICA DE CPF (IMMUTABLE para uso em CHECK)
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_validar_cpf(p_cpf VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    v_soma INT;
    v_resto INT;
    v_digito1 INT;
    v_digito2 INT;
    i INT;
BEGIN
    -- 1. Verifica se possui exatamente 11 dígitos numéricos
    IF p_cpf IS NULL OR p_cpf !~ '^\d{11}$' THEN
        RETURN FALSE;
    END IF;

    -- 2. Rejeita CPFs com todos os dígitos iguais (ex: 11111111111)
    IF p_cpf ~ '^(\d)\1{10}$' THEN
        RETURN FALSE;
    END IF;

    -- 3. Cálculo do 1º dígito verificador
    v_soma := 0;
    FOR i IN 1..9 LOOP
        v_soma := v_soma + (SUBSTRING(p_cpf, i, 1)::INT * (11 - i));
    END LOOP;

    v_resto := 11 - (v_soma % 11);
    IF v_resto >= 10 THEN
        v_digito1 := 0;
    ELSE
        v_digito1 := v_resto;
    END IF;

    IF v_digito1 <> SUBSTRING(p_cpf, 10, 1)::INT THEN
        RETURN FALSE;
    END IF;

    -- 4. Cálculo do 2º dígito verificador
    v_soma := 0;
    FOR i IN 1..10 LOOP
        v_soma := v_soma + (SUBSTRING(p_cpf, i, 1)::INT * (12 - i));
    END LOOP;

    v_resto := 11 - (v_soma % 11);
    IF v_resto >= 10 THEN
        v_digito2 := 0;
    ELSE
        v_digito2 := v_resto;
    END IF;

    IF v_digito2 <> SUBSTRING(p_cpf, 11, 1)::INT THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;


-- ============================================================================
-- 3. CRIAÇÃO DAS TABELAS E RESTRIÇÕES DE INTEGRIDADE
-- ============================================================================

-- Tabela: Autor
CREATE TABLE autor (
    id_autor SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    pseudonimo VARCHAR(50),
    nacionalidade VARCHAR(100),
    data_nascimento DATE
);

-- Tabela: Livro
CREATE TABLE livro (
    id_livro SERIAL PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    genero VARCHAR(50),
    editora VARCHAR(100),
    idioma VARCHAR(50) DEFAULT 'Português'
);

-- Tabela Associativa N:N: Livro_Autor
CREATE TABLE livro_autor (
    id_livro INT NOT NULL REFERENCES livro(id_livro) ON DELETE CASCADE,
    id_autor INT NOT NULL REFERENCES autor(id_autor) ON DELETE CASCADE,
    PRIMARY KEY (id_livro, id_autor)
);

-- Tabela: Leitor (com CPF único e validado)
-- VARCHAR(14) permite receber '000.000.000-00' antes do trigger limpar para 11 dígitos
CREATE TABLE leitor (
    id_leitor SERIAL PRIMARY KEY,
    cpf VARCHAR(14) UNIQUE NOT NULL CONSTRAINT chk_cpf_valido CHECK (fn_validar_cpf(cpf)),
    nome VARCHAR(150) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'Ativo' NOT NULL 
        CHECK (status IN ('Ativo', 'Bloqueado', 'Inativo'))
);

-- Tabela: Exemplar
CREATE TABLE exemplar (
    id_exemplar SERIAL PRIMARY KEY,
    id_livro INT NOT NULL REFERENCES livro(id_livro) ON DELETE RESTRICT,
    codigo_barras VARCHAR(50) UNIQUE NOT NULL,
    localizacao VARCHAR(50),
    estado_conservacao VARCHAR(50) DEFAULT 'Bom' NOT NULL,
    status VARCHAR(20) DEFAULT 'Disponível' NOT NULL 
        CHECK (status IN ('Disponível', 'Emprestado', 'Manutenção', 'Perdido'))
);

-- Tabela: Emprestimo
CREATE TABLE emprestimo (
    id_emprestimo SERIAL PRIMARY KEY,
    id_leitor INT NOT NULL REFERENCES leitor(id_leitor) ON DELETE RESTRICT,
    id_exemplar INT NOT NULL REFERENCES exemplar(id_exemplar) ON DELETE RESTRICT,
    data_retirada TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_prevista_devolucao DATE NOT NULL,
    data_devolucao DATE,
    CONSTRAINT chk_datas_emprestimo CHECK (data_prevista_devolucao >= data_retirada::date),
    CONSTRAINT chk_data_devolucao_valida CHECK (data_devolucao IS NULL OR data_devolucao >= data_retirada::date)
);

-- Tabela: Reserva
CREATE TABLE reserva (
    id_reserva SERIAL PRIMARY KEY,
    id_leitor INT NOT NULL REFERENCES leitor(id_leitor) ON DELETE RESTRICT,
    id_livro INT NOT NULL REFERENCES livro(id_livro) ON DELETE CASCADE,
    data_reserva TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'Pendente' NOT NULL 
        CHECK (status IN ('Pendente', 'Concluída', 'Cancelada', 'Expirada'))
);


-- ============================================================================
-- 4. ÍNDICES DE PERFORMANCE E REGRAS DE NEGÓCIO
-- ============================================================================

CREATE UNIQUE INDEX idx_exemplar_emprestimo_ativo 
ON emprestimo (id_exemplar) 
WHERE data_devolucao IS NULL;

CREATE INDEX idx_livro_titulo ON livro (titulo);
CREATE INDEX idx_exemplar_livro ON exemplar (id_livro);
CREATE INDEX idx_emprestimo_leitor ON emprestimo (id_leitor);
CREATE INDEX idx_reserva_livro_status ON reserva (id_livro, status);


-- ============================================================================
-- 5. AUTOMAÇÃO VIA TRIGGERS
-- ============================================================================

-- Trigger 1: Remove pontos e traços do CPF antes da validação do CHECK
CREATE OR REPLACE FUNCTION fn_limpar_cpf_leitor()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.cpf IS NOT NULL THEN
        NEW.cpf := REGEXP_REPLACE(NEW.cpf, '[^0-9]', '', 'g');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_antes_salvar_leitor
BEFORE INSERT OR UPDATE OF cpf ON leitor
FOR EACH ROW
EXECUTE FUNCTION fn_limpar_cpf_leitor();

-- Trigger 2: Valida leitor/exemplar e bloqueia o exemplar ao emprestar
CREATE OR REPLACE FUNCTION fn_validar_e_bloquear_exemplar()
RETURNS TRIGGER AS $$
DECLARE
    v_status_exemplar VARCHAR(20);
    v_status_leitor VARCHAR(20);
BEGIN
    SELECT status INTO v_status_leitor FROM leitor WHERE id_leitor = NEW.id_leitor;
    IF v_status_leitor <> 'Ativo' THEN
        RAISE EXCEPTION 'Empréstimo negado: o leitor possui status "%".', v_status_leitor;
    END IF;

    SELECT status INTO v_status_exemplar FROM exemplar WHERE id_exemplar = NEW.id_exemplar FOR UPDATE;
    IF v_status_exemplar <> 'Disponível' THEN
        RAISE EXCEPTION 'Empréstimo negado: o exemplar não está disponível (Status atual: "%").', v_status_exemplar;
    END IF;

    IF NEW.data_devolucao IS NULL THEN
        UPDATE exemplar SET status = 'Emprestado' WHERE id_exemplar = NEW.id_exemplar;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_antes_inserir_emprestimo
BEFORE INSERT ON emprestimo
FOR EACH ROW
EXECUTE FUNCTION fn_validar_e_bloquear_exemplar();

-- Trigger 3: Libera o exemplar automaticamente na devolução
CREATE OR REPLACE FUNCTION fn_liberar_exemplar_devolucao()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.data_devolucao IS NULL AND NEW.data_devolucao IS NOT NULL THEN
        UPDATE exemplar 
        SET status = 'Disponível' 
        WHERE id_exemplar = NEW.id_exemplar AND status = 'Emprestado';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_apos_devolucao_emprestimo
AFTER UPDATE OF data_devolucao ON emprestimo
FOR EACH ROW
EXECUTE FUNCTION fn_liberar_exemplar_devolucao();


-- ============================================================================
-- 6. VIEWS (Consultas em tempo real)
-- ============================================================================

CREATE VIEW vw_status_emprestimos AS
SELECT 
    emp.id_emprestimo,
    emp.id_leitor,
    lei.cpf,
    lei.nome AS nome_leitor,
    emp.id_exemplar,
    ex.codigo_barras,
    l.id_livro,
    l.titulo AS titulo_livro,
    emp.data_retirada,
    emp.data_prevista_devolucao,
    emp.data_devolucao,
    CASE 
        WHEN emp.data_devolucao IS NOT NULL THEN 'Devolvido'
        WHEN emp.data_prevista_devolucao < CURRENT_DATE THEN 'Em Atraso'
        ELSE 'Ativo'
    END AS status_emprestimo
FROM emprestimo emp
JOIN leitor lei ON emp.id_leitor = lei.id_leitor
JOIN exemplar ex ON emp.id_exemplar = ex.id_exemplar
JOIN livro l ON ex.id_livro = l.id_livro;

CREATE VIEW vw_disponibilidade_acervo AS
SELECT 
    l.id_livro,
    l.titulo,
    l.genero,
    l.editora,
    STRING_AGG(DISTINCT a.nome, ', ') AS autores,
    COUNT(ex.id_exemplar) AS total_exemplares,
    COUNT(ex.id_exemplar) FILTER (WHERE ex.status = 'Disponível') AS disponiveis,
    COUNT(ex.id_exemplar) FILTER (WHERE ex.status = 'Emprestado') AS emprestados
FROM livro l
LEFT JOIN livro_autor la ON l.id_livro = la.id_livro
LEFT JOIN autor a ON la.id_autor = a.id_autor
LEFT JOIN exemplar ex ON l.id_livro = ex.id_livro
GROUP BY l.id_livro, l.titulo, l.genero, l.editora;