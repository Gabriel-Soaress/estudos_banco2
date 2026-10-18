# 🏆 2º SIMULADO PRÁTICO (EDIÇÃO DE DOMINGO) — BANCO `TRE_`

> **Instruções de Prova:**
> - Todas as 5 questões abaixo foram projetadas e validadas para o seu banco oficial **`TRE_`** (`TRE_SCRIPT_DDL.sql` e `TRE_SCRIPT_DML_CORRETO.sql`).
> - **Restrições Obrigatórias da Disciplina:**
>   - ❌ **Proibido** usar `WITH` (CTEs) — utilize subqueries aninhadas quando necessário.
>   - ❌ **Proibido** usar `UNION` ou `UNION ALL`.
>   - ❌ **Proibido** usar blocos `EXCEPTION` em PL/SQL — trate validações com `IF / ELSIF / ELSE`, `NVL` e variáveis.
> - Ao finalizar no SQL Developer, cole todo o seu script aqui no chat para correção comentada!

---

## 📋 Questão 1 — Extremos Globais e Extremos por Categoria (2,0 pontos)

### Parte A — Usuário com a Maior Média Geral de Carga (1,0 ponto)
Identificou-se a necessidade de descobrir qual usuário possui a **maior média geral de carga** considerando todas as séries executadas no sistema (`TRE_SERIE`). Elabore uma consulta `SELECT` que exiba:
- O identificador do usuário (`ID_USUARIO`);
- O nome do usuário (`NOME`);
- A média geral de carga arredondada em 2 casas decimais (`MEDIA_GERAL_CARGA`);
- A maior carga individual já levantada por esse usuário em uma série (`MAIOR_CARGA_USUARIO`).

### Parte B — Maior e Menor Recorde por Grupo Muscular (1,0 ponto)
Identificou-se também a necessidade de gerar um relatório comparativo por grupo muscular (`TRE_GRUPOMUSCULAR`) com base na tabela de recordes (`TRE_RECORD`). Elabore uma consulta `SELECT` utilizando subqueries aninhadas no `FROM` que exiba, em uma mesma linha para cada grupo muscular:
- O nome do grupo muscular (`NOME_GRUPO`);
- O nome do exercício que detém o **maior recorde** daquele grupo (`EXERCICIO_MAIOR_REC`);
- O valor desse maior recorde (`MAIOR_RECORD`);
- O nome do exercício que detém o **menor recorde** daquele grupo (`EXERCICIO_MENOR_REC`);
- O valor desse menor recorde (`MENOR_RECORD`).

---

## 📋 Questão 2 — View de Raio-X dos Exercícios (2,0 pontos)

Descobriu-se necessária a criação de uma View chamada `VW_RAIO_X_EXERCICIOS` contendo **todos** os exercícios cadastrados na tabela `TRE_EXERCICIO` (inclusive aqueles que nunca foram executados em séries ou que não possuem recordes registrados).

A View deve exibir:
- O código do exercício (`COD_EXERCICIO`);
- O nome do exercício (`NOME_EXERCICIO`);
- O tipo de autoria do exercício (`TIPO_EXERCICIO`): exibindo `'PERSONALIZADO'` quando a coluna `ID_USUARIO` da tabela `TRE_EXERCICIO` estiver preenchida (`IS NOT NULL`), ou `'GLOBAL'` quando for nula (`IS NULL`);
- A quantidade total de séries já realizadas para esse exercício em `TRE_SERIE` (`TOTAL_SERIES`), exibindo `0` caso nunca tenha sido executado;
- O valor do maior recorde já registrado para esse exercício em `TRE_RECORD` (`MAIOR_RECORDE`), exibindo `0` caso não possua recordes;
- Uma coluna calculada chamada `NIVEL_CARGA` (construída diretamente no `SELECT` da View, sem criar Function auxiliar) que exiba:
  - `'PESADO'` quando o `MAIOR_RECORDE` for maior ou igual a `100`;
  - `'MODERADO'` quando o `MAIOR_RECORDE` for maior que `0` e menor que `100`;
  - `'SEM HISTORICO'` quando o `MAIOR_RECORDE` for igual a `0`.

