-- ============================================================
-- PROJETO: Transações e Controle de Concorrência no MySQL
-- CURSO: Engenharia de Software
-- DISCIPLINA: Administração em Banco de Dados:
--             Otimização e Segurança
--
-- OBJETIVO:
-- Praticar transações, COMMIT, ROLLBACK, propriedades ACID,
-- níveis de isolamento, bloqueios, deadlocks e MVCC.
--
-- ATENÇÃO:
-- Este roteiro usa como exemplo as tabelas aluno, mensalidade,
-- turma e matricula. Confira os nomes reais das tabelas e
-- colunas do banco da atividade antes de executar.
--
-- Os testes identificados como SESSÃO A e SESSÃO B devem ser
-- executados em duas conexões diferentes do MySQL Workbench.
-- ============================================================


-- ============================================================
-- PARTE 1 - PREPARAÇÃO DO AMBIENTE
-- ============================================================

USE escola_curso;

-- As tabelas de laboratório evitam alterar diretamente
-- os dados originais. Estes comandos recriam as cópias.
DROP TABLE IF EXISTS lab_mensalidade;
DROP TABLE IF EXISTS lab_aluno;

CREATE TABLE lab_aluno LIKE aluno;
INSERT INTO lab_aluno SELECT * FROM aluno;

CREATE TABLE lab_mensalidade LIKE mensalidade;
INSERT INTO lab_mensalidade SELECT * FROM mensalidade;

-- Conferindo os dados copiados.
SELECT * FROM lab_aluno;
SELECT * FROM lab_mensalidade;


-- ============================================================
-- PARTE 2 - PRIMEIRA TRANSAÇÃO (QUESTÕES 1 E 2)
-- ============================================================

SELECT * FROM lab_aluno WHERE id_aluno = 1;

START TRANSACTION;

UPDATE lab_aluno
SET cidade = 'Quixadá'
WHERE id_aluno = 1;

-- A alteração ainda está dentro da transação.
SELECT * FROM lab_aluno WHERE id_aluno = 1;

-- Confirma a alteração.
COMMIT;

SELECT * FROM lab_aluno WHERE id_aluno = 1;


-- ============================================================
-- PARTE 3 - ROLLBACK (QUESTÃO 3)
-- ============================================================

SELECT * FROM lab_aluno WHERE id_aluno = 2;

START TRANSACTION;

UPDATE lab_aluno
SET cidade = 'Fortaleza'
WHERE id_aluno = 2;

SELECT * FROM lab_aluno WHERE id_aluno = 2;

-- Desfaz a alteração ainda não confirmada.
ROLLBACK;

SELECT * FROM lab_aluno WHERE id_aluno = 2;


-- ============================================================
-- PARTE 4 - UNIDADE LÓGICA DE TRABALHO (QUESTÕES 4 E 5)
-- ============================================================

-- As duas atualizações fazem parte da mesma transação.
START TRANSACTION;

UPDATE lab_mensalidade
SET valor_pago = valor
WHERE id_mensalidade = 1;

UPDATE lab_mensalidade
SET situacao = 'Paga'
WHERE id_mensalidade = 1;

COMMIT;

SELECT * FROM lab_mensalidade WHERE id_mensalidade = 1;

-- Simulando uma falha antes da conclusão.
START TRANSACTION;

UPDATE lab_mensalidade
SET valor_pago = valor
WHERE id_mensalidade = 2;

-- Desfaz a primeira alteração porque a operação não terminou.
ROLLBACK;

SELECT * FROM lab_mensalidade WHERE id_mensalidade = 2;


-- ============================================================
-- PARTE 5 - PROPRIEDADES ACID (QUESTÃO 6)
-- ============================================================

-- ATOMICIDADE: a transação é concluída por inteiro ou desfeita.
-- CONSISTÊNCIA: os dados devem respeitar as regras do banco.
-- ISOLAMENTO: transações simultâneas não devem interferir
--             indevidamente umas nas outras.
-- DURABILIDADE: depois do COMMIT, as alterações são persistidas.


-- ============================================================
-- PARTE 6 - DUAS SESSÕES SIMULTÂNEAS (QUESTÃO 7)
-- ============================================================

-- SESSÃO A:
-- START TRANSACTION;
-- UPDATE lab_aluno SET cidade = 'Sobral' WHERE id_aluno = 3;
-- Não executar COMMIT ainda.
--
-- SESSÃO B:
-- SELECT * FROM lab_aluno WHERE id_aluno = 3;
--
-- SESSÃO A:
-- COMMIT;
--
-- SESSÃO B:
-- SELECT * FROM lab_aluno WHERE id_aluno = 3;
--
-- Compare o resultado antes e depois da confirmação.


-- ============================================================
-- PARTE 7 - BLOQUEIOS (QUESTÃO 8)
-- ============================================================

