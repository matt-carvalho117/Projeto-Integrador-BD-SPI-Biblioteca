# Dicionário de dados — Biblioteca Carolina Maria de Jesus

Os tipos, nulabilidade, valores padrão e restrições abaixo correspondem ao DDL de `sql/01_criacao.sql`.

## AUTOR

| Campo | Tipo | Nulo | Padrão / regra |
|---|---|---|---|
| `id_autor` | SERIAL | Não | Chave primária |
| `nome` | VARCHAR(150) | Não | — |
| `pseudonimo` | VARCHAR(50) | Sim | — |
| `nacionalidade` | VARCHAR(100) | Sim | — |
| `data_nascimento` | DATE | Sim | — |

## LIVRO

| Campo | Tipo | Nulo | Padrão / regra |
|---|---|---|---|
| `id_livro` | SERIAL | Não | Chave primária |
| `titulo` | VARCHAR(200) | Não | — |
| `genero` | VARCHAR(50) | Sim | — |
| `editora` | VARCHAR(100) | Sim | — |
| `idioma` | VARCHAR(50) | Sim | `'Português'` |

## LIVRO_AUTOR

| Campo | Tipo | Nulo | Padrão / regra |
|---|---|---|---|
| `id_livro` | INT | Não | Parte da PK composta; FK para `livro(id_livro)`, `ON DELETE CASCADE` |
| `id_autor` | INT | Não | Parte da PK composta; FK para `autor(id_autor)`, `ON DELETE CASCADE` |

## LEITOR

| Campo | Tipo | Nulo | Padrão / regra |
|---|---|---|---|
| `id_leitor` | SERIAL | Não | Chave primária |
| `cpf` | VARCHAR(14) | Não | Único; trigger remove pontuação; `CHECK fn_validar_cpf(cpf)` |
| `nome` | VARCHAR(150) | Não | — |
| `telefone` | VARCHAR(20) | Sim | — |
| `email` | VARCHAR(100) | Não | Único |
| `status` | VARCHAR(20) | Não | `'Ativo'`; permitido: `Ativo`, `Bloqueado`, `Inativo` |

## EXEMPLAR

| Campo | Tipo | Nulo | Padrão / regra |
|---|---|---|---|
| `id_exemplar` | SERIAL | Não | Chave primária |
| `id_livro` | INT | Não | FK para `livro(id_livro)`, `ON DELETE RESTRICT` |
| `codigo_barras` | VARCHAR(50) | Não | Único |
| `localizacao` | VARCHAR(50) | Sim | — |
| `estado_conservacao` | VARCHAR(50) | Não | `'Bom'` |
| `status` | VARCHAR(20) | Não | `'Disponível'`; permitido: `Disponível`, `Emprestado`, `Manutenção`, `Perdido` |

## EMPRESTIMO

| Campo | Tipo | Nulo | Padrão / regra |
|---|---|---|---|
| `id_emprestimo` | SERIAL | Não | Chave primária |
| `id_leitor` | INT | Não | FK para `leitor(id_leitor)`, `ON DELETE RESTRICT` |
| `id_exemplar` | INT | Não | FK para `exemplar(id_exemplar)`, `ON DELETE RESTRICT` |
| `data_retirada` | TIMESTAMP | Não | `CURRENT_TIMESTAMP` |
| `data_prevista_devolucao` | DATE | Não | Entre a data de retirada e, no máximo, sete dias depois |
| `data_devolucao` | DATE | Sim | Nula enquanto ativo; não pode anteceder a retirada |

Índice parcial `idx_exemplar_emprestimo_ativo`: no máximo um empréstimo com `data_devolucao IS NULL` por exemplar.

## RESERVA

| Campo | Tipo | Nulo | Padrão / regra |
|---|---|---|---|
| `id_reserva` | SERIAL | Não | Chave primária |
| `id_leitor` | INT | Não | FK para `leitor(id_leitor)`, `ON DELETE RESTRICT` |
| `id_livro` | INT | Não | FK para `livro(id_livro)`, `ON DELETE CASCADE` |
| `data_reserva` | TIMESTAMP | Não | `CURRENT_TIMESTAMP` |
| `status` | VARCHAR(20) | Não | `'Pendente'`; permitido: `Pendente`, `Concluída`, `Cancelada`, `Expirada` |

## Views e índices

`vw_status_emprestimos` calcula o estado dos empréstimos. `vw_disponibilidade_acervo` resume autores e disponibilidade do catálogo. Índices adicionais atendem buscas por título, livro de um exemplar, empréstimos por leitor e reservas por livro/status.
