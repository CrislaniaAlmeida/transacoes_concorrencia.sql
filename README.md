# Transações e Controle de Concorrência no MySQL

Esse projeto faz parte de uma atividade prática da disciplina de Administração em Banco de Dados: Otimização e Segurança, do curso de Engenharia de Software.

A ideia foi praticar como o MySQL trabalha com transações e com vários usuários acessando ou modificando informações ao mesmo tempo.

## O que foi trabalhado

- Início, confirmação e cancelamento de transações com START TRANSACTION, COMMIT e ROLLBACK.
- Propriedades ACID.
- Testes com duas sessões simultâneas.
- Bloqueios de registros.
- Níveis de isolamento.
- MVCC.
- Simulação e análise de deadlocks.
- Estratégias para reduzir conflitos entre transações.
- Exemplo de controle de vagas em um sistema acadêmico.

## Arquivos

- `transacoes_concorrencia.sql`: comandos SQL organizados por etapas e acompanhados de comentários.
- `evidencias/README.md`: orientação para organizar os registros dos testes.

## Ferramentas

- MySQL
- MySQL Workbench
- SQL
- Git e GitHub

## Um pouco sobre o que aprendi

A parte das duas sessões é especialmente interessante porque mostra, na prática, o que pode acontecer quando duas operações tentam alterar o mesmo registro. Também ajuda a entender por que existem bloqueios, níveis de isolamento e mecanismos como o MVCC.

Organizei os comandos e as observações para conseguir acompanhar cada etapa e consultar depois durante meus estudos.

**Observação:** os testes que envolvem duas sessões precisam ser executados em duas conexões diferentes no MySQL Workbench. Os resultados e prints devem ser adicionados depois da execução real. Os nomes de tabelas e colunas usados no roteiro precisam ser conferidos com a estrutura do banco disponibilizado na atividade antes de executar os comandos.