-- SESSÃO A:
-- START TRANSACTION;
-- UPDATE lab_aluno SET cidade = 'Crato' WHERE id_aluno = 4;
-- Não confirmar ainda.
--
-- SESSÃO B:
-- START TRANSACTION;
-- UPDATE lab_aluno SET cidade = 'Iguatu' WHERE id_aluno = 4;
-- A segunda atualização deverá aguardar a liberação do bloqueio.
--
-- SESSÃO A:
-- COMMIT;
--
-- SESSÃO B:
-- Quando a atualização terminar, execute COMMIT.
--
-- Conferência:
-- SELECT * FROM lab_aluno WHERE id_aluno = 4;


-- ============================================================
-- PARTE 8 - ROLLBACK E BLOQUEIOS (QUESTÃO 9)
-- ============================================================

-- SESSÃO A:
-- START TRANSACTION;
-- UPDATE lab_aluno SET cidade = 'Maracanaú' WHERE id_aluno = 4;
--
-- SESSÃO B:
-- START TRANSACTION;
-- UPDATE lab_aluno SET cidade = 'Juazeiro do Norte'
-- WHERE id_aluno = 4;
-- A sessão B deverá aguardar.
--
-- SESSÃO A:
-- ROLLBACK;
-- O bloqueio é liberado sem confirmar a alteração.
--
-- SESSÃO B:
-- Depois que a atualização terminar, execute COMMIT.


-- ============================================================
-- PARTE 9 - NÍVEIS DE ISOLAMENTO (QUESTÃO 10)
-- ============================================================

SELECT @@transaction_isolation;

-- READ UNCOMMITTED: pode permitir leitura de alterações
-- ainda não confirmadas.
--
-- READ COMMITTED: cada leitura consistente considera dados
-- que já foram confirmados.
--
-- REPEATABLE READ: leituras consistentes na mesma transação
-- mantêm a mesma visão dos dados.
--
-- SERIALIZABLE: aplica controle mais rigoroso para evitar
-- anomalias entre transações simultâneas.


-- ============================================================
-- PARTE 10 - READ COMMITTED (QUESTÃO 11)
-- ============================================================

-- SESSÃO A:
-- Configure o isolamento e inicie a transação:
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- START TRANSACTION;
-- SELECT * FROM lab_aluno WHERE id_aluno = 5;
--
-- SESSÃO B:
-- START TRANSACTION;
-- UPDATE lab_aluno SET cidade = 'Canindé' WHERE id_aluno = 5;
-- COMMIT;
--
-- SESSÃO A:
-- SELECT * FROM lab_aluno WHERE id_aluno = 5;
-- Em READ COMMITTED, uma nova leitura consistente pode
-- visualizar a alteração confirmada pela sessão B.
-- COMMIT;


-- ============================================================
-- PARTE 11 - REPEATABLE READ (QUESTÃO 12)
-- ============================================================

-- SESSÃO A:
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- START TRANSACTION;
-- SELECT * FROM lab_aluno WHERE id_aluno = 5;
--
-- SESSÃO B:
-- START TRANSACTION;
-- UPDATE lab_aluno SET cidade = 'Itapipoca' WHERE id_aluno = 5;
-- COMMIT;
--
-- SESSÃO A:
-- SELECT * FROM lab_aluno WHERE id_aluno = 5;
-- Em uma leitura consistente, a sessão A mantém sua visão
-- dos dados até encerrar a transação.
-- COMMIT;


-- ============================================================
-- PARTE 12 - MVCC (QUESTÃO 13)
-- ============================================================

-- MVCC significa Multi-Version Concurrency Control.
-- O mecanismo mantém versões dos registros para permitir
-- leituras consistentes enquanto outras transações escrevem.
-- Isso reduz conflitos entre leituras e escritas, mas não
-- elimina todos os bloqueios.


-- ============================================================
-- PARTE 13 - SIMULAÇÃO DE DEADLOCK (QUESTÃO 14)
-- ============================================================

-- Execute os passos na ordem indicada, em duas conexões.
--
-- SESSÃO A - PASSO 1:
-- START TRANSACTION;
-- UPDATE lab_aluno SET cidade = 'Cidade A' WHERE id_aluno = 1;
--
-- SESSÃO B - PASSO 2:
-- START TRANSACTION;
-- UPDATE lab_aluno SET cidade = 'Cidade B' WHERE id_aluno = 2;
--
-- SESSÃO A - PASSO 3:
-- UPDATE lab_aluno SET cidade = 'Cidade A2' WHERE id_aluno = 2;
-- A sessão A ficará aguardando o bloqueio mantido pela B.
--
-- SESSÃO B - PASSO 4:
-- UPDATE lab_aluno SET cidade = 'Cidade B2' WHERE id_aluno = 1;
-- O InnoDB deverá detectar o ciclo de espera e escolher
-- uma transação para desfazer.
--
-- Verifique a mensagem de erro e finalize a transação
-- sobrevivente com COMMIT ou ROLLBACK, conforme o teste.


