# ⚡ LISTA DE REVISÃO RÁPIDA: EXERCÍCIOS DIRETOS POR TÓPICO (ESTILO PROVA REAL)

> **Objetivo:** Exercícios rápidos, diretos e independentes (sem código mastigado e sem dicas que entregam a resposta) para você testar cada técnica isoladamente antes do Simulado Geral.  
> **Regras Absolutas da Prova:** ❌ Proibido `WITH` (CTEs) | ❌ Proibido `UNION` / `UNION ALL` | ❌ Proibido Bloco `EXCEPTION`.

---

## 📝 PARTE 1: ENUNCIADOS DOS EXERCÍCIOS DE REVISÃO RÁPIDA

### 🎯 EXERCÍCIO 1 (Subqueries no `SELECT` com `DUAL`)
Crie um `SELECT` que retorne, em uma única linha, duas colunas:
* `QTD_METAS_ATIVAS`: quantidade total de metas com status `'ATIVA'`.
* `QTD_RECORDES_100KG`: quantidade total de recordes com carga maior ou igual a `100`.

**Exigência:** Usar subqueries no `SELECT` consultando a tabela `DUAL`.

---

### 🎯 EXERCÍCIO 2 (Anti-Produto Cartesiano com Subquery no `SELECT`)
Crie um `SELECT` que retorne o `COD_USUARIO`, o `NOME` do usuário, a quantidade total de treinos realizados (`TOTAL_TREINOS`) e a quantidade total de metas cadastradas (`TOTAL_METAS`).

**Exigência:** Proibido usar `JOIN` e proibido usar `GROUP BY`. Resolva ambas as contagens usando subqueries correlacionadas no `SELECT`.

---

### 🎯 EXERCÍCIO 3 (Subquery Aninhada no `FROM` + `LEFT JOIN` + `NVL`)
Crie um `SELECT` que retorne o `NOME` de todos os exercícios cadastrados no banco e a coluna `MAIOR_CARGA_SERIE` (a maior carga já levantada em séries daquele exercício). Caso o exercício nunca tenha sido executado em nenhuma série, exiba `0`.

**Exigência:** Usar obrigatoriamente uma subquery aninhada no `FROM` (ou no `LEFT JOIN`) para agrupar a maior carga por exercício antes de juntar com a tabela de exercícios, tratando nulos com `NVL`.

---

### 🎯 EXERCÍCIO 4 (`GROUP BY`, `HAVING`, `ROUND` e `NULLIF`)
Crie um `SELECT` que retorne o `NOME` do grupo muscular, a quantidade total de séries realizadas naquele grupo (`TOTAL_SERIES`), a média de carga arredondada em 2 casas decimais (`MEDIA_CARGA`) e a média de repetições por série calculada pela divisão da soma de repetições pela quantidade de séries (`MEDIA_REPETICOES`).

**Exigências:**
* Usar `GROUP BY`.
* Proteger a divisão contra zero usando `NULLIF`.
* Filtrar no `HAVING` apenas os grupos musculares que possuam mais de 5 séries realizadas.

---

### 🎯 EXERCÍCIO 5 (Dono do Maior Valor com Subquery no `WHERE`)
Crie um `SELECT` que retorne o `NOME` do usuário, o `COD_TREINO` e a `DURACAO_MINUTO` apenas do(s) treino(s) que tiverem a **maior duração de todo o banco de dados**.

**Exigência:** Proibido usar `GROUP BY` e proibido usar `ORDER BY` / `ROWNUM`. Usar subquery aninhada no `WHERE`.

---

### 🎯 EXERCÍCIO 6 (Conexão Temporal Meta $\times$ Recorde e Rastreio de Série)
Resolva as duas consultas independentes abaixo:
* **6A (Vigência da Meta):** Crie um `SELECT` que retorne o `COD_META`, o `NOME` do usuário e a quantidade de recordes (`QTD_RECORDES`) batidos por aquele usuário, naquele mesmo exercício, dentro do período de vigência da meta (entre a criação da meta e a sua conclusão ou data atual).
* **6B (Origem do Recorde):** Crie um `SELECT` que retorne o `COD_RECORD`, a `CARGA_RECORD`, o `COD_TREINO` e o `NUMERO_SERIE` exato onde cada recorde foi batido.

