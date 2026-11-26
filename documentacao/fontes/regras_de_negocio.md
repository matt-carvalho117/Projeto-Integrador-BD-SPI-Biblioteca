# Regras de negócio — Biblioteca Carolina Maria de Jesus

1. Cada exemplar possui código de barras único e pertence a um livro cadastrado.
2. CPF deve conter onze dígitos válidos; a pontuação é removida antes da validação. CPF e e-mail não podem se repetir.
3. Leitores podem ter status `Ativo`, `Bloqueado` ou `Inativo`. Somente leitores ativos podem retirar exemplares.
4. Um leitor não pode iniciar empréstimo se já tiver um empréstimo ativo vencido.
5. Cada leitor pode manter no máximo três empréstimos ativos simultaneamente.
6. O prazo previsto deve ser posterior ou igual à retirada e não pode exceder sete dias.
7. Um exemplar só pode ser emprestado quando está `Disponível`; enquanto o empréstimo está ativo, seu estado passa a `Emprestado`.
8. A devolução não pode anteceder a retirada. Ao registrar a devolução, o exemplar emprestado volta automaticamente a `Disponível`.
9. Cada exemplar pode ter no máximo um empréstimo ativo; empréstimos históricos podem se repetir ao longo do tempo.
10. Uma reserva com status `Pendente` só pode ser registrada quando não há exemplares disponíveis daquele livro. Reservas podem ser `Pendente`, `Concluída`, `Cancelada` ou `Expirada`.
11. Exemplares e empréstimos protegem seus registros referenciados contra exclusões que deixariam dados órfãos. Associações livro-autor e reservas acompanham a exclusão do livro/autor conforme as FKs definidas.
12. A disponibilidade e o estado do empréstimo são consultados pelas views `vw_disponibilidade_acervo` e `vw_status_emprestimos`; estados temporais não são armazenados como dados derivados.
