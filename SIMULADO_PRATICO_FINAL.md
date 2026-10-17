# 🏆 SIMULADO PRÁTICO FINAL — BANCO DE DADOS II (FASE 2)

> **Instruções de Prova:**
> - Resolva as 5 questões abaixo diretamente no seu **Oracle SQL Developer** conectado ao banco `TRE_`.
> - **Restrições Obrigatórias da Disciplina:**
>   - ❌ **Proibido** usar `WITH` (CTEs) — utilize subqueries aninhadas quando necessário.
>   - ❌ **Proibido** usar `UNION` ou `UNION ALL`.
>   - ❌ **Proibido** usar blocos `EXCEPTION` em PL/SQL — trate validações com `IF / ELSIF / ELSE`, `NVL` e variáveis.
> - Ao finalizar, cole todo o seu script SQL/PLSQL no chat para correção e nota final!

---

## 📋 Questão 1 — Relatório Gerencial de Usuários (2,0 pontos)

Identificou-se a necessidade de gerar um relatório gerencial contendo todos os usuários cadastrados no sistema (`TRE_USUARIO`), exibindo:
- O código do usuário (`COD_USUARIO`);
- O nome do usuário (`NOME`);
- A quantidade total de metas cadastradas por ele (`TOTAL_METAS`);
- A quantidade total de recordes batidos por ele (`TOTAL_RECORDES`);
- A maior carga já levantada por ele em uma série de treino (`MAIOR_CARGA_SERIE`, baseada na coluna `CARGA` da tabela `TRE_SERIE`).

**Requisitos:**
- A consulta não pode gerar multiplicação indevida de linhas (produto cartesiano) entre metas, recordes e séries.
- Usuários que não possuam metas, recordes ou séries registradas devem aparecer normalmente na listagem exibindo o valor `0` nas respectivas colunas numéricas.

---

## 📋 Questão 2 — View de Auditoria de Metas na Vigência (2,0 pontos)

Descobriu-se necessária a criação de uma View chamada `VW_AUDITORIA_METAS` capaz de auditar o desempenho de todas as metas cadastradas na tabela `TRE_META`. A View deve exibir:
- O código da meta (`COD_META`);
- O nome do usuário dono da meta (`NOME_USUARIO`);
- O nome do exercício vinculado à meta (`NOME_EXERCICIO`);
- A carga-alvo da meta (`CARGA_ALVO`);
- O maior recorde (`MAIOR_RECORD_VIGENCIA`, baseado em `CARGA_RECORD` de `TRE_RECORD`) registrado por esse mesmo usuário e para esse mesmo exercício **estritamente dentro do período de vigência da meta** (entre `DATA_CRIACAO` e `DATA_CONCLUSAO`, considerando a data atual do sistema `SYSDATE` caso `DATA_CONCLUSAO` seja nula, ou `0` caso não haja nenhum recorde no período);
- Uma coluna calculada chamada `SITUACAO_AUDITORIA` que exiba:
  - `'META SUPERADA NO PRAZO'` quando o maior recorde registrado na vigência for maior ou igual à `CARGA_ALVO`;
  - `'EM EVOLUCAO'` quando houver recorde registrado na vigência, porém inferior à `CARGA_ALVO`;
  - `'SEM RECORDE NA VIGENCIA'` quando não houver nenhum recorde registrado no período de vigência.

**Requisitos:**
- Após o comando `CREATE OR REPLACE VIEW VW_AUDITORIA_METAS AS ...`, escreva também um `SELECT * FROM VW_AUDITORIA_METAS;` para consultar o resultado.

---

## 📋 Questão 3 — Fechamento Automático de Metas Atingidas (2,0 pontos)

Constatou-se que algumas metas que ainda constam com o status `'ATIVA'` na tabela `TRE_META` já tiveram sua `CARGA_ALVO` alcançada ou superada pelos usuários na tabela de histórico de recordes (`TRE_RECORD`).

Elabore um único comando `UPDATE` na tabela `TRE_META` que:
- Altere a coluna `STATUS` para `'CONCLUIDA'`;
- Preencha a coluna `DATA_CONCLUSAO` com a data atual do sistema (`SYSDATE`);
- Aplique essa alteração **apenas** para as metas que estejam atualmente com `STATUS = 'ATIVA'` e cujo usuário já possua, para o mesmo exercício da meta, algum registro na tabela `TRE_RECORD` com `CARGA_RECORD` maior ou igual à `CARGA_ALVO` da meta.

---

## 📋 Questão 4 — Procedure de Cadastro de Meta por Código (2,0 pontos)

