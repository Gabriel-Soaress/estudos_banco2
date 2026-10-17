# ⚡ LISTA DE REVISÃO RÁPIDA: EXERCÍCIOS DIRETOS POR TÓPICO (ESTILO PROVA REAL)

> **Objetivo:** Exercícios rápidos, diretos e independentes (sem código mastigado e sem dicas que entregam a resposta) para você testar cada técnica isoladamente antes do Simulado Geral.  
> **Regras Absolutas da Prova:** ❌ Proibido `WITH` (CTEs) | ❌ Proibido `UNION` / `UNION ALL` | ❌ Proibido Bloco `EXCEPTION`.

---

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