**Requisitos:**
- A View não pode gerar multiplicação indevida de linhas (produto cartesiano) entre séries e recordes e não pode duplicar exercícios.
- Ao final, escreva `SELECT * FROM VW_RAIO_X_EXERCICIOS;` para exibir o resultado.

---

## 📋 Questão 3 — Atualização em Lote e Exclusão Segura com Subqueries (2,0 pontos)

### Parte A — Padronização de Observações de Treino via `UPDATE` (1,0 ponto)
Constatou-se a necessidade de padronizar a coluna `OBSERVACOES` de todos os registros da tabela `TRE_TREINO` de acordo com a quantidade de exercícios (`TRE_ITEM_TREINO`) realizados em cada sessão. Elabore um único comando `UPDATE` na tabela `TRE_TREINO` (utilizando `CASE WHEN` e subquery correlacionada) que preencha `OBSERVACOES` com:
- `'TREINO COMPLETO'` quando o treino possuir **3 ou mais** itens vinculados em `TRE_ITEM_TREINO`;
- `'TREINO RAPIDO'` quando o treino possuir **1 ou 2** itens vinculados em `TRE_ITEM_TREINO`;
- `'TREINO VAZIO'` quando o treino não possuir **nenhum** item vinculado (`0`).

### Parte B — Limpeza de Exercícios Nunca Utilizados via `DELETE` (1,0 ponto)
Constatou-se que alguns exercícios cadastrados na tabela `TRE_EXERCICIO` jamais foram utilizados no sistema. Elabore um único comando `DELETE` na tabela `TRE_EXERCICIO` utilizando `NOT IN` (com a devida proteção contra valores nulos) que apague apenas os exercícios que **não** estejam presentes em `TRE_ITEM_TREINO`, **não** estejam presentes em `TRE_META` e **não** estejam presentes em `TRE_RECORD`.

---

## 📋 Questão 4 — Procedure de Revisão de Série com Saneamento `IN OUT` (2,0 pontos)

Descobriu-se necessária a criação de uma Procedure chamada `PRC_REVISAR_CARGA_SERIE` para atualizar a carga e as repetições de uma série específica na tabela `TRE_SERIE` a partir do seu código textual (`COD_SERIE`).

**Especificações da Procedure:**
1. **Parâmetros:**
   - `P_COD_SERIE` (entrada — `IN`): código textual da série (ex: `'SER-001'`);
   - `P_NOVA_CARGA` (entrada e saída — `IN OUT`): novo valor de carga proposto;
   - `P_NOVAS_REPETICOES` (entrada e saída — `IN OUT`): nova quantidade de repetições proposta;
   - `P_RESULTADO` (saída — `OUT VARCHAR2`): mensagem de status da gravação.
2. **Regras de Negócio:**
   - **Saneamento:** Caso `P_NOVA_CARGA` seja menor que `5`, a Procedure deve corrigir o valor do próprio parâmetro para `5`. Caso `P_NOVAS_REPETICOES` seja menor que `1`, deve corrigir o valor do parâmetro para `1`.
   - **Atualização:** Executar um `UPDATE` na tabela `TRE_SERIE` alterando `CARGA` e `REPETICOES` para os valores já saneados onde `COD_SERIE = P_COD_SERIE`.
   - **Retorno de Status:** Verificar com `SQL%ROWCOUNT` se o `UPDATE` alterou alguma linha. Se alterou (`>= 1`), preencher `P_RESULTADO` com `'SERIE ATUALIZADA COM SUCESSO'`; caso contrário (`0`), preencher com `'ERRO: SERIE NAO ENCONTRADA'`.
