# Entrega da 1ª Semana
## Levantamento de requisitos e análise do problema

### 1. Objetivo da etapa

Definir o cenário do projeto, compreender o problema operacional e registrar os requisitos iniciais para orientar a modelagem e a implementação do banco de dados.

### 2. Cenário e problema

A Biblioteca Carolina Maria de Jesus é uma biblioteca comunitária de bairro que oferece leitura no local e empréstimo de livros. No cenário inicial, o controle de leitores, acervo e empréstimos é feito manualmente em cadernos. Esse processo dificulta localizar obras, acompanhar devoluções e verificar a disponibilidade dos exemplares, além de aumentar o risco de perda de livros e de inconsistências nos registros.

O projeto propõe centralizar essas informações em um banco de dados relacional, facilitando o controle do acervo e o atendimento às necessidades de consulta da biblioteca.

### 3. Informações a serem armazenadas

| Grupo de informação | Dados identificados no levantamento |
|---|---|
| Leitores | Identificador, nome, CPF, telefone, e-mail e situação cadastral. O endereço foi considerado no levantamento inicial, mas não integra o esquema físico atual. |
| Autores | Identificador, nome, pseudônimo, nacionalidade e data de nascimento. |
| Livros | Identificador, título, gênero, editora e idioma. |
| Exemplares | Identificador, livro relacionado, código de barras, localização, conservação e disponibilidade. |
| Empréstimos | Identificador, leitor, exemplar, retirada, prazo previsto e devolução efetiva. |
| Reservas | Identificador, leitor, livro, data e situação da reserva. |
| Autoria | Associação entre livros e autores, permitindo registrar coautoria. |

### 4. Requisitos funcionais

1. Cadastrar livros do acervo com os dados necessários à identificação da obra.
2. Cadastrar leitores, incluindo dados de contato e identificação.
3. Consultar a disponibilidade dos exemplares de uma obra.
4. Consultar o histórico de empréstimos.
5. Consultar pendências do leitor antes de autorizar novo empréstimo.
6. Registrar reservas quando solicitadas por leitores.
7. Registrar a retirada de um exemplar por um leitor cadastrado e informar o prazo de devolução.
8. Registrar a devolução, atualizar a disponibilidade do exemplar e permitir verificar atrasos.

### 5. Regras de negócio levantadas

As regras abaixo representam o levantamento inicial da primeira semana. Regras operacionais foram detalhadas e implementadas nas etapas seguintes.

1. Leitores com empréstimos em atraso não devem iniciar novos empréstimos.
2. Cada leitor pode manter até três livros emprestados simultaneamente.
3. O leitor precisa estar cadastrado para realizar empréstimos.
4. O cadastro do leitor também é exigido para registrar a leitura local, conforme a proposta inicial.
5. A biblioteca deve notificar o leitor após um dia de atraso na devolução.
6. Quando não houver exemplar disponível, o sistema deve permitir registrar uma reserva.
7. O prazo inicial proposto para empréstimo é de sete dias.
8. O levantamento propôs até três renovações por empréstimo, totalizando até quatro semanas de posse.
9. A renovação proposta deve ser realizada presencialmente por um funcionário.
10. O sistema deve informar quando uma obra solicitada já constar no histórico de empréstimos do leitor.

### 6. Entidades iniciais

Foram identificadas sete entidades: **Leitor**, **Livro**, **Autor**, **Livro_Autor**, **Exemplar**, **Empréstimo** e **Reserva**. A relação Livro_Autor resolve a associação muitos-para-muitos entre obras e autores.

### 7. Perguntas gerenciais

- Quantos exemplares existem de determinada obra?
- Quais empréstimos estão atrasados?
- Quais obras estão emprestadas a determinado leitor?
- Quais livros foram escritos por determinado autor?
- Quantos empréstimos foram realizados em um intervalo de datas?

### 8. Resultado da etapa

O levantamento estabeleceu o problema, o escopo informacional, oito requisitos funcionais, dez regras de negócio iniciais e perguntas que orientarão as consultas SQL. Esses elementos serviram de base para o DER, o modelo relacional e os scripts das etapas posteriores.
