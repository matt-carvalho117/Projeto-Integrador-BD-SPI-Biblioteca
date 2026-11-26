# Entrega da 4ª Semana
## População, consultas SQL, testes e validação

### 1. Objetivo da etapa

Demonstrar que o banco de dados armazena um conjunto coerente de informações e responde a necessidades de consulta, manipulação e integridade da biblioteca.

### 2. População dos dados

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

### 3. Consultas SQL

O script `sql/03_consultas.sql` contém 12 consultas com enunciados:

- 3 consultas com `SELECT`, `WHERE`, operadores e filtros;
- 3 consultas com `JOIN`, incluindo uma com quatro tabelas e uma com `LEFT JOIN`;
- 2 consultas de agregação com `GROUP BY`, ambas com `HAVING`;
- 2 consultas com subconsultas, incluindo uma escalar;
- 2 consultas de negócio: empréstimos em atraso e demanda de reservas versus disponibilidade.

`ORDER BY` é usado para priorizar e organizar os resultados; `LIMIT` aparece nas consultas de listagem mais relevantes.

### 4. Manipulação e integridade

O script `sql/04_testes.sql` demonstra `INSERT`, `UPDATE` e `DELETE`, com consultas de confirmação. Testa FKs, CPF inválido e duplicado, domínios de status, prazo máximo, reserva sem disponibilidade, leitor bloqueado/em atraso, limite de três empréstimos ativos, exclusividade de exemplar ativo e os triggers de retirada/devolução. Toda a demonstração termina em `ROLLBACK`.

### 5. Execução dos scripts

Execute `01_criacao.sql`, depois `02_populacao.sql`, consulte `03_consultas.sql` e finalize com `04_testes.sql`. O primeiro script apaga e recria as tabelas; use-o apenas em uma base de demonstração.

### 6. Evidências e validação

Os scripts foram executados em PostgreSQL embutido (PGlite), e os resultados locais estão em `evidencias/resultados_consultas_local.md`. Antes da entrega final, ainda devem ser feitas capturas dos resultados na instância Supabase da equipe e inseridas em `evidencias/capturas_de_tela/`; a validação local não substitui evidência da instância hospedada.

### 7. Resultado da etapa

A entrega reúne população diversificada, doze consultas, operações de manipulação e testes de integridade referencial e das regras principais. Os testes destrutivos terminam com `ROLLBACK`, preservando a população inicial.