---

### 🎯 EXERCÍCIO 7 (Criação e Consumo de `VIEW` Analítica)
1. Crie uma View chamada **`VW_ESTATISTICAS_USUARIOS`** que retorne `ID_USUARIO`, `COD_USUARIO`, `NOME`, a quantidade total de treinos (`QTD_TREINOS`) e a duração média dos treinos arredondada em 2 casas decimais (`MEDIA_DURACAO`), exibindo `0` na média caso o usuário não tenha treinos.
2. Em seguida, escreva um `SELECT` consultando apenas a `VW_ESTATISTICAS_USUARIOS` que retorne os usuários cuja `MEDIA_DURACAO` seja maior ou igual a `50`.

---

### 🎯 EXERCÍCIO 8 (`DELETE` Seguro com `NOT IN` e Proteção contra `NULL`)
Escreva um comando `DELETE` na tabela `TRE_TREINO` que apague todos os treinos que não possuem nenhum item de treino vinculado.

**Exigência:** Usar `NOT IN` com subquery aninhada e incluir obrigatoriamente a proteção contra valores nulos dentro da subquery.

---

### 🎯 EXERCÍCIO 9 (`PROCEDURE` com Tradução de `COD` $\rightarrow$ `ID` e Parâmetros `IN`, `OUT`, `IN OUT`)
Crie uma procedure chamada **`PRC_AVALIAR_CARGA_EXERCICIO`** que receba:
* `p_cod_usuario IN VARCHAR2` (ex: `'USR-001'`)
* `p_cod_exercicio IN VARCHAR2` (ex: `'EXC-001'`)
* `p_carga_teste IN OUT NUMBER`
* `p_resultado OUT VARCHAR2`

**Regras de Negócio:**
1. Se `p_carga_teste` for menor que `10`, ajuste seu valor para `10`.
2. Busque o `ID_USUARIO` e o `ID_EXERCICIO` correspondentes aos códigos recebidos.
3. Busque o maior recorde atual (`CARGA_RECORD`) daquele usuário naquele exercício (use `NVL` para considerar `0` caso não tenha recorde).
4. Se `p_carga_teste` for maior que o recorde atual, preencha `p_resultado` com `'NOVO RECORDE'`; caso contrário, preencha com `'CARGA NORMAL'`.
5. Escreva o **Bloco Anônimo (`DECLARE ... BEGIN ... END`)** para testar a procedure e imprimir os valores finais com `DBMS_OUTPUT.PUT_LINE`.

---

### 🎯 EXERCÍCIO 10 (`FUNCTION` com `%ROWTYPE` Consumida no `SELECT`)
Crie uma function chamada **`FNC_DIAS_PRAZO_META`** que receba `p_id_meta IN NUMBER` e retorne `NUMBER`.

**Regras de Negócio:**
1. Declare uma variável usando **`TRE_META%ROWTYPE`** e carregue a linha inteira da meta recebida.
2. Retorne a quantidade de dias entre a `DATA_CRIACAO` e a `DATA_ALVO` daquela meta (`v_meta.DATA_ALVO - v_meta.DATA_CRIACAO`).
3. Escreva um `SELECT` na tabela `TRE_META` exibindo `COD_META`, `STATUS` e a chamada da função como `DIAS_TOTAIS_PRAZO`.

---

