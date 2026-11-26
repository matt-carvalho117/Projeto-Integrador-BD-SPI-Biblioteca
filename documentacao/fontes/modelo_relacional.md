# Modelo relacional — Biblioteca Carolina Maria de Jesus

Esquema implementado no PostgreSQL pelo script `sql/01_criacao.sql`. O modelo possui sete tabelas, duas views e regras de integridade implementadas com chaves, restrições, funções e triggers.

## Relações e atributos

- **AUTOR** (`id_autor` SERIAL PK, `nome` VARCHAR(150) NOT NULL, `pseudonimo` VARCHAR(50), `nacionalidade` VARCHAR(100), `data_nascimento` DATE).
- **LIVRO** (`id_livro` SERIAL PK, `titulo` VARCHAR(200) NOT NULL, `genero` VARCHAR(50), `editora` VARCHAR(100), `idioma` VARCHAR(50) DEFAULT 'Português').
- **LIVRO_AUTOR** (`id_livro` INT FK → LIVRO, `id_autor` INT FK → AUTOR, PK composta). Ambas as FKs usam `ON DELETE CASCADE`.
- **LEITOR** (`id_leitor` SERIAL PK, `cpf` VARCHAR(14) UNIQUE NOT NULL, `nome` VARCHAR(150) NOT NULL, `telefone` VARCHAR(20), `email` VARCHAR(100) UNIQUE NOT NULL, `status` VARCHAR(20) DEFAULT 'Ativo' NOT NULL).
- **EXEMPLAR** (`id_exemplar` SERIAL PK, `id_livro` INT FK → LIVRO NOT NULL, `codigo_barras` VARCHAR(50) UNIQUE NOT NULL, `localizacao` VARCHAR(50), `estado_conservacao` VARCHAR(50) DEFAULT 'Bom' NOT NULL, `status` VARCHAR(20) DEFAULT 'Disponível' NOT NULL).
- **EMPRESTIMO** (`id_emprestimo` SERIAL PK, `id_leitor` INT FK → LEITOR NOT NULL, `id_exemplar` INT FK → EXEMPLAR NOT NULL, `data_retirada` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, `data_prevista_devolucao` DATE NOT NULL, `data_devolucao` DATE).
- **RESERVA** (`id_reserva` SERIAL PK, `id_leitor` INT FK → LEITOR NOT NULL, `id_livro` INT FK → LIVRO NOT NULL, `data_reserva` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, `status` VARCHAR(20) DEFAULT 'Pendente' NOT NULL).

## Cardinalidades

| Relacionamento | Cardinalidade implementada |
|---|---|
| AUTOR — LIVRO, por LIVRO_AUTOR | N:N; cada linha associativa referencia exatamente um autor e um livro. Uma entidade pode ainda não ter associação. |
| LIVRO — EXEMPLAR | Um livro pode ter 0..N exemplares; cada exemplar pertence a exatamente um livro. |
| LEITOR — EMPRESTIMO | Um leitor pode ter 0..N empréstimos históricos; cada empréstimo pertence a exatamente um leitor. |
| EXEMPLAR — EMPRESTIMO | Um exemplar pode ter 0..N empréstimos históricos; cada empréstimo referencia exatamente um exemplar. O índice parcial permite no máximo um empréstimo ativo por exemplar. |
| LEITOR — RESERVA | Um leitor pode ter 0..N reservas; cada reserva pertence a exatamente um leitor. |
| LIVRO — RESERVA | Um livro pode ter 0..N reservas; cada reserva referencia exatamente um livro. |

## Restrições e automações

- CPF é higienizado pelo trigger `trg_antes_salvar_leitor` e validado matematicamente por `fn_validar_cpf`; CPF e e-mail são únicos.
- Status de leitor, exemplar e reserva são limitados a valores permitidos por `CHECK`.
- Datas de empréstimo garantem retirada não posterior ao prazo, prazo máximo de sete dias e devolução não anterior à retirada.
- O trigger de empréstimo exige leitor ativo, impede novos empréstimos enquanto existir atraso, limita a três empréstimos ativos por leitor e exige exemplar disponível.
- O empréstimo ativo altera o exemplar para `Emprestado`; a devolução o libera para `Disponível`.
- Uma reserva `Pendente` é aceita somente quando não há exemplar disponível para o livro.
- FKs de empréstimo e exemplar protegem registros referenciados (`ON DELETE RESTRICT`); a associação livro-autor e as reservas usam `ON DELETE CASCADE`.

## Views

- `vw_status_emprestimos`: apresenta o estado calculado do empréstimo (ativo, em atraso ou devolvido).
- `vw_disponibilidade_acervo`: agrega autores e totais de exemplares, disponíveis e emprestados sem duplicar contagens em livros com coautoria.
