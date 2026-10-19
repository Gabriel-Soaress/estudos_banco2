# 🛡️ MAPA DE BOLSO: ARSENAL DE PROVA (`ARSENAL_PROVA_TRE.sql`)

> **Como usar amanhã:**
> 1. Antes da prova começar (ou assim que abrir o SQL Developer), abra o arquivo **[`ARSENAL_PROVA_TRE.sql`](ARSENAL_PROVA_TRE.sql)** e aperte **`F5` (Run Script)**. Ele vai criar todas as **8 Views**, **8 Functions** e **22 Procedures** de uma vez só no seu banco!
> 2. Durante a prova, você pode:
>    - **Consultar as Views** (`SELECT * FROM VW_...`) para já ter os `JOIN`s, `SUM`, `AVG`, `MAX`, `MIN` e `COUNT` prontos sem precisar digitar tudo do zero!
>    - **Usar as Views dentro das suas Subqueries / Procedures / Functions** (ex: em vez de fazer 5 `INNER JOIN`s dentro de uma Procedure, você faz `SELECT ... FROM VW_TUDO_SERIE_TREINO_EXERCICIO`).
>    - **Copiar o `SELECT` de dentro da View** caso o professor peça a consulta SQL aberta na resposta da questão!

---

## 📊 PARTE 1: As 8 Views "Salva-Vidas" (JOINs + Somas, Médias, Max e Min)