Descobriu-se necessária a criação de uma Procedure chamada `PRC_CADASTRAR_META_POR_CODIGO` para registrar uma nova meta na tabela `TRE_META` utilizando os códigos textuais das entidades (`COD_`), sem que a aplicação externa precise informar os IDs numéricos internos.

**Especificações da Procedure:**
1. **Parâmetros:**
   - `P_COD_USUARIO` (entrada): código textual do usuário (ex: `'USR-001'`);
   - `P_COD_EXERCICIO` (entrada): código textual do exercício (ex: `'EXC-001'`);
   - `P_COD_META` (entrada): código textual da nova meta que será gravada (ex: `'META-099'`);
   - `P_CARGA_ALVO` (entrada): valor numérico da carga-alvo;
   - `P_DATA_ALVO` (entrada): data limite planejada para a meta;
   - `P_MENSAGEM` (saída — `OUT VARCHAR2`): texto informativo do resultado da operação.
2. **Regras de Negócio:**
   - A Procedure deve validar se `P_CARGA_ALVO` é maior que zero. Caso seja menor ou igual a zero (`<= 0`), **não** deve realizar o `INSERT` e deve preencher `P_MENSAGEM` com `'ERRO: CARGA ALVO INVALIDA'`.
   - Caso a carga-alvo seja válida (`> 0`), a Procedure deve consultar e armazenar em variáveis internas o `ID_USUARIO` e o `ID_EXERCICIO` correspondentes aos códigos recebidos, realizar o `INSERT` na tabela `TRE_META` preenchendo `DATA_CRIACAO` com `SYSDATE`, `DATA_CONCLUSAO` com `NULL` e `STATUS` com `'ATIVA'`, e preencher `P_MENSAGEM` com `'META CADASTRADA COM SUCESSO'`.
3. **Teste:**
   - Escreva um bloco anônimo (`DECLARE ... BEGIN ... END;`) que chame a Procedure `PRC_CADASTRAR_META_POR_CODIGO` passando dados válidos para um usuário e exercício existentes no banco e imprima o conteúdo de `P_MENSAGEM` no console via `DBMS_OUTPUT.PUT_LINE`.

---

## 📋 Questão 5 — Cálculo de Volume de Treino e Descoberta do Maior Treino (2,0 pontos)

### Parte A — Function `FNC_VOLUME_TOTAL_TREINO` (1,0 ponto)
Identificou-se a necessidade de criar uma Function chamada `FNC_VOLUME_TOTAL_TREINO` que receba como parâmetro o código textual de um treino (`P_COD_TREINO VARCHAR2`) e retorne o volume total de carga movimentado naquela sessão de treino.
- O volume total de um treino é dado pela soma da multiplicação de repetições por carga (`SUM(REPETICOES * CARGA)`) de todas as séries (`TRE_SERIE`) pertencentes aos itens daquele treino (`TRE_ITEM_TREINO`).
- Caso o treino não possua séries registradas, a função deve retornar `0`.
- Escreva também uma consulta `SELECT` na tabela `TRE_TREINO` que utilize a função `FNC_VOLUME_TOTAL_TREINO` para exibir `COD_TREINO`, `DATA_TREINO` e o volume total de cada treino.

### Parte B — Procedure `PRC_TREINO_MAIOR_VOLUME` (1,0 ponto)
Em seguida, descobriu-se necessária a criação de uma Procedure chamada `PRC_TREINO_MAIOR_VOLUME` (sem parâmetros) capaz de identificar e exibir no console (`DBMS_OUTPUT.PUT_LINE`), utilizando **obrigatoriamente** a função `FNC_VOLUME_TOTAL_TREINO` criada na Parte A:
- O valor do maior volume total registrado entre todos os treinos do sistema;
- O `ID_TREINO` correspondente a esse maior volume (em caso de empate entre dois ou mais treinos, deve capturar o menor `ID_TREINO`);
- O `COD_TREINO` desse treino vencedor.
- Ao final, escreva o comando para executar a Procedure.


---
---

## 🏆 PARTE 2: SUAS RESOLUÇÕES ENVIADAS E CORREÇÃO DETALHADA (NOTA: 9,1 / 10,0)

### 💻 Seu Script Enviado:

