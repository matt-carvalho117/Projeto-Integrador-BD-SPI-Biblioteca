# Entrega da Semana 4 — Biblioteca Carolina Maria de Jesus

## Objetivo

Demonstrar que o banco de dados armazena um conjunto coerente de informações e responde a necessidades de consulta, manipulação e integridade da biblioteca.

## Parte A — População

O script `sql/02_populacao.sql` cria uma massa demonstrativa com **64 registros** distribuídos pelas sete tabelas:

| Tabela | Registros |
|---|---:|
| `autor` | 4 |
| `livro` | 6 |
| `livro_autor` | 6 |
| `leitor` | 5 |
| `exemplar` | 9 |
| `emprestimo` | 26 |
| `reserva` | 8 |
| **Total** | **64** |

Há empréstimos ativos, atrasados e devolvidos antes, no prazo e depois do vencimento. As reservas têm os quatro estados permitidos. O catálogo inclui um exemplar disponível sem histórico de empréstimos ou reservas. O próprio script valida o total mínimo de 60 e que todas as tabelas estão populadas.

## Parte B — Consultas

O script `sql/03_consultas.sql` contém 12 consultas com enunciados:

- 3 consultas com `SELECT`, `WHERE`, operadores e filtros;
- 3 consultas com `JOIN`, incluindo uma com quatro tabelas e uma com `LEFT JOIN`;
- 2 consultas de agregação com `GROUP BY`, ambas com `HAVING`;
- 2 consultas com subconsultas, incluindo uma escalar;
- 2 consultas de negócio: empréstimos em atraso e demanda de reservas versus disponibilidade.

`ORDER BY` é usado para priorizar e organizar os resultados; `LIMIT` aparece nas consultas de listagem mais relevantes.

## Parte C — Manipulação e integridade

O script `sql/04_testes.sql` demonstra `INSERT`, `UPDATE` e `DELETE`, com consultas de confirmação. Testa FKs, CPF inválido e duplicado, domínios de status, prazo máximo, reserva sem disponibilidade, leitor bloqueado/em atraso, limite de três empréstimos ativos, exclusividade de exemplar ativo e os triggers de retirada/devolução. Toda a demonstração termina em `ROLLBACK`.

## Parte D — Apresentação

`apresentacao_semana_4.pdf` organiza a demonstração do problema, requisitos, DER, estrutura, dados, consultas, testes, dificuldades e soluções. Os exemplos de consulta foram executados com a população do projeto em PostgreSQL embutido (PGlite).

## Execução

Execute `01_criacao.sql`, depois `02_populacao.sql`, consulte `03_consultas.sql` e finalize com `04_testes.sql`. O primeiro script apaga e recria as tabelas; use-o apenas em uma base de demonstração.

## Evidências

Os resultados anexos registram a validação local dos scripts. Antes da entrega, ainda devem ser feitas capturas de tela dos resultados na instância Supabase da equipe e inseridas em `evidencias/capturas_de_tela/`; a validação local não substitui evidência da instância hospedada.