| Nome da View | O que ela junta / resolve? | Colunas Prontas que ela te entrega | Quando usar na Prova? |
| :--- | :--- | :--- | :--- |
| **`VW_TUDO_SERIE_TREINO_EXERCICIO`** | **O "Joinzão" das 6 tabelas operacionais:** `USUARIO` $\rightarrow$ `TREINO` $\rightarrow$ `ITEM_TREINO` $\rightarrow$ `SERIE` $\rightarrow$ `EXERCICIO` $\rightarrow$ `GRUPOMUSCULAR` | `ID_USUARIO`, `COD_USUARIO`, `NOME_USUARIO`, `ID_TREINO`, `COD_TREINO`, `DATA_TREINO`, `DURACAO_MINUTO`, `ID_ITEM_TREINO`, `ORDEM_EXERCICIO`, `ID_EXERCICIO`, `COD_EXERCICIO`, `NOME_EXERCICIO`, `ID_GRP_MUSCULAR`, `COD_GRP_MUSCULAR`, `NOME_GRUPO_MUSCULAR`, `ID_SERIE`, `COD_SERIE`, `NUMERO_SERIE`, `REPETICOES`, `CARGA_SERIE`, **`VOLUME_SERIE`** (`CARGA * REPETICOES`) | Sempre que precisar cruzar **Usuário + Treino + Exercício + Série + Grupo Muscular** sem ter que digitar 5 `INNER JOIN`s! |
| **`VW_ESTATISTICAS_USUARIO`** | **Raio-X completo por Usuário** (usando Subqueries no `SELECT` para **zero** risco de Produto Cartesiano!) | `ID_USUARIO`, `COD_USUARIO`, `NOME_USUARIO`, `QTD_TREINOS`, `SOMA_MINUTOS_TREINO`, `MEDIA_MINUTOS_TREINO`, `QTD_SERIES_TOTAL`, `SOMA_VOLUME_TOTAL`, `MEDIA_CARGA_SERIES`, `MAX_CARGA_SERIE`, `MIN_CARGA_SERIE`, `QTD_METAS_TOTAL`, `QTD_METAS_ATIVAS`, `QTD_METAS_CONCLUIDAS`, `MAX_CARGA_META`, `MIN_CARGA_META`, `QTD_RECORDES_BATIDOS`, `MAX_CARGA_RECORD`, `MIN_CARGA_RECORD`, `MEDIA_CARGA_RECORD` | Quando o professor pedir **qualquer estatística por Aluno/Usuário** (quem tem mais treinos, maior volume, mais metas, maior recorde, média de carga, etc.). |
| **`VW_RESUMO_POR_TREINO`** | **Agregações por Sessão de Treino** (`GROUP BY` por Treino) | `ID_TREINO`, `COD_TREINO`, `DATA_TREINO`, `DURACAO_MINUTO`, `ID_USUARIO`, `COD_USUARIO`, `NOME_USUARIO`, `QTD_EXERCICIOS_NO_TREINO`, `QTD_SERIES_NO_TREINO`, `SOMA_REPETICOES`, `SOMA_VOLUME_TREINO`, `MEDIA_CARGA_TREINO`, `MAX_CARGA_TREINO`, `MIN_CARGA_TREINO` | Questões sobre **qual Treino teve mais séries, maior volume ou maior média de carga** (como no `ATV_GRUPO.sql`). |
| **`VW_RESUMO_POR_EXERCICIO`** | **Agregações por Exercício** (Séries, Volume, Recordes e Metas sem Produto Cartesiano) | `ID_EXERCICIO`, `COD_EXERCICIO`, `NOME_EXERCICIO`, `TIPO_EXERCICIO` (`GLOBAL` vs `PERSONALIZADO`), `NOME_GRUPO_MUSCULAR`, `QTD_SERIES_EXECUTADAS`, `SOMA_VOLUME_EXERCICIO`, `MEDIA_CARGA_SERIE`, `MAX_CARGA_SERIE`, `MIN_CARGA_SERIE`, `QTD_RECORDES`, `MAX_CARGA_RECORD`, `MIN_CARGA_RECORD`, `MEDIA_CARGA_RECORD`, `QTD_METAS` | Questões sobre **Exercício mais executado, exercício com maior recorde, média de carga por exercício** ou diferença entre Global e Personalizado. |
| **`VW_RESUMO_POR_GRUPO_MUSCULAR`** | **Agregações por Grupo Muscular** (`Peitoral`, `Costas`, `Pernas`, etc.) | `ID_GRP_MUSCULAR`, `COD_GRP_MUSCULAR`, `NOME_GRUPO_MUSCULAR`, `QTD_EXERCICIOS_CADASTRADOS`, `QTD_SERIES_GRUPO`, `SOMA_VOLUME_GRUPO`, `MEDIA_CARGA_GRUPO`, `MAX_RECORD_GRUPO`, `MIN_RECORD_GRUPO` | Questões sobre **qual Grupo Muscular é mais treinado, tem maior volume ou maior recorde**. |
| **`VW_META_VS_RECORDE`** | **Relacionamento Indireto Temporal (`TRE_META` $\leftrightarrow$ `TRE_RECORD`)** | `ID_META`, `COD_META`, `NOME_USUARIO`, `NOME_EXERCICIO`, `CARGA_ALVO`, `DATA_CRIACAO`, `DATA_ALVO`, `DATA_CONCLUSAO`, `STATUS_META`, **`MAIOR_RECORD_NO_PERIODO`** (`BETWEEN DATA_CRIACAO AND NVL(DATA_CONCLUSAO, SYSDATE)`), `MAIOR_RECORD_GERAL`, **`PERCENTUAL_CONCLUIDO`** (com `NULLIF`) | Quando o professor pedir para **comparar a Meta com o Recorde batido durante a vigência da meta** ou calcular quantos % da meta o aluno atingiu! |
| **`VW_RECORDE_COM_SERIE_DO_TREINO`** | **Relacionamento Indireto (`TRE_RECORD` $\leftrightarrow$ `TRE_SERIE`)** | `ID_RECORD`, `COD_RECORD`, `NOME_USUARIO`, `NOME_EXERCICIO`, `CARGA_RECORD`, `DATA_RECORD`, `ID_TREINO`, `COD_TREINO`, `ID_SERIE`, `COD_SERIE`, `REPETICOES_NO_RECORDE` | Quando precisar descobrir **em qual treino e com quantas repetições** o aluno bateu determinado recorde (`TRUNC(DATA_TREINO) = TRUNC(DATA_RECORD)` e `CARGA = CARGA_RECORD`). |
| **`VW_MAIOR_E_MENOR_POR_GRUPO`** | **Molde Clássico do Professor (Max e Min lado a lado na mesma linha)** | `NOME_GRUPO`, `MAIOR_CARGA`, `EXERCICIO_MAIOR_CARGA`, `ALUNO_MAIOR_CARGA`, `MENOR_CARGA`, `EXERCICIO_MENOR_CARGA`, `ALUNO_MENOR_CARGA` | Quando o professor pedir na mesma linha **o Maior e o Menor valor de cada categoria com os nomes dos respectivos donos** (3 subqueries no `FROM`). |