### 🎯 EXERCÍCIO 11 (Padrão da Atividade em Grupo: Procedure Manual $\rightarrow$ Function $\rightarrow$ Procedure Refatorada)
1. **Passo A (`PRC_USUARIO_MAIS_TREINOS_V1`):** Crie uma procedure (sem parâmetros) que descubra qual é a maior quantidade de treinos realizados por um único usuário (usando subquery no `FROM` com `GROUP BY`), depois busque o `MIN(ID_USUARIO)` que atingiu essa quantidade máxima (para blindar contra empates) e imprima no `DBMS_OUTPUT` o `ID_USUARIO` e a quantidade máxima.
2. **Passo B (`FNC_CONTAR_TREINOS_USR`):** Crie uma function que receba `p_cod_usuario IN VARCHAR2`, busque o `ID_USUARIO` correspondente, conte e retorne (`RETURN NUMBER`) quantos treinos aquele usuário possui.
3. **Passo C (`PRC_USUARIO_MAIS_TREINOS_V2`):** Crie a versão 2 da procedure do Passo A substituindo os joins e `GROUP BY` internos pela chamada direta da function `FNC_CONTAR_TREINOS_USR(COD_USUARIO)` dentro da subquery do `FROM`.

---
---

## 🏆 PARTE 2: SUAS RESOLUÇÕES ENVIADAS (LISTA RÁPIDA + `ATV_GRUPO.sql`)

### 2.1 Resoluções que você enviou na Revisão Rápida:

```sql
-- ========================================================
-- EX 1: Subquery no SELECT (Contagem de Treinos por Usuário)
-- ========================================================
SELECT 
    U.NOME,
    (SELECT COUNT(*) FROM TRE_TREINO T WHERE T.ID_USUARIO = U.ID_USUARIO) AS TOTAL_TREINOS
FROM TRE_USUARIO U;


-- ========================================================
-- EX 2: Subquery no FROM (Maior Duração de Treino por Usuário)
-- ========================================================
-- Sua versão 1 (com Subquery no LEFT JOIN):
SELECT
    U.NOME,
    NVL(RESUMO.MAIOR_DURACAO,0)
FROM TRE_USUARIO U
LEFT JOIN(
    SELECT
        U.NOME,
        MAX(T.DURACAO_MINUTO) AS MAIOR_DURACAO
    FROM TRE_USUARIO U
    INNER JOIN TRE_TREINO T ON T.ID_USUARIO = U.ID_USUARIO
    GROUP BY U.NOME
)RESUMO ON U.NOME = RESUMO.NOME;

-- 💡 Ajuste Fino de Prova para a Versão 1 (Ligar sempre pelo ID_USUARIO e sem precisar de JOIN interno):
SELECT
    U.NOME,
    NVL(RESUMO.MAIOR_DURACAO, 0) AS MAIOR_DURACAO
FROM TRE_USUARIO U
LEFT JOIN (
    SELECT
        ID_USUARIO,
        MAX(DURACAO_MINUTO) AS MAIOR_DURACAO
    FROM TRE_TREINO
    GROUP BY ID_USUARIO
) RESUMO ON U.ID_USUARIO = RESUMO.ID_USUARIO;

-- Sua versão 2 (Com Subquery Escalar no SELECT):
SELECT 
    U.NOME,
    NVL((SELECT MAX(DURACAO_MINUTO) FROM TRE_TREINO T WHERE T.ID_USUARIO = U.ID_USUARIO), 0) AS MAIOR_DURACAO
FROM TRE_USUARIO U;


-- ========================================================
-- EX 3: GROUP BY + HAVING + ROUND (Média de Repetições > 10)
-- ========================================================
SELECT
    IT.ID_EXERCICIO,
    ROUND(AVG(S.REPETICOES),2) AS MEDIA_REP
FROM TRE_ITEM_TREINO IT
INNER JOIN TRE_SERIE S ON IT.ID_ITEM_TREINO = S.ID_ITEM_TREINO
GROUP BY IT.ID_EXERCICIO
HAVING ROUND(AVG(S.REPETICOES),2) > 10;


-- ========================================================
-- EX 4: Dono do Maior Valor com Subquery no WHERE
-- ========================================================
SELECT
    U.NOME,
    T.COD_TREINO,
    T.DURACAO_MINUTO
FROM TRE_USUARIO U
INNER JOIN TRE_TREINO T ON T.ID_USUARIO = U.ID_USUARIO
WHERE T.DURACAO_MINUTO = (SELECT MAX(DURACAO_MINUTO) FROM TRE_TREINO);


-- ========================================================
-- EX 5: VIEW de Resumo de Metas Ativas (Com Subquery no SELECT!)
-- ========================================================
-- ✅ Solução Nota 10 (Mais limpa e imune à armadilha do WHERE no LEFT JOIN):
CREATE OR REPLACE VIEW VW_RESUMO_METAS_USUARIOS AS
    SELECT
        U.COD_USUARIO,
        U.NOME,
        (SELECT COUNT(M.ID_META) 
         FROM TRE_META M 
         WHERE M.ID_USUARIO = U.ID_USUARIO 
           AND M.STATUS = 'ATIVA') AS QTD_META_ATIVA
    FROM TRE_USUARIO U;


-- ========================================================
-- EX 9: DELETE Seguro com NOT IN e Proteção IS NOT NULL
-- ========================================================
DELETE FROM TRE_EXERCICIO 
WHERE ID_EXERCICIO NOT IN (
    SELECT 
        IT.ID_EXERCICIO
    FROM TRE_ITEM_TREINO IT
    WHERE ID_EXERCICIO IS NOT NULL
);
```

