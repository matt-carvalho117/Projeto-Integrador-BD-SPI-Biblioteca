**Projeto Integrador \- Banco de Dados Ponta a Ponta**  
**Sistema de Biblioteca**

André Luiz Ferreira Lauriano \| andreluizdevolper  
Aquila Fernando Alves Silva \| aquila-silva  
Matheus Carvalho Roldão \| matt-carvalho117  
Victor Cauã Duarte Rodrigues \| caua-creator-create   
Ygor Teodoro Rodrigues \| ygorodrigs

Link GitHub: [https\://github.com/matt-carvalho117/Projeto-Integrador-BD-SPI-Biblioteca](https://github.com/matt-carvalho117/Projeto-Integrador-BD-SPI-Biblioteca)

**SEMANA 1 — Levantamento de requisitos e análise do problema**

1. **Selecionar o cenário do projeto.**

	Sistema de Biblioteca.

2. **Descrever a organização fictícia e o problema que o banco deverá resolver.**  
   	Uma pequena biblioteca de bairro, que o leitor pode ler no local ou realizar empréstimos. O controle é feito de forma manual num caderno de registros. Tal mecanismo gera falhas de controle pelos funcionários, das obras emprestadas e dos usuários  cadastrados, ocasionando na perda de livros do acervo. Desta forma, o sistema de banco de dados iria suprir esse gargalo do local.
   
4. **Identificar quais informações precisam ser armazenadas.**

   Para atender às necessidades operacionais e de controle da biblioteca, o banco de dados armazenará as seguintes informações agrupadas por domínio:Informações dos Leitores/Usuários: Identificação única do leitor (id_leitor), nome completo, endereço residencial, telefone de contato e e-mail.

* Informações das Obras (Livros): Identificação única do livro (id_livro), título da obra, gênero literário, editora e idioma.
* Informações dos Autores: Identificação única do autor (id_autor), nome completo, pseudônimo, nacionalidade e data de nascimento.
* Informações da Associação Autor-Livro: Vínculo estruturado entre as obras e seus autores (id_livro_autor), permitindo o registro de coautoria.
* Informações dos Exemplares: Identificação única física do exemplar (id_exemplar), vínculo com o livro correspondente (id_livro) e status atual de disponibilidade (ex.: disponível, emprestado, em manutenção).
* Informações dos Empréstimos: Identificação única da transação (id_emprestimo), leitor associado (id_leitor), exemplar emprestado (id_exemplar), data de retirada, data prevista para devolução e data efetiva de devolução.
* Informações das Reservas: Identificação única da reserva (id_reserva), leitor solicitante (id_leitor), livro desejado (id_livro), data em que a reserva foi realizada e status do pedido (ex.: aguardando, concluída, cancelada).   
     
5. **Elaborar pelo menos 8 requisitos funcionais relacionados aos dados e às operações do sistema.**

* Realizar o cadastro dos livros do acervo, com informações relacionadas à obra;  
* Realizar o cadastro de usuários/leitores, com nome, endereço, telefone de contato e e-mail.;  
* Consultar a disponibilidade da obra no acervo;  
* Consultar o histórico de empréstimo do livro;  
* Consultar pendências do usuário, verificando a possibilidade de novos empréstimos;  
* Registrar no sistema a reserva da obra, conforme a solicitação do leitor;  
* Vincular um exemplar disponível a um usuário cadastrado, definindo a data de retirada e o prazo limite de devolução;  
* Dar baixa no empréstimo, atualizar o status do exemplar para disponível e verificar se houve atraso.

5. **Descrever pelo menos 10 regras de negócio.**

* O leitor tem que estar em dia com os empréstimos para poder continuar pegando outras obras;  
* Cada leitor poderá ter em seu cadastro até três livros emprestados.  
* O leitor deve ter um cadastro obrigatório com o sistema se quiser pegar algum livro;  
* Para o leitor pegar algum livro, para uso nas dependências do local, o cadastro do leitor deverá constar no sistema;  
* Após um dia de atraso da devolução da obra, o sistema deverá notificar o usuário;  
* Se a obra escolhida pelo leitor não tiver disponível para empréstimo o sistema apresentará uma opção que o leitor poderá realizar a reserva da obra;  
* O leitor poderá ficar com o livro no prazo de 7 dias;  
* Cada leitor poderá realizar a renovação da obra no máximo três vezes, contabilizando assim quatro semanas com a obra;  
* A renovação das obras deverá ser feita presencialmente, por algum funcionário da biblioteca;  
* O sistema deverá notificar o leitor que a obra solicitada consta no seu histórico de empréstimo. 

6. **Identificar preliminarmente as entidades e seus principais atributos.**  
   **Entidades criadas:**   
* Leitor, Livro, Autor, Livro\_Autor, Exemplar, Empréstimo e Reserva. 

  **Principais Atributos:**  
    
* **Leitor:** id\_leitor (PK), nome, telefone, email  
* Autor: id\_autor (PK), nome, pseudonimo, nacionalidade, data\_nascimento  
* **Livro:** id\_livro (PK), titulo, genero, editora, idioma  
* **Livro\_Autor:** id\_livro\_autor(PK formada por duas FK “id\_autor e id\_livro”)  
* **Exemplar:** id\_exemplar (PK), id\_livro (FK)  
* **Emprestimo:** id\_emprestimo (PK), id\_leitor (FK), id\_exemplar (FK), data\_retirada, data\_devolucao  
* **Reserva:** id\_reserva (PK), id\_leitor (FK), id\_livro (FK), data\_reserva, status

7. Elaborar pelo menos 5 perguntas gerenciais que deverão ser respondidas posteriormente por consultas SQL.

* Qual o número de exemplares de tal obra?  
* Quais empréstimos estão atrasados na entrega?  
* Quais obras estão emprestadas no cadastro de determinado leitor?  
* Quais livros de determinado autor?  
* Quantos empréstimos foram realizados no intervalo de determinadas datas?