---

### 💡 Exemplos de Como as Views Facilitam sua Vida na Prova

Imagine que na prova caia:
> *"Descobriu-se necessária uma consulta que retorne o nome do usuário com o maior volume total de treino (`CARGA * REPETICOES`)..."*

Com a **`VW_ESTATISTICAS_USUARIO`** já criada no banco, olha o tamanho que fica a sua query:
```sql
SELECT NOME_USUARIO, SOMA_VOLUME_TOTAL
FROM VW_ESTATISTICAS_USUARIO
WHERE SOMA_VOLUME_TOTAL = (SELECT MAX(SOMA_VOLUME_TOTAL) FROM VW_ESTATISTICAS_USUARIO);
```
*(E se o professor exigir sem usar View na resposta final, basta abrir o `ARSENAL_PROVA_TRE.sql` e copiar o `SELECT` prontinho de dentro da View!)*

---

## ⚙️ PARTE 2: As 8 Functions Coringas (Sem Bloco Anônimo!)

Todas recebem o código textual (`P_COD_... VARCHAR2`) e devolvem um número (`RETURN NUMBER`). Você pode chamá-las **direto no `SELECT`**!

| Nome da Function | Parâmetro | O que ela retorna? | Como chamar direto no `SELECT` |
| :--- | :--- | :--- | :--- |
| **`COUNT_SERIES_TREINO`** *(do `ATV_GRUPO`)* | `P_COD_TREINO` | Total de séries de um treino | `SELECT COD_TREINO, COUNT_SERIES_TREINO(COD_TREINO) FROM TRE_TREINO;` |
| **`FN_QTD_SERIES_USUARIO`** | `P_COD_USUARIO` | Total de séries feitas pelo usuário | `SELECT NOME, FN_QTD_SERIES_USUARIO(COD_USUARIO) FROM TRE_USUARIO;` |
| **`FN_VOLUME_USUARIO`** | `P_COD_USUARIO` | Volume total (`SUM(CARGA * REPETICOES)`) do usuário | `SELECT NOME, FN_VOLUME_USUARIO(COD_USUARIO) FROM TRE_USUARIO;` |
| **`FN_MAX_RECORD_USUARIO`** | `P_COD_USUARIO` | Maior `CARGA_RECORD` do usuário | `SELECT NOME, FN_MAX_RECORD_USUARIO(COD_USUARIO) FROM TRE_USUARIO;` |
| **`FN_QTD_RECORDES_USUARIO`** | `P_COD_USUARIO` | Quantidade de recordes batidos pelo usuário | `SELECT NOME, FN_QTD_RECORDES_USUARIO(COD_USUARIO) FROM TRE_USUARIO;` |
| **`FN_QTD_METAS_CONCLUIDAS`** | `P_COD_USUARIO` | Quantidade de metas com `STATUS = 'CONCLUIDA'` | `SELECT NOME, FN_QTD_METAS_CONCLUIDAS(COD_USUARIO) FROM TRE_USUARIO;` |
| **`FN_QTD_SERIES_EXERCICIO`** | `P_COD_EXERCICIO` | Quantidade de séries executadas daquele exercício | `SELECT NOME, FN_QTD_SERIES_EXERCICIO(COD_EXERCICIO) FROM TRE_EXERCICIO;` |
| **`FN_MEDIA_CARGA_EXERCICIO`** | `P_COD_EXERCICIO` | Média de carga (`AVG(CARGA)`) daquele exercício | `SELECT NOME, FN_MEDIA_CARGA_EXERCICIO(COD_EXERCICIO) FROM TRE_EXERCICIO;` |
| **`FN_QTD_SERIES_GRUPO`** | `P_COD_GRP` | Quantidade total de séries de um Grupo Muscular | `SELECT NOME, FN_QTD_SERIES_GRUPO(COD_GRP_MUSCULAR) FROM TRE_GRUPOMUSCULAR;` |