```sql
-- ========================================================
-- EX 1: Relatório Gerencial de Usuários
-- ========================================================
SELECT
    U.COD_USUARIO,
    U.NOME AS N_USUARIO,
    NVL((SELECT COUNT(M.ID_META) FROM TRE_META M WHERE M.ID_USUARIO = U.ID_USUARIO),0) AS QTD_META,
    NVL((SELECT COUNT(R.ID_RECORD) FROM TRE_RECORD R WHERE R.ID_USUARIO = U.ID_USUARIO),0) AS QTD_RECORD,
    MAX_CARGA_RES.MAIOR_CARGA_RECORD
FROM TRE_USUARIO U
LEFT JOIN(
    SELECT
        U.ID_USUARIO,
        MAX(S.CARGA) AS MAIOR_CARGA_RECORD
    FROM TRE_USUARIO U
    LEFT JOIN TRE_TREINO T ON T.ID_USUARIO = U.ID_USUARIO
    LEFT JOIN TRE_ITEM_TREINO IT ON T.ID_TREINO = IT.ID_TREINO
    LEFT JOIN TRE_SERIE S ON S.ID_ITEM_TREINO = IT.ID_ITEM_TREINO
    GROUP BY U.ID_USUARIO
)MAX_CARGA_RES ON U.ID_USUARIO = MAX_CARGA_RES.ID_USUARIO;


-- ========================================================
-- EX 2: View de Auditoria de Metas na Vigência
-- ========================================================
CREATE OR REPLACE FUNCTION VW_AUDITORIA_METAS_STATUS(
    P_META_ALVO TRE_META.CARGA_ALVO%TYPE,
    P_RECORD_MAX  TRE_RECORD.CARGA_RECORD%TYPE
)RETURN VARCHAR2 IS
    V_STATUS_MES VARCHAR2(100);
BEGIN
   CASE 
        WHEN P_RECORD_MAX >= P_META_ALVO THEN V_STATUS_MES:= 'META SUPERADA NO PRAZO';
        WHEN P_RECORD_MAX < P_META_ALVO THEN V_STATUS_MES:= 'EM EVOLUÇÃO';
        ELSE V_STATUS_MES:= 'SEM RECORD';
    END CASE;
    
    RETURN  V_STATUS_MES;
END;
/

CREATE OR REPLACE VIEW VW_AUDITORIA_METAS AS
    SELECT
        M.COD_META,
        U.NOME AS USUARIO,
        E.NOME AS EXERCICIO,
        M.CARGA_ALVO,
        RES_MAX.MAIOR_RECORD AS RECORD_ATUAL,
        VW_AUDITORIA_METAS_STATUS(M.CARGA_ALVO,RES_MAX.MAIOR_RECORD) AS SITUACAO_AUDITORIA
    FROM TRE_META M
    INNER JOIN TRE_USUARIO U ON M.ID_USUARIO = U.ID_USUARIO
    INNER JOIN TRE_EXERCICIO E ON M.ID_EXERCICIO = E.ID_EXERCICIO
    LEFT JOIN(
        SELECT 
            R.ID_USUARIO,
            R.ID_EXERCICIO,
            R.DATA_RECORD,
            MAX(R.CARGA_RECORD)AS MAIOR_RECORD
        FROM TRE_RECORD R
        GROUP BY ID_USUARIO,ID_EXERCICIO,R.DATA_RECORD
    )RES_MAX ON RES_MAX.ID_USUARIO = M.ID_USUARIO 
                AND RES_MAX.ID_EXERCICIO = M.ID_EXERCICIO 
                AND RES_MAX.DATA_RECORD BETWEEN M.DATA_CRIACAO AND NVL(DATA_CONCLUSAO,SYSDATE);
                        
SELECT * FROM VW_AUDITORIA_METAS;


-- ========================================================
-- EX 3: UPDATE Automático de Metas Atingidas
-- ========================================================
UPDATE TRE_META M
SET STATUS = 'CONCLUIDA',
    DATA_CONCLUSAO = (TRUNC(SYSDATE))
WHERE STATUS = 'ATIVA' AND M.CARGA_ALVO <= 
    (SELECT
        MAX(R.CARGA_RECORD)
    FROM TRE_RECORD R
    WHERE R.ID_USUARIO = M.ID_USUARIO AND M.ID_EXERCICIO = R.ID_EXERCICIO
    );
    
    
-- ========================================================
-- EX 4: Procedure de Cadastro de Meta por Código
-- ========================================================
CREATE OR REPLACE PROCEDURE PRC_CADASTRAR_META_POR_CODIGO(
    P_COD_USUARIO TRE_USUARIO.COD_USUARIO%TYPE,
    P_COD_EXERCICIO TRE_EXERCICIO.COD_EXERCICIO%TYPE,
    P_COD_META TRE_META.COD_META%TYPE,
    P_CARGA_ALVO TRE_META.CARGA_ALVO%TYPE,
    P_DATA_ALVO TRE_META.DATA_ALVO%TYPE,
    P_MENSAGEM OUT VARCHAR2
)IS 
    V_ID_USUARIO TRE_USUARIO.ID_USUARIO%TYPE;
    V_ID_EXERCICIO TRE_EXERCICIO.ID_EXERCICIO%TYPE;
BEGIN
    IF P_CARGA_ALVO <= 0 THEN
       P_MENSAGEM:= 'ERRO CARGA ALVO INVALIDA';
    ELSE  
        SELECT
            U.ID_USUARIO,
            E.ID_EXERCICIO
        INTO V_ID_USUARIO,V_ID_EXERCICIO
        FROM TRE_USUARIO U
        INNER JOIN TRE_EXERCICIO E ON E.COD_EXERCICIO = P_COD_EXERCICIO
        WHERE U.COD_USUARIO = P_COD_USUARIO;
        
        INSERT INTO TRE_META
        (ID_USUARIO,ID_EXERCICIO,COD_META,CARGA_ALVO,DATA_CRIACAO,DATA_ALVO,DATA_CONCLUSAO,STATUS)
        VALUES
        (V_ID_USUARIO,V_ID_EXERCICIO,P_COD_META,P_CARGA_ALVO,TRUNC(SYSDATE),P_DATA_ALVO,NULL,'ATIVA');

        P_MENSAGEM:= 'META: CADASTRADA!';

    END IF;
END;
/

SET SERVEROUTPUT ON;
DECLARE
    v_menssagem varchar2(200);
BEGIN
    PRC_CADASTRAR_META_POR_CODIGO('USR-001','EXC-001','META-013',122,DATE '2026-12-25',v_menssagem);
    DBMS_OUTPUT.PUT_LINE(v_menssagem);
END;
/
    
    
-- ========================================================
-- EX 5: Function de Volume Total + Procedure do Maior Treino
-- ========================================================
CREATE OR REPLACE FUNCTION FNC_VOLUME_TOTAL_TREINO(
    P_COD_TREINO TRE_TREINO.COD_TREINO%TYPE
)RETURN NUMBER IS
    V_ID_TREINO NUMBER;
    V_VOLUME_TOTAL NUMBER;
BEGIN
    SELECT ID_TREINO 
    INTO V_ID_TREINO
    FROM TRE_TREINO 
    WHERE COD_TREINO = P_COD_TREINO;
    
    SELECT
        NVL(SUM(S.REPETICOES * S.CARGA), 0) AS VOLUME
    INTO V_VOLUME_TOTAL
    FROM TRE_SERIE S
    WHERE S.ID_ITEM_TREINO IN (
        SELECT
            IT.ID_ITEM_TREINO
        FROM TRE_ITEM_TREINO IT
        WHERE IT.ID_TREINO = V_ID_TREINO);
        
   RETURN V_VOLUME_TOTAL;
END;
/
    
SELECT 
    T.COD_TREINO,
    T.DATA_TREINO,
    FNC_VOLUME_TOTAL_TREINO(T.COD_TREINO) AS VOLUME_TREINO
FROM TRE_TREINO T;

CREATE OR REPLACE PROCEDURE PRC_TREINO_MAIOR_VOLUME 
IS
    V_MAIOR_V NUMBER;
    V_ID_TREINO NUMBER;
    V_COD_TREINO VARCHAR2(20);
    V_DATA_TREINO TRE_TREINO.DATA_TREINO%TYPE;
BEGIN 
    SELECT
        MAX(RES.MAIOR_TREINO)
    INTO V_MAIOR_V
    FROM(
        SELECT 
            FNC_VOLUME_TOTAL_TREINO(T.COD_TREINO) AS MAIOR_TREINO
        FROM TRE_TREINO T
    )RES;
    
    SELECT
        T.ID_TREINO,
        T.COD_TREINO,
        T.DATA_TREINO
    INTO V_ID_TREINO,V_COD_TREINO,V_DATA_TREINO
    FROM TRE_TREINO T
    WHERE FNC_VOLUME_TOTAL_TREINO(T.COD_TREINO) = V_MAIOR_V
          AND T.ID_TREINO = (SELECT
                                MIN(T2.ID_TREINO)
                            FROM TRE_TREINO T2
                            WHERE FNC_VOLUME_TOTAL_TREINO(T2.COD_TREINO) = V_MAIOR_V);
                            
    DBMS_OUTPUT.PUT_LINE('ID TREINO: '|| V_ID_TREINO || ' COD TREINO: ' || V_COD_TREINO || ' DATA TREINO: ' || V_DATA_TREINO || ' VOLUME: ' || V_MAIOR_V);
END;
/
    
EXEC PRC_TREINO_MAIOR_VOLUME;
```

