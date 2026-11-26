# Apresentação — Semana 4

## Slide 1 — Sistema de biblioteca

**Biblioteca Carolina Maria de Jesus**
População, consultas SQL, testes de integridade e demonstração do banco.

## Slide 2 — Problema e requisitos

- O controle manual de acervo, leitores, empréstimos e pendências dificulta a operação.
- O sistema centraliza livros, autores, exemplares, leitores, empréstimos e reservas.
- As regras incluem prazo de até sete dias, até três empréstimos ativos e bloqueio de novos empréstimos em atraso.

## Slide 3 — DER e estrutura

- Sete tabelas relacionais, incluindo a associação N:N `livro_autor`.
- Duas views para situação de empréstimos e disponibilidade do acervo.
- FKs, `CHECK`, `UNIQUE`, índice parcial, funções e triggers mantêm a integridade.

## Slide 4 — Dados populados

- 64 registros distribuídos nas sete tabelas.
- Catálogo de seis livros e nove exemplares.
- Histórico de empréstimos devolvidos no prazo e em atraso, além de empréstimos ativos.
- Reservas pendentes, concluídas, canceladas e expiradas.

## Slide 5 — Consultas de demonstração

1. `03_consultas.sql`, consulta 2.2: leitor, exemplar, livro e empréstimo em um `JOIN` de quatro tabelas.
2. Consulta 3.2: leitores com pelo menos dois empréstimos, usando agregação e `HAVING`.
3. Consulta 4.1: livros com exemplares acima da média, usando subconsulta escalar.
4. Consulta 5.1: empréstimos ativos em atraso e quantidade de dias.

Os resultados locais executados estão em `evidencias/resultados_consultas_local.md`.

## Slide 6 — Manipulação e testes

- INSERT, UPDATE e DELETE com consultas de confirmação.
- Testes de FK, CPF, status, prazos, reservas, leitor bloqueado/em atraso e limite de empréstimos.
- Triggers alteram o status do exemplar na retirada e na devolução.
- `04_testes.sql` termina com `ROLLBACK`, preservando a base.

## Slide 7 — Dificuldades, soluções e demonstração

- Divergência entre valores de status, requisitos documentados e DDL: alinhada aos domínios do banco.
- Contagens da view de disponibilidade podiam duplicar exemplares em livros com coautoria: corrigidas com `COUNT(DISTINCT ...)`.
- A base local foi validada em PostgreSQL embutido; confirmar a implantação na instância Supabase.
- Roteiro ao vivo: executar criação e população; abrir uma consulta `JOIN`, uma agregação e uma subconsulta; executar testes; capturar telas dos resultados no Supabase.