---

### 2.2 Suas Resoluções da Atividade em Grupo (`ATV_GRUPO.sql`):

```sql
-- ========================================================
-- CRUD EM PL/SQL: TRE_USUARIO
-- ========================================================
create or replace procedure ADD_TRE_USUARIO(
    P_COD TRE_USUARIO.COD_USUARIO%TYPE,
    P_NOME TRE_USUARIO.NOME%TYPE,
    P_EMAIL TRE_USUARIO.EMAIL%TYPE,
    P_SENHA TRE_USUARIO.SENHA%TYPE
)IS
BEGIN
    INSERT INTO TRE_USUARIO
    (COD_USUARIO,NOME,EMAIL,SENHA)
    VALUES
    (P_COD,P_NOME,P_EMAIL,P_SENHA);

    DBMS_OUTPUT.PUT_LINE('Aluno '|| P_COD || ' inserido com sucesso');
END;
/

create or replace procedure UPDATE_TRE_USUARIO(
    -- IDENTIFICADOR:
    P_COD TRE_USUARIO.COD_USUARIO%TYPE,
    -- COLUNAS QUE ALTERAM:
    P_NEW_NOME TRE_USUARIO.NOME%TYPE,
    P_NEW_EMAIL TRE_USUARIO.EMAIL%TYPE,
    P_NEW_SENHA TRE_USUARIO.SENHA%TYPE
)IS
BEGIN
    UPDATE TRE_USUARIO
    SET NOME = P_NEW_NOME, EMAIL = P_NEW_EMAIL, SENHA = P_NEW_SENHA
    WHERE COD_USUARIO = P_COD;

    DBMS_OUTPUT.PUT_LINE('Aluno '|| P_COD || ' ATUALIZADO com sucesso');
END;
/

create or replace procedure DELETE_TRE_USUARIO(
    P_COD TRE_USUARIO.COD_USUARIO%TYPE
)IS
BEGIN
    DELETE FROM TRE_USUARIO
    WHERE COD_USUARIO = P_COD;

    DBMS_OUTPUT.PUT_LINE('Aluno '|| P_COD || ' DELETADO com sucesso');
END;
/

-- ========================================================
-- CRUD EM PL/SQL: TRE_GRUPOMUSCULAR
-- ========================================================
create or replace PROCEDURE TRE_ADD_GRPMUSCULAR(
    P_COD TRE_GRUPOMUSCULAR.COD_GRP_MUSCULAR%TYPE,
    P_NOME TRE_GRUPOMUSCULAR.NOME%TYPE
) IS
BEGIN
    INSERT INTO tre_grupomuscular
    (COD_GRP_MUSCULAR,NOME)
    VALUES(P_COD,P_NOME);
END;
/

create or replace PROCEDURE TRE_UPD_GRPMUSCULAR(
    P_COD TRE_GRUPOMUSCULAR.COD_GRP_MUSCULAR%TYPE,
    P__NOVO_NOME TRE_GRUPOMUSCULAR.NOME%TYPE
)IS
BEGIN
    UPDATE TRE_GRUPOMUSCULAR
    SET NOME = P__NOVO_NOME
    WHERE COD_GRP_MUSCULAR = P_COD;   
END;
/

create or replace PROCEDURE TRE_DEL_TRE_GRUPOMUSCULAR(
    P_COD TRE_GRUPOMUSCULAR.COD_GRP_MUSCULAR%TYPE
) IS
    V_ID INTEGER;
BEGIN
    SELECT ID_GRP_MUSCULAR
    INTO V_ID
    FROM TRE_GRUPOMUSCULAR
    WHERE COD_GRP_MUSCULAR = P_COD;

    DELETE FROM TRE_GRUPOMUSCULAR
    WHERE ID_GRP_MUSCULAR = V_ID;
END;
/

-- ========================================================
-- CRUD EM PL/SQL: TRE_EXERCICIO (Conversão COD -> ID e Global vs Pessoal)
-- ========================================================
create or replace PROCEDURE TRE_ADD_EXERCICIO(
    P_COD_USR TRE_USUARIO.COD_USUARIO%TYPE,
    P_COD_GRP TRE_GRUPOMUSCULAR.COD_GRP_MUSCULAR%TYPE,
    P_COD_EX  TRE_EXERCICIO.COD_EXERCICIO%TYPE,
    P_NOME    TRE_EXERCICIO.NOME%TYPE,
    P_DESC    TRE_EXERCICIO.DESCRICAO%TYPE
)IS
    V_ID_USER TRE_USUARIO.id_usuario%type := NULL;
    V_ID_GRP  TRE_GRUPOMUSCULAR.ID_GRP_MUSCULAR%TYPE;
BEGIN
    -- O COD PODE SER NULL, QUANDO O EXERCICIO É GLOBAL!
    IF P_COD_USR IS NOT NULL THEN 
        SELECT U.ID_USUARIO
        INTO V_ID_USER
        FROM TRE_USUARIO U
        WHERE U.COD_USUARIO = P_COD_USR;
    END IF;

    SELECT GRP.ID_GRP_MUSCULAR
    INTO V_ID_GRP 
    FROM TRE_GRUPOMUSCULAR GRP 
    WHERE GRP.COD_GRP_MUSCULAR = P_COD_GRP;

    INSERT INTO TRE_EXERCICIO
    (ID_USUARIO,ID_GRP_MUSCULAR,COD_EXERCICIO,NOME,DESCRICAO)
    VALUES 
    (V_ID_USER,V_ID_GRP,P_COD_EX,P_NOME,P_DESC);
END;
/

create or replace PROCEDURE TRE_UPD_EXERCICIO(
    P_COD_EX  TRE_EXERCICIO.COD_EXERCICIO%TYPE,
    P_COD_USR TRE_USUARIO.COD_USUARIO%TYPE,
    P_COD_GRP TRE_GRUPOMUSCULAR.COD_GRP_MUSCULAR%TYPE,
    P_NOME    TRE_EXERCICIO.NOME%TYPE,
    P_DESC    TRE_EXERCICIO.DESCRICAO%TYPE
)IS
    V_ID_USER TRE_USUARIO.id_usuario%type := NULL;
    V_ID_GRP  TRE_GRUPOMUSCULAR.ID_GRP_MUSCULAR%TYPE;
BEGIN
    IF P_COD_USR IS NOT NULL THEN 
        SELECT U.ID_USUARIO
        INTO V_ID_USER
        FROM TRE_USUARIO U
        WHERE U.COD_USUARIO = P_COD_USR;
    END IF;

    SELECT GRP.ID_GRP_MUSCULAR
    INTO V_ID_GRP 
    FROM TRE_GRUPOMUSCULAR GRP 
    WHERE GRP.COD_GRP_MUSCULAR = P_COD_GRP;

    UPDATE TRE_EXERCICIO
    SET ID_USUARIO = V_ID_USER, ID_GRP_MUSCULAR = V_ID_GRP, NOME = P_NOME, DESCRICAO = P_DESC
    WHERE COD_EXERCICIO = P_COD_EX;
END;
/

create or replace PROCEDURE TRE_DEL_EXERCICIO(
    P_COD_EX TRE_EXERCICIO.COD_EXERCICIO%TYPE
)IS
BEGIN
    DELETE FROM tre_exercicio
    WHERE COD_EXERCICIO = P_COD_EX;
END;
/

-- ========================================================
-- PADRÃO AVANÇADO: PROCEDURE V1 -> FUNCTION -> PROCEDURE V2
-- ========================================================

-- 1. PROCEDURE V1 (Com Subquery no FROM + GROUP BY + Desempate com MIN):
create or replace PROCEDURE TREINO_MAX_SERIE IS
    V_QTD_MAIOR INTEGER;
    V_ID_TREINO INTEGER;
BEGIN
    SELECT MAX(QTD_SERIE)
    INTO V_QTD_MAIOR
    FROM(
        SELECT 
            T.ID_TREINO,
            COUNT(S.ID_SERIE) AS QTD_SERIE 
        FROM TRE_TREINO T
        INNER JOIN TRE_ITEM_TREINO IT ON IT.ID_TREINO = T.ID_TREINO
        INNER JOIN TRE_SERIE S ON IT.ID_ITEM_TREINO = S.ID_ITEM_TREINO
        GROUP BY T.ID_TREINO
    );

    SELECT MIN(id_treino)
    INTO V_ID_TREINO
    FROM (
        SELECT 
            T.ID_TREINO,
            COUNT(S.ID_SERIE) AS QTD_SERIE
        FROM TRE_TREINO T
        INNER JOIN TRE_ITEM_TREINO IT ON IT.ID_TREINO = T.ID_TREINO
        INNER JOIN TRE_SERIE S ON IT.ID_ITEM_TREINO = S.ID_ITEM_TREINO
        GROUP BY T.ID_TREINO
    )
    WHERE QTD_SERIE = V_QTD_MAIOR;

    DBMS_OUTPUT.PUT_LINE(
        ' | ID do treino: ' || V_ID_TREINO ||
        ' Maior quantidade de séries: ' || V_QTD_MAIOR
    );
END;
/

-- 2. FUNCTION DE CONTAGEM DE SÉRIES POR CÓDIGO DE TREINO:
create or replace FUNCTION COUNT_SERIES_TREINO(P_COD_TREINO VARCHAR2) RETURN INTEGER IS
    V_ID_TREINO INTEGER;
    V_QTD_SERIE_ID INTEGER;
BEGIN
    SELECT ID_TREINO INTO V_ID_TREINO
    FROM TRE_TREINO
    WHERE COD_TREINO = P_COD_TREINO;

    SELECT COUNT(S.ID_SERIE)
    INTO V_QTD_SERIE_ID
    FROM TRE_SERIE S
    INNER JOIN TRE_ITEM_TREINO IT ON IT.ID_ITEM_TREINO = S.ID_ITEM_TREINO
    WHERE IT.ID_TREINO = V_ID_TREINO;

    RETURN V_QTD_SERIE_ID;
END;
/

-- 3. PROCEDURE V2 REUTILIZANDO A FUNCTION NA SUBQUERY DO FROM:
create or replace PROCEDURE TREINO_MAX_SERIE2 IS
    V_QTD_MAIOR INTEGER;
    V_ID_TREINO INTEGER;
BEGIN
    SELECT MAX(QTD_SERIE)
    INTO V_QTD_MAIOR
    FROM(
        SELECT
            COUNT_SERIES_TREINO(COD_TREINO) AS QTD_SERIE
        FROM TRE_TREINO
    );

    SELECT MIN(ID_TREINO)
    INTO V_ID_TREINO
    FROM(
        SELECT
            ID_TREINO,
            COUNT_SERIES_TREINO(COD_TREINO) AS QTD_SERIE
        FROM TRE_TREINO
    )
    WHERE QTD_SERIE = V_QTD_MAIOR;

    DBMS_OUTPUT.PUT_LINE(
        ' | ID do treino: ' || V_ID_TREINO ||
        ' Maior quantidade de séries: ' || V_QTD_MAIOR
    );
END;
/
```