---

## 🛠️ GABARITO DE REFERÊNCIA PARA OS AJUSTES FINOS (QUESTÕES 1 E 2)

### 1. Ajuste Fino na Questão 1 (Colocar `NVL` no `MAX(S.CARGA)`):
O `COUNT` devolve `0` nativamente quando não acha linhas, mas o `MAX()` devolve `NULL`! Por isso, o `NVL` é indispensável em volta da coluna `MAX_CARGA_RES.MAIOR_CARGA_RECORD`:

```sql
SELECT
    U.COD_USUARIO,
    U.NOME,
    (SELECT COUNT(M.ID_META) FROM TRE_META M WHERE M.ID_USUARIO = U.ID_USUARIO) AS TOTAL_METAS,
    (SELECT COUNT(R.ID_RECORD) FROM TRE_RECORD R WHERE R.ID_USUARIO = U.ID_USUARIO) AS TOTAL_RECORDES,
    NVL(MAX_CARGA_RES.MAIOR_CARGA_RECORD, 0) AS MAIOR_CARGA_SERIE
FROM TRE_USUARIO U
LEFT JOIN (
    SELECT
        T.ID_USUARIO,
        MAX(S.CARGA) AS MAIOR_CARGA_RECORD
    FROM TRE_TREINO T
    INNER JOIN TRE_ITEM_TREINO IT ON T.ID_TREINO = IT.ID_TREINO
    INNER JOIN TRE_SERIE S ON S.ID_ITEM_TREINO = IT.ID_ITEM_TREINO
    GROUP BY T.ID_USUARIO
) MAX_CARGA_RES ON U.ID_USUARIO = MAX_CARGA_RES.ID_USUARIO;
```