3. **Teste:**
   - Escreva um bloco anônimo (`DECLARE ... BEGIN ... END;`) que teste a Procedure passando `'SER-001'`, uma carga `0` (para testar o saneamento) e repetições `10`, imprimindo ao final o `P_RESULTADO` e o valor corrigido da variável de carga no console.

---

## 📋 Questão 5 — Function com `%ROWTYPE` + Procedure do Exercício Mais Praticado (2,0 pontos)

### Parte A — Function `FNC_QTD_SERIES_EXERCICIO` (1,0 ponto)
Identificou-se a necessidade de criar uma Function chamada `FNC_QTD_SERIES_EXERCICIO` que receba como parâmetro o código textual de um exercício (`P_COD_EXERCICIO VARCHAR2`) e retorne (`RETURN NUMBER`) a quantidade total de séries (`TRE_SERIE`) já realizadas para aquele exercício em todo o banco.
- **Requisito obrigatório:** Dentro da Function, declare uma variável utilizando **`TRE_EXERCICIO%ROWTYPE`**, carregue a linha completa do exercício correspondente ao `P_COD_EXERCICIO` nessa variável e utilize o campo `ID_EXERCICIO` dessa variável para contar as séries vinculadas.
- Escreva também um `SELECT` na tabela `TRE_EXERCICIO` exibindo `COD_EXERCICIO`, `NOME` e o retorno da Function.

### Parte B — Procedure `PRC_EXERCICIO_MAIS_PRATICADO` (1,0 ponto)
Em seguida, descobriu-se necessária a criação de uma Procedure chamada `PRC_EXERCICIO_MAIS_PRATICADO` (sem parâmetros) capaz de identificar e exibir no console (`DBMS_OUTPUT.PUT_LINE`), utilizando **obrigatoriamente** a função `FNC_QTD_SERIES_EXERCICIO` criada na Parte A:
- A maior quantidade de séries realizadas em um único exercício no sistema;
- O `ID_EXERCICIO` vencedor (em caso de empate, o menor `ID_EXERCICIO`);
- O `NOME` desse exercício vencedor.
- Ao final, escreva o comando para executar a Procedure.


---
---

## 🏆 GABARITO OFICIAL COMENTADO (PARA CONSULTA E REVISÃO RÁPIDA)

> 💡 *Deixei o gabarito 100% resolvido e comentado aqui embaixo para que amanhã, nos intervalos do trabalho, você possa consultar qualquer questão na hora se bater alguma dúvida!*