-- ============================================================
-- PARTE 14 - INVESTIGANDO O DEADLOCK (QUESTÃO 15)
-- ============================================================

SHOW ENGINE INNODB STATUS;

-- Procure a seção LATEST DETECTED DEADLOCK.
-- Ela apresenta informações sobre transações, comandos,
-- bloqueios e a transação escolhida como vítima.


-- ============================================================
-- PARTE 15 - REDUZINDO DEADLOCKS (QUESTÃO 16)
-- ============================================================

-- A estratégia demonstrada é acessar os registros sempre
-- na mesma ordem nas diferentes transações.
--
-- SESSÃO A:
-- START TRANSACTION;
-- UPDATE lab_aluno SET cidade = 'Teste A1' WHERE id_aluno = 1;
-- UPDATE lab_aluno SET cidade = 'Teste A2' WHERE id_aluno = 2;
-- COMMIT;
--
-- SESSÃO B:
-- START TRANSACTION;
-- UPDATE lab_aluno SET cidade = 'Teste B1' WHERE id_aluno = 1;
-- UPDATE lab_aluno SET cidade = 'Teste B2' WHERE id_aluno = 2;
-- COMMIT;
--
-- A ordem consistente reduz a chance de ciclo de espera.


-- ============================================================
-- PARTE 16 - DIAGNÓSTICO (QUESTÃO 17)
-- ============================================================

-- Bloqueio e concorrência: investigar transações que aguardam.
-- Isolamento e MVCC: observar as versões visíveis dos dados.
-- Deadlock: identificar o ciclo de espera entre transações.
-- Atomicidade: verificar se COMMIT ou ROLLBACK foi aplicado.


-- ============================================================
-- PARTE 17 - DESAFIO: CONTROLE DE VAGAS (QUESTÃO 18)
-- ============================================================

-- Exemplo ilustrativo. Confira os nomes reais das colunas
-- da tabela turma e da tabela matricula antes de executar.

SELECT vagas_disponiveis
FROM turma
WHERE id_turma = 10;

START TRANSACTION;

UPDATE turma
SET vagas_disponiveis = vagas_disponiveis - 1
WHERE id_turma = 10
  AND vagas_disponiveis > 0;

-- Verifique o número de linhas afetadas imediatamente
-- após o UPDATE. Uma linha indica que a vaga foi reservada;
-- zero linhas indica que não havia vaga disponível.
SELECT ROW_COUNT() AS vagas_reservadas;

-- Se uma vaga foi reservada, inserir a matrícula nesta mesma
-- transação, usando os nomes reais das colunas:
-- INSERT INTO matricula (id_aluno, id_turma) VALUES (1, 10);
--
-- Se todas as operações derem certo: COMMIT;
-- Se ocorrer algum erro ou não houver vaga: ROLLBACK;
--
-- Não execute o INSERT de exemplo sem conferir a estrutura
-- real da tabela e sem validar o resultado do UPDATE.


-- ============================================================
-- PARTE 18 - TRANSAÇÕES LONGAS (QUESTÃO 19)
-- ============================================================

-- Exemplo de transação que deve ser evitada:
--
-- START TRANSACTION;
-- UPDATE lab_aluno SET cidade = 'Fortaleza' WHERE id_aluno = 1;
-- O usuário demora vários minutos preenchendo um formulário.
-- UPDATE lab_aluno SET cidade = 'Sobral' WHERE id_aluno = 2;
-- COMMIT;
--
-- Manter uma transação aberta por muito tempo pode causar
-- bloqueios prolongados, espera, consumo de recursos e retenção
-- de versões antigas dos registros no InnoDB.
-- O ideal é concluir a transação o mais rápido possível.


-- ============================================================
-- PARTE 19 - ANÁLISE INTEGRADA (QUESTÃO 20)
-- ============================================================

-- As transações agrupam operações relacionadas.
-- ACID ajuda a manter a confiabilidade dos dados.
-- O isolamento controla a visibilidade entre transações.
-- Bloqueios coordenam o acesso simultâneo aos registros.
-- MVCC permite leituras consistentes usando versões.
-- COMMIT confirma as alterações e ROLLBACK desfaz
-- operações ainda não confirmadas.
-- A detecção de deadlock identifica ciclos de espera.


-- ============================================================
-- CONFERÊNCIA FINAL
-- ============================================================

SELECT * FROM lab_aluno;
SELECT * FROM lab_mensalidade;

-- FIM DO ROTEIRO
