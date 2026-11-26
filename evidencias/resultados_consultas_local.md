# Resultados das consultas — execução local

Execução: 2026-11-26T02:13:08.410Z
SGBD: PostgreSQL 19.0 (PGlite 0.6.0) on wasm32-unknown-emscripten, compiled by emcc (Emscripten gcc/clang-like replacement + linker emulating GNU ld) 6.0.13 (e13ee988ce3d87a738dd8f3661d02223308c412a), 32-bit
Ambiente: PostgreSQL embutido em WebAssembly (PGlite), sem conexão com o Supabase.
Scripts executados: criação, população e as 12 consultas de `sql/03_consultas.sql`.

## Consulta 1 — Quais livros em português são de fantasia ou romance?

Linhas retornadas: 5.

| id_livro | titulo | genero | editora |
| --- | --- | --- | --- |
| 4 | A Hora da Estrela | Romance | Rocco |
| 3 | Dom Casmurro | Romance | Principis |
| 2 | O Hobbit | Fantasia | HarperCollins |
| 1 | O Senhor dos Anéis | Fantasia | HarperCollins |
| 6 | Quincas Borba | Romance | Principis |

## Consulta 2 — Quais leitores ativos possuem telefone cadastrado?

Linhas retornadas: 4.

| id_leitor | nome | email | telefone |
| --- | --- | --- | --- |
| 4 | Ana Oliveira | ana@email.com | (62) 99444-4444 |
| 3 | Carlos Pereira | carlos@email.com | (62) 99333-3333 |
| 1 | João Silva | joao@email.com | (62) 99111-1111 |
| 5 | Lucas Mendes | lucas@email.com | (62) 99555-5555 |

## Consulta 3 — Quais empréstimos estão atrasados ou foram devolvidos após o prazo?

Linhas retornadas: 9.

| id_emprestimo | id_leitor | data_prevista_devolucao | data_devolucao |
| --- | --- | --- | --- |
| 9 | 5 | 2026-09-14 | 2026-09-16 |
| 11 | 4 | 2026-10-04 | 2026-10-07 |
| 12 | 5 | 2026-10-09 | 2026-10-10 |
| 15 | 5 | 2026-10-24 | 2026-10-27 |
| 18 | 5 | 2026-11-05 | 2026-11-06 |
| 20 | 4 | 2026-11-09 | 2026-11-12 |
| 23 | 4 | 2026-11-15 | 2026-11-16 |
| 25 | 1 | 2026-11-19 | 2026-11-22 |
| 6 | 3 | 2026-11-21 | NULL |

## Consulta 4 — Quais exemplares estão disponíveis e a que livros pertencem?

Linhas retornadas: 5.

| titulo | genero | codigo_barras | localizacao |
| --- | --- | --- | --- |
| 1984 | Ficção Científica | BARRAS007 | Corredor C - Prateleira 1 |
| 1984 | Ficção Científica | BARRAS008 | Corredor C - Prateleira 1 |
| Dom Casmurro | Romance | BARRAS005 | Corredor B - Prateleira 1 |
| O Senhor dos Anéis | Fantasia | BARRAS001 | Corredor A - Prateleira 1 |
| Quincas Borba | Romance | BARRAS009 | Corredor B - Prateleira 2 |

## Consulta 5 — Quais leitores estão com livros emprestados e quais são os prazos?

Linhas retornadas: 4.

| id_emprestimo | nome_leitor | titulo | codigo_barras | data_retirada | data_prevista_devolucao |
| --- | --- | --- | --- | --- | --- |
| 6 | Carlos Pereira | Dom Casmurro | BARRAS004 | 2026-11-14 02:13:08 | 2026-11-21 |
| 4 | Ana Oliveira | A Hora da Estrela | BARRAS006 | 2026-11-23 02:13:08 | 2026-11-30 |
| 5 | Lucas Mendes | O Senhor dos Anéis | BARRAS002 | 2026-11-24 02:13:08 | 2026-12-01 |
| 3 | João Silva | O Hobbit | BARRAS003 | 2026-11-26 02:13:08 | 2026-12-03 |

## Consulta 6 — Quais leitores têm empréstimos ativos, incluindo os que não têm?

Linhas retornadas: 5.

| id_leitor | nome_leitor | id_emprestimo | data_prevista_devolucao |
| --- | --- | --- | --- |
| 4 | Ana Oliveira | 4 | 2026-11-30 |
| 3 | Carlos Pereira | 6 | 2026-11-21 |
| 1 | João Silva | 3 | 2026-12-03 |
| 5 | Lucas Mendes | 5 | 2026-12-01 |
| 2 | Maria Souza | NULL | NULL |

## Consulta 7 — Quantos livros há por gênero, considerando gêneros com dois títulos?

Linhas retornadas: 2.

| genero | quantidade_livros |
| --- | --- |
| Romance | 3 |
| Fantasia | 2 |

## Consulta 8 — Quais leitores possuem dois ou mais empréstimos registrados?

Linhas retornadas: 3.

| id_leitor | nome | total_emprestimos |
| --- | --- | --- |
| 4 | Ana Oliveira | 9 |
| 1 | João Silva | 9 |
| 5 | Lucas Mendes | 7 |

## Consulta 9 — Quais livros têm mais exemplares do que a média do acervo?

Linhas retornadas: 3.

| id_livro | titulo | total_exemplares |
| --- | --- | --- |
| 5 | 1984 | 2 |
| 3 | Dom Casmurro | 2 |
| 1 | O Senhor dos Anéis | 2 |

## Consulta 10 — Quais livros têm reserva pendente e nenhum exemplar disponível?

Linhas retornadas: 2.

| id_livro | titulo |
| --- | --- |
| 4 | A Hora da Estrela |
| 2 | O Hobbit |

## Consulta 11 — Quais empréstimos ativos estão atrasados e por quantos dias?

Linhas retornadas: 1.

| id_emprestimo | nome_leitor | titulo | data_prevista_devolucao | dias_em_atraso |
| --- | --- | --- | --- | --- |
| 6 | Carlos Pereira | Dom Casmurro | 2026-11-21 | 5 |

## Consulta 12 — Quais livros têm mais reservas pendentes que cópias disponíveis?

Linhas retornadas: 2.

| id_livro | titulo | reservas_pendentes | exemplares_disponiveis |
| --- | --- | --- | --- |
| 4 | A Hora da Estrela | 2 | 0 |
| 2 | O Hobbit | 2 | 0 |

## Verificação do rollback

Após executar `04_testes.sql`, o total da população continuou em 64 registros.