```sql
-- ============================================================================
-- QUESTÃO 1 (PARTE A): Usuário com a Maior Média Geral de Carga
-- ============================================================================
SELECT
    U.ID_USUARIO,
    U.NOME,
    ROUND(AVG(S.CARGA), 2) AS MEDIA_GERAL_CARGA,
    MAX(S.CARGA) AS MAIOR_CARGA_USUARIO
FROM TRE_USUARIO U
INNER JOIN TRE_TREINO T ON T.ID_USUARIO = U.ID_USUARIO
INNER JOIN TRE_ITEM_TREINO IT ON IT.ID_TREINO = T.ID_TREINO
INNER JOIN TRE_SERIE S ON S.ID_ITEM_TREINO = IT.ID_ITEM_TREINO
GROUP BY U.ID_USUARIO, U.NOME
HAVING AVG(S.CARGA) = (
    -- Subquery no HAVING sem ID_USUARIO no SELECT para achar o teto máximo das médias:
    SELECT MAX(AVG(S2.CARGA))
    FROM TRE_TREINO T2
    INNER JOIN TRE_ITEM_TREINO IT2 ON IT2.ID_TREINO = T2.ID_TREINO
    INNER JOIN TRE_SERIE S2 ON S2.ID_ITEM_TREINO = IT2.ID_ITEM_TREINO
    GROUP BY T2.ID_USUARIO
);


-- ============================================================================
-- QUESTÃO 1 (PARTE B): Maior e Menor Recorde por Grupo Muscular (3 Post-its no FROM)
-- ============================================================================
SELECT
    RESUMO_GRP.NOME AS NOME_GRUPO,
    EX_MAIOR.NOME_EXERCICIO AS EXERCICIO_MAIOR_REC,
    RESUMO_GRP.MAIOR_RECORD,
    EX_MENOR.NOME_EXERCICIO AS EXERCICIO_MENOR_REC,
    RESUMO_GRP.MENOR_RECORD
FROM (
    -- 1. Post-it Central: Maior e menor recorde de cada grupo muscular
    SELECT
        GRP.ID_GRP_MUSCULAR,
        GRP.NOME,
        MAX(R.CARGA_RECORD) AS MAIOR_RECORD,
        MIN(R.CARGA_RECORD) AS MENOR_RECORD
    FROM TRE_GRUPOMUSCULAR GRP
    INNER JOIN TRE_EXERCICIO E ON E.ID_GRP_MUSCULAR = GRP.ID_GRP_MUSCULAR
    INNER JOIN TRE_RECORD R ON R.ID_EXERCICIO = E.ID_EXERCICIO
    GROUP BY GRP.ID_GRP_MUSCULAR, GRP.NOME
) RESUMO_GRP
-- 2. Post-it do Maior: Liga pela carga máxima E pelo ID do grupo muscular!
INNER JOIN (
    SELECT
        E.ID_GRP_MUSCULAR,
        E.NOME AS NOME_EXERCICIO,
        R.CARGA_RECORD
    FROM TRE_EXERCICIO E
    INNER JOIN TRE_RECORD R ON R.ID_EXERCICIO = E.ID_EXERCICIO
) EX_MAIOR 
    ON EX_MAIOR.CARGA_RECORD = RESUMO_GRP.MAIOR_RECORD
   AND EX_MAIOR.ID_GRP_MUSCULAR = RESUMO_GRP.ID_GRP_MUSCULAR
-- 3. Post-it do Menor: Liga pela carga mínima E pelo ID do grupo muscular!
INNER JOIN (
    SELECT
        E.ID_GRP_MUSCULAR,
        E.NOME AS NOME_EXERCICIO,
        R.CARGA_RECORD
    FROM TRE_EXERCICIO E
    INNER JOIN TRE_RECORD R ON R.ID_EXERCICIO = E.ID_EXERCICIO
) EX_MENOR 
    ON EX_MENOR.CARGA_RECORD = RESUMO_GRP.MENOR_RECORD
   AND EX_MENOR.ID_GRP_MUSCULAR = RESUMO_GRP.ID_GRP_MUSCULAR;


-- ============================================================================
-- QUESTÃO 2: View VW_RAIO_X_EXERCICIOS (CASE WHEN direto no SELECT + NVL no MAX)
-- ============================================================================
CREATE OR REPLACE VIEW VW_RAIO_X_EXERCICIOS AS
SELECT
    E.COD_EXERCICIO,
    E.NOME AS NOME_EXERCICIO,
    -- Coluna condicional 1: Verifica se ID_USUARIO está preenchido ou nulo
    CASE
        WHEN E.ID_USUARIO IS NOT NULL THEN 'PERSONALIZADO'
        ELSE 'GLOBAL'
    END AS TIPO_EXERCICIO,
    -- Subquery 1 no SELECT: Conta o total de séries do exercício (COUNT já devolve 0 sozinho)
    (
        SELECT COUNT(S.ID_SERIE)
        FROM TRE_ITEM_TREINO IT
        INNER JOIN TRE_SERIE S ON S.ID_ITEM_TREINO = IT.ID_ITEM_TREINO
        WHERE IT.ID_EXERCICIO = E.ID_EXERCICIO
    ) AS TOTAL_SERIES,
    -- Subquery 2 no SELECT: Maior recorde do exercício (com NVL obrigatório no MAX!)
    NVL((
        SELECT MAX(R.CARGA_RECORD)
        FROM TRE_RECORD R
        WHERE R.ID_EXERCICIO = E.ID_EXERCICIO
    ), 0) AS MAIOR_RECORDE,
    -- Coluna condicional 2: Classifica o nível da carga direto no SELECT
    CASE
        WHEN NVL((SELECT MAX(R.CARGA_RECORD) FROM TRE_RECORD R WHERE R.ID_EXERCICIO = E.ID_EXERCICIO), 0) >= 100 THEN 'PESADO'
        WHEN NVL((SELECT MAX(R.CARGA_RECORD) FROM TRE_RECORD R WHERE R.ID_EXERCICIO = E.ID_EXERCICIO), 0) > 0    THEN 'MODERADO'
        ELSE 'SEM HISTORICO'
    END AS NIVEL_CARGA
FROM TRE_EXERCICIO E;

SELECT * FROM VW_RAIO_X_EXERCICIOS;


-- ============================================================================
-- QUESTÃO 3 (PARTE A): UPDATE Multinível com CASE WHEN e Subquery
-- ============================================================================
-- Lembrete: Nunca colocar o apelido T. no lado esquerdo do SET!
UPDATE TRE_TREINO T
SET OBSERVACOES = CASE
    WHEN (SELECT COUNT(*) FROM TRE_ITEM_TREINO IT WHERE IT.ID_TREINO = T.ID_TREINO) >= 3 THEN 'TREINO COMPLETO'
    WHEN (SELECT COUNT(*) FROM TRE_ITEM_TREINO IT WHERE IT.ID_TREINO = T.ID_TREINO) >= 1 THEN 'TREINO RAPIDO'
    ELSE 'TREINO VAZIO'
END;


-- ============================================================================
-- QUESTÃO 3 (PARTE B): DELETE Seguro com NOT IN e Proteção IS NOT NULL
-- ============================================================================
DELETE FROM TRE_EXERCICIO
WHERE ID_EXERCICIO NOT IN (
    SELECT ID_EXERCICIO FROM TRE_ITEM_TREINO WHERE ID_EXERCICIO IS NOT NULL
)
AND ID_EXERCICIO NOT IN (
    SELECT ID_EXERCICIO FROM TRE_META WHERE ID_EXERCICIO IS NOT NULL
)
AND ID_EXERCICIO NOT IN (
    SELECT ID_EXERCICIO FROM TRE_RECORD WHERE ID_EXERCICIO IS NOT NULL
);


-- ============================================================================
-- QUESTÃO 4: Procedure PRC_REVISAR_CARGA_SERIE (IN, IN OUT, OUT + SQL%ROWCOUNT)
-- ============================================================================
CREATE OR REPLACE PROCEDURE PRC_REVISAR_CARGA_SERIE(
    P_COD_SERIE        IN     TRE_SERIE.COD_SERIE%TYPE,
    P_NOVA_CARGA       IN OUT TRE_SERIE.CARGA%TYPE,
    P_NOVAS_REPETICOES IN OUT TRE_SERIE.REPETICOES%TYPE,
    P_RESULTADO        OUT    VARCHAR2
) IS
BEGIN
    -- 1. Saneamento dos parâmetros IN OUT:
    IF P_NOVA_CARGA < 5 THEN
        P_NOVA_CARGA := 5;
    END IF;

    IF P_NOVAS_REPETICOES < 1 THEN
        P_NOVAS_REPETICOES := 1;
    END IF;

    -- 2. Atualização na tabela TRE_SERIE:
    UPDATE TRE_SERIE
    SET CARGA = P_NOVA_CARGA,
        REPETICOES = P_NOVAS_REPETICOES
    WHERE COD_SERIE = P_COD_SERIE;

    -- 3. Verificação com SQL%ROWCOUNT:
    IF SQL%ROWCOUNT >= 1 THEN
        P_RESULTADO := 'SERIE ATUALIZADA COM SUCESSO';
    ELSE
        P_RESULTADO := 'ERRO: SERIE NAO ENCONTRADA';
    END IF;
END;
/

-- Bloco Anônimo de Teste (Com variáveis obrigatórias para os parâmetros IN OUT e OUT):
SET SERVEROUTPUT ON;
DECLARE
    v_carga      NUMBER := 0;
    v_repeticoes NUMBER := 10;
    v_resultado  VARCHAR2(100);
BEGIN
    PRC_REVISAR_CARGA_SERIE('SER-001', v_carga, v_repeticoes, v_resultado);
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_resultado || ' | Carga ajustada para: ' || v_carga);
END;
/


-- ============================================================================
-- QUESTÃO 5 (PARTE A): Function FNC_QTD_SERIES_EXERCICIO com %ROWTYPE
-- ============================================================================
CREATE OR REPLACE FUNCTION FNC_QTD_SERIES_EXERCICIO(
    P_COD_EXERCICIO VARCHAR2
) RETURN NUMBER IS
    v_exercicio  TRE_EXERCICIO%ROWTYPE; -- Maleta completa de TRE_EXERCICIO
    v_qtd_series NUMBER;
BEGIN
    -- Carrega a linha inteira na variável %ROWTYPE usando SELECT *
    SELECT *
    INTO v_exercicio
    FROM TRE_EXERCICIO
    WHERE COD_EXERCICIO = P_COD_EXERCICIO;

    -- Conta as séries usando v_exercicio.ID_EXERCICIO
    SELECT COUNT(S.ID_SERIE)
    INTO v_qtd_series
    FROM TRE_SERIE S
    INNER JOIN TRE_ITEM_TREINO IT ON IT.ID_ITEM_TREINO = S.ID_ITEM_TREINO
    WHERE IT.ID_EXERCICIO = v_exercicio.ID_EXERCICIO;

    RETURN NVL(v_qtd_series, 0);
END;
/

-- Consulta consumindo a Function:
SELECT
    COD_EXERCICIO,
    NOME,
    FNC_QTD_SERIES_EXERCICIO(COD_EXERCICIO) AS TOTAL_SERIES
FROM TRE_EXERCICIO;


-- ============================================================================
-- QUESTÃO 5 (PARTE B): Procedure PRC_EXERCICIO_MAIS_PRATICADO
-- ============================================================================
CREATE OR REPLACE PROCEDURE PRC_EXERCICIO_MAIS_PRATICADO IS
    v_maior_qtd    NUMBER;
    v_id_exercicio TRE_EXERCICIO.ID_EXERCICIO%TYPE;
    v_nome_exerc   TRE_EXERCICIO.NOME%TYPE;
BEGIN
    -- 1. Descobre a maior quantidade de séries usando a Function na subquery do FROM:
    SELECT MAX(RES.QTD_SERIES)
    INTO v_maior_qtd
    FROM (
        SELECT FNC_QTD_SERIES_EXERCICIO(COD_EXERCICIO) AS QTD_SERIES
        FROM TRE_EXERCICIO
    ) RES;

    -- 2. Busca o ID e o NOME do exercício vencedor (desempatando pelo menor ID_EXERCICIO):
    SELECT
        E.ID_EXERCICIO,
        E.NOME
    INTO v_id_exercicio, v_nome_exerc
    FROM TRE_EXERCICIO E
    WHERE FNC_QTD_SERIES_EXERCICIO(E.COD_EXERCICIO) = v_maior_qtd
      AND E.ID_EXERCICIO = (
          SELECT MIN(E2.ID_EXERCICIO)
          FROM TRE_EXERCICIO E2
          WHERE FNC_QTD_SERIES_EXERCICIO(E2.COD_EXERCICIO) = v_maior_qtd
      );

    DBMS_OUTPUT.PUT_LINE(
        'ID Exercício: ' || v_id_exercicio ||
        ' | Nome: ' || v_nome_exerc ||
        ' | Maior Qtd de Séries: ' || v_maior_qtd
    );
END;
/

EXEC PRC_EXERCICIO_MAIS_PRATICADO;
```
