# Projeto-Integrador-BD-SPI-Biblioteca

Projeto de banco de dados relacional desenvolvido para a disciplina de Introdução a Banco de Dados, no curso de Tecnologia em Sistemas para Internet no IFTM - Campus Uberlândia Centro.

Sistema de Banco de Dados | **Biblioteca Carolina Maria de Jesus**

**Alunos envolvidos no projeto:**

A Biblioteca Carolina Maria de Jesus é uma biblioteca comunitária de bairro que oferece espaço para leitura local e empréstimo de livros aos moradores. Anteriormente, todo o controle de acervo, empréstimos e leitores era feito manualmente em um caderno de registros, o que gerava falhas de rastreamento, extravios de obras e dificuldades para identificar pendências ou disponibilidade dos exemplares.

Para solucionar esse gargalo operacional, foi desenvolvido um sistema de banco de dados relacional em PostgreSQL (hospedado no Supabase) que automatiza e centraliza toda a gestão da biblioteca.

- Aquila Fernando Alves Silva \| [aquila-silva](https://github.com/aquila-silva)
- André Luiz Ferreira Lauriano \| [andreluizdevolper](https://github.com/andreluizdevolper)
- Matheus Carvalho Roldão \| [matt-carvalho117](https://github.com/matt-carvalho117)
- Victor Cauã Duarte Rodrigues \| [caua-creator-create](https://github.com/caua-creator-create)
- Ygor Teodoro Rodrigues \| [ygorodrigs](https://github.com/ygorodrigs)

## Ordem de execução

Execute os scripts na seguinte ordem, no PostgreSQL/Supabase:

1. `sql/01_criacao.sql` cria o esquema, as restrições, as funções, os gatilhos e as views. **Atenção:** este script remove e recria as tabelas do projeto; não o execute em uma base com dados que devam ser preservados.
2. `sql/02_populacao.sql` insere 64 registros demonstrativos em uma transação e valida o total mínimo exigido de 60.
3. `sql/03_consultas.sql` contém as 12 consultas de análise. Execute cada consulta para visualizar seu resultado.
4. `sql/04_testes.sql` demonstra INSERT, UPDATE, DELETE e testes de integridade em uma transação finalizada com `ROLLBACK`.

## Documentação e evidências

Os documentos de requisitos, regras de negócio, DER, modelo relacional e dicionário de dados estão em `documentacao/`, junto da documentação e apresentação da Semana 4. Os fontes Markdown desses documentos ficam em `documentacao/fontes/`. `evidencias/resultados_consultas_local.md` registra a execução local; capturas da instância Supabase devem ser adicionadas em `evidencias/capturas_de_tela/`.

├── 1º Semana.pdf
├── 2º Semana.pdf
├── 3º Semana.pdf
├── README.md
├── documentacao/
│   ├── apresentacao_semana_4.pdf
│   ├── der.pdf
│   ├── dicionario_de_dados.pdf
│   ├── entrega_semana_4.pdf
│   ├── fontes/
│   ├── modelo_relacional.pdf
│   ├── requisitos.pdf
│   └── regras_de_negocio.pdf
├── evidencias/
│   ├── README.md
│   ├── resultados_consultas_local.md
│   └── capturas_de_tela/
└── sql/
    ├── 01_criacao.sql
    ├── 02_populacao.sql
    ├── 03_consultas.sql
    └── 04_testes.sql