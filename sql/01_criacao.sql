-- ============================================================================
-- 1. LIMPEZA SEGURA DO AMBIENTE (Ordem inversa de dependência: Filhas -> Pais)
-- ============================================================================

-- Remove Views dependentes primeiro
DROP VIEW IF EXISTS vw_status_emprestimos;
DROP VIEW IF EXISTS vw_disponibilidade_acervo;

-- Remove tabelas filhas (associativas e transacionais) antes das tabelas pai
DROP TABLE IF EXISTS reserva;
DROP TABLE IF EXISTS emprestimo;
DROP TABLE IF EXISTS livro_autor;
DROP TABLE IF EXISTS exemplar;

-- Remove tabelas independentes (pais)
DROP TABLE IF EXISTS leitor;
DROP TABLE IF EXISTS livro;
DROP TABLE IF EXISTS autor;

-- Remove funções de gatilho antigas, se existirem
DROP FUNCTION IF EXISTS fn_validar_e_bloquear_exemplar();
DROP FUNCTION IF EXISTS fn_liberar_exemplar_devolucao();


-- ============================================================================
-- 2. CRIAÇÃO DAS TABELAS E RESTRIÇÕES DE INTEGRIDADE
-- ============================================================================

-- Tabela: Autor
CREATE TABLE autor (
    id_autor SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    pseudonimo VARCHAR(100),
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
-- ON DELETE CASCADE aqui é seguro: se um livro ou autor for excluído, o vínculo deixa de existir.
CREATE TABLE livro_autor (
    id_livro INT NOT NULL REFERENCES livro(id_livro) ON DELETE CASCADE,
    id_autor INT NOT NULL REFERENCES autor(id_autor) ON DELETE CASCADE,
    PRIMARY KEY (id_livro, id_autor)
);

-- Tabela: Leitor
CREATE TABLE leitor (
    id_leitor SERIAL PRIMARY KEY,
    matricula VARCHAR(20) UNIQUE NOT NULL,
    nome VARCHAR(150) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'Ativo' NOT NULL 
        CHECK (status IN ('Ativo', 'Bloqueado', 'Inativo'))
);

-- Tabela: Exemplar (Unidades físicas do acervo)
-- ON DELETE RESTRICT impede apagar um livro se ainda existirem cópias físicas catalogadas.
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
-- ON DELETE RESTRICT preserva o histórico de empréstimos de leitores e exemplares.
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
-- 3. ÍNDICES DE PERFORMANCE E REGRAS DE NEGÓCIO
-- ============================================================================

-- Regra crítica: Um exemplar não pode estar em dois empréstimos ativos simultaneamente
CREATE UNIQUE INDEX idx_exemplar_emprestimo_ativo 
ON emprestimo (id_exemplar) 
WHERE data_devolucao IS NULL;

-- Índices para acelerar buscas frequentes por chaves estrangeiras e títulos
CREATE INDEX idx_livro_titulo ON livro (titulo);
CREATE INDEX idx_exemplar_livro ON exemplar (id_livro);
CREATE INDEX idx_emprestimo_leitor ON emprestimo (id_leitor);
CREATE INDEX idx_reserva_livro_status ON reserva (id_livro, status);


-- ============================================================================
-- 4. AUTOMAÇÃO VIA TRIGGERS (Consistência entre Empréstimo e Exemplar)
-- ============================================================================

-- Trigger 1: Valida se o leitor está ativo e se o exemplar está disponível antes de emprestar,
-- atualizando automaticamente o status do exemplar para 'Emprestado'.
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

-- Trigger 2: Libera o exemplar automaticamente quando data_devolucao é preenchida
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
-- 5. VIEWS (Consultas inteligentes em tempo real sem redundância)
-- ============================================================================

-- View 1: Calcula o status real dos empréstimos ('Ativo', 'Em Atraso', 'Devolvido')
CREATE VIEW vw_status_emprestimos AS
SELECT 
    emp.id_emprestimo,
    emp.id_leitor,
    lei.matricula,
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

-- View 2: Resumo de disponibilidade de exemplares por título
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