---

## 🏆 PARTE 3: Os Trios de Procedures Estilo `ATV_GRUPO.sql` (V1 e V2)

No trabalho em grupo (`ATV_GRUPO.sql`), o professor pediu:
1. **Procedure V1:** Acha a maior quantidade usando Subquery no `FROM` + `GROUP BY`, desempata pelo menor ID (`MIN(ID_...)`) e imprime no `DBMS_OUTPUT`.
2. **Function:** Calcula a métrica para 1 código específico (`P_COD_...`).
3. **Procedure V2:** Faz a mesma coisa que a V1, mas chamando a **Function** dentro da Subquery do `FROM` (sem precisar de `JOIN` nem `GROUP BY`).

Para você não ser pego de surpresa se ele mudar de "Treino com mais Séries" para outra tabela, já deixamos os **5 Trios completos** prontos:

| Tema da Questão | Procedure V1 (Pura com `GROUP BY`) | Function Auxiliar | Procedure V2 (Usando a Function) | Como testar (1 linha!) |
| :--- | :--- | :--- | :--- | :--- |
| **1. Treino com mais Séries** *(Já no `ATV_GRUPO.sql`)* | `TREINO_MAX_SERIE` | `COUNT_SERIES_TREINO(COD_TREINO)` | `TREINO_MAX_SERIE2` | `EXEC TREINO_MAX_SERIE2;` |
| **2. Usuário com Maior Volume Total** | `PRC_USUARIO_MAX_VOLUME_V1` | `FN_VOLUME_USUARIO(COD_USUARIO)` | `PRC_USUARIO_MAX_VOLUME_V2` | `EXEC PRC_USUARIO_MAX_VOLUME_V2;` |
| **3. Exercício Mais Executado (em Séries)** | `PRC_EXERCICIO_MAX_SERIE_V1` | `FN_QTD_SERIES_EXERCICIO(COD_EXERCICIO)` | `PRC_EXERCICIO_MAX_SERIE_V2` | `EXEC PRC_EXERCICIO_MAX_SERIE_V2;` |
| **4. Grupo Muscular Mais Treinado** | `PRC_GRUPO_MAX_SERIE_V1` | `FN_QTD_SERIES_GRUPO(COD_GRP_MUSCULAR)` | `PRC_GRUPO_MAX_SERIE_V2` | `EXEC PRC_GRUPO_MAX_SERIE_V2;` |
| **5. Usuário com Mais Recordes** | `PRC_USUARIO_MAX_RECORDES_V1` | `FN_QTD_RECORDES_USUARIO(COD_USUARIO)` | `PRC_USUARIO_MAX_RECORDES_V2` | `EXEC PRC_USUARIO_MAX_RECORDES_V2;` |

---

## 🛠️ PARTE 4: Todos os CRUDs das 8 Tabelas (Por `COD_`)

Se o professor pedir Procedure de `INSERT`, `UPDATE` ou `DELETE` para qualquer uma das tabelas que faltavam no `ATV_GRUPO.sql` (recebendo os `COD_` das tabelas mães e buscando os `ID_` com `SELECT ... INTO`), já estão todas prontas na Parte 4 do [`ARSENAL_PROVA_TRE.sql`](ARSENAL_PROVA_TRE.sql):

* **Usuário, Grupo Muscular e Exercício:** Já estão no [`ATV_GRUPO.sql`](ATV_GRUPO.sql).
* **Meta:** `TRE_ADD_META`, `TRE_UPD_META`, `TRE_DEL_META`
* **Recorde:** `TRE_ADD_RECORD`, `TRE_UPD_RECORD`, `TRE_DEL_RECORD`
* **Treino:** `TRE_ADD_TREINO`, `TRE_UPD_TREINO`, `TRE_DEL_TREINO`
* **Item de Treino:** `TRE_ADD_ITEM_TREINO`
* **Série:** `TRE_ADD_SERIE`, `TRE_UPD_SERIE`, `TRE_DEL_SERIE`