### 2. Ajuste Fino na Questão 2 (Como usar `CASE WHEN` direto no `SELECT` e evitar duplicar metas no `GROUP BY`):
1. **Sem precisar de Function auxiliar:** No SQL puro (`SELECT` ou `VIEW`), você pode abrir um bloco **`CASE WHEN ... THEN ... ELSE ... END AS NOME_COLUNA`** direto como uma coluna da consulta!
2. **Cuidado com o `GROUP BY R.DATA_RECORD` na subquery:** Como uma mesma meta (`META-001`) teve 3 recordes em datas diferentes dentro da vigência, agrupar por `R.DATA_RECORD` faz a subquery devolver 3 linhas para a mesma meta, triplicando a `META-001` na View! Fazendo o `LEFT JOIN` direto e agrupando pelas colunas da meta lá fora (ou usando subquery no `SELECT`), cada meta aparece exatamente 1 vez:

```sql
-- JEITO 1: Usando LEFT JOIN + GROUP BY na Meta + CASE WHEN direto no SELECT (Sem precisar de Function!)
CREATE OR REPLACE VIEW VW_AUDITORIA_METAS AS
SELECT
    M.COD_META,
    U.NOME AS NOME_USUARIO,
    E.NOME AS NOME_EXERCICIO,
    M.CARGA_ALVO,
    NVL(MAX(R.CARGA_RECORD), 0) AS MAIOR_RECORD_VIGENCIA,
    CASE
        WHEN NVL(MAX(R.CARGA_RECORD), 0) >= M.CARGA_ALVO THEN 'META SUPERADA NO PRAZO'
        WHEN NVL(MAX(R.CARGA_RECORD), 0) > 0            THEN 'EM EVOLUCAO'
        ELSE 'SEM RECORDE NA VIGENCIA'
    END AS SITUACAO_AUDITORIA
FROM TRE_META M
INNER JOIN TRE_USUARIO U ON U.ID_USUARIO = M.ID_USUARIO
INNER JOIN TRE_EXERCICIO E ON E.ID_EXERCICIO = M.ID_EXERCICIO
LEFT JOIN TRE_RECORD R
    ON R.ID_USUARIO = M.ID_USUARIO
   AND R.ID_EXERCICIO = M.ID_EXERCICIO
   AND R.DATA_RECORD BETWEEN M.DATA_CRIACAO AND NVL(M.DATA_CONCLUSAO, SYSDATE)
GROUP BY
    M.COD_META, U.NOME, E.NOME, M.CARGA_ALVO;
```